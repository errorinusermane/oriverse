# Day 6 QA 피드백 — TTS + 녹음

> 작성일: 2026-03-15
> 작성자: Chief Android Backend QA Manager
> 대상 파일: `src/hooks/useRecorder.ts`, `src/hooks/useTTS.ts`, `app/learn/[id].tsx`, `supabase/functions/tts-generate/index.ts`

---

## 핵심 요약

오류가 "고치면 또 다른 오류가 나는" 패턴으로 반복되는 이유:
**근본 원인이 하나가 아니라, 구조적으로 3개의 독립된 버그가 동시에 존재하기 때문.**
하나를 고쳐도 나머지가 터진다. 세 개를 한 번에 고쳐야 한다.

---

## 🔴 Critical — 반드시 지금 고쳐야 하는 것

### 1. Audio Session 충돌 — TTS와 Recording이 같은 세션을 공유

**파일:** `useTTS.ts:67`, `useRecorder.ts:67`

**현상:** 녹음 시작 시 바로 오류 또는 무음 녹음

**원인:**
`expo-av`의 `Audio.setAudioModeAsync()`는 앱 전역 오디오 세션을 바꾼다.

```
TTS play() → setAudioModeAsync({ allowsRecordingIOS: false })
                ↓
사용자가 "다음" → UI는 User 턴으로 전환
                ↓
TTS의 unloadAsync() 아직 진행 중  ← 비동기, 완료 보장 없음
                ↓
"녹음 시작" 클릭 → setAudioModeAsync({ allowsRecordingIOS: true })
                ↓
Android: TTS unload ↔ Recording 세션 전환이 동시에 충돌
```

`[id].tsx`의 AI→User 턴 전환 흐름:
```ts
// currentIndex 변화 시 실행되는 useEffect
useEffect(() => {
  if (!current) return;
  if (current.speaker === 'ai') {
    const timer = setTimeout(() => tts.play(), 300);
    return () => clearTimeout(timer);
  }
  setRecordingUri(null); // ← TTS를 멈추는 코드가 없다
}, [currentIndex]);
```

User 턴으로 넘어갈 때 `tts.stop()`이 명시적으로 호출되지 않는다.
`useTTS`의 `useEffect([scriptId])`가 `unloadAsync`를 시도하지만, 이게 완료되기 전에 녹음 세션 설정이 실행된다.

**수정 방향:**
- `[id].tsx`의 `advance()` 함수에서 User 턴으로 넘어갈 때 `await tts.stop()` 먼저 호출
- `tts.stop()`이 완료된 후에만 recorder UI를 활성화
- 또는 `useRecorder.startRecording()` 직전에 `Audio.setAudioModeAsync`를 await로 강제 완료 후 100ms 대기

---

### 2. countdown callback 안에서 async stopRecording 호출 — React Anti-pattern

**파일:** `useRecorder.ts:46-52`

**현상:** 60초 카운트다운 종료 시 녹음이 끊기거나 URI가 null로 반환됨

**원인:**
```ts
timerRef.current = setInterval(() => {
  setCountdown((c) => {
    if (c <= 1) {
      stopRecording(); // ← React state updater 안에서 async side effect 호출
      return 0;
    }
    return c - 1;
  });
}, 1000);
```

React state updater 함수는 **순수 함수**여야 한다. 여기서 `stopRecording()`을 호출하면:
- React StrictMode에서 updater가 두 번 실행되어 `stopRecording` 두 번 호출 가능
- `stopRecording`은 async인데 반환값이 버려짐 (URI를 누가 받아서 처리하지 않음)
- 결과: 녹음 파일이 생성되지 않거나, `handleStopRecording`을 눌렀을 때와 다른 코드 경로를 타서 `uploadRecording`이 건너뜀

동시에 사용자가 카운트다운 1초 남았을 때 "녹음 완료" 버튼을 누르면:
타이머 콜백 + 버튼 클릭이 동시에 `stopRecording` 호출 → `recordingRef.current`가 null로 세팅된 직후 다른 쪽에서 다시 접근

**수정 방향:**
- state updater 안의 `stopRecording()` 호출 제거
- 대신 `useEffect`에서 `countdown === 0`을 감지해서 호출:
  ```ts
  useEffect(() => {
    if (countdown === 0 && isRecording) {
      stopRecording().then((uri) => {
        // uri 처리 로직
      });
    }
  }, [countdown]);
  ```
- 또는 타이머 내부에서 직접 `clearInterval` 후 별도 핸들러 호출

---

### 3. stopRecording 후 URI 취득 순서 — expo-av 버전 이슈

**파일:** `useRecorder.ts:87-88`

**현상:** 녹음 완료 후 URI가 null로 반환 → 업로드 건너뜀 → Storage에 파일 없음

**원인:**
```ts
await recordingRef.current.stopAndUnloadAsync();
const uri = recordingRef.current.getURI(); // ← stopAndUnload 후 호출
```

