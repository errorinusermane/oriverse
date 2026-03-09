# Oriverse 최종 기획안 v2

> 작성일: 2026-03-05
> 반영 피드백: feedback.md / feedback_frombackqa.md / feedback_fromfrontqa.md / feedback2.md(사용자)

--

## 1. 앱 개요

**앱 이름**: Oriverse

**핵심 메시지**: 언어는 학습이 아니라 소통이다.

**차별점**: 텍스트 채팅 없음. 실시간 통화 없음. 음성 전용 비실시간 보이스메일이 핵심.
HelloTalk/Tandem은 텍스트 + 실시간이라 부담스럽다. Oriverse는 언제든 녹음하고, 답장은 여유롭게.

**캐릭터**: Ori (긴꼬리딱새 / 주황·검정·남색). 정적 일러스트 PNG (MVP). 등장 화면 4개:
1. 온보딩 환영 화면
2. 스텝 완료 축하 화면
3. 소통 탭 잠금 화면 (진행도 표시)
4. 브로드캐스트 피드 Empty State

**타겟**: 20-30대. 언어에 관심 있으나 실전 소통이 두렵거나 귀찮은 초급자.

**지원 언어**: 영어, 스페인어, 독일어, 프랑스어, 중국어, 일본어, 한국어 (7개)

---

## 2. 앱 구조 (화면 흐름)

```
앱 진입
  └── 온보딩 (최초 1회, onboarding_step으로 재진입 시 복원)
        ├── 1. Native 언어 선택
        │     └── 플래그 + 언어명 리스트 (7개)
        ├── 2. 학습 언어 선택
        │     └── 커스텀 SVG 애니메이션 세계 지도
        │           ├── 국가 영역을 탭하면 딸깍 애니메이션 + 언어 선택
        │           ├── 동일 언어 다국가(스페인어, 중국어 등): 어느 나라 탭해도 같은 언어로 매핑
        │           ├── 지도 위 언어명 레이블 표시로 혼란 방지
        │           └── 지도 하단에 선택된 언어 플래그 + 이름 확인 표시
        └── 3. 레벨 퀴즈 (5문항)
              ├── 초급 → 스텝 1부터 시작
              └── 중급 → 스텝 3부터 시작 (스텝 1~2 복습 모드 제공)

메인 탭 (Bottom Bar)
  ├── 학습 탭
  │     ├── 스텝 목록 (잠금/해제 상태 표시)
  │     │     ├── 완료 스텝: 복습 모드 진입 가능
  │     │     └── 잠긴 스텝 탭: "이전 스텝을 먼저 완료하세요" 토스트
  │     ├── 각 스텝: 스크립트 뷰 → TTS 재생 → 음성 입력 → AI 피드백
  │     ├── 완료 기준: 1회 시도 = 완료 (점수는 참고용)
  │     ├── 진행도 / 스트릭 / 포인트 (낙관적 업데이트)
  │     └── 스텝 7 (50동사, 유료. 처음 3개 무료 미리보기)
  │
  └── 소통 탭
        ├── [3스텝 미완료] 잠금 화면 (탭은 항상 표시)
        │     └── Ori + "X스텝 남았어요" 진행도 + 미리보기 CTA
        ├── [3스텝 완료~5스텝] 읽기 전용 미리보기
        │     └── 브로드캐스트 피드 읽기 가능. 녹음/답장 불가. "6스텝 완료 후 참여 가능" 안내
        └── [6스텝 완료] 전체 기능 활성화
              ├── 브로드캐스트 피드 (전세계 보이스메일)
              ├── 내 대화 목록 (1:1)
              └── 새 녹음 버튼

우측 상단 (프로필)
  ├── 내 정보 (언어 변경: 확인 팝업 → 언어별 진행도 독립 저장)
  ├── 구독 관리 (Google Play Billing / 구독 상태)
  └── 설정 (알림 설정, 개인정보)
```

---

## 3. 기능 상세

### 3-1. 학습 탭

| 스텝 | 주제 | 핵심 문법 |
|------|------|----------|
| 1 | 기본 문법 | 어순, 평서문, 의문문, 명령문, 의문사, 조동사 |
| 2 | 카페 대화 | 주문 표현, 정중한 요청 |
| 3 | 음식점 대화 | 메뉴 묻기, 알레르기, 계산 |
| 4 | 마트 대화 | 위치 묻기, 수량 표현 |
| 5 | 취미 / 과거 경험 | 과거형, 수동태, 과거분사 |
| 6 | 리액션 모음 | 감정 표현, 맞장구, 감탄사 |
| 7 (유료) | 50동사 회화 | 빈도 높은 동사 50개 실전 회화 |

**학습 방식**:
1. 스크립트 표시 (텍스트 + TTS 재생 버튼)
   - TTS 파일 로드 실패 시: 에러 아이콘 표시, 텍스트만으로 진행 가능
2. 사용자 차례 → 음성 녹음
   - AppState 리스너: 백그라운드 전환 감지 → 명시적 중단 + 재시작 유도 UI
   - 60초 도달 10초 전부터 카운트다운. 60초에 자동 중단.
3. STT Edge Function 호출
   - 10초 타임아웃. 실패 시 에러 메시지 + "다시 시도" 버튼
   - Whisper confidence score < 0.7 → "발음을 다시 확인해보세요" + 재녹음 유도
   - STT 결과 먼저 DB 저장 → GPT 피드백은 비동기 분리
4. 결과 표시: confidence score 기반 간략 피드백 (MVP). 점수는 참고용. 1회 시도 = 완료 처리.
5. 완료 시 포인트 적립, 스트릭 +1 (낙관적 업데이트 후 백그라운드 동기화)
   - 스트릭: 사용자 현지 타임존 기준, 하루 1회만 증가

