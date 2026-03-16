# Day 7 QA 피드백 — STT + 발음 평가 + AI 피드백

> 작성일: 2026-03-16
> 작성자: Chief Backend QA Manager
> 대상 파일: `supabase/functions/stt-transcribe/index.ts`, `supabase/functions/pronunciation-score/index.ts`, `supabase/functions/ai-feedback/index.ts`, `app/learn/[id].tsx`

---

## 핵심 요약

Day 7의 세 Edge Function 중 하나(ai-feedback)는 **DB 컬럼명 불일치로 배포 즉시 전면 오류**가 발생하는 blocking bug를 포함하고 있다.
나머지 두 함수는 작동하나, pronunciation-score는 **한국어·중국어 등 비 ASCII 언어에서 채점이 무너지는 구조적 결함**이 있고, ai-feedback UI는 프론트엔드에 아직 연결되지 않았다.

---

## 🔴 Critical — 반드시 지금 고쳐야 하는 것

### 1. ai-feedback: DB 컬럼명 불일치 — `date` vs `stat_date`

**파일:** `supabase/functions/ai-feedback/index.ts:41, 105, 106`
**참조 DB:** `supabase/migrations/005_payments_gamification.sql:66`

**현상:** 함수 호출 시 항상 실패. 통계 저장 안 됨.

**원인:**
```ts
// ai-feedback/index.ts — 현재 (잘못됨)
.eq('date', today)
// ...
{ user_id, date: today, ai_feedback_count: 1 }
// onConflict: 'user_id,date'
```

```sql
-- 005_payments_gamification.sql:66 — 실제 스키마
stat_date  DATE  NOT NULL,
UNIQUE(user_id, stat_date)  -- line 69
```

`date`라는 컬럼은 `user_daily_stats` 테이블에 존재하지 않는다.
- 조회 시: 빈 결과 → "해당 날짜 사용 기록 없음"으로 오판
- upsert 시: 잘못된 컬럼명으로 insert 실패 또는 잘못된 행 생성
- onConflict 키도 틀려서 중복 체크 자체가 작동 불가

**수정 방향:**
```ts
// 3곳 모두 date → stat_date 로 변경
.eq('stat_date', today)
{ user_id, stat_date: today, ai_feedback_count: 1 }
// onConflict: 'user_id,stat_date'
```

---

### 2. ai-feedback: GPT 응답 JSON 파싱 오류 미처리

**파일:** `supabase/functions/ai-feedback/index.ts:99`

**현상:** GPT가 JSON 형식을 벗어난 응답을 줄 경우 500 Internal Error (예외 메시지 노출)

**원인:**
```ts
const parsed = JSON.parse(openaiData.choices[0].message.content); // ← try-catch 없음
```

`response_format: { type: 'json_object' }`를 사용해도 GPT가 완벽한 JSON을 보장하지 않는다.
특히 토큰 제한에 걸리면 JSON이 잘린 상태로 반환될 수 있다.

**수정 방향:**
```ts
let parsed;
try {
  parsed = JSON.parse(openaiData.choices[0].message.content);
} catch {
  return new Response(JSON.stringify({ error: 'AI 응답 파싱 실패' }), {
    status: 502,
    headers: corsHeaders,
  });
}
```

---

## 🟠 High — 조만간 터질 것들

### 3. pronunciation-score: 비 ASCII 언어 채점 불가

**파일:** `supabase/functions/pronunciation-score/index.ts:14-19`

**현상:** 한국어·중국어·아랍어 등에서 점수가 0점이거나 100점으로 극단적 오류 발생

**원인:**
```ts
// 현재 토크나이저
const normalize = (t: string) =>
  t.toLowerCase().replace(/[^\w\s]/g, '').trim(); // \w = ASCII 영숫자만
```

JavaScript의 `\w`는 `[a-zA-Z0-9_]`만 매칭한다.
한국어 "안녕하세요"는 `replace(/[^\w\s]/g, '')` 이후 빈 문자열 `""`이 된다.
- 토큰이 모두 `""` → 빈 배열 → Levenshtein 비교 불가
- 실제 로드맵에는 7개 언어 지원이 명시되어 있음 (`susie/roadmap.md`)

**수정 방향:**
`\w` 대신 유니코드 속성 이스케이프 `\p{L}` 사용:
```ts
const normalize = (t: string) =>
  t.toLowerCase().replace(/[^\p{L}\s]/gu, '').trim();
```
`/u` 플래그와 `\p{L}` (모든 언어 문자)를 사용하면 한국어·일본어·아랍어 등이 모두 정상 처리된다.

---

### 4. pronunciation-score: upsert 실패 시 성공 응답 반환

**파일:** `supabase/functions/pronunciation-score/index.ts:116-118`

**현상:** RLS 정책 오류나 제약 위반으로 DB 저장이 실패해도 프론트엔드에는 `{ score, passed }` 성공 응답이 반환됨

**원인:**
```ts
await supabase.from('user_pronunciation_logs').upsert(logRow);
// 반환값을 확인하지 않음
return new Response(JSON.stringify({ score, passed, feedback_tokens }), ...);
```

**수정 방향:**
```ts
const { error: upsertError } = await supabase
  .from('user_pronunciation_logs')
  .upsert(logRow);

if (upsertError) {
  console.error('[pronunciation-score] upsert failed:', upsertError);
  // 점수는 반환하되, 저장 실패 여부를 로깅
}
```

---