`expo-av`의 일부 버전에서 `stopAndUnloadAsync()` 완료 후 내부 상태가 정리되어 `getURI()`가 null을 반환할 수 있다.

안전한 순서:
```
getURI() 먼저 → stopAndUnloadAsync() 후 → URI 반환
```

또한 현재 `catch` 블록이 오류를 그냥 삼키고 있어서 (`return null`만 하고 로그 없음), 오류 원인 추적이 불가능하다.

**수정 방향:**
```ts
async function stopRecording(): Promise<string | null> {
  if (!recordingRef.current) return null;
  setIsRecording(false);
  try {
    const uri = recordingRef.current.getURI(); // ← 먼저 URI 취득
    await recordingRef.current.stopAndUnloadAsync();
    recordingRef.current = null;
    return uri ?? null;
  } catch (e) {
    console.error('[stopRecording] error:', e); // ← 로그 추가
    recordingRef.current = null;
    return null;
  }
}
```

---

## 🟠 High — 조만간 터질 것들

### 4. Signed URL 클라이언트 캐시에 만료 없음

**파일:** `useTTS.ts:14`

**현상:** 앱을 장시간 사용하거나, 1시간 이상 지나면 TTS 재생 불가

**원인:**
```ts
// 모듈 레벨 URL 캐시 (앱 세션 동안 유지)
const urlCache = new Map<string, string>();
```

서버의 signed URL TTL은 `3600초 (1시간)`이지만, 클라이언트 캐시에는 만료 시간이 없다.
1시간이 지나면 캐시된 URL이 만료되어 재생 실패.

**수정 방향:**
```ts
const urlCache = new Map<string, { url: string; expiresAt: number }>();
// 저장: urlCache.set(id, { url, expiresAt: Date.now() + 3300 * 1000 }); // 55분
// 조회: if (cached && cached.expiresAt > Date.now()) return cached.url;
```

---

### 5. tts-generate Race Condition — 동시 요청 시 Storage 업로드 실패

**파일:** `supabase/functions/tts-generate/index.ts:93-105`

**현상:** 같은 script에 대해 여러 prefetch 요청이 동시에 들어가면 500 에러

**원인:**
- 캐시 체크 후 `upsert: false`로 업로드
- 두 요청이 동시에 캐시 미스 → 둘 다 OpenAI TTS 생성 → 하나는 `upsert: false`로 충돌 → 500

prefetch 로직(`[id].tsx:184`)이 스크립트 목록 전체를 한 번에 prefetch 요청하기 때문에 첫 진입 시 이 문제가 발생하기 쉬움.

**수정 방향:**
```ts
// upsert: false → upsert: true 로 변경
const { error: uploadError } = await supabase.storage
  .from(BUCKET)
  .upload(storagePath, audioBuffer, {
    contentType: 'audio/mpeg',
    upsert: true, // ← 충돌 시 덮어쓰기 (동일 파일이므로 안전)
  });
```

---

### 6. Android 업로드: base64 → ArrayBuffer 방식이 메모리 위험

**파일:** `useRecorder.ts:107-116`

**현상:** 60초 녹음 파일 업로드 시 OOM 또는 매우 느린 업로드

**원인:**
```ts
const base64 = await FileSystem.readAsStringAsync(uri, { encoding: 'base64' });
const arrayBuffer = decode(base64);
await supabase.storage.from('user-recordings').upload(path, arrayBuffer, ...);
```

60초 HIGH_QUALITY m4a ≈ 3~5MB → base64 인코딩 후 ≈ 4~7MB 문자열 + decode 후 ArrayBuffer ≈ 4~7MB
메모리에 최대 15MB 이상이 동시에 올라감. 저사양 Android에서 OOM crash 또는 느린 처리.

**수정 방향:**
`expo-file-system`의 `uploadAsync` 직접 사용 (Supabase Storage REST endpoint 직접 호출):
```ts
const { data: { session } } = await supabase.auth.getSession();
const uploadUrl = `${SUPABASE_URL}/storage/v1/object/user-recordings/${path}`;
await FileSystem.uploadAsync(uploadUrl, uri, {
  httpMethod: 'POST',
  headers: {
    Authorization: `Bearer ${session!.access_token}`,
    'x-upsert': 'true',
  },
  uploadType: FileSystem.FileSystemUploadType.BINARY_CONTENT,
});
```
메모리 스트리밍 업로드 → base64/ArrayBuffer 변환 없음.

---

## 🟡 Medium — 다음 스프린트 전에 해결

### 7. prefetch tts 함수 의존성 배열 누락

**파일:** `app/learn/[id].tsx:182-189`

```ts
useEffect(() => {
  if (scripts.length === 0) return;
  scripts.forEach((s) => {
    if (s.speaker === 'ai' && !prefetchedRef.current.has(s.id)) {
      prefetchedRef.current.add(s.id);
      tts.prefetch(s.id); // ← tts가 의존성 배열에 없음
    }
  });
}, [scripts]); // ← tts 빠짐
```

