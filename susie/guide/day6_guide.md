# Day 6 — 인간이 할 일: Supabase Storage 완전 초보 가이드

> **전제**: Supabase 프로젝트는 이미 만들어져 있고, Dashboard에 로그인할 수 있는 상태

---

## 큰 그림 먼저

이번에 만들 버킷 2개의 역할을 먼저 이해하고 시작하자.

| 버킷 이름 | 저장하는 것 | 누가 접근? |
|---|---|---|
| `tts-cache` | 원어민 AI 음성 mp3 | Edge Function(서버)만. 유저 직접 접근 X |
| `user-recordings` | 사용자가 녹음한 파일 | 각 유저가 자기 것만 업로드·다운로드 |

**버킷(Bucket)** = 구글 드라이브의 폴더 같은 개념.  
파일들을 담는 컨테이너다. 2개를 만들면 된다.

---

## PART 1 — `tts-cache` 버킷 만들기

### 1-1. Dashboard → Storage 메뉴 열기

1. 브라우저에서 [https://supabase.com](https://supabase.com) 접속 → 로그인
2. 본인 프로젝트 클릭해서 들어가기
3. 왼쪽 사이드바에서 **Storage** 아이콘 클릭  
   (아이콘 모양: 원통형 데이터베이스처럼 생긴 것. 메뉴 이름은 "Storage"라고 쓰여 있음)
4. 처음 들어가면 버킷 목록이 비어있다. 화면 왼쪽 위에 **"New bucket"** 버튼이 보임

### 1-2. 버킷 생성 폼 작성

"New bucket" 버튼 클릭하면 오른쪽에 패널이 열린다.

**입력 항목별 설명:**

```
Name: tts-cache
```
- 이름은 정확히 `tts-cache`로 입력 (하이픈 포함, 대소문자 구별 없지만 소문자로)
- 이 이름은 코드에 하드코딩 되어 있음 → 다르게 쓰면 Edge Function이 못 찾음

```
Public bucket: OFF (토글 끄기)
```
- **반드시 Private으로 설정** (Public = 누구나 URL만 알면 다운로드 가능 → 음성 파일 무단 사용 위험)
- 토글이 파란색이면 Public → 꺼서 회색으로 만들어야 함

```
File size limit: 비워두기 (기본값 사용)
Allowed MIME types: 비워두기 (기본값 사용)
```
- 나머지는 건드리지 말고 그냥 둬도 됨

**"Save" 버튼 클릭**

→ 왼쪽 버킷 목록에 `tts-cache`가 나타나면 성공

### 1-3. tts-cache는 RLS 정책 추가 안 해도 되는 이유

Edge Function(`tts-generate`)이 `SUPABASE_SERVICE_ROLE_KEY`를 사용해서 접근한다.  
Service Role Key는 RLS(행 수준 보안)를 **완전히 우회**한다.  
즉, 아무 정책 없어도 서버에서는 자유롭게 읽고 쓸 수 있다.  
유저가 직접 접근할 일이 없으므로 정책 설정 생략해도 안전하다.

---

## PART 2 — `user-recordings` 버킷 만들기

### 2-1. 버킷 생성

다시 **"New bucket"** 클릭

```
Name: user-recordings
Public bucket: OFF (Private)
```

**"Save"** 클릭 → 버킷 목록에 `user-recordings` 추가 확인

### 2-2. RLS 정책 설정 (이게 핵심!)

`user-recordings`는 각 사용자가 **자기 녹음 파일만** 올리고 볼 수 있어야 한다.  
이걸 제어하는 게 RLS 정책이다.  
정책 없으면 → 모든 유저가 서로의 녹음을 볼 수 있거나, 아니면 아무도 업로드 못 하거나 → 둘 다 문제.

**정책 설정 경로:**

1. Storage 화면에서 왼쪽 사이드바 아래쪽에 **"Policies"** 탭 클릭  
   (또는 상단 탭에서 "Policies" 선택)
2. `user-recordings` 버킷 항목 아래에 **"New policy"** 버튼 클릭

> ⚠️ 버킷이 2개 보일 텐데 반드시 `user-recordings` 아래의 New policy를 클릭할 것

---

#### 정책 1 — 업로드(INSERT) 허용

**"New policy" 클릭 → "For full customization" 선택**

```
Policy name: user_recordings_insert
Allowed operation: INSERT
Target roles: authenticated
```

**USING expression 칸은 비워두고,**  
**WITH CHECK expression** 칸을 보면 아래처럼 이미 적혀 있다:

```sql
bucket_id = 'user-recordings'
```

이걸 **지우지 말고**, 뒤에 `AND`로 이어서 다음처럼 완성시킨다:

```sql
bucket_id = 'user-recordings' AND (storage.foldername(name))[1] = auth.uid()::text
```

**의미 해설:**  
- `bucket_id = 'user-recordings'` → 이 정책이 이 버킷에만 적용됨 (UI가 자동으로 써줌)  
- `(storage.foldername(name))[1]` = 업로드 경로(`{유저ID}/{파일명}.m4a`)에서 첫 번째 폴더명 추출 = 유저 ID 부분  
- `auth.uid()::text` = 현재 로그인한 유저의 ID  
- 이 둘이 같을 때만 업로드 허용 → 자기 폴더에만 올릴 수 있음

**"Review" → "Save policy"** 클릭

---

#### 정책 2 — 다운로드(SELECT) 허용

다시 **"New policy"** 클릭 → **"For full customization"**

```
Policy name: user_recordings_select
Allowed operation: SELECT
Target roles: authenticated
```

**USING expression** 칸을 보면 이미 적혀 있다:

```sql
bucket_id = 'user-recordings'
```

뒤에 `AND`로 이어서 완성:

```sql
bucket_id = 'user-recordings' AND (storage.foldername(name))[1] = auth.uid()::text
```

WITH CHECK는 비워둠 (SELECT에는 필요 없음)

**"Review" → "Save policy"** 클릭

---

#### 정책 3 — 삭제(DELETE) 허용 (나중에 필요할 수 있으니 지금 추가)

**"New policy"** → **"For full customization"**

```
Policy name: user_recordings_delete
Allowed operation: DELETE
Target roles: authenticated
```

**USING expression** 칸을 보면 이미 적혀 있다:

```sql
bucket_id = 'user-recordings'
```

뒤에 `AND`로 이어서 완성:

```sql
bucket_id = 'user-recordings' AND (storage.foldername(name))[1] = auth.uid()::text
```

**"Review" → "Save policy"** 클릭

---

#### 최종 확인

Policies 탭에서 `user-recordings` 버킷 아래에 정책 3개가 보이면 완료:

```
✅ user_recordings_insert   INSERT   authenticated
✅ user_recordings_select   SELECT   authenticated
✅ user_recordings_delete   DELETE   authenticated
```

---

## PART 3 — Edge Function 환경변수 등록

Edge Function이 OpenAI API를 호출하려면 API Key가 필요하다.  
Key를 코드에 직접 쓰면 안 되고, Supabase의 Secrets에 등록해야 한다.

### 3-1. OPENAI_API_KEY 등록

**방법 A: Dashboard에서 등록 (추천)**

1. 왼쪽 사이드바 → **"Edge Functions"** 클릭
2. 상단 탭에서 **"Secrets"** 클릭  
   (또는 사이드바에서 Settings → Edge Functions Secrets)
3. **"Add new secret"** 버튼 클릭
4. 입력:
   ```
   Name:  OPENAI_API_KEY
   Value: sk-xxxxxxxxxxxxxxxxxxxxxxxx  (본인의 실제 OpenAI API Key)
   ```
5. **"Save"** 클릭

> OpenAI API Key는 [https://platform.openai.com/api-keys](https://platform.openai.com/api-keys) 에서 발급

**방법 B: CLI로 등록 (터미널 선호 시)**

```bash
supabase secrets set OPENAI_API_KEY=sk-xxxxxxxxxxxxxxxxxxxxxxxx
```

### 3-2. 자동으로 있는 환경변수 (추가 등록 불필요)

Edge Function 코드에서 `SUPABASE_URL`과 `SUPABASE_SERVICE_ROLE_KEY`를 사용하는데,  
이 두 개는 Supabase가 **자동으로** Edge Function에 주입해준다. 직접 등록 안 해도 됨.

---

## PART 4 — Edge Function 배포

터미널(VS Code 내장 터미널)을 열고:

### 4-1. Supabase CLI 로그인 확인

```bash
supabase --version
```

버전 숫자가 나오면 OK. 없으면:

```bash
brew install supabase/tap/supabase
```

### 4-2. 프로젝트 연결 확인

```bash
supabase projects list
```

본인 프로젝트(`oriverse` 같은 이름)가 목록에 보이면 OK.  
없으면 아직 link가 안 된 것:

```bash
supabase link --project-ref YOUR_PROJECT_REF
```

> `YOUR_PROJECT_REF`는 Supabase Dashboard URL에서 확인:  
> `https://supabase.com/dashboard/project/abcdefghijklmnop` → `abcdefghijklmnop` 부분

### 4-3. 배포

```bash
supabase functions deploy tts-generate
```

성공 시 출력 예시:
```
Deploying function tts-generate...
✓ Done.
Function tts-generate deployed.
```

### 4-4. 배포 확인

Dashboard → **Edge Functions** → `tts-generate` 함수가 목록에 보이면 성공

---

## PART 5 — 최종 점검 체크리스트

아래를 순서대로 확인하고 넘어가기:

```
[ ] Storage → tts-cache 버킷 존재 (Private)
[ ] Storage → user-recordings 버킷 존재 (Private)
[ ] user-recordings Policies에 INSERT / SELECT / DELETE 정책 3개 존재
[ ] Edge Functions → Secrets에 OPENAI_API_KEY 등록됨
[ ] Edge Functions → tts-generate 함수 배포됨
```

5개 모두 체크되면 → AI #2 (앱 클라이언트) 작업 넘겨도 OK

---

## 참고: 자주 하는 실수

| 실수 | 증상 | 해결 |
|---|---|---|
| `tts-cache` 이름 오타 | Edge Function 로그에 `Bucket not found` 에러 | 버킷 이름 정확히 `tts-cache`인지 확인 |
| Public 버킷으로 만듦 | 보안 이슈 (당장 에러는 안 남) | 버킷 설정 들어가서 Public 토글 끄기 |
| user-recordings 정책 누락 | 앱에서 업로드 시 `403 Forbidden` | PART 2 정책 3개 다시 추가 |
| OPENAI_API_KEY 미등록 | Edge Function 로그에 `401 Unauthorized` | PART 3 다시 확인 |
| 배포 전 functions deploy 안 함 | 앱에서 TTS 호출 시 404 | `supabase functions deploy tts-generate` 실행 |

---

## 완료 후 AI에게 전달할 것

버킷 생성 + 배포 완료 후 AI에게 이렇게 말하면 된다:

> "버킷 2개 생성 완료, OPENAI_API_KEY 등록 완료, tts-generate 배포 완료. AI #2 시작해줘."
