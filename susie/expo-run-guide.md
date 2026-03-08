# 🚀 Oriverse React Native Expo 실행 가이드

## 📌 목차
1. [사전 준비 사항](#사전-준비-사항)
2. [Step 1: Node.js 버전 확인 및 설정](#step-1-nodejs-버전-확인-및-설정)
3. [Step 2: 프로젝트 생성 (최초 1회만)](#step-2-프로젝트-생성-최초-1회만)
4. [Step 3: 의존성 패키지 설치](#step-3-의존성-패키지-설치)
5. [Step 4: 환경 변수 설정](#step-4-환경-변수-설정)
6. [Step 5: Expo 개발 서버 실행](#step-5-expo-개발-서버-실행)
7. [Step 6: 앱 실행 방법 선택](#step-6-앱-실행-방법-선택)
8. [문제 해결](#문제-해결)

---

## 사전 준비 사항

### 필수 설치 항목

#### 1. Node.js (v20.19.4 이상)
- Expo SDK 52+는 Node.js 20 이상 필요
- nvm으로 설치 권장 (버전 관리 편함)

#### 2. 모바일 디바이스 또는 에뮬레이터
**옵션 A: 실제 기기 (가장 쉬움)**
- iOS: App Store에서 "Expo Go" 앱 설치
- Android: Play Store에서 "Expo Go" 앱 설치

**옵션 B: iOS 시뮬레이터 (Mac만 가능)**
- Xcode 14.0 이상 설치 필요
- 약 10GB 용량 필요

**옵션 C: Android 에뮬레이터**
- Android Studio 설치 필요
- 약 5GB 용량 필요

**옵션 D: 웹 브라우저**
- 별도 설치 없음
- Chrome/Safari/Firefox 최신 버전

---

## Step 1: Node.js 버전 확인 및 설정

### 1-1. 현재 Node.js 버전 확인

터미널을 열고 다음 명령어 실행:

```bash
node --version
```

**결과 확인:**
- ✅ `v20.19.4` 이상 → 다음 단계로
- ❌ `v18.x.x` 또는 그 이하 → 1-2로 이동

---

### 1-2. Node.js 20 설치 (필요 시)

#### 방법 1: nvm 사용 (권장)

**nvm 설치 여부 확인:**
```bash
nvm --version
```

**nvm이 없다면 설치:**
```bash
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
```

설치 후 터미널 재시작 또는:
```bash
source ~/.zshrc
# 또는
source ~/.bash_profile
```

**Node.js 20 설치 및 사용:**
```bash
nvm install 20
nvm use 20
node --version  # v20.20.1 이상 확인
```

**기본 버전으로 설정 (선택):**
```bash
nvm alias default 20
```

---

#### 방법 2: Homebrew 사용 (Mac)

```bash
brew update
brew install node@20
brew link --overwrite node@20
node --version  # 확인
```

---

#### 방법 3: 공식 설치 프로그램
1. https://nodejs.org/ 접속
2. "LTS" 버전 다운로드 (20.x.x)
3. 설치 프로그램 실행
4. 터미널 재시작 후 `node --version` 확인

---

## Step 2: 프로젝트 생성 (최초 1회만)

### 2-1. 프로젝트 폴더 이동

```bash
cd /Users/susie/Desktop/Temp_Laptop3/Vibe_Files/oriverse-md
```

---

### 2-2. Expo 프로젝트 생성

```bash
npx create-expo-app@latest front --template blank-typescript
```

**프롬프트 응답:**
- "Ok to proceed?" → `y` 입력 후 Enter
- 약 1-2분 소요

**생성되는 폴더 구조:**
```
oriverse-md/
└── front/
    ├── app/
    │   └── index.tsx          # 메인 화면
    ├── app.json               # Expo 설정
    ├── package.json           # 의존성 목록
    ├── tsconfig.json          # TypeScript 설정
    └── ...
```

---

### 2-3. 추가 패키지 설치

프로젝트 폴더로 이동:
```bash
cd front
```

필수 패키지 설치:
```bash
npx expo install @supabase/supabase-js expo-av expo-file-system expo-notifications expo-router nativewind tailwindcss zustand react-native-iap @react-native-community/netinfo
```

**설치 시간:** 약 2-3분

---

## Step 3: 의존성 패키지 설치

### 3-1. package.json 확인

```bash
cat package.json
```

다음 패키지들이 있는지 확인:
- `expo`: ~52.0.0
- `react-native`: 0.76.x
- `expo-router`: ~4.0.x
- `@supabase/supabase-js`: 최신
- `zustand`: 최신

---

### 3-2. node_modules 설치

**이미 설치되어 있다면 건너뛰기**

```bash
npm install
```

**예상 시간:** 2-5분  
**설치 패키지 수:** 약 1000개

**경고 메시지는 대부분 무시 가능:**
- `npm warn deprecated ...` → 괜찮음
- `npm warn EBADENGINE ...` → Node 버전 맞으면 무시

---

### 3-3. Expo CLI 전역 설치 (선택)

```bash
npm install -g expo-cli
```

이후 `expo start` 명령어를 `npx` 없이 사용 가능  
(권장하지 않음, `npx expo start`가 더 안정적)

---

## Step 4: 환경 변수 설정

### 4-1. .env 파일 생성

`front` 폴더 안에 `.env` 파일 생성:

```bash
touch .env
```

---

### 4-2. .env 파일 내용 작성

에디터로 `.env` 파일 열고 다음 내용 입력:

```env
# Supabase
EXPO_PUBLIC_SUPABASE_URL=https://your-project-ref.supabase.co
EXPO_PUBLIC_SUPABASE_ANON_KEY=your-anon-key-here

# OpenAI (나중에 추가)
OPENAI_API_KEY=sk-...
```

**⚠️ 주의:**
- `EXPO_PUBLIC_` 접두사 필수 (클라이언트에서 접근 가능)
- Supabase URL/Key는 [Supabase Dashboard → Settings → API](https://supabase.com/dashboard) 에서 확인
- 아직 Supabase 없다면 임시로 빈 값 입력 가능:
  ```env
  EXPO_PUBLIC_SUPABASE_URL=https://placeholder.supabase.co
  EXPO_PUBLIC_SUPABASE_ANON_KEY=placeholder
  ```

---

### 4-3. .gitignore 확인

`.env` 파일이 Git에 커밋되지 않도록 확인:

```bash
cat .gitignore | grep .env
```

`.env`가 포함되어 있어야 함. 없다면 추가:
```bash
echo ".env" >> .gitignore
```

---

## Step 5: Expo 개발 서버 실행

### 5-1. Node 버전 재확인 (중요!)

**현재 터미널에서 Node 20 사용 중인지 확인:**
```bash
node --version
```

**v18.x.x로 표시되면:**
```bash
nvm use 20
node --version  # v20.20.1 확인
```

---

### 5-2. front 폴더로 이동

```bash
cd /Users/susie/Desktop/Temp_Laptop3/Vibe_Files/oriverse-md/front
```

---

### 5-3. Expo 개발 서버 시작

```bash
npx expo start
```

**또는 (nvm 사용자):**
```bash
nvm use 20 && npx expo start
```

---

### 5-4. 서버 실행 확인

**성공 시 화면:**
```
Starting Metro Bundler
▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄
█ ▄▄▄▄▄ █▄▄▄ ▀ ▀█▄█ ▄▄▄▄▄ █
█ █   █ ██▄▀ █  █▄█ █   █ █
█ █▄▄▄█ ██▀▄ ▄▀██▀█ █▄▄▄█ █
█▄▄▄▄▄▄▄█ ▀▄█ ▀ ▀ █▄▄▄▄▄▄▄█

› Metro waiting on exp://192.168.x.x:8081
› Web is waiting on http://localhost:8081

› Press w │ open web
› Press i │ open iOS simulator
› Press a │ open Android
```

**⚠️ 에러 발생 시 → [문제 해결](#문제-해결) 섹션 참고**

---

### 5-5. 명령어 단축키 (서버 실행 중)

| 키 | 동작 |
|----|------|
| `w` | 웹 브라우저에서 열기 |
| `i` | iOS 시뮬레이터 열기 (Mac만) |
| `a` | Android 에뮬레이터 열기 |
| `r` | 앱 새로고침 |
| `m` | 개발자 메뉴 토글 |
| `j` | 디버거 열기 |
| `c` | 터미널 로그 지우기 |
| `Ctrl+C` | 서버 종료 |

---

## Step 6: 앱 실행 방법 선택

### 방법 A: 실제 기기 (Expo Go) ⭐ 권장

#### iOS (iPhone/iPad)
1. App Store에서 **"Expo Go"** 앱 다운로드
2. iPhone과 Mac이 **같은 Wi-Fi** 연결 확인
3. Expo Go 앱 열기 → **"Scan QR code"** 탭
4. 터미널에 표시된 QR 코드 스캔
5. 앱이 자동으로 빌드되고 열림 (약 10-30초)

#### Android
1. Play Store에서 **"Expo Go"** 앱 다운로드
2. Android와 Mac/PC가 **같은 Wi-Fi** 연결 확인
3. Expo Go 앱 열기
4. 터미널에 표시된 QR 코드를 스캔 (카메라 앱 또는 Expo Go 내장 스캐너)
5. 앱이 자동으로 빌드되고 열림

**⚠️ 문제 발생 시:**
- "Unable to connect" → Wi-Fi 동일 네트워크 확인
- "Network error" → 방화벽 8081 포트 확인
- "Manifest error" → 서버 재시작: `Ctrl+C` 후 `npx expo start`

---

### 방법 B: iOS 시뮬레이터 (Mac만)

#### 사전 준비
1. **Xcode 설치 확인:**
   ```bash
   xcode-select --version
   ```
   없다면 App Store에서 Xcode 설치 (약 10GB)

2. **시뮬레이터 설치 확인:**
   ```bash
   xcrun simctl list devices available
   ```

---

#### 실행 방법
1. Expo 서버 실행 중인 터미널에서 `i` 키 입력
2. 시뮬레이터 자동 실행 (첫 실행 시 1-2분 소요)
3. 앱이 시뮬레이터에 설치되고 자동 실행

**수동 실행:**
```bash
open -a Simulator
# 시뮬레이터 열린 후
npx expo start --ios
```

**시뮬레이터 단축키:**
- `Cmd+D`: 개발자 메뉴
- `Cmd+R`: 앱 새로고침
- `Cmd+K`: 키보드 토글
- `Cmd+Q`: 시뮬레이터 종료

---

### 방법 C: Android 에뮬레이터

#### 사전 준비
1. **Android Studio 설치:**
   - https://developer.android.com/studio 다운로드
   - 설치 시 "Android Virtual Device" 옵션 선택

2. **AVD Manager에서 에뮬레이터 생성:**
   ```
   Android Studio → More Actions → Virtual Device Manager
   → Create Device → Pixel 7 Pro → R (API 30) → Finish
   ```

3. **adb 경로 설정 (Mac/Linux):**
   ```bash
   export ANDROID_HOME=$HOME/Library/Android/sdk
   export PATH=$PATH:$ANDROID_HOME/emulator
   export PATH=$PATH:$ANDROID_HOME/platform-tools
   ```
   
   `.zshrc` 또는 `.bash_profile`에 추가하면 영구 적용:
   ```bash
   echo 'export ANDROID_HOME=$HOME/Library/Android/sdk' >> ~/.zshrc
   echo 'export PATH=$PATH:$ANDROID_HOME/emulator' >> ~/.zshrc
   echo 'export PATH=$PATH:$ANDROID_HOME/platform-tools' >> ~/.zshrc
   source ~/.zshrc
   ```

---

#### 실행 방법
1. **에뮬레이터 먼저 실행:**
   ```bash
   emulator -avd Pixel_7_Pro_API_30
   ```
   또는 Android Studio → AVD Manager → ▶ 버튼

2. **Expo 서버에서 `a` 키 입력**
3. 앱이 에뮬레이터에 설치되고 자동 실행

**수동 실행:**
```bash
npx expo start --android
```

**에뮬레이터 단축키:**
- `Cmd+M` (Mac) / `Ctrl+M` (Windows): 개발자 메뉴
- `R+R`: 앱 새로고침

---

### 방법 D: 웹 브라우저

#### 실행 방법
1. Expo 서버 실행 중인 터미널에서 `w` 키 입력
2. 자동으로 `http://localhost:8081` 열림
3. 브라우저에서 앱 실행

**수동 실행:**
```bash
npx expo start --web
```

**⚠️ 주의:**
- 웹 버전은 네이티브 기능 제한적 (카메라, 음성 녹음 등)
- 빠른 UI 테스트용으로 사용 권장
- 프로덕션 배포는 별도 설정 필요

---

## 문제 해결

### 1. Node.js 버전 에러

**에러:**
```
Unsupported engine
required: { node: '>=20.19.4' }
current: { node: 'v18.20.8' }
```

**해결:**
```bash
nvm install 20
nvm use 20
node --version  # 확인
```

---

### 2. "expo: command not found"

**에러:**
```
sh: expo: command not found
```

**해결:**
- `npx expo start` 사용 (권장)
- 또는 전역 설치: `npm install -g expo-cli`

---

### 3. "The required package `expo-asset` cannot be found"

**에러:**
```
Error: The required package `expo-asset` cannot be found
```

**해결:**
```bash
npm install expo-asset
npx expo start
```

---

### 4. 포트 8081 이미 사용 중

**에러:**
```
Error: Port 8081 is already in use
```

**해결:**
```bash
# 기존 프로세스 종료
lsof -ti:8081 | xargs kill -9

# 다른 포트 사용
npx expo start --port 8082
```

---

### 5. "Unable to resolve module"

**에러:**
```
Error: Unable to resolve module @react-native/...
```

**해결:**
```bash
# node_modules 삭제 후 재설치
rm -rf node_modules package-lock.json
npm install

# 캐시 클리어
npx expo start --clear
```

---

### 6. iOS 시뮬레이터 앱이 안 열림

**해결:**
```bash
# 시뮬레이터 재시작
xcrun simctl shutdown all
xcrun simctl erase all

# Xcode 재설치 확인
xcode-select --install
```

---

### 7. Android 에뮬레이터 연결 실패

**해결:**
```bash
# adb 재시작
adb kill-server
adb start-server

# 디바이스 확인
adb devices

# 에뮬레이터 재시작
emulator -avd Pixel_7_Pro_API_30 -wipe-data
```

---

### 8. "Network response timed out"

**원인:** 방화벽 또는 Wi-Fi 문제

**해결:**
1. Mac과 모바일 기기가 **같은 Wi-Fi** 연결 확인
2. VPN 끄기
3. 터널링 모드 사용:
   ```bash
   npx expo start --tunnel
   ```
   (ngrok 설치 필요, 느릴 수 있음)

---

### 9. 빌드 에러 (JavaScript 코드 오류)

**에러:**
```
Metro Bundler error: SyntaxError...
```

**해결:**
1. 에러 메시지에서 파일명과 줄 번호 확인
2. 해당 파일 열어서 구문 오류 수정
3. 저장 후 자동 새로고침 (Fast Refresh)
4. 안 되면 `r` 키로 수동 새로고침

---

### 10. Supabase 연결 에러

**에러:**
```
Error: Invalid Supabase URL
```

**해결:**
1. `.env` 파일 확인:
   ```bash
   cat .env
   ```
2. `EXPO_PUBLIC_SUPABASE_URL`과 `EXPO_PUBLIC_SUPABASE_ANON_KEY` 값 확인
3. Supabase Dashboard에서 정확한 값 복사
4. 서버 재시작: `Ctrl+C` 후 `npx expo start`

---

## 🎉 성공 체크리스트

앱이 정상적으로 실행되면 다음을 확인할 수 있습니다:

- [ ] Expo Go 또는 시뮬레이터에서 앱이 열림
- [ ] 기본 화면이 표시됨 (Welcome to Expo)
- [ ] 터미널에 로그가 출력됨
- [ ] 코드 수정 시 자동 새로고침 (Fast Refresh)
- [ ] 개발자 메뉴 열림 (`Cmd+D` 또는 기기 흔들기)

---

## 📚 다음 단계

Expo 앱이 실행되었다면:

1. **UI 개발 시작**
   - `app/index.tsx` 파일 수정
   - NativeWind (Tailwind CSS) 스타일링
   - Expo Router로 화면 추가

2. **Supabase 연결 테스트**
   - 회원가입/로그인 기능 구현
   - 데이터베이스 조회 테스트

3. **네이티브 기능 테스트**
   - `expo-av`로 음성 녹음
   - `expo-notifications`로 푸시 알림

4. **빌드 및 배포 준비**
   - EAS Build 설정
   - TestFlight (iOS) 또는 내부 테스트 (Android)

---

## 🔗 유용한 링크

- [Expo 공식 문서](https://docs.expo.dev/)
- [React Native 문서](https://reactnative.dev/docs/getting-started)
- [Expo Router 가이드](https://docs.expo.dev/routing/introduction/)
- [NativeWind 문서](https://www.nativewind.dev/)
- [Supabase React Native 가이드](https://supabase.com/docs/guides/getting-started/quickstarts/react-native)

---

## 💡 팁

### 개발 효율성 높이기

1. **Fast Refresh 활용**
   - 코드 저장 시 자동 새로고침
   - 상태 유지하면서 UI만 업데이트

2. **개발자 메뉴 활용**
   - Debug JS Remotely: Chrome DevTools 디버깅
   - Show Perf Monitor: 성능 모니터링
   - Toggle Inspector: UI 요소 검사

3. **VS Code 확장**
   - React Native Tools
   - ES7+ React/Redux/React-Native snippets
   - Prettier - Code formatter

4. **단축 명령어 설정**
   ```bash
   # .zshrc 또는 .bash_profile에 추가
   alias expo-start='cd /Users/susie/Desktop/Temp_Laptop3/Vibe_Files/oriverse-md/front && nvm use 20 && npx expo start'
   ```
   
   이후 어디서든 `expo-start` 명령어로 실행 가능

---

**문제가 계속되면 Expo Community 또는 GitHub Issues에 질문하세요!**