**스텝 완료 조건 정의**:
- `user_lesson_progress.status = 'completed'` 상태가 6개 행일 때 소통 탭 전체 활성화
- `status = 'completed'` 조건: 해당 레슨의 모든 스크립트(speaker='user')를 1회 이상 시도
- 3스텝 완료 시: 소통 탭 읽기 전용 미리보기 활성화 트리거

**Gamification**: 스트릭, 포인트, 완료 배지. 스텝 완료 시 Ori 축하 화면 + 애니메이션.

### 3-2. 소통 탭

**보이스메일 흐름**:
1. 녹음 (최대 60초, 카운트다운 UI)
2. "AI 피드백 받기" 버튼 (선택. 무료 사용자 일 5회 제한)
   - 비용 통제: 사용자가 명시적으로 요청할 때만 Edge Function 호출
3. AI 피드백 팝업: "이 표현이 더 자연스러워요 + 예시 문장" → 재녹음 또는 그대로 전송
4. 브로드캐스트 버튼 탭 → "검토 중..." 상태 표시
   - 모더레이션 통과 → "게시되었습니다" 토스트
   - 모더레이션 거부 → "부적절한 콘텐츠로 게시할 수 없습니다" 안내 (사유 미공개)
   - 모더레이션 5분 타임아웃 → `failed` 상태 전환 → 사용자 알림 + 재시도 가능

**브로드캐스트 피드**:
- 학습 언어 기준 필터링 (언어 없으면 전체 피드 표시)
- 전역 오디오 플레이어 (Zustand): 새 재생 시 기존 재생 자동 중단
- 음성 재생: 재생 버튼 탭 → 서버에서 fresh signed URL 발급 후 재생
- Empty State: Ori + "첫 보이스메일을 남겨보세요" CTA
- **Cold Start 전략**: 런치 전 팀원 7개 언어 시드 보이스메일 직접 생성 + AI 샘플 메시지 추가 (언어당 최소 10개)

**상대방 정보 (기본)**:
- 피드 카드에 표시: 학습 중인 언어 플래그 + 스트릭 배지 (7일+, 30일+)
- 탈퇴 계정의 메시지는 피드에서 자동 숨김 처리

**1:1 대화**:
- 대화 스레드 상단: "X회 남음 (무료 10회 기준)" 표시
- 0회 도달 → 답장 버튼 탭 → 구독 유도 모달
- 체크 + INSERT 단일 트랜잭션 처리 (레이스 컨디션 방지)

**AI 모더레이션**: INSERT 시 DB 트리거로 `moderation_status = 'pending'` 강제. 클라이언트 우회 불가.

---

## 4. 기술 트리

