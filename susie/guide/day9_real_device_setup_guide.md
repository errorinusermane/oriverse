# Day 9 실기기 테스트 복구 가이드 (USB 없이 진행)

> 목표: **지금 당장 폰에서 앱 설치 + 녹음/재생 테스트 가능 상태** 만들기

---

## 0) 현재 상황 정리

이 가이드는 아래 상황을 전제로 작성됨:

- 맥에 USB 단자 없음
- 폰 개발자 옵션/USB 디버깅 사용 불가
- Expo 프로젝트에서 네이티브 기능(녹음/오디오/결제 예정) 테스트 필요

따라서 **로컬 USB 연결 방식이 아니라, 클라우드 빌드로 APK를 받아 설치**하는 방식으로 진행한다.

---

## 1) 첫 준비 (맥에서 1회만)

### 1-1. 프로젝트 루트로 이동

```bash
cd /Users/susie/Desktop/Temp_Laptop3/Vibe_Files/oriverse
```

### 1-2. EAS CLI 설치

```bash
npm install -g eas-cli
```

### 1-3. Expo 로그인

```bash
eas login
```

---

## 2) Android 빌드 설정 만들기 (1회만)

### 2-1. 빌드 설정 초기화

```bash
eas build:configure
```

실행 후 `eas.json` 파일이 생성된다.

### 2-2. `eas.json` 확인 (없으면 아래로 생성)

```json
{
  "build": {
    "preview": {
      "android": {
        "buildType": "apk"
      }
    },
    "production": {
      "android": {
        "buildType": "app-bundle"
      }
    }
  }
}
```

- `preview`: 폰에 바로 설치할 APK
- `production`: Play Console 업로드용 AAB

---

## 3) APK 빌드 (실기기 테스트용)

### 3-1. preview APK 빌드 시작

```bash
eas build --platform android --profile preview
```

빌드가 끝나면 Expo 페이지에:

- 다운로드 링크
- QR 코드

가 표시된다.

---

## 4) 폰에 설치

### 4-1. 폰에서 빌드 링크/QR 열기

- 브라우저로 APK 다운로드

### 4-2. 설치 허용

Android에서 처음 설치 시:

- “알 수 없는 앱 설치 허용” 필요
- 브라우저(또는 파일 앱)에 설치 권한 허용

### 4-3. 앱 설치

- 설치 후 앱 실행

---

## 5) 오늘 최소 테스트 시나리오 (Day 8 검증 재개용)

아래 4개만 먼저 통과하면 됨:

1. 앱 실행 성공
2. 녹음 시작/종료 1회 성공
3. 업로드 1회 성공
4. 재생 1회 성공

추가로 가능하면:

5. 브로드캐스트가 피드에 노출되는지 확인
6. 모더레이션 상태(`pending/approved/rejected`) 확인
7. 1:1 메시지 전송 + RPC 동작 확인

---

## 6) 실패 시 복구 순서

### 6-1. 빌드 실패 시

1. `app.json`의 package/bundle 식별자 확인
2. Expo 로그 에러 메시지 확인
3. 다시 빌드

```bash
eas build --platform android --profile preview --clear-cache
```

### 6-2. 설치 실패 시

- 기존 앱 삭제 후 재설치
- 저장공간 여유 확인
- 다운로드 파일 손상 시 재다운로드

### 6-3. 앱 실행은 되는데 녹음이 안 될 때

- 앱 권한에서 마이크 허용
- 앱 재시작
- 그래도 안 되면 앱 삭제 후 재설치

---

## 7) Day 9/10과의 관계

- 이 APK 방식으로 **Day 8 검증**은 충분히 가능
- Day 9 결제의 “실제 테스트 구매”는 최종적으로
  - Play Console 내부 테스트 트랙
  - AAB 업로드
  - 테스터 계정 설치
  가 필요함

즉, 지금은 **실기기 동작 확인(녹음/피드/오디오)**부터 먼저 고정하고,
결제 실검증은 계정/콘솔 준비 후 이어서 진행한다.

---

## 8) 바로 실행할 명령어 요약

```bash
cd /Users/susie/Desktop/Temp_Laptop3/Vibe_Files/oriverse
npm install -g eas-cli
eas login
eas build:configure
eas build --platform android --profile preview
```

빌드 완료 후 링크/QR로 APK 설치 → 녹음/업로드/재생 테스트 진행.