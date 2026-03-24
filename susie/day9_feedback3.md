# Day 9 QA Feedback — 수정 필요 사항 정리

작성일: 2026-03-24
기준 파일: roadmap.md (Day 8까지 구현 완료 기준)

---

## 공통 전제

수정 전에 반드시 `/app/learn/[id].tsx`, `/app/(tabs)/community.tsx`, `/app/conversation/[id].tsx`, `/src/hooks/useRecorder.ts`, `/src/hooks/useTTS.ts`, `/src/store/audioStore.ts` 를 먼저 읽어라.
수정 범위를 최소화하고, 기존 구조(hook, store, Supabase RPC) 위에서 해결하라.

---

## 이슈 1 — 학습 탭: TTS 자동 재생 안 됨

### 현상
AI 턴이 시작되어도 TTS가 자동 재생되지 않음. 사용자가 직접 듣기 버튼을 눌러야 재생됨.

### 원인 추정
`/app/learn/[id].tsx` 에서 AI 턴 진입 시 `useTTS` 훅의 `play()` 가 자동 호출되지 않거나, `useEffect` 의존성 배열이 잘못 설정되어 있어 AI 턴 변경을 감지하지 못하는 것으로 추정.

### 수정 지시

**Agent 역할**: `app/learn/[id].tsx` 전문 수정 에이전트 (UI/UX 로직 담당)

```
You are a React Native UI logic engineer specializing in audio-driven learning apps.
Fix the auto-play TTS issue in /app/learn/[id].tsx.

Goal: When the current turn is the AI's turn (i.e., the active script belongs to the AI character),
TTS must auto-play without any user interaction.

Steps:
1. Read /app/learn/[id].tsx and /src/hooks/useTTS.ts fully.
2. Find where the lesson advances to an AI-turn script.
3. Add a useEffect that triggers tts.play() when:
   - The current script owner is 'ai' (or equivalent field name)
   - The tts status is 'idle' (not already loading/playing)
   - The component is mounted
4. Add a 300ms delay (setTimeout) before calling play() to avoid race conditions
   with audio session initialization.
5. Make sure to clear the timeout in the useEffect cleanup to prevent memory leaks.
6. Do NOT restructure the component. Minimal change only.
```

---

## 이슈 2 — 학습 탭: 녹음 시 인식 실패 + 녹음 상태 불투명

### 현상
- 녹음 후 항상 "인식 실패, 음성이 인식되지 않았어요. 더 크게 말해보세요." 출력
- 실제 녹음이 되고 있는지, Supabase Edge Function이 응답하는지 사용자가 알 수 없음

### 원인 추정 (2가지 가능성)
1. **녹음 자체 실패**: `expo-av` Audio.Recording 세션이 제대로 열리지 않거나, 실기기에서 마이크 권한이 런타임에 거부됨
2. **STT/발음 평가 Edge Function 실패**: Supabase `stt-transcribe` 또는 `pronunciation-score` Edge Function이 콜드 스타트 이후 제대로 응답하지 않거나, Storage 업로드 경로/권한 문제로 파일이 도달하지 않음

### 수정 지시 (2개 에이전트 병렬 처리)

#### Agent A — 녹음 파동 시각화

**Agent 역할**: React Native 오디오 시각화 전문 에이전트

```
You are a React Native audio visualization engineer.
Add a real-time waveform animation to the recording UI in /app/learn/[id].tsx
(or wherever the RecordingUI component is rendered).

Requirements:
1. Read /src/hooks/useRecorder.ts and /app/learn/[id].tsx fully first.
2. While isRecording === true, show an animated waveform (3–5 vertical bars)
   that pulse up and down using Animated API or react-native-reanimated.
3. Use simple sine-wave style animation with staggered delays per bar.
   Do NOT use any third-party waveform library — implement with Animated.Value only.
4. Show a clear "REC" indicator label alongside the waveform.
5. Remove or hide the static recording countdown text while the waveform is visible
   (keep countdown as a number in a smaller font below the waveform).
6. Minimal file changes: prefer adding the waveform component inline or in a
   new file /src/components/RecordingWaveform.tsx if it exceeds 30 lines.
```

#### Agent B — Edge Function 연결 디버깅

**Agent 역할**: Supabase Edge Function 디버깅 전문 에이전트