### 5. ai-feedback: 프론트엔드 미연결

**파일:** `app/learn/[id].tsx` (ai-feedback 호출 코드 없음)

**현상:** ai-feedback Edge Function은 존재하지만 사용자가 요청할 방법이 없음

**로드맵 요건:** `susie/roadmap.md` — "사용자 명시적 요청 시에만 호출 (버튼)"

**수정 방향:**
학습 화면 내 "AI 피드백 받기" 버튼 추가 필요:
```ts
const handleRequestFeedback = async () => {
  const res = await fetch(`${SUPABASE_URL}/functions/v1/ai-feedback`, {
    method: 'POST',
    headers: { Authorization: `Bearer ${accessToken}`, 'Content-Type': 'application/json' },
    body: JSON.stringify({
      lesson_id: lessonId,
      original_script: scripts.map((s) => s.text).join('\n'),
      user_transcript: lastTranscript,
    }),
  });
  const data = await res.json();
  // feedback 표시 로직
};
```

---

### 6. ai-feedback: 일일 한도 초과 상태 코드 오류

**파일:** `supabase/functions/ai-feedback/index.ts:57`

**현상:** 5회 한도 초과 시 HTTP 402 반환 → 프론트엔드에서 rate limit 오류로 인식 불가

**원인:**
```ts
return new Response(JSON.stringify({ error: 'daily_limit_exceeded' }), {
  status: 402, // Payment Required — 의미가 맞지 않음
});
```

**수정 방향:**
```ts
status: 429, // Too Many Requests — 표준 rate limit 코드
```

---

## 🟡 Medium — 다음 스프린트 전에 해결

### 7. stt-transcribe: language 파라미터 미전달

**파일:** `app/learn/[id].tsx:323`

**현상:** Whisper API가 언어를 자동 감지하므로 비영어 발음 인식 정확도 저하 가능

**원인:**
```ts
// 현재
body: JSON.stringify({ recording_path: path })

// 개선
body: JSON.stringify({ recording_path: path, language: lesson.language_code })
```

Edge Function은 `language` 파라미터를 이미 받을 수 있도록 구현되어 있음 — 프론트엔드만 수정하면 됨.

---

### 8. pronunciation-score: 단음절 토큰 Levenshtein 허용치 과도

**파일:** `supabase/functions/pronunciation-score/index.ts:50`

**현상:** "a" ↔ "an", "if" ↔ "of" 등 의미가 다른 단어가 정답 처리됨

**원인:**
```ts
const isClose = distance <= 1; // 모든 토큰에 동일하게 적용
```

길이 2~3자 단어에서 편집 거리 1은 오류율이 너무 높다.

**수정 방향:**
```ts
const isClose = (distance === 0) || (token.length >= 4 && distance <= 1);
```

---

## 수정 우선순위 체크리스트

| 우선순위 | 항목 | 파일 | 상태 |
|---------|------|------|------|
| 🔴 1 | `date` → `stat_date` 3곳 수정 | `ai-feedback/index.ts:41,105,106` | ❌ |
| 🔴 2 | GPT JSON 파싱 try-catch 추가 | `ai-feedback/index.ts:99` | ❌ |
| 🟠 3 | 비 ASCII 토크나이저 `\p{L}` 적용 | `pronunciation-score/index.ts:14` | ❌ |
| 🟠 4 | upsert 반환값 에러 체크 | `pronunciation-score/index.ts:116` | ❌ |
| 🟠 5 | ai-feedback 프론트엔드 버튼 연결 | `app/learn/[id].tsx` | ❌ |
| 🟠 6 | 일일 한도 상태 코드 402 → 429 | `ai-feedback/index.ts:57` | ❌ |
| 🟡 7 | STT language 파라미터 전달 | `app/learn/[id].tsx:323` | ❌ |
| 🟡 8 | 단음절 Levenshtein 허용치 조정 | `pronunciation-score/index.ts:50` | ❌ |

---

## 로드맵 준수 현황

| 요건 | 상태 | 비고 |
|------|------|------|
| AI #1: stt-transcribe | ✅ 80% | language 파라미터 미전달 |
| AI #2: pronunciation-score | ✅ 70% | ASCII-only 채점, upsert 오류 미처리 |
| AI #2: Pass/Retry UI | ✅ 완료 | 60점 기준, 오답 토큰 표시 정상 |
| AI #3: ai-feedback (5회/일 제한) | 🔴 0% | DB 컬럼 버그 + 프론트 미연결 |

---

## 작업 순서 제안

**지금 바로 (20분):**
1번·2번 — ai-feedback 컬럼명 수정 + JSON 파싱 try-catch. 이 두 개만 해도 함수가 정상 작동하기 시작함.

**오늘 안에 (1시간):**
3번·6번 — 토크나이저 `\p{L}` 교체 + 상태 코드 수정. 한국어 채점이 즉시 살아남.

**내일:**
5번 — ai-feedback 프론트엔드 연결. 기능이 완성되어야 Day 7이 실질적으로 완료됨.

---

## 공통 패턴 메모

Day 6 피드백에서 지적한 **"catch 블록에 로그 없음"** 문제가 Day 7 코드에도 반복됨.
`ai-feedback`와 `pronunciation-score` 모두 catch 시 단순 반환만 있고 `console.error`가 없다.
새 Edge Function을 작성할 때마다 catch 블록에 `console.error('[함수명] error:', e)`를 기본으로 포함할 것.
