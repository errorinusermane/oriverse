# Day 7 QA 피드백 2 — 기능 검증 보고서

> 작성일: 2026-03-16
> 검증 대상: stt-transcribe, pronunciation-score, ai-feedback 세 Edge Function 및 프론트엔드 연결

---

## 전체 결론

**세 가지 기능 모두 배포 가능한 상태입니다.**

`day7_feedback.md`에서 지적된 4개의 크리티컬 이슈(DB 컬럼 불일치, JSON 파싱 오류, 토크나이저 버그, 상태 코드 오류)는 **이미 코드에 반영되어 수정 완료** 상태입니다. 아래에 남은 미완 항목과 개선 사항을 정리합니다.

---

## 1. stt-transcribe Edge Function

**파일**: `supabase/functions/stt-transcribe/index.ts`
**상태**: ✅ 정상 동작

### 검증 항목

| 항목 | 결과 | 비고 |
|------|------|------|
| `recording_path` 필수 검증 | ✅ | 없으면 400 반환 |
| Storage 파일 다운로드 실패 처리 | ✅ | 404 반환 |
| Whisper API 오류 처리 | ✅ | 502 반환 |
| `language` 파라미터 전달 | ✅ | 프론트에서 `lessonLanguageCode` 넘김 (`[id].tsx:374`) |
| 빈 transcript 처리 | ✅ | 프론트(`[id].tsx:378`)에서 체크 후 advance |
| CORS 헤더 | ✅ | 일관 적용 |

### 남은 이슈

**[MEDIUM] STT 실패 시 사용자에게 알림 없음**
- 위치: `app/learn/[id].tsx:378-380`
- 현재: transcript가 없으면 조용히 다음 스크립트로 넘어감
- 영향: 사용자가 왜 넘어갔는지 알 수 없음
- 제안: 다음 스프린트에서 toast 알림 추가

---

## 2. pronunciation-score Edge Function

**파일**: `supabase/functions/pronunciation-score/index.ts`
**상태**: ✅ 정상 동작

### 검증 항목

| 항목 | 결과 | 비고 |
|------|------|------|
| 유니코드 토크나이저 (`\p{L}`) | ✅ | Korean/Chinese/Arabic 정상 처리 |
| Levenshtein 4글자 이상 조건 | ✅ | `token.length >= 4 && dist <= 1` |
| 60점 합격 기준 | ✅ | `PASS_THRESHOLD = 60` |
| `confidence_score` 변환 (÷100) | ✅ | DB NUMERIC(4,3) 타입에 맞게 변환 |
| `onConflict: 'user_id,script_id'` | ✅ | 스키마 unique 제약과 일치 |
| 스크립트 없을 때 404 반환 | ✅ | 정상 처리 |
| 전체 catch 블록 | ✅ | 500 반환 |

### 남은 이슈

**[MEDIUM] DB upsert 실패 시 응답은 성공으로 반환**
- 위치: `pronunciation-score/index.ts:119-125`
- 현재: upsert 실패해도 score/passed 값은 정상 반환, 에러만 로깅
- 영향: RLS 정책 오류 발생 시 점수가 저장 안 되는데 사용자는 모름
- 평가: MVP에서는 허용 가능한 수준

**[LOW] 특수문자 포함 스크립트에서 토큰 이탈**
- 예시: `"I'm happy"` → 토큰 `["i", "m", "happy"]` (apostrophe 제거)
- 사용자가 "I am happy" 발음 시 `"m"` 토큰이 불일치 처리됨
- 영향: 점수가 약간 낮게 계산될 수 있음 (오탐 수준)
- 평가: 현재 서비스 범위에서 허용 가능

---

## 3. ai-feedback Edge Function

**파일**: `supabase/functions/ai-feedback/index.ts`
**상태**: ✅ 정상 동작

### 검증 항목

| 항목 | 결과 | 비고 |
|------|------|------|
| `stat_date` 컬럼명 일치 | ✅ | SELECT/UPSERT 모두 올바른 컬럼 사용 |
| `onConflict: 'user_id,stat_date'` | ✅ | 스키마 unique 제약과 일치 |
| GPT 응답 JSON 파싱 try-catch | ✅ | 파싱 실패 시 502 반환 |
| Rate limit 상태 코드 | ✅ | 429 반환 (표준 Too Many Requests) |
| 일일 5회 제한 | ✅ | GPT 호출 전에 체크 |
| OpenAI API 오류 처리 | ✅ | 502 반환 |
| CORS 헤더 | ✅ | 일관 적용 |

