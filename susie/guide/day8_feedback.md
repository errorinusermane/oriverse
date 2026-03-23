# Day 8 피드백 — 소통 탭 피드 + 1:1 대화

검토일: 2026-03-22

---

## 전체 요약

| 기능 | 상태 | 완성도 |
|------|------|--------|
| 브로드캐스트 피드 UI | ⚠️ 미완 | Mock 데이터. 실제 DB 연결 없음 |
| get-signed-url Edge Function | ❌ 없음 | 전용 함수 미존재 |
| 전역 audioStore | ✅ 완료 | 단일 인스턴스, 충돌 방지 구현됨 |
| moderation Edge Function | ✅ 완료 | DB 트리거 연동까지 완성 |
| moderation 상태 UI | ❌ 없음 | "검토중/게시됨/거부" 표시 화면 없음 |
| 1:1 대화 스레드 UI | ⚠️ 미완 | UI는 있으나 녹음→전송 플로우 미연결 |
| send_conversation_message RPC 연동 | ✅ 완료 | DB 함수 + store 호출 구현됨 |
| "X회 남음" 카운터 | ✅ 완료 | RemainingBadge, 프로그레스바 포함 |
| 구독 유도 모달 (Paywall) | ✅ 완료 | 0회 시 트리거 동작 확인됨 |

---

## 미완성 항목 상세

### 1. 브로드캐스트 피드 — DB 연결 없음
**파일:** `app/(tabs)/community.tsx`

현재 `MOCK_BROADCASTS` 상수를 화면에 렌더링 중. 실제 동작 불가.

**필요한 작업:**
- `voice_messages` 테이블 쿼리 (`broadcast_status = 'broadcasted' AND moderation_status = 'approved'`)
- 각 row의 `storage_path`로 서명 URL 생성해서 오디오 재생

---

### 2. get-signed-url Edge Function 없음

TTS 오디오는 `tts-generate`가 서명 URL을 반환하지만, **브로드캐스트 녹음(user-recordings 버킷)** 에 대한 서명 URL 생성 함수가 없음.

**필요한 작업:**
- `get-signed-url` Edge Function 신규 작성
- 입력: `storage_path`
- 출력: 서명 URL (TTL 1시간)
- 또는 브로드캐스트 피드 로딩 로직 내부에서 Supabase Storage `createSignedUrl` 직접 호출

---

### 3. 1:1 대화 — 녹음→전송 플로우 미연결
**파일:** `app/conversation/[id].tsx` (line 130 부근 TODO 확인)

UI와 RPC는 준비됐으나, 실제 녹음 버튼 → 파일 업로드 → `send_conversation_message` 호출하는 연결고리가 없음.

**필요한 작업:**
- `useRecorder` hook을 conversation 화면에 연결
- 녹음 완료 → Storage 업로드 → `voice_message` row 생성 → RPC 호출 순서 구현
- Day 6/7에서 만든 녹음 컴포넌트 재활용 가능

---

### 4. moderation 상태 UI 없음

DB에 `moderation_status` 컬럼은 있고, Edge Function도 작동하지만 **사용자에게 상태를 보여주는 UI가 없음**.

**필요한 작업:**
- 내가 올린 브로드캐스트 목록에 뱃지 표시: "검토중" / "게시됨" / "거부됨"
- 최소한 "검토중" 상태 뱃지만 있어도 Day 8 완료 기준 충족

---

## 완성된 항목 (확인 불필요)

- `audioStore.ts` — 전역 단일 오디오 인스턴스 완성. 학습 탭 TTS와 소통 탭 충돌 없음
- `content-moderation/index.ts` + `007_moderation_trigger.sql` — OpenAI Moderation API + DB AFTER INSERT 트리거 완성
- `conversationStore.ts` — `send_conversation_message` RPC 호출, 잔여 횟수 감소, 한도 초과 처리 완성
- `PaywallModal.tsx` — 0회 도달 시 구독 유도 모달 완성
- `conversation/[id].tsx` — RemainingBadge, 프로그레스바, MessageBubble UI 완성

---

## 우선순위

Day 8 완료 기준("브로드캐스트 녹음 → 피드 표시 + 1:1 대화 전송 → RPC 확인")을 충족하려면:

1. **[필수]** `get-signed-url` Edge Function 작성
2. **[필수]** 브로드캐스트 피드 DB 연결 (mock 제거)
3. **[필수]** 1:1 대화 녹음→전송 플로우 연결
4. **[선택]** moderation 상태 UI (뱃지만으로도 충분)

