# Day 9 QA Feedback 4 — 수정 필요 사항 정리

작성일: 2026-03-24
기준: day9_feedback3.md 수정 APK 재QA 결과

---

## QA 결과 요약

| 이슈 | 상태 | 비고 |
|------|------|------|
| 이슈 1: TTS 자동 재생 | ✅ 해결됨 | — |
| 이슈 2-A: 녹음 파동 시각화 | ❌ 부분 미해결 | 파동이 항상 움직임 |
| 이슈 2-B: STT/발음 평가 | ❌ 미해결 | OpenAI API 키 미설정 |
| 이슈 3: 소통 마이크 모달 | ✅ 해결됨 | — |
| 이슈 4: 소통 탭 피드\|대화 구조 | ⚠️ 부분 해결 | 녹음 전송 후 검토중·재생 불가 |
| 이슈 5: 대화 목록 실데이터 | ⏳ QA 미진행 | — |

---

## 이슈 A — 파동 애니메이션 항상 동작 (이슈 2-A 잔존)

### 현상
녹음 중이 아닐 때도 파동 바가 움직이고 있음. 녹음 시작/중지와 무관하게 항상 애니메이션이 실행됨.

### 근본 원인
`/src/components/RecordingWaveform.tsx`의 `useEffect`가 **빈 의존성 배열(`[]`)**로 선언되어 있어, 컴포넌트가 마운트되는 즉시 애니메이션 루프를 시작하고 멈추지 않음. `isRecording` prop을 받지 않으므로 실제 녹음 상태와 연동되지 않음.

```ts
// 현재 코드 (문제)
useEffect(() => {
  // 마운트 즉시 루프 시작 — isRecording 상태 무관
  animValues.forEach((val, i) => {
    const loop = Animated.loop(...)
    ...
  });
  return () => { /* unmount 시에만 cleanup */ };
}, []); // ← 빈 배열이 문제
```

조건부 렌더링(`recorder.isRecording && <RecordingWaveform />`)이 되어 있더라도,
React 상태 업데이트 타이밍 차이나 모달 열림 시점에 의해 컴포넌트가 마운트된 직후
잠깐이라도 애니메이션이 실행되는 현상이 발생함.

### 수정 지시

**수정 파일**: `src/components/RecordingWaveform.tsx`

```
You are a React Native animation engineer.
Fix RecordingWaveform so the animation only runs while isRecording is true.

Current problem:
- The component has no isRecording prop
- useEffect([], []) starts animation immediately on mount regardless of recording state

Fix:
1. Add isRecording: boolean to the props interface
2. Change useEffect dependency array from [] to [isRecording]
3. Inside the effect:
   - If isRecording === false: stop all loops, reset all bars to MIN_HEIGHT, return immediately
   - If isRecording === true: start the staggered loop animation as before
4. Update the return cleanup to stop loops and reset bars

In learn/[id].tsx and community.tsx:
- Pass isRecording={recorder.isRecording} to <RecordingWaveform>
- Keep existing conditional rendering (recorder.isRecording && <RecordingWaveform .../>)
  OR remove the condition and always render, letting isRecording prop control behavior

Minimal change: only modify RecordingWaveform.tsx + the two call sites.
```

---

## 이슈 B — STT/발음 평가 전체 불동작 (이슈 2-B 잔존)

### 현상
어떤 녹음을 해도 "서버 연결 실패 — 잠시 후 다시 시도하세요" 메시지 출력. Supabase에 OpenAI API 키가 연결되지 않아 Whisper API 호출이 실패하는 것으로 추정.

### 근본 원인
**코드 문제 없음** — 환경변수 미설정 문제.

`stt-transcribe/index.ts`가 `Deno.env.get('OPENAI_API_KEY')`를 사용하는데, Supabase Edge Function Secrets에 해당 키가 등록되지 않은 상태. OpenAI API가 401을 반환하면 `whisperRes.ok === false`가 되어 502 에러로 클라이언트에 전달됨.

