# Oriverse

언어는 학습이 아니라 소통이다.

---

## 앱 개요

**Oriverse**는 음성 전용 비실시간 보이스메일로 전 세계 사람들과 소통하는 언어 학습 앱입니다.

텍스트 채팅도, 실시간 통화도 없습니다. 부담 없이 녹음하고, 여유롭게 답장합니다.

### 핵심 컨셉

- **학습 탭**: 6개 스텝의 고정 스크립트를 AI 음성과 함께 따라 말하며 기초를 쌓습니다.
- **소통 탭**: 보이스메일을 전 세계에 퍼뜨리고, 원어민의 답장을 받습니다. 6스텝 완료 후 활성화됩니다.

HelloTalk·Tandem과 달리 텍스트·실시간 통화 없이 **음성 보이스메일만** 주고받습니다. 말하기가 두려운 초보자를 위한 구조입니다.

### 지원 언어

영어 · 스페인어 · 독일어 · 프랑스어 · 중국어 · 일본어 · 한국어

### 학습 스텝

| 스텝 | 주제 | 핵심 문법 |
|------|------|----------|
| 1 | 기본 문법 | 어순, 평서문, 의문문, 명령문, 조동사 |
| 2 | 카페 대화 | 주문 표현, 정중한 요청 |
| 3 | 음식점 대화 | 메뉴 묻기, 알레르기, 계산 |
| 4 | 마트 대화 | 위치 묻기, 수량 표현 |
| 5 | 취미 / 과거 경험 | 과거형, 수동태, 과거분사 |
| 6 | 리액션 모음 | 감정 표현, 맞장구, 감탄사 |
| 7 _(유료)_ | 50동사 회화 | 빈도 높은 동사 50개 실전 회화 |

### 수익 모델

| 플랜 | 가격 | 내용 |
|------|------|------|
| 연 구독 ★ | $39.99/년 (월 $3.33) | 전체 기능 무제한 |
| 월 구독 | $4.99/월 | 전체 기능 무제한 |
| 대화 팩 | $1.99 / 10회 | 1:1 대화 추가 |
| 일일 브로드캐스트 패스 | $1.99 / 1일 | 브로드캐스트 무제한 |

무료: 학습 스텝 1~6 전체 · 브로드캐스트 5회/일 · 1:1 대화 7회 · AI 피드백 5회/일

---

## 기술 스택

### 프론트엔드

| 항목 | 선택 |
|------|------|
| 프레임워크 | React Native (Expo SDK 52+) |
| 네비게이션 | Expo Router (File-based) |
| 상태 관리 | Zustand |
| 스타일링 | NativeWind (TailwindCSS) |
| 음성 녹음/재생 | expo-av |
| 지도 (온보딩) | react-native-svg (커스텀 SVG 애니메이션 세계 지도) |
| 결제 | react-native-iap (Google Play Billing / Apple IAP) |
| 푸시 알림 | expo-notifications |
| 네트워크 감지 | @react-native-community/netinfo |

### 백엔드

| 항목 | 선택 |
|------|------|
| DB | Supabase PostgreSQL |
| 인증 | Supabase Auth |
| 파일 스토리지 | Supabase Storage (private bucket) |
| 실시간 | Supabase Realtime (WebSocket) |
| 서버리스 함수 | Supabase Edge Functions (Deno) |
| 스케줄러 | pg_cron |

### AI / 음성

| 항목 | 선택 |
|------|------|
| STT | OpenAI Whisper API |
| 피드백 생성 | OpenAI GPT-4o-mini |
| TTS (학습 스크립트) | OpenAI TTS (사전 생성 후 Storage 저장) |
| 콘텐츠 필터링 | OpenAI Moderation API |

### 결제 / 인프라

| 항목 | 선택 |
|------|------|
| Android 결제 | Google Play Billing |
| iOS 결제 _(2차)_ | Apple IAP |
| Web 결제 _(2차)_ | Stripe |
| 빌드 | EAS Build (Expo) |
| 배포 | Google Play Store (Android 우선) |
| 등록 비용 | Google Play Console $25 일회성 |
| 에러 모니터링 | Sentry |
| 분석 | Mixpanel |
| 이메일 | Resend |

### Edge Functions

| 함수 | 역할 |
|------|------|
| `stt-transcribe` | Whisper STT → DB 저장 |
| `ai-feedback` | GPT-4o-mini 피드백 생성 (사용자 요청 시) |
| `moderation` | 브로드캐스트 콘텐츠 필터링 (DB 트리거 → 비동기) |
| `get-signed-url` | Storage 경로 → signed URL 발급 |
| `google-play-verify` | Google Play 영수증 검증 → 구독 상태 업데이트 |
| `sync-subscription` | 앱 실행 시 구독 상태 동기화 |
| `stripe-webhook` | Stripe 이벤트 처리 (Web 전용) |
| `daily-reset` | 일일 사용량 카운트 초기화 (pg_cron) |
| `moderation-retry` | pending 타임아웃 메시지 재시도 (pg_cron) |