`tts`가 의존성 배열에서 빠져 있어, `tts` 객체가 바뀌어도 prefetch가 재실행되지 않음.
현재 구조에서 `tts.prefetch`는 모듈 레벨 `urlCache`를 사용하므로 실제로 문제가 없지만, 향후 변경 시 버그 원인이 됨.

---

### 8. tts-generate의 Storage 존재 확인 방법이 불안정

**파일:** `supabase/functions/tts-generate/index.ts:38-42`

```ts
const { data: existingFile } = await supabase.storage
  .from(BUCKET)
  .list(voice, { search: `${script_id}.mp3` })

const isCached = existingFile && existingFile.length > 0
```

`.list()` + `search`는 prefix match로 동작할 수 있어서 의도한 exact match가 아닐 수 있음.
또한 빈 폴더인 경우 `list()`가 오류가 아닌 빈 배열을 반환하므로 ambiguous.

**수정 방향:**
`createSignedUrl` 먼저 시도 → 실패 시 생성 패턴 (EAFP):
```ts
const { data: signedUrlData } = await supabase.storage
  .from(BUCKET).createSignedUrl(storagePath, SIGNED_URL_TTL);

if (signedUrlData) {
  return new Response(JSON.stringify({ url: signedUrlData.signedUrl, cached: true }), ...);
}
// 없으면 생성 로직으로
```
`list()` 호출 1회 절약 + 정확도 향상.

---

### 9. 녹음 오류가 catch에서 묻힘 — 디버그 불가

**파일:** `useRecorder.ts:79`, `useTTS.ts:92`

두 훅 모두 `catch` 블록에서 단순히 `return false/null`을 반환하고 로그가 없다.
"자꾸 오류가 뜬다"는 상황에서 어떤 오류인지 파악이 불가능한 근본적인 이유.

```ts
// 현재
} catch {
  return false;
}

// 수정
} catch (e) {
  console.error('[startRecording] failed:', e);
  return false;
}
```

---

## 🔵 Low — 나중에

### 10. TTS 자동 재생 타이머가 정리되지 않을 수 있음

**파일:** `app/learn/[id].tsx:197`

```ts
const timer = setTimeout(() => tts.play(), 300);
return () => clearTimeout(timer);
```

cleanup은 되어 있으나, 300ms 이내에 빠르게 탭을 이동하면 timer가 발동되기 전에 cleanup되어 TTS가 재생되지 않을 수 있음.
실제 UX 영향은 미미하지만, "TTS가 안 들려요" 버그 리포트의 원인이 될 수 있음.

---

## 수정 우선순위 체크리스트

| 우선순위 | 항목 | 파일 | 상태 |
|---------|------|------|------|
| 🔴 1 | AI→User 턴 전환 시 `tts.stop()` 먼저 await | `[id].tsx` `advance()` | ❌ |
| 🔴 2 | countdown state updater에서 async 호출 제거 | `useRecorder.ts` | ❌ |
| 🔴 3 | `getURI()` 순서 수정 (`stopAndUnload` 이전으로) | `useRecorder.ts:87-88` | ❌ |
| 🔴 4 | catch 블록에 console.error 추가 (디버그용) | `useRecorder.ts`, `useTTS.ts` | ❌ |
| 🟠 5 | Storage upload를 FileSystem.uploadAsync로 교체 | `useRecorder.ts:100-130` | ❌ |
| 🟠 6 | tts-generate `upsert: false → true` | `tts-generate/index.ts:97` | ❌ |
| 🟠 7 | 클라이언트 URL 캐시에 만료 시간 추가 | `useTTS.ts:14` | ❌ |
| 🟡 8 | tts-generate Storage 확인 방법 개선 | `tts-generate/index.ts:38` | ❌ |

---

## 작업 순서 제안

**지금 바로 (30분):**
1번, 3번, 4번을 먼저 적용. 4번은 로그만 추가하면 돼서 빠름.
이것만 해도 "오류가 뜨는데 뭔지 모르는" 상황은 해결됨.

**오늘 안에 (2시간):**
2번 countdown 수정 + 5번 업로드 방식 교체.
이 두 개가 Android 녹음 오류의 핵심 원인.

**내일:**
6번, 7번. tts-generate race condition과 URL 캐시 만료는 초기엔 드물게 발생하지만 사용자 증가 시 반드시 터짐.

---

## 참고: 공통 Anti-pattern

현재 코드 전반에서 async 오류가 모두 `catch {}` 또는 `catch { return null }`로 묻히는 패턴이 반복되고 있다.
Day 7 (STT + 발음 평가) 작업 전에 **최소한 console.error 로깅**을 모든 catch 블록에 추가할 것.
오류를 고치는 것보다 **오류가 어디서 나는지 보이게 만드는 것**이 먼저다.