```
You are a Supabase Edge Function debugging engineer.
Diagnose and fix the STT/pronunciation scoring pipeline failure in the learning tab.

Steps:
1. Read /app/learn/[id].tsx fully to trace the recording → upload → STT → score flow.
2. Read /src/hooks/useRecorder.ts to understand the upload mechanism.
3. Add console.log checkpoints at each step:
   - After stopRecording(): log the file URI and file size
   - After Storage upload: log the response status and storage path
   - Before calling stt-transcribe: log the request payload
   - After stt-transcribe response: log the full response (transcript or error)
   - Before calling pronunciation-score: log input params
   - After pronunciation-score response: log score and any error
4. Add a user-visible error state: if STT returns empty transcript or edge function
   returns an error, show a specific message (e.g., "서버 연결 실패 — 잠시 후 다시 시도하세요")
   instead of the generic "인식 실패" message.
5. Check if the Storage upload uses the correct bucket name and RLS-compliant path.
   Fix the path format if it differs from {userId}/{scriptId}.m4a.
6. Do NOT change the edge function code itself. Only fix the client-side call and error handling.
```

---

## 이슈 3 — 소통 탭: 마이크 버튼 눌러도 아무것도 안 뜸

### 현상
소통 탭의 FAB(마이크) 버튼을 눌러도 반응 없음. 녹음 모달이 열리지 않음.

### 원인
`/app/(tabs)/community.tsx` 의 FAB 버튼에 `// TODO(Day 8): 녹음 모달 열기` 주석만 있고 실제 구현이 없음.

### 수정 지시

**Agent 역할**: React Native 모달 + 오디오 레코딩 통합 에이전트

```
You are a React Native engineer implementing a voice recording modal for a social feed screen.
Implement the broadcast recording flow in /app/(tabs)/community.tsx.

Context:
- The FAB (floating action button) currently has a TODO comment instead of an action.
- The recording hook already exists at /src/hooks/useRecorder.ts — reuse it exactly as-is.
- The waveform component will be created as /src/components/RecordingWaveform.tsx
  (from Issue 2 fix) — import and use it here as well.

Requirements:
1. Read /app/(tabs)/community.tsx, /src/hooks/useRecorder.ts, and /app/learn/[id].tsx fully.
2. Add a local state: const [showRecordModal, setShowRecordModal] = useState(false)
3. On FAB press: set showRecordModal = true
4. Render a bottom-sheet style Modal (use React Native's built-in Modal with
   animationType="slide" and transparent={true}):
   - Show RecordingWaveform when isRecording === true
   - Show a large circular mic button to start/stop recording
   - Show countdown timer
   - Show a "전송" (send/broadcast) button after recording stops
   - Show a "취소" button that discards the recording
5. On "전송" press: call the broadcast submission logic (see Issue 4 for the correct
   behavior — one active broadcast at a time, expires after a set time).
6. On modal close/cancel: call recorder.stopRecording() if still recording.
7. Match the visual style of the existing RecordingUI in learn/[id].tsx.
```

---

## 이슈 4 — 소통 탭: 브로드캐스트 구조 완전 재설계

### 현상 / 잘못된 현재 구조
- "브로드캐스트" 탭과 "내 대화" 탭이 분리되어 있음
- 브로드캐스트가 누적 피드처럼 동작함 (기존 로드맵 Day 8 설계 기준)

### 올바른 동작 방식 (재정의)
1. 브로드캐스트는 **일회성 발신** — 녹음 1개를 퍼뜨리면 **일정 시간(예: 24시간)** 동안만 다른 사용자에게 노출됨
2. 새 녹음을 퍼뜨리면 **이전 브로드캐스트는 즉시 비활성화**됨 (사용자당 활성 브로드캐스트 1개)
3. "브로드캐스트" 탭을 **별도 탭으로 분리할 필요 없음**
4. 소통 탭 진입 시 피드(다른 사람들의 활성 브로드캐스트)가 바로 보여야 함
5. 탭 구조: ~~브로드캐스트 탭 / 내 대화 탭~~ → **피드(전체) / 내 대화** 2개로 단순화

### 수정 지시 (2개 에이전트 병렬)

#### Agent A — DB/백엔드 스키마 수정