영향 범위:
- `stt-transcribe` → OpenAI Whisper API 호출 (`OPENAI_API_KEY` 필요) ← **핵심 블로커**
- `ai-feedback` → GPT-4o 호출 (`OPENAI_API_KEY` 필요)
- `content-moderation` → OpenAI Moderation API 호출 (`OPENAI_API_KEY` 필요)
- `pronunciation-score` → 자체 알고리즘 (Levenshtein), OpenAI 불필요

### 수정 지시 — Supabase 대시보드 설정 (코드 변경 없음)

**Claude가 할 수 없는 작업 — 직접 진행 필요:**

```
1. Supabase Dashboard 접속
2. 좌측 메뉴 → Edge Functions → Secrets (또는 Project Settings → API → Secrets)
3. 아래 항목 추가:
   - Name:  OPENAI_API_KEY
   - Value: sk-proj-... (OpenAI 대시보드에서 발급)
4. 저장 후 Edge Functions 재배포 (자동 반영되는 경우도 있음)
   - 재배포: supabase functions deploy stt-transcribe --no-verify-jwt
            supabase functions deploy ai-feedback --no-verify-jwt
            supabase functions deploy content-moderation --no-verify-jwt
```

> ⚠️ OpenAI 키는 openai.com → API Keys에서 발급. 결제 수단 등록 필요.

설정 후 재QA 항목:
- [ ] 녹음 → STT 텍스트 정상 추출 여부
- [ ] 발음 점수 및 피드백 정상 출력 여부

---

## 이슈 C — 브로드캐스트 전송 후 '검토중' 상태 고착 + 재생 불가 (이슈 4 잔존)

### 현상
- 브로드캐스트 녹음 전송 시 `voice_messages` 테이블에는 레코드가 올라감
- UI에서는 '검토중' 뱃지가 표시되고 재생 버튼이 비활성화됨

### 원인 1: 검토중 상태 고착 — content-moderation 미호출

`content-moderation` edge function은 DB webhook trigger에서 자동 호출되도록 설계됨.
현재 Supabase에 webhook trigger가 설정되지 않아 함수가 전혀 호출되지 않고,
`moderation_status`가 영원히 `'pending'` 상태로 남음.

`content-moderation` 코드를 보면 transcript가 없으면 자동 approved 처리하는 로직이 있음:
```ts
if (!message.transcript || message.transcript.trim() === '') {
  // 자동 승인
  await supabase.from('voice_messages').update({ moderation_status: 'approved' })
}
```
따라서 함수만 호출되면 transcript 없는 브로드캐스트는 즉시 approved가 됨.

**수정 방법 — community.tsx `handleSend`에서 직접 호출 (DB webhook 없이)**

수정 파일: `app/(tabs)/community.tsx`

```
You are a React Native engineer.
In /app/(tabs)/community.tsx, modify the handleSend function to call
the content-moderation edge function right after inserting the voice_message.

Current flow:
1. Upload recording → get path
2. Deactivate old broadcasts
3. Insert new voice_message with moderation_status: 'pending'
4. Close modal, refresh feed

New flow (add step 4):
4. After insert, get the inserted row's id (use .select('id').single())
5. Call supabase.functions.invoke('content-moderation', {
     body: { voice_message_id: insertedId },
     headers: { 'x-webhook-secret': process.env.EXPO_PUBLIC_MODERATION_WEBHOOK_SECRET }
   })
6. Do NOT await or block on the result — fire and forget (catch and ignore errors)
7. Wait 500ms then call loadBroadcasts() so the updated status shows

Note: EXPO_PUBLIC_MODERATION_WEBHOOK_SECRET must be set in .env.local and
Supabase secrets (MODERATION_WEBHOOK_SECRET).

If EXPO_PUBLIC_MODERATION_WEBHOOK_SECRET is not available, alternative:
- Change default insert value to moderation_status: 'approved' for development
  (with a TODO comment to revert for production)
```

> **간단한 개발용 임시 조치**: `handleSend`에서 `moderation_status: 'pending'` 대신
> `moderation_status: 'approved'`로 삽입하면 즉시 피드에 노출됨. 프로덕션 전 원복 필요.