```
Oriverse
├── [프론트엔드]
│   ├── React Native (Expo SDK 52+)
│   │   ├── expo-av                         # 음성 녹음/재생
│   │   ├── expo-file-system                # 파일 업로드 처리
│   │   ├── expo-notifications              # 푸시 알림
│   │   │     └── 권한 요청 타이밍: 첫 보이스메일 답장 수신 시 컨텍스트 기반 요청
│   │   ├── react-native-reanimated         # 애니메이션 (국가 선택 딸깍 효과 포함)
│   │   ├── react-native-svg                # 커스텀 SVG 세계 지도 렌더링
│   │   │     ├── 국가별 Path/Polygon으로 구성된 SVG 지도 (Maps API 미사용)
│   │   │     ├── 탭 시 Reanimated로 선택 애니메이션
│   │   │     └── 동일 언어 국가(스페인어 권역 등) → 같은 언어 ID로 매핑
│   │   └── @react-native-community/netinfo # 네트워크 상태 감지 (오프라인 에러 표시)
│   │   ※ react-native-maps, Google Maps API → 미사용
│   │
│   ├── IAP (결제)
│   │   └── react-native-iap                # Google Play Billing (Android 우선) / Apple IAP (iOS, 2차)
│   │         ├── 소비성: 대화 팩, 일일 브로드캐스트 패스
│   │         └── 구독: 월/연 구독 (Google Play Billing 필수. Stripe는 Web 전용)
│   │
│   ├── 상태 관리
│   │   └── Zustand
│   │         ├── 전역 오디오 플레이어 상태 (동시 재생 방지)
│   │         ├── 인증 상태
│   │         └── 오프라인 큐 (2차)
│   │
│   ├── 네비게이션
│   │   └── Expo Router (File-based)
│   │
│   ├── UI / 스타일링
│   │   ├── NativeWind (TailwindCSS)
│   │   └── 로딩 상태 통일 기준:
│   │         ├── 피드/목록: 스켈레톤 UI
│   │         └── 액션 처리 중: 버튼 내 스피너
│   │
│   └── 오프라인 처리 (MVP)
│         ├── 네트워크 없음 → 명확한 에러 메시지 + 재시도 버튼
│         └── 스크립트 콘텐츠 로컬 캐싱 (읽기 전용 오프라인 학습 가능)
│
├── [백엔드 - Supabase]
│   ├── Auth                                # 소셜 로그인 전용 (자체 이메일 로그인 없음)
│   │                                       # MVP: Google OAuth 완료. 추후: Facebook, Apple
│   ├── PostgreSQL DB                       # 메인 데이터베이스
│   ├── Row Level Security (RLS)            # 데이터 접근 제어
│   ├── DB Trigger                          # voice_messages INSERT 시 moderation_status 강제 'pending'
│   ├── Storage                             # 음성 파일 (private bucket, 경로만 DB 저장)
│   │     └── signed URL: 재생 시점마다 동적 발급 (24시간 또는 요청 시 발급)
│   ├── Realtime                            # 새 메시지 알림 + is_premium 변경 즉시 반영
│   │     └── useEffect cleanup에서 .unsubscribe() 필수
│   └── Edge Functions (Deno)
│         ├── stt-transcribe                # Whisper STT만 처리 → DB 저장
│         ├── ai-feedback                   # GPT-4o-mini 피드백 생성 (비동기, 사용자 요청 시)
│         ├── moderation                    # DB 트리거 → 비동기 호출. OpenAI Moderation API
│         │     └── 5분 타임아웃 → 'failed' 전환 + 재시도 cron
│         ├── stripe-webhook (Web 전용)     # Stripe 이벤트 → DB 업데이트 (Web 구독용)
│         ├── google-play-verify              # Apple 영수증 검증 → users 업데이트
│         ├── sync-subscription-status      # 앱 실행 시 Stripe/Google Play Billing 상태 동기화
│         ├── daily-reset                   # 일일 브로드캐스트 카운트 리셋
│         └── moderation-retry              # pending 5분 초과 메시지 재시도 (cron)
│
├── [AI / 음성]
│   ├── OpenAI Whisper API                  # STT, 다국어. confidence score 0.7 미만 → 재녹음 유도
│   ├── OpenAI GPT-4o-mini                 # 표현 수정 제안, 학습 피드백 (비동기)
│   ├── OpenAI TTS                          # 학습 스크립트 AI 음성 (사전 생성 → Storage 저장)
│   │     └── 생성 대상: 7언어 × 6스텝 × 스크립트 수 (약 500~1,000개 파일)
│   └── OpenAI Moderation API              # 보이스메일 텍스트 자동 필터링
│         └── 실패 시: 메시지 'pending' 유지 → 재시도 큐 등록
│
├── [결제]
│   ├── Google Play Billing (Android, CRITICAL)
│   │     ├── 소비성: 대화 팩, 일일 패스
│   │     └── 자동갱신 구독: 월 $4.99, 연 $39.99
│   └── Stripe (Web 전용)                  # 웹 버전 결제 (2차. Android 앱 내 사용 불가)
│         ├── Webhook 이벤트:
│         │     ├── customer.subscription.updated
│         │     ├── customer.subscription.deleted
│         │     ├── customer.subscription.trial_will_end
│         │     └── invoice.payment_failed
│         └── 서명 검증: constructEvent() 필수
│
├── [인프라 / DevOps]
│   ├── GitHub                              # 코드 저장소
│   ├── GitHub Actions                      # CI (lint, test, type-check)
│   ├── EAS Build (Expo)                   # Android 빌드 & Google Play 내부 테스트 배포
│   └── Sentry                              # 에러 모니터링
│
├── [분석]
│   └── Mixpanel (무료 티어)                # 사용자 행동 추적, 페이월 퍼널 분석
│
└── [외부 서비스]
    ├── Resend                              # 이메일 (가입 확인, 알림)
    └── Google Play Console                 # Android 배포 ($25 일회성)
```

---

## 5. 데이터베이스 스키마 (최종)

### 5-1. 테이블 목록 및 변경점

| 테이블 | 역할 | 변경점 (v1 대비) |
|--------|------|-----------------|
| `users` | 계정 + 학습 상태 + 구독 | `subscription_type` ENUM 추가. `timezone` 추가. `onboarding_step` 추가. `daily_*` 컬럼 제거 |
| `user_daily_stats` | 일일 사용량 추적 | **신규**: users에서 분리. 쓰기 경합 방지 |
| `languages` | 지원 언어 7개 | 변경 없음 |
| `lessons` | 학습 스텝 메타데이터 | `level_required` 컬럼 추가 ('beginner'/'intermediate') |
| `lesson_scripts` | 스텝별 대화 스크립트 | `audio_storage_path` 컬럼 (URL 아닌 경로 저장) |
| `user_lesson_progress` | 학습 진행도 | 변경 없음 |
| `voice_messages` | 보이스메일 | `moderation_status`에 `'failed'` 추가. `storage_path` 저장 (URL 아님) |
| `conversations` | 1:1 대화 스레드 | 변경 없음 |
| `conversation_messages` | 대화 내 메시지 | 변경 없음 |
| `payments` | 결제 내역 | `payment_provider` 컬럼 추가 ('google_play' / 'apple_iap' / 'stripe') |
| `user_achievements` | 업적/배지 | 변경 없음 |
| `user_level_quiz` | 레벨 퀴즈 결과 | **신규** |

### 5-2. 주요 스키마 변경