**Agent 역할**: Supabase 데이터 모델 및 RLS 정책 전문 에이전트

```
You are a Supabase database engineer.
Modify the broadcast data model to support one-active-broadcast-per-user with auto-expiry.

Steps:
1. Read /app/(tabs)/community.tsx to understand the current query and data shape.
2. Check if voice_messages table has expires_at and is_active fields.
   If not, write a SQL migration snippet (do NOT run it — output it as a code block
   so the human can paste it into Supabase SQL Editor):
   ALTER TABLE voice_messages
     ADD COLUMN IF NOT EXISTS expires_at timestamptz,
     ADD COLUMN IF NOT EXISTS is_active boolean DEFAULT true;
3. Write the logic (as a Supabase RPC or client-side update) that:
   - When a new broadcast is submitted:
     a. Sets is_active = false on all previous voice_messages of this user
        where broadcast_status = 'broadcasted'
     b. Inserts the new voice_message with:
        - broadcast_status = 'pending' (awaiting moderation)
        - expires_at = NOW() + INTERVAL '24 hours'
        - is_active = true
4. Update the fetch query in community.tsx to filter:
   WHERE is_active = true AND expires_at > NOW() AND broadcast_status = 'broadcasted'
5. Output all SQL as copy-pasteable blocks. Do not modify the edge function files.
```

#### Agent B — UI 재구성

**Agent 역할**: React Native 탭 레이아웃 재설계 에이전트

```
You are a React Native UI engineer restructuring a social feed screen.
Redesign /app/(tabs)/community.tsx to remove the separate "브로드캐스트" tab
and show the feed directly on entry.

Current structure:
- Tab 1: "브로드캐스트" (broadcast feed)
- Tab 2: "내 대화" (1:1 conversations)

New structure:
- On entry: show feed of other users' active broadcasts (not a separate tab)
- A segmented control or header tabs: "피드" | "대화"
- "피드": Other users' active broadcasts (filtered by is_active + not expired)
- "대화": 1:1 conversation threads (existing "My Conversations" section)

Steps:
1. Read /app/(tabs)/community.tsx fully.
2. Replace the current top-tab segmented control with the new "피드" / "대화" layout.
3. On app load, default to "피드" tab (not "브로드캐스트").
4. The feed should NOT show the user's own active broadcast in the main list
   (show it separately as a "내 브로드캐스트" card at the top of the feed if active).
5. Keep all existing audio playback logic (audioStore integration) intact.
6. Minimal structural change — do not rewrite the component from scratch.
```

---

## 이슈 5 — 소통 탭: 1:1 대화 기능 구현 여부 확인

### 확인 사항
QA 미진행. 코드 레벨에서 구현 상태 파악만 필요.

### 현재 구현 상태 (탐색 결과 기반)

| 기능 | 상태 | 파일 |
|------|------|------|
| 대화 상세 페이지 (메시지 스레드 UI) | ✅ 구현됨 | `/app/conversation/[id].tsx` |
| 메시지 녹음 + 업로드 | ✅ 구현됨 | `/app/conversation/[id].tsx` |
| 무료 한도 추적 (7회) + 페이월 | ✅ 구현됨 | `/src/store/conversationStore.ts` |
| 대화 목록 (내 대화 리스트) | ❌ 미구현 — 하드코딩 빈 배열 | `/app/(tabs)/community.tsx` |
| 대화 시작 플로우 (브로드캐스트에서 답장) | ❌ 미구현 | — |
| 오디오 재생 중 녹음 방지 | ✅ 구현됨 | `audioStore.stop()` 연동 |

### 수정 지시

**Agent 역할**: Supabase 실시간 데이터 조회 + 대화 목록 UI 에이전트

```
You are a React Native engineer implementing a conversation list with Supabase.
The goal is to replace the hardcoded empty MOCK_CONVERSATIONS array in
/app/(tabs)/community.tsx with real data from Supabase.

Steps:
1. Read /app/(tabs)/community.tsx, /app/conversation/[id].tsx,
   and /src/store/conversationStore.ts fully.
2. Identify the conversations table schema (look for joins between
   conversations, conversation_messages, and users tables).
3. Write a Supabase query to fetch conversations where the current user
   is a participant (check for participant_id or a join table).
4. Replace MOCK_CONVERSATIONS with the real fetched data.
5. Each conversation card should show:
   - Other user's flag emoji and display name
   - Last message timestamp (or "아직 메시지 없음" if empty)
   - Unread indicator if applicable
   - Tap → navigate to /conversation/[id]
6. Add a loading state and empty state ("아직 대화가 없어요").
7. Do NOT implement the conversation creation flow (reply from broadcast) —
   that is deferred to a later task.
```