### 원인 2: 재생 불가 — get-signed-url 실패로 audioUrl이 null

`fetchBroadcasts`에서 각 아이템마다 `get-signed-url` edge function을 호출해 signed URL을 받아오는데,
실패 시 silently null 처리되어 재생 버튼이 비활성화됨.

**디버깅 먼저 필요** — 정확한 실패 원인이 불명확.

가능한 원인:
1. `get-signed-url` edge function이 배포되지 않았거나 cold start 실패
2. Storage bucket `user-recordings`가 Supabase에 생성되어 있지 않음
3. storage_path 경로 형식 불일치 (`userId/broadcast_timestamp.m4a`)

**수정 지시 — 디버깅 로그 추가**

수정 파일: `app/(tabs)/community.tsx`

```
You are a React Native debugging engineer.
In /app/(tabs)/community.tsx, modify fetchBroadcasts to add explicit error logging
when get-signed-url fails, so we can see the exact failure reason in console.

Change the try/catch block in the messages.map() loop:
  try {
    const { data, error } = await supabase.functions.invoke('get-signed-url', {
      body: { storage_path: msg.storage_path, bucket: 'user-recordings' },
    });
    if (error) {
      console.error('[get-signed-url] invoke error:', JSON.stringify(error), '| path:', msg.storage_path);
    }
    audioUrl = data?.signedUrl ?? null;
    if (!audioUrl) {
      console.warn('[get-signed-url] signedUrl null for path:', msg.storage_path);
    }
  } catch (e) {
    console.error('[get-signed-url] exception:', e, '| path:', msg.storage_path);
  }

After adding logs, run the app, open community tab, and check the console output.
Report the exact error message so we can determine the root cause.
Do NOT change any other logic.
```

**디버깅 결과에 따른 후속 조치:**

| 콘솔 출력 | 원인 | 조치 |
|----------|------|------|
| `Function not found` | edge function 미배포 | `supabase functions deploy get-signed-url` |
| `Object not found` / 404 | Storage 파일 없음 또는 bucket 없음 | Storage 버킷 `user-recordings` 생성 확인 |
| `Unauthorized` | JWT 만료 또는 RLS 문제 | 로그아웃 후 재로그인 테스트 |
| `signedUrl null` | 파일은 있지만 createSignedUrl 실패 | storage_path 경로 Supabase Storage에서 직접 확인 |

---

## 수정 우선순위 및 실행 순서

### 즉시 진행 (코드 변경 없음)

| 작업 | 담당 | 방법 |
|------|------|------|
| OpenAI API Key Supabase 등록 | Susie 직접 | Supabase Dashboard → Secrets |
| Edge Function 재배포 (선택) | Susie 직접 | CLI or Dashboard |

### Round 1 — 단일 에이전트

| Agent | 수정 파일 | 내용 |
|-------|----------|------|
| Agent A | `src/components/RecordingWaveform.tsx`, `app/learn/[id].tsx`, `app/(tabs)/community.tsx` | isRecording prop 추가, 의존성 배열 수정 |

### Round 2 — OpenAI 키 등록 후 재QA 결과 보고 대기

STT가 작동하는지 확인 후 진행.

### Round 3 — 디버그 로그 추가 후 실행, 결과 확인

| Agent | 수정 파일 | 내용 |
|-------|----------|------|
| Agent B | `app/(tabs)/community.tsx` | get-signed-url 디버그 로그 추가 |

**→ 콘솔 출력 결과 캡처 후 원인 파악, 후속 수정 진행**

### Round 4 — moderation 자동화 또는 임시 우회

디버그 결과와 OpenAI 키 등록 후 재QA 결과를 종합하여 진행.

---

## 공통 전제

수정 전 반드시 읽어야 하는 파일:
- `src/components/RecordingWaveform.tsx`
- `app/learn/[id].tsx`
- `app/(tabs)/community.tsx`
- `src/hooks/useRecorder.ts`

수정 범위 최소화. 기존 구조(hook, store, conditional rendering) 위에서 해결.