```sql
-- users 테이블 추가 컬럼
subscription_type TEXT DEFAULT 'free'
  CHECK (subscription_type IN ('free', 'monthly', 'annual', 'lifetime')),
  -- Lifetime은 웹훅 만료 처리 예외 대상
timezone TEXT DEFAULT 'UTC',           -- 스트릭 로컬 날짜 계산용
onboarding_step INTEGER DEFAULT 0,    -- 0: 미시작, 1: native 완료, 2: learning 완료, 3: 퀴즈 완료

-- is_premium 컬럼 유지 (빠른 체크용), subscription_type으로 세분화
-- Lifetime 처리: stripe-webhook에서 subscription_type = 'lifetime'이면 is_premium 업데이트 건너뜀


-- user_daily_stats 신규 테이블
CREATE TABLE user_daily_stats (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE NOT NULL,
  stat_date DATE NOT NULL DEFAULT CURRENT_DATE,
  broadcasts_count INTEGER DEFAULT 0,    -- 오늘 브로드캐스트 횟수 (무료 상한: 5)
  ai_feedback_count INTEGER DEFAULT 0,   -- 오늘 AI 피드백 요청 횟수 (무료 상한: 5)
  UNIQUE(user_id, stat_date)
);
CREATE INDEX idx_daily_stats_user_date ON user_daily_stats(user_id, stat_date);


-- voice_messages moderation_status 확장
moderation_status TEXT DEFAULT 'pending'
  CHECK (moderation_status IN ('pending', 'approved', 'rejected', 'failed')),
moderation_checked_at TIMESTAMP WITH TIME ZONE,
storage_path TEXT NOT NULL,  -- URL 아닌 Storage 경로 저장 (signed URL은 요청 시 생성)


-- DB 트리거: INSERT 시 moderation_status 강제 'pending'
CREATE OR REPLACE FUNCTION enforce_moderation_pending()
RETURNS TRIGGER AS $$
BEGIN
  NEW.moderation_status = 'pending';
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER voice_messages_moderation_check
  BEFORE INSERT ON voice_messages
  FOR EACH ROW EXECUTE FUNCTION enforce_moderation_pending();


-- 피드 쿼리 복합 인덱스
CREATE INDEX idx_voice_messages_feed
  ON voice_messages(broadcast_status, moderation_status, created_at DESC);


-- lessons 레벨 컬럼
level_required TEXT DEFAULT 'beginner'
  CHECK (level_required IN ('beginner', 'intermediate')),
  -- 레벨 퀴즈 중급 결과 시 step_number >= 3의 lesson만 표시


-- user_level_quiz 신규 테이블
CREATE TABLE user_level_quiz (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE NOT NULL,
  language_id UUID REFERENCES languages(id) NOT NULL,
  result TEXT CHECK (result IN ('beginner', 'intermediate')),
  taken_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(user_id, language_id)
);


-- payments payment_provider 추가
payment_provider TEXT DEFAULT 'google_play'
  CHECK (payment_provider IN ('google_play', 'apple_iap', 'stripe')),
  -- google_play: Android (기본), apple_iap: iOS (2차), stripe: Web
```

### 5-3. DB 함수

```sql
-- 스트릭: 사용자 timezone 기반으로 로컬 날짜 비교
CREATE OR REPLACE FUNCTION update_user_streak(p_user_id UUID)
RETURNS VOID AS $$
DECLARE
  user_tz TEXT;
  local_today DATE;
  local_last DATE;
  current_streak INTEGER;
BEGIN
  SELECT timezone, last_active_date, streak_days
  INTO user_tz, local_last, current_streak
  FROM users WHERE id = p_user_id;

  local_today := (NOW() AT TIME ZONE user_tz)::DATE;

  IF local_last = local_today THEN
    RETURN;
  ELSIF local_last = local_today - INTERVAL '1 day' THEN
    UPDATE users SET streak_days = streak_days + 1, last_active_date = local_today WHERE id = p_user_id;
  ELSE
    UPDATE users SET streak_days = 1, last_active_date = local_today WHERE id = p_user_id;
  END IF;
END;
$$ LANGUAGE plpgsql;


-- 대화 제한 체크 + INSERT 단일 트랜잭션 (TOCTOU 방지)
-- 클라이언트에서 BOOLEAN 체크 후 INSERT 방식 폐기
-- 대신 아래 함수가 내부에서 체크 후 INSERT까지 처리:
CREATE OR REPLACE FUNCTION send_conversation_message(
  p_user_id UUID,
  p_conversation_id UUID,
  p_voice_message_id UUID,
  p_message_order INTEGER
) RETURNS BOOLEAN AS $$
DECLARE
  v_is_premium BOOLEAN;
  v_msg_count INTEGER;
BEGIN
  SELECT is_premium INTO v_is_premium FROM users WHERE id = p_user_id FOR UPDATE;

  IF NOT v_is_premium THEN
    SELECT COUNT(*) INTO v_msg_count
    FROM conversation_messages
    WHERE conversation_id = p_conversation_id AND sender_id = p_user_id;

    -- 무료 대화 제한: 기본값 7회. A/B 테스트 시 10으로 변경 가능 (설정값으로 관리)
    IF v_msg_count >= 7 THEN
      RETURN FALSE;
    END IF;
  END IF;

  INSERT INTO conversation_messages(conversation_id, voice_message_id, sender_id, message_order)
  VALUES (p_conversation_id, p_voice_message_id, p_user_id, p_message_order);

  RETURN TRUE;
END;
$$ LANGUAGE plpgsql;


-- 일일 브로드캐스트 / AI 피드백 카운트 리셋 (user_daily_stats 기반)
-- daily-reset Edge Function (cron): 별도 쿼리로 처리 (pg_cron 필수 활성화)


-- 소프트 삭제 정책
-- voice_messages: is_deleted = true (Storage 파일은 7일 후 자동 삭제 cron)
-- users: is_banned = true (계정 삭제 요청 시). GDPR 삭제 권리: 30일 유예 후 하드 삭제
```

---

## 6. API 설계