---

## 수정 우선순위

| 우선순위 | 이슈 | 이유 |
|---------|------|------|
| P0 | 이슈 2-B (Edge Function 디버깅) | 발음 평가가 핵심 기능인데 완전히 막혀 있음 |
| P0 | 이슈 2-A (녹음 파동 시각화) | 사용자가 녹음 여부를 알 수 없어 UX 전체가 붕괴 |
| P0 | 이슈 1 (TTS 자동 재생) | 학습 흐름이 매 스텝마다 수동 개입 필요 |
| P1 | 이슈 3 (소통 탭 마이크) | 소통 탭 핵심 입력이 막혀 있음 |
| P1 | 이슈 4-A (DB 스키마) | 브로드캐스트 재설계의 백엔드 기반 |
| P1 | 이슈 4-B (UI 재구성) | 소통 탭 구조 자체가 잘못됨 |
| P2 | 이슈 5 (대화 목록) | 디테일 페이지는 되는데 리스트가 빈 상태 |

---

## 병렬 실행 추천 순서

### Round 1 — 동시 실행 (3개 agent)

| Agent | 이슈 | Worktree 이름 | 수정 파일 |
|-------|------|--------------|----------|
| Agent 1-A | 이슈 1: TTS 자동 재생 | `fix/tts-autoplay` | `app/learn/[id].tsx` |
| Agent 1-B | 이슈 2-B: Edge Function 디버깅 | `fix/stt-debug` | `app/learn/[id].tsx`, `src/hooks/useRecorder.ts` |
| Agent 1-C | 이슈 4-A: DB 스키마 (SQL 출력만) | `fix/broadcast-schema` | SQL 코드블록 출력만 (파일 변경 없음) |

**Agent 1-A 실행 프롬프트 (worktree: `fix/tts-autoplay`)**
```
isolation: worktree
branch: fix/tts-autoplay

[이슈 1 Agent 프롬프트 내용 그대로]

When done, output a summary of all changed files and lines.
This branch will be merged into main independently.
Make sure your changes do not touch any file other than app/learn/[id].tsx.
```

**Agent 1-B 실행 프롬프트 (worktree: `fix/stt-debug`)**
```
isolation: worktree
branch: fix/stt-debug

[이슈 2-B Agent 프롬프트 내용 그대로]

When done, output a summary of all changed files and lines.
This branch will be merged into main independently.
Make sure your changes do not touch any file other than
app/learn/[id].tsx and src/hooks/useRecorder.ts.
```

**Agent 1-C 실행 프롬프트 (worktree: `fix/broadcast-schema`)**
```
isolation: worktree
branch: fix/broadcast-schema

[이슈 4-A Agent 프롬프트 내용 그대로]

Output all SQL as copy-pasteable code blocks only.
Do NOT write or modify any source files.
This agent produces no git changes — the human applies SQL manually in Supabase SQL Editor.
```

**Round 1 머지 절차** (각 agent 완료 즉시, 순서 무관하게 머지 가능)
```bash
# Agent 1-A 완료 후
git checkout main
git merge --no-ff fix/tts-autoplay -m "fix: auto-play TTS on AI turn in learn screen"
git branch -d fix/tts-autoplay

# Agent 1-B 완료 후
git checkout main
git merge --no-ff fix/stt-debug -m "fix: add STT pipeline debug logging and specific error messages"
git branch -d fix/stt-debug

# Agent 1-C: SQL만 출력하므로 머지 없음. Supabase SQL Editor에 수동 실행.
```

---

### Round 2 — Round 1 완료 후 동시 실행 (2개 agent)

> 전제: `fix/tts-autoplay`, `fix/stt-debug` 두 브랜치 모두 main에 머지된 상태여야 함.