### 프론트엔드 연결 검증 (`app/learn/[id].tsx`)

| 항목 | 결과 | 비고 |
|------|------|------|
| `handleRequestAiFeedback` 함수 | ✅ | `lines 401-420` |
| "AI 피드백 받기" 버튼 | ✅ | `lines 135-149` |
| `aiFeedbackLoading` 상태 처리 | ✅ | 버튼 disabled 처리 |
| 피드백 UI 렌더링 | ✅ | suggestions 배열 매핑 |
| advance 시 상태 초기화 | ✅ | `line 333, 531` |

### 남은 이슈

**[MEDIUM] upsert 실패 시 일일 제한 카운트 미증가**
- 위치: `ai-feedback/index.ts:118-120`
- 현재: upsert 실패 시 로깅만 하고 응답은 성공 반환
- 영향: RLS 오류 발생 시 `ai_feedback_count`가 올라가지 않아 5회 제한 우회 가능
- 평가: 비정상적인 케이스로 MVP에서는 허용 가능

---

## 4. 전체 호출 흐름 검증

```
녹음 완료
  ↓
handleStopRecording() [id].tsx:358
  ↓
Storage 업로드 → stt-transcribe 호출 [:373-375]
  ↓
setLastTranscript() [:383]
  ↓
pronunciation-score 호출 [:386-388]
  ↓
setScoringPhase('result') [:392]
  ↓
ScoreResultView 렌더링 (통과/재시도 분기)
  ↓
사용자가 "AI 피드백 받기" 클릭
  ↓
handleRequestAiFeedback() [:401-420]
  ↓
ai-feedback 호출
  ↓
setAiFeedback() → 피드백 UI 표시
```

**전체 흐름 이상 없음 ✅**

---

## 5. DB 스키마 정합성

| 테이블 | 컬럼 | 코드 사용 | 일치 여부 |
|--------|------|-----------|-----------|
| `user_daily_stats` | `stat_date` | `ai-feedback:40,114` | ✅ |
| `user_daily_stats` | `ai_feedback_count` | `ai-feedback:114` | ✅ |
| `user_daily_stats` | UNIQUE(`user_id,stat_date`) | `onConflict` 설정 | ✅ |
| `user_lesson_progress` | `confidence_score` NUMERIC(4,3) | `score/100` 변환 | ✅ |
| `user_lesson_progress` | UNIQUE(`user_id,script_id`) | `onConflict` 설정 | ✅ |

---

## 6. 보안 검토

**[MEDIUM] Edge Function에 JWT 인증 검증 없음**
- 세 함수 모두 서비스 롤 키를 사용하며 `user_id`는 프론트가 전달하는 값을 신뢰
- 악의적 사용자가 다른 사람의 `user_id`를 위조하면 타인 점수 덮어쓰기 가능
- MVP 범위에서는 허용하되, 정식 출시 전에 JWT 검증 추가 권장

---

## 7. 우선순위 정리

### 다음 스프린트에서 처리 권장

| 우선순위 | 항목 | 위치 |
|---------|------|------|
| P2 | STT/발음 채점 실패 시 사용자 알림 toast 추가 | `[id].tsx:378-396` |
| P2 | Edge Function JWT 인증 추가 | 세 함수 공통 |
| P2 | 일일 AI 피드백 한도 초과 시 UI 메시지 표시 | `[id].tsx:415` |

### 정식 출시 전 처리 권장

| 우선순위 | 항목 |
|---------|------|
| P3 | `PASS_THRESHOLD`, `DAILY_LIMIT` 환경변수로 분리 |
| P3 | Edge Function 요청 파라미터 빈 값 검증 추가 |
| P3 | AI 토큰 사용량 모니터링 (5회/일 × 300토큰 ≒ $0.0002/사용자/일) |

---

## 8. 배포 준비 체크리스트

| 항목 | 상태 |
|------|------|
| 세 함수 코드 완성 | ✅ |
| DB 스키마 정합성 | ✅ |
| 프론트엔드 연결 | ✅ |
| 에러 핸들링 (함수 내부) | ✅ |
| Rate Limiting | ✅ |
| CORS 설정 | ✅ |
| 사용자 에러 알림 UI | ⚠️ 부분 (다음 스프린트) |
| JWT 인증 | ⚠️ 부재 (정식 출시 전) |

**종합 평가: MVP 배포 가능. 사용자 알림 UX와 보안 강화는 이후 스프린트 진행.**