```
[인증]
# 자체 로그인 없음. 소셜 로그인만 지원.
# MVP: Google OAuth (완료). 추후 추가 예정: Facebook, Apple
supabase.auth.signInWithOAuth({ provider: 'google' })  # MVP 완료
# supabase.auth.signInWithOAuth({ provider: 'facebook' })  # 추후 추가
# supabase.auth.signInWithOAuth({ provider: 'apple' })     # 추후 추가
supabase.auth.updateUser({ data: { native_language_id, learning_language_id, timezone } })

[온보딩]
supabase.from('users').update({ onboarding_step: N })   # 단계 진행 시마다 저장

[학습]
supabase.from('lessons').select()
  .gte('step_number', startStep)                          # 레벨 퀴즈 결과 기반 필터링
supabase.from('lesson_scripts').select().eq('lesson_id')
supabase.functions.invoke('stt-transcribe', { audio_url }) # STT만
supabase.functions.invoke('ai-feedback', { transcription, script }) # 사용자가 요청할 때만
supabase.from('user_lesson_progress').upsert()

[소통]
supabase.storage.from('voice-recordings').upload()
supabase.from('voice_messages').insert()                   # DB 트리거로 moderation_status = 'pending' 강제
supabase.functions.invoke('get-signed-url', { path })      # 재생 시점마다 호출
supabase.from('voice_messages')                            # 피드 조회
  .select().eq('broadcast_status','broadcasted')
  .eq('moderation_status','approved')
  .order('created_at', { ascending: false })

# 대화 메시지 전송: 클라이언트에서 check 후 insert 방식 금지
supabase.rpc('send_conversation_message', { ... })         # 단일 트랜잭션 처리

[실시간]
supabase.channel('conv-{id}').on('postgres_changes', ...)
  # useEffect cleanup: return () => supabase.removeChannel(channel)
supabase.channel('user-{id}').on('postgres_changes',      # is_premium 변경 즉시 감지
  { filter: `id=eq.${userId}` }, ...)
```

### Edge Functions 목록

| 함수명 | 트리거 | 주요 동작 |
|--------|--------|----------|
| `stt-transcribe` | 클라이언트 invoke | Whisper STT → 텍스트 + confidence score → DB 저장 |
| `ai-feedback` | 클라이언트 invoke (선택) | GPT-4o-mini 피드백 생성. Rate Limit: user_id 기준 일 5회 |
| `moderation` | DB 트리거 → 비동기 호출 | OpenAI Moderation → approved/rejected. 5분 타임아웃 → failed |
| `get-signed-url` | 클라이언트 invoke | storage_path → 24시간 signed URL 발급 |
| `google-play-verify` | 클라이언트 invoke | Google Play 영수증 검증 → subscription_type + is_premium 업데이트 |
| `sync-subscription` | 앱 실행 시 클라이언트 invoke | Google Play/Stripe 구독 상태 조회 → DB 동기화 |
| `stripe-webhook` | Stripe HTTP (Web 전용) | 서명 검증 → subscription 이벤트 처리 (trial_will_end 포함) |
| `daily-reset` | pg_cron (매일 자정 UTC) | user_daily_stats 당일 카운트 초기화 |
| `moderation-retry` | pg_cron (5분마다) | pending 5분 초과 메시지 → 재시도 또는 failed 전환 |

---

## 7. 수익화

### 무료/유료 경계 단순 요약 (가입 시 1화면에서 설명)

| 기능 | 무료 | 프리미엄 |
|------|------|---------|
| 학습 스텝 1~6 | 전체 | - |
| 50동사 스텝 7 | 처음 7개 | 전체 |
| 소통 탭 읽기 | 3스텝 완료 후 | - |
| 소통 탭 참여 | 6스텝 완료 후 | - |
| 브로드캐스트 | 하루 5회 | 무제한 |
| 1:1 대화 | 1인당 7회 (A/B 테스트: 10회 vs 7회) | 무제한 |
| AI 피드백 | 하루 5회 | 무제한 |

> 제한에 걸리는 화면에서 "뭘 사면 풀리나?" 계산 없도록: 항상 "프리미엄에서 무제한" 한 문장으로 안내.
> 스텝 7 무료 7개: 50개 중 14% 완료 후 페이월 → Zeigarnik Effect(미완성 과제 완료 욕구) 발동.
> 1:1 대화 7회: 대화가 활발한 중간 지점에서 막혀야 "더 하고 싶다"는 욕구가 강함. 런치 후 Mixpanel로 10회 vs 7회 전환율 비교 필수.

### Google Play Billing 요금제 (Android 앱 내 모든 결제)

**결제 화면 표시 순서 (앵커링 + 디코이 효과)**:
비싼 것 → 싼 것 순서로 표시해야 나머지가 저렴하게 느껴진다.

```
① 연간 플랜 ★ MOST POPULAR
   $39.99/년 · 월 $3.33
   "N개월 무료" (월간 대비 절약 개월 수로 표현)

② 월간 플랜
   $4.99/월 · 언제든 해지 가능
```

> "~33% 할인" 표현 대신 "N개월 무료"로 통일 — 무료라는 단어가 전환율을 높임 (Amazon Prime, Spotify 동일 원칙).

| 플랜 | 가격 | 포함 내용 |
|------|--------------|----------|
| 연 구독 (자동갱신) ★ | $39.99/년 (월 $3.33) | 50동사 전체 + 무제한 브로드캐스트/대화/AI 피드백. "N개월 무료" 강조 |
| 월 구독 (자동갱신) | $4.99/월 | 위와 동일. "언제든 해지 가능" 강조 |
| 대화 팩 (소비성) | $1.99/10회 | 1:1 대화 추가 10회 |
| 일일 브로드캐스트 패스 (소비성) | $1.99/1일 무제한 | - |
| Early Bird Lifetime | $29 (일회성) | 월 구독 무제한 영구. `subscription_type = 'lifetime'` |

> Google Play Billing: 구독 15% 수수료 (첫 해부터 적용). 실수령 월 $4.24.
> Stripe는 2차 Web 버전에서만 사용.