| Agent | 이슈 | Worktree 이름 | 수정 파일 |
|-------|------|--------------|----------|
| Agent 2-A | 이슈 2-A: 녹음 파동 시각화 | `fix/recording-waveform` | `src/components/RecordingWaveform.tsx` (신규), `app/learn/[id].tsx` |
| Agent 2-B | 이슈 4-B: 소통 탭 UI 재구성 | `fix/community-feed-redesign` | `app/(tabs)/community.tsx` |

**Agent 2-A 실행 프롬프트 (worktree: `fix/recording-waveform`)**
```
isolation: worktree
branch: fix/recording-waveform
base: main  ← Round 1이 머지된 최신 main 기준

[이슈 2-A Agent 프롬프트 내용 그대로]

When done, output a summary of all changed/created files and lines.
This branch will be merged into main independently.
Allowed files: src/components/RecordingWaveform.tsx (new), app/learn/[id].tsx only.
```

**Agent 2-B 실행 프롬프트 (worktree: `fix/community-feed-redesign`)**
```
isolation: worktree
branch: fix/community-feed-redesign
base: main  ← Round 1이 머지된 최신 main 기준

[이슈 4-B Agent 프롬프트 내용 그대로]

When done, output a summary of all changed files and lines.
This branch will be merged into main independently.
Allowed files: app/(tabs)/community.tsx only.
```

**Round 2 머지 절차** (각 agent 완료 즉시 머지 가능 — 수정 파일이 겹치지 않으므로 충돌 없음)
```bash
# Agent 2-A 완료 후
git checkout main
git merge --no-ff fix/recording-waveform -m "feat: add recording waveform visualization component"
git branch -d fix/recording-waveform

# Agent 2-B 완료 후
git checkout main
git merge --no-ff fix/community-feed-redesign -m "refactor: restructure community tab to feed+conversation layout"
git branch -d fix/community-feed-redesign
```

---

### Round 3 — Round 2 완료 후 동시 실행 (2개 agent)

> 전제: `fix/recording-waveform` (RecordingWaveform 컴포넌트 존재), `fix/community-feed-redesign` 모두 main에 머지된 상태여야 함.

| Agent | 이슈 | Worktree 이름 | 수정 파일 |
|-------|------|--------------|----------|
| Agent 3-A | 이슈 3: 소통 탭 마이크 모달 | `fix/community-mic-modal` | `app/(tabs)/community.tsx` |
| Agent 3-B | 이슈 5: 대화 목록 실데이터 | `fix/conversation-list` | `app/(tabs)/community.tsx` |

> ⚠️ Round 3의 두 agent 모두 `community.tsx` 를 수정함. **동시 실행 후 순차 머지** 필요.
> 먼저 3-A를 머지하고, 3-B에서 충돌이 생기면 충돌 해소 후 머지.

**Agent 3-A 실행 프롬프트 (worktree: `fix/community-mic-modal`)**
```
isolation: worktree
branch: fix/community-mic-modal
base: main  ← Round 2가 머지된 최신 main 기준

[이슈 3 Agent 프롬프트 내용 그대로]

IMPORTANT: RecordingWaveform component already exists at
src/components/RecordingWaveform.tsx — import and use it directly.
Do NOT recreate it.

When done, output a summary of all changed files and lines.
Allowed files: app/(tabs)/community.tsx only.
```

**Agent 3-B 실행 프롬프트 (worktree: `fix/conversation-list`)**
```
isolation: worktree
branch: fix/conversation-list
base: main  ← Round 2가 머지된 최신 main 기준

[이슈 5 Agent 프롬프트 내용 그대로]

When done, output a summary of all changed files and lines.
Allowed files: app/(tabs)/community.tsx only.
```

**Round 3 머지 절차** (순차 머지 — 3-A 먼저)
```bash
# Agent 3-A 완료 후 먼저 머지
git checkout main
git merge --no-ff fix/community-mic-modal -m "feat: implement microphone recording modal in community tab"
git branch -d fix/community-mic-modal

# Agent 3-B 완료 후 — 충돌 여부 확인 후 머지
git checkout main
git merge --no-ff fix/conversation-list
# 충돌 발생 시: 충돌 파일 열어 수동 해소 후
# git add app/(tabs)/community.tsx
# git commit -m "feat: load real conversation list from Supabase"
git branch -d fix/conversation-list
```
