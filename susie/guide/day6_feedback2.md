# Day 6 QA 피드백 2 — 반영 확인 + 신규 오류

> 작성일: 2026-03-15
> 대상 파일: `src/hooks/useRecorder.ts`, `src/hooks/useTTS.ts`, `app/learn/[id].tsx`, `supabase/functions/tts-generate/index.ts`

---

## 1. day6_feedback.md 반영 확인

| # | 항목 | 파일 | 반영 여부 |
|---|------|------|----------|
| 🔴 1 | AI→User 턴 전환 시 `await tts.stop()` 추가 | `[id].tsx:215` | ✅ 반영 |
| 🔴 2 | countdown state updater에서 async 제거 → `useEffect` 분리 | `[id].tsx:206-210`, `useRecorder.ts:47` | ✅ 반영 |
| 🔴 3 | `getURI()` 순서 수정 (stopAndUnloadAsync 이전 호출) | `useRecorder.ts:85` | ✅ 반영 |
| 🔴 4 | catch 블록 console.error 추가 | `useRecorder.ts:74,90`, `useTTS.ts:54,96,111` | ✅ 반영 |
| 🟠 5 | base64 → FileSystem.uploadAsync 스트리밍 업로드 | `useRecorder.ts:114` | ⚠️ **신규 오류 발생** |
| 🟠 6 | tts-generate `upsert: false → true` | `tts-generate/index.ts:103` | ✅ 반영 |
| 🟠 7 | 클라이언트 URL 캐시 만료 시간 추가 (55분) | `useTTS.ts:13-14,37,58` | ✅ 반영 |
| 🟡 8 | tts-generate Storage 확인 방법 개선 (EAFP) | `tts-generate/index.ts:38-47` | ✅ 반영 |

**결론: 8개 항목 중 7개 반영 완료. 5번만 새 오류 발생.**

---

## 2. 신규 오류 분석

```
ERROR  [uploadRecording] Exception: [Error: Method uploadAsync imported from "expo-file-system" is deprecated.
You can migrate to the new filesystem API using "File" and "Directory" classes
or import the legacy API from "expo-file-system/legacy".]
```

**원인:**

`expo-file-system` v55에서 `uploadAsync`를 포함한 기존 절차형 API 전체가 deprecated 처리됨.
새 버전은 `File`/`Directory` 클래스 기반 API로 전환됨.

현재 코드(`useRecorder.ts:10`):
```ts
import * as FileSystem from 'expo-file-system'; // ← 여기서 uploadAsync 가져오면 deprecated
```

---

## 3. 해결 방법 (3가지 옵션)

### 옵션 A — `/legacy` import (가장 빠른 수정, 1줄 변경)

```ts
// useRecorder.ts:10 변경
import * as FileSystem from 'expo-file-system/legacy'; // ← /legacy 추가
```

나머지 코드 변경 없음. Expo가 공식 마이그레이션 경로로 명시한 방법.
단점: deprecated 경고는 없어지지만, 언젠가 `/legacy`도 삭제될 예정.

---

### 옵션 B — fetch + blob (권장. expo-file-system 의존성 제거) ⭐

```ts
// useRecorder.ts — uploadRecording 함수 교체
// expo-file-system import 완전 제거 가능

async function uploadRecording(uri: string, scriptId: string): Promise<string | null> {
  if (!userId) return null;
  setIsUploading(true);
  try {
    const ext = uri.split('.').pop() ?? 'm4a';
    const path = `${userId}/${scriptId}.${ext}`;

    // React Native fetch는 file:// URI를 네이티브로 읽음 (base64 변환 없음)
    const fileResponse = await fetch(uri);
    const blob = await fileResponse.blob();

    const { error } = await supabase.storage
      .from('user-recordings')
      .upload(path, blob, {
        contentType: `audio/${ext}`,
        upsert: true,
      });

    if (error) {
      console.error('[uploadRecording] Storage error:', error.message);
      return null;
    }
    return path;
  } catch (e) {
    console.error('[uploadRecording] Exception:', e);
    return null;
  } finally {
    setIsUploading(false);
  }
}
```

변경점:
- `expo-file-system` import 제거
- `fetch(uri)` → `blob()` → Supabase SDK 업로드
- Android에서 React Native의 네이티브 fetch가 `file://` URI를 스트리밍 처리