**소비성 IAP → 구독 전환 유도**:
- 대화 팩 구매 직후: "대화 팩 $1.99 × 5번 = $9.95/월 vs 구독 $4.99/월. 구독이 2배 저렴해요" 비교 카드 표시
- 일일 브로드캐스트 패스 2회 이상 구매 시: "이번 달에 $X 쓰셨어요. 구독하면 $4.99로 매일 무제한이에요" 메시지 자동 발송 (payments 테이블에서 서버 사이드 조건 체크)

### 페이월 트리거 시나리오

> **원칙**: 벽에 막혔을 때(좌절 전환)보다 감정적 정점에서 보여주는 게 전환율이 높다.
> 소진 트리거는 0이 되기 전 선제 안내를 병행해야 이탈을 막는다.

| 상황 | 사용자 감정 | 트리거 | CTA |
|------|------------|--------|-----|
| 6스텝 완료 직후 | 성취감 최고조 | 소통 탭 활성화 화면 | "무제한 소통 시작하기" + 구독 화면 |
| **스트릭 7일 달성** ★ | 습관 형성 확신 | 달성 축하 화면 하단 | "7일 연속 학습자의 78%는 프리미엄으로 목표를 완주했어요" + 구독 CTA |
| **브로드캐스트 첫 답장 수신** ★ | "세상에 닿았다" | 답장 알림 → 앱 오픈 + 오늘 3회 이상 사용 조건 동시 충족 시 | "오늘 이미 N개를 올렸어요. 프리미엄에서 무제한으로." |
| 1:1 대화 잔여 2회 (선제 안내) | 관계 유지 욕구 | 스레드 상단 카드 (자동, 0되기 전) | "이 대화, 2번 더 말할 수 있어요. 계속 이어가고 싶다면?" |
| 1:1 대화 전량 소진 | 차단감 | 답장 버튼 탭 | "이 대화를 계속하려면 프리미엄으로" |
| 브로드캐스트 5회 소진 | 좌절 (선택 아키텍처로 완화) | 전송 버튼 탭 | "오늘 이미 5개를 올렸어요. 내일까지 기다리거나, 지금 바로 계속하거나." |
| AI 피드백 5회 소진 | 아쉬움 | "AI 피드백 받기" 버튼 탭 | "오늘 AI 피드백 소진. 구독하면 무제한" |
| 스텝 7 (8번째 동사) | 완료 욕구 (Zeigarnik) | 진입 시 | "50동사 중 7개 완료. 나머지 43개는 프리미엄에서" |
| 소비성 IAP 구매 직후 | 구매 의향 확인됨 | 결제 완료 직후 | "팩 5번 구매 = 월 $9.95. 구독은 $4.99. 지금 전환하면 더 저렴해요." |
| 7일 체험 만료 4일째 | 습관 형성 중 | 푸시 알림 | "벌써 4일 연속 학습 중이에요. 남은 체험 3일, 소통 탭을 꼭 써보세요." |
| 7일 체험 만료 6일째 | 손실 예상 | 푸시 알림 | "이번 주 브로드캐스트 N개, 대화 N회. 내일이면 이 모든 게 멈춰요." (개인화) |
| 7일 체험 만료 후 재진입 | 상실감 | Realtime 감지 → 즉시 잠금 | "체험 종료. 계속하려면 구독" |

**7일 무료 체험** (기존 3일 → 연장):
- 3일은 스텝 2~3까지밖에 못 감 → 소통 탭 경험 불가 → 핵심 가치 미경험 → 전환 불가
- 7일이면 스텝 4~5 + 소통 탭 읽기 전용 미리보기 경험 가능 → 가치 체감 후 결제
- 중간 알림 2회 필수 (4일째, 6일째)

**구독 화면 사회적 증거** (하드코딩, 서버 불필요):
- "지금 [언어] 학습자 N명이 프리미엄으로 학습 중" (런치 초기 수동 작성)
- 베타 테스터 후기 1~2개 + 별점 (Google Play Store 리뷰 쌓이기 전까지 베타 피드백 기반)

---

## 8. 보안 체크리스트

- [ ] Supabase RLS 전 테이블 적용
- [ ] DB 트리거: `voice_messages` INSERT 시 `moderation_status = 'pending'` 강제
- [ ] Google Play 영수증 서버 사이드 검증 (`google-play-verify` Edge Function)
- [ ] Stripe 웹훅 서명 검증: `constructEvent()` 필수
- [ ] OpenAI API 키: Edge Function 환경 변수에만 저장
- [ ] Storage: private bucket + `get-signed-url` Edge Function으로만 발급
- [ ] Rate Limiting: `user_id` (JWT `sub`) 기반. IP 기반 금지
- [ ] 개인정보 처리방침: 온보딩에서 음성 데이터 수집/보관/처리 동의
- [ ] 연령 확인: 온보딩에서 "13세 이상" 체크박스 (COPPA 최소 대응)
- [ ] `subscription_type = 'lifetime'` 사용자는 웹훅 만료 처리에서 예외 처리

---

## 9. 비용 예측 (100명 활성 사용자, 보수적 추정)