---

## AI 작업 할당

> 항목 1+2는 의존 관계가 있어 같은 agent에게 묶어서 줌. 3과 4는 독립적으로 병렬 실행 가능.

---

### AI A — get-signed-url + 브로드캐스트 피드 DB 연결 (항목 1 + 2 묶음)

**왜 묶는가:** get-signed-url이 완성돼야 피드 DB 연결이 의미 있음. 같은 agent가 흐름을 일관되게 작성하는 게 낫다.

**참고 파일:**
- `supabase/functions/tts-generate/index.ts` — 서명 URL 반환 패턴 참고
- `app/(tabs)/community.tsx` — mock 제거 대상
- `supabase/migrations/004_voice_messages.sql` — 테이블 스키마 확인

**역할 부여 프롬프트:**
```
You are a Supabase Edge Functions engineer and React Native developer.

Task 1: Create a new Edge Function at supabase/functions/get-signed-url/index.ts
- Input (POST body): { storage_path: string, bucket: string }
- Output: { signedUrl: string }
- TTL: 3600 seconds
- Auth: require valid JWT (use supabaseClient with auth header)
- Follow the exact same structure as supabase/functions/tts-generate/index.ts

Task 2: Update app/(tabs)/community.tsx
- Remove MOCK_BROADCASTS and replace with a real Supabase query
- Query: voice_messages WHERE broadcast_status = 'broadcasted' AND moderation_status = 'approved', ordered by created_at DESC
- For each row, call the get-signed-url Edge Function with storage_path and bucket='user-recordings' to get the playback URL
- Pass the signed URL into the existing audioStore play() call
- Keep all existing UI components (BroadcastFeedItem, play/pause, progress bar) intact — only replace the data source
```

---

### AI B — 1:1 대화 녹음→전송 플로우 연결 (항목 3)

**참고 파일:**
- `app/conversation/[id].tsx` — TODO 위치 (line 130 부근)
- `src/store/conversationStore.ts` — `sendMessage()` 호출 방법
- Day 6/7 녹음 컴포넌트 (`useRecorder` hook 또는 RecordButton 컴포넌트) — 재활용

**역할 부여 프롬프트:**
```
You are a React Native engineer completing a voice message send flow.

The UI in app/conversation/[id].tsx is already built. Your job is to wire the recording button to the full send pipeline.

Required flow (in order):
1. User taps record button → start recording via useRecorder hook
2. User taps stop → recording file is ready
3. Upload file to Supabase Storage bucket 'user-recordings' with path: {userId}/conversations/{conversationId}/{timestamp}.m4a
4. Insert a row into voice_messages table: { user_id, storage_path, duration_seconds, transcript: null }
5. Call conversationStore.sendMessage(conversationId, voiceMessageId) — this internally calls send_conversation_message RPC
6. On RPC return false (limit exceeded) → show PaywallModal

Reuse the existing useRecorder hook and upload logic from the learning tab (Day 6/7). Do not create new abstractions — wire existing pieces together.
```

---

### AI C — moderation 상태 UI (항목 4, 선택)

**참고 파일:**
- `app/(tabs)/community.tsx` — BroadcastFeedItem 컴포넌트에 뱃지 추가
- DB `moderation_status` 값: `'pending' | 'approved' | 'rejected'`

**역할 부여 프롬프트:**
```
You are a React Native UI engineer adding a small moderation status badge.

In app/(tabs)/community.tsx, add a status badge to BroadcastFeedItem for items that belong to the current user (compare item.user_id === currentUserId).

Badge display rules:
- moderation_status = 'pending'  → 회색 뱃지 "검토중"
- moderation_status = 'approved' → 뱃지 없음 (정상 표시)
- moderation_status = 'rejected' → 빨간 뱃지 "거부됨"

Additionally, in the broadcast feed query, also fetch the current user's own rejected/pending items (so they can see their own posts regardless of approval status, but others only see approved).

Keep the badge small (text-xs, rounded-full). Use NativeWind classes consistent with the existing file.
```

---

## 병렬 실행 가능 여부

```
AI A (get-signed-url + 피드 연결)  ──┐
AI B (녹음→전송 플로우)            ──┼── 동시 시작 가능
AI C (moderation 뱃지)             ──┘
```

AI A, B, C 모두 서로 다른 파일을 건드리므로 충돌 없음. 동시에 시작해도 됨.