---

### 옵션 C — 새 File 클래스 API (장기적으로 올바른 방향이나 복잡도 높음)

```ts
import { File } from 'expo-file-system';

const file = new File(uri);
// 파일 열기 → 읽기 → 업로드 플로우
// 현 시점에서 Supabase Storage와 직접 연동하는 예제가 적어 검증 필요
```

현시점(MVP 개발 중)에서는 옵션 B를 권장. 옵션 C는 v1.1 이후 리팩토링 시 고려.

---

## 4. 권장 수정 내용

`useRecorder.ts` 최소 변경:

**수정 전 (`useRecorder.ts:8-11`):**
```ts
import * as FileSystem from 'expo-file-system';
import { decode } from 'base64-arraybuffer'; // ← 삭제
```

**수정 후:**
```ts
// expo-file-system, base64-arraybuffer import 모두 제거
```

**수정 전 (`useRecorder.ts:100-135`):**
```ts
async function uploadRecording(uri: string, scriptId: string): Promise<string | null> {
  if (!userId) return null;
  setIsUploading(true);
  try {
    const ext = uri.split('.').pop() ?? 'm4a';
    const path = `${userId}/${scriptId}.${ext}`;

    const { data: { session } } = await supabase.auth.getSession();
    if (!session) { ... }

    const uploadUrl = `${SUPABASE_URL}/storage/v1/object/user-recordings/${path}`;
    const result = await FileSystem.uploadAsync(uploadUrl, uri, {   // ← deprecated
      httpMethod: 'POST',
      headers: { ... },
      uploadType: 0,
    });
    ...
  }
}
```

**수정 후 (옵션 B 적용):**
```ts
async function uploadRecording(uri: string, scriptId: string): Promise<string | null> {
  if (!userId) return null;
  setIsUploading(true);
  try {
    const ext = uri.split('.').pop() ?? 'm4a';
    const path = `${userId}/${scriptId}.${ext}`;

    const fileResponse = await fetch(uri);
    const blob = await fileResponse.blob();

    const { error } = await supabase.storage
      .from('user-recordings')
      .upload(path, blob, {
        contentType: `audio/${ext}`,
        upsert: true,
      });

    if (error) {
      console.error('[uploadRecording] Storage error:', error.message);
      return null;
    }
    return path;
  } catch (e) {
    console.error('[uploadRecording] Exception:', e);
    return null;
  } finally {
    setIsUploading(false);
  }
}
```

---

## 5. 이번 검토에서 추가 발견된 이슈

### 🟡 [id].tsx — countdown=0 useEffect의 stale closure

**파일:** `[id].tsx:206-210`

```ts
useEffect(() => {
  if (recorder.countdown === 0 && recorder.isRecording) {
    handleStopRecording(); // ← 의존성 배열에 없음
  }
}, [recorder.countdown]); // ← handleStopRecording 빠짐
```

`handleStopRecording`이 의존성 배열에서 누락됨. 현재 구조에서는 `current`, `recorder`가 recording 중에 바뀌지 않으므로 실제 버그로 이어지지 않지만, 엄밀히는 React 규칙 위반.

ESLint `react-hooks/exhaustive-deps` 규칙이 켜져 있다면 경고 발생.

수정 방향:
- `handleStopRecording`을 `useCallback`으로 감싸고 의존성 배열에 추가
- 또는 `handleStopRecording` 로직을 직접 useEffect 안으로 인라인

---

## 6. Day 6 최종 상태 요약

| 구분 | 상태 | 비고 |
|------|------|------|
| Audio Session 충돌 | ✅ 해결 | TTS stop() await 추가 |
| countdown async race | ✅ 해결 | useEffect 분리 |
| getURI() 순서 | ✅ 해결 | stopAndUnload 이전 호출 |
| Storage upload 방식 | ⚠️ 수정 필요 | uploadAsync deprecated → fetch+blob |
| TTS URL 캐시 만료 | ✅ 해결 | 55분 TTL |
| tts-generate race condition | ✅ 해결 | upsert: true |
| tts-generate Storage 체크 | ✅ 해결 | EAFP 방식 |

**남은 작업: `uploadRecording`을 fetch+blob 방식으로 교체 (옵션 B) → Day 6 완료**