| 항목 | 월 예상 비용 | 비고 |
|------|-------------|------|
| Supabase Pro | $25 | DB + Storage + Edge Functions. pg_cron 포함 |
| OpenAI Whisper (STT) | $90~150 | 100명 × 5~8분/일 × 30일 × $0.006/분 |
| OpenAI GPT-4o-mini (피드백) | $10~25 | 선택적 호출이라 절감. 일 5회 무료 제한 적용 |
| OpenAI TTS (초기 1회 생성) | $20~50 | 약 500~1,000개 파일 사전 생성 (반복 없음) |
| OpenAI Moderation | $5~10 | 브로드캐스트 메시지당 소액 |
| Storage bandwidth | $5~15 | 9GB/월 × $0.09/GB + 여유분 |
| Sentry | $0 | 무료 티어 |
| Mixpanel | $0 | 무료 티어 (1,000 MTU) |
| Google Play Console | $1 | $25 일회성 환산 |
| **합계** | **$163~283/월** | - |

> ⚠ OpenAI 사용량 급증 방어:
> - 1인당 일일 STT 처리 상한: 30분 (Edge Function에서 user_daily_stats 체크)
> - 학습 TTS는 사전 생성 파일 재사용 (API 반복 호출 없음)
> - AI 피드백은 사용자가 명시적 요청 시에만 호출

**Break-even**: 월 구독($4.99) Google Play 15% 수수료 후 실수령 $4.24. 약 39~67명 유료 전환 시 손익분기.
초기 50명 Early Bird Lifetime $29 판매 시: $1,450 일회성 수입으로 3~5개월 운영 가능.

---

## 10. MVP 구현 로드맵 (3주)

### Week 1: 기반 셋업 + 학습 탭 핵심

**Day 1-2: 인프라**
- [ ] Supabase 프로젝트 생성 (us-east-1)
- [ ] **pg_cron 활성화** (Dashboard → Database → Extensions → pg_cron)
- [ ] 스키마 전체 마이그레이션 (신규 테이블 포함: user_daily_stats, user_level_quiz)
- [ ] DB 트리거 설정 (`enforce_moderation_pending`)
- [ ] RLS 정책 설정
- [ ] Storage 버킷 생성 (voice-recordings: private, avatars: public)
- [ ] Expo 프로젝트 생성 (`create-expo-app --template blank-typescript`)
- [ ] Supabase + react-native-iap 설치 및 초기화

**Day 3-4: 인증 + 온보딩**
- [ ] 이메일 회원가입/로그인
- [ ] 온보딩: 플래그 리스트로 Native 언어 선택 → 학습 언어 선택 → 레벨 퀴즈 5문항
- [ ] `onboarding_step` DB 저장 (재진입 복원)
- [ ] `users.timezone` 자동 감지 저장

**Day 5-7: 학습 탭**
- [ ] 스텝 목록 (레벨 기반 시작점 적용, 잠금/완료/복습 상태)
- [ ] 스크립트 뷰 + TTS 재생 (Storage signed URL, 실패 fallback UI)
- [ ] 음성 녹음 (AppState 리스너, 60초 카운트다운)
- [ ] `stt-transcribe` Edge Function (confidence score 반환)
- [ ] `ai-feedback` Edge Function (선택적 호출)
- [ ] 1회 시도 = 완료 처리 + 스트릭/포인트 낙관적 업데이트
- [ ] 스크립트 콘텐츠 로컬 캐싱 (오프라인 읽기)

### Week 2: 소통 탭 + 결제

**Day 8-10: 소통 탭**
- [ ] 3스텝 → 읽기 전용 미리보기. 6스텝 → 전체 활성화 로직
- [ ] 소통 탭 잠금 화면 (Ori + 진행도)
- [ ] 보이스메일 녹음 + "AI 피드백 받기" 버튼
- [ ] `moderation` Edge Function + DB 트리거 연동
- [ ] 브로드캐스트 상태 UI ("검토 중..." → "게시됨" / "게시 불가")
- [ ] 브로드캐스트 피드 (스켈레톤 로딩, Empty State, 전역 오디오 플레이어)
- [ ] `get-signed-url` Edge Function + 재생 시 호출
- [ ] 1:1 대화 + `send_conversation_message` RPC + "X회 남음" 표시
- [ ] Realtime: 새 메시지 알림 + is_premium 변경 감지 (cleanup 포함)
- [ ] **Cold Start용 시드 콘텐츠 생성** (언어당 10개 이상 브로드캐스트 메시지 수동 등록)

**Day 11-12: 결제 (Google Play Billing)**
- [ ] Google Play Console → 인앱 상품 등록 (구독 2개, 소비성 2개)
- [ ] `react-native-iap` 구독 + 소비성 구매 플로우
- [ ] `google-play-verify` Edge Function (Google Play 영수증 서버 검증)
- [ ] `sync-subscription` Edge Function (앱 실행 시 상태 동기화)
- [ ] `subscription_type` 별 is_premium 업데이트 (Lifetime 예외 처리 포함)
- [ ] 페이월 트리거 12개 시나리오 구현 (선제 안내 카드 + 감정적 정점 트리거 포함)
- [ ] 소비성 IAP 구매 직후 구독 비교 카드 표시 로직
- [ ] 7일 체험 중간 알림 (4일째·6일째) 개인화 문구 세팅

**Day 13-14: 프로필 + 설정**
- [ ] 프로필 (학습 언어 변경 확인 팝업, 언어별 진행도 독립 저장)
- [ ] 구독 관리 (Google Play Billing 복원 포함)
- [ ] 알림 설정 (푸시 빈도 조절)

### Week 3: 테스트 + 배포

**Day 15-17: 테스트**
- [ ] Front QA 체크리스트 12개 항목 전수 테스트
- [ ] Back QA 우선순위 1~7번 항목 검증
- [ ] Google Play 내부 테스트 베타 (친구 5~10명)
- [ ] OpenAI 비용 모니터링 (일일 상한선 동작 확인)
- [ ] Cold Start 시드 콘텐츠 충분한지 확인

**Day 18-19: 마케팅 소재**
- [ ] 데모 영상 20~40초 (TikTok/X)
- [ ] Google Play Store 스크린샷 + 설명문 (7개 언어 지원 강조)
- [ ] Early Bird Lifetime $29 랜딩 페이지 (간단한 웹페이지)

**Day 20-21: 배포**
- [ ] EAS Build (Android Production AAB)
- [ ] Google Play Store 심사 제출
- [ ] 런치 당일 소셜 포스팅 + Early Bird 공지

---

## 11. UX 규칙 (개발 중 공통 기준)

### 로딩 상태
- 피드 / 목록 화면: 스켈레톤 UI
- 버튼 액션 처리 중: 버튼 내 스피너 (버튼 비활성화)
- 모더레이션 대기: "검토 중..." 전용 상태 화면

### 에러 상태
- 네트워크 오프라인: 배너 + "연결을 확인해주세요" + 재시도 버튼
- STT 타임아웃 (10초): "음성 인식에 실패했습니다" + "다시 시도" 버튼
- TTS 파일 로드 실패: 에러 아이콘. 텍스트만으로 진행 가능
- OpenAI 전체 장애: STT 실패 → 위와 동일. 모더레이션 실패 → 재시도 큐 등록 (사용자에게 "잠시 후 자동으로 처리됩니다" 안내)

### Ori 캐릭터 등장 (정적 PNG, MVP)
1. 온보딩 환영 화면
2. 스텝 완료 축하 화면
3. 소통 탭 잠금 화면 (진행도 표시)
4. 브로드캐스트 피드 / 대화 목록 Empty State

### 푸시 알림 시점

**권한 요청 타이밍**: 첫 보이스메일 답장 수신 시 ("답장이 왔어요! 알림을 켜면 바로 확인할 수 있어요")
- 앱 실행 직후 요청 금지 (업계 거부율 40~60%)

**알림 시나리오 전체**:

| 시점 | 문구 방향 | 목적 |
|------|----------|------|
| 스트릭 5일 달성 | "5일 연속 학습 중. 7일 달성하면 특별 배지." | 7일 페이월 트리거 포인트로 유인 |
| 스트릭 7일 달성 | "7일 연속! 이 습관을 프리미엄으로 지키세요." | 구독 전환 (감정적 정점) |
| 브로드캐스트에 첫 외국인 답장 | "[언어] 원어민이 답장했어요." | 즉시 앱 재오픈 → 감정 정점 페이월 |
| 3일 앱 미사용 (무료 사용자) | "N일 스트릭이 위험해요. 지금 돌아오세요." | 이탈 방지 |
| 무료 사용자 D14 | "이번 달 N개 학습 완료. 스텝 7까지 가면 어디서든 자유롭게 말할 수 있어요." | 성취 요약 → 동기 부여 |
| 7일 체험 4일째 | "벌써 4일 연속 학습 중. 남은 체험 3일, 소통 탭을 꼭 써보세요." | 핵심 기능 경험 유도 |
| 7일 체험 6일째 | "이번 주 브로드캐스트 N개, 대화 N회. 내일이면 이 모든 게 멈춰요." (개인화) | 손실 회피 (Loss Aversion) |
| 스트릭 유지 알림 | 오늘 학습 안 했을 때 1회 | 사용자가 설정에서 빈도 조절 가능 |

---

## 12. 2차 로드맵 (런치 후)

| 우선순위 | 기능 | 이유 |
|---------|------|------|
| P1 | 세계 지도 UI 언어 추가 (온보딩) | 지원 언어 확장 시 SVG 지도에 신규 국가 Path 추가 |
| P1 | 스트릭 챌린지 (커뮤니티) | Retention |
| P1 | iOS 배포 | Android 안정화 후 추가. react-native-iap iOS 브랜치 활성화 |
| P2 | Web 버전 (Vercel + Stripe) | 설치 허들 제거 + 스토어 수수료 우회 |
| P2 | 상대방 상세 프로필 | 소통 신뢰도 향상 |
| P2 | AI 실시간 대화 연습 (GPT-4o) | 유료 프리미엄 기능 |
| P3 | 오프라인 큐 (보이스메일 예약 전송) | 지하철 사용자 |
| P3 | 멀티 언어 동시 학습 UI | 파워 유저 |
| P3 | Supabase Read Replicas | 10만 유저 이후 |

---

## 13. 핵심 KPI

| 지표 | 목표 (런치 후 1개월) |
|------|---------------------|
| 다운로드 | 500+ |
| 유료 전환율 | 5% (약 25명) |
| D7 리텐션 | 30%+ |
| 6스텝 완료율 | 40%+ (온보딩 완료 기준) |
| 소통 탭 첫 브로드캐스트 | 6스텝 완료자의 60%+ |
| Early Bird Lifetime 판매 | 50명 |

---

## 14. 개발 원칙

- **단순함 우선**: Supabase 클라이언트 직접 사용. GraphQL, Redis는 필요할 때.
- **Google Play Billing 필수**: Android 앱 내 디지털 결제는 Google Play Billing 외 불가. 위반 시 심사 거절.
- **모더레이션은 서버 사이드 전용**: DB 트리거로 강제. 클라이언트 우회 불가 구조.
- **음성 비용 통제**: STT 상한선 + AI 피드백 명시적 요청 시에만 호출.
- **Lifetime 예외 처리**: `subscription_type = 'lifetime'`은 모든 만료 로직에서 제외.
- **빠른 배포 > 완벽한 코드**: 기능과 결제가 돌아가는 게 우선.
