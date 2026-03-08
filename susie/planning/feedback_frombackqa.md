# Backend QA 피드백 — final-plan.md

> 작성일: 2026-03-05
> 역할: 백엔드 QA 전문가
> 기준: final-plan.md 실행 시 발생 가능한 문제 전수 분석

---

## 심각도 기준

- **[CRITICAL]** : 서비스 불가 또는 App Store 거절 유발
- **[HIGH]** : 보안 취약점 또는 결제 데이터 손실 가능
- **[MEDIUM]** : 기능 오작동 또는 사용자 경험 심각 저하
- **[LOW]** : 성능 저하 또는 운영 비효율

---

## 1. 결제 / IAP

### [CRITICAL] iOS에서 Stripe로 IAP 처리 불가
**위치**: 섹션 7 요금제 — "대화 팩 (IAP)", "일일 브로드캐스트 패스 (IAP)"

Apple App Store 가이드라인(3.1.1)에 따라 iOS 앱 내에서 디지털 콘텐츠/기능 판매 시 반드시 Apple In-App Purchase를 사용해야 한다. Stripe로 처리하면 **심사 거절** 확정이다.

**영향**: MVP 자체가 App Store 심사를 통과하지 못함.

**해결**: 소비성 IAP(`대화 팩`, `일일 패스`)는 `expo-in-app-purchases` 또는 `react-native-iap`로 Apple IAP 처리. Stripe는 구독(월/연)에 한해 웹 결제로만 사용 가능하며, 이 경우에도 앱 내에서 결제 UI를 보여주면 안 된다(외부 링크로만 유도 가능).

---

### [HIGH] Stripe 웹훅 미수신 시 premium 상태 미복구 로직 없음
**위치**: 섹션 6 Edge Functions — `stripe-webhook`

웹훅 전달이 실패하면 Stripe는 재시도하지만, 이 사이에 사용자의 `is_premium`이 갱신되지 않아 유료 사용자가 무료 제한에 걸린다. 반대로, 구독 취소 웹훅을 놓치면 무료 사용자가 계속 프리미엄 상태로 남는다.

**해결**: 앱 실행 시마다 Stripe Customer Portal API 또는 subscription status를 직접 조회해 DB와 동기화하는 서버 함수 추가 필요.

---

### [HIGH] Early Bird Lifetime Deal 구현 미정의
**위치**: 섹션 7 — "첫 50명 유료 사용자에게 Lifetime Deal $29"

`is_premium` boolean 컬럼으로는 영구 플랜과 구독 플랜을 구분할 수 없다. 구독이 만료되면 Stripe 웹훅이 `is_premium = false`로 덮어쓸 위험이 있다.

**해결**: `users` 테이블에 `subscription_type ENUM('free', 'monthly', 'annual', 'lifetime')` 컬럼 추가. Lifetime 사용자는 웹훅에서 만료 처리 대상에서 제외하는 조건 필요.

---

### [MEDIUM] 3일 무료 체험 만료 웹훅 이벤트 미처리
**위치**: 섹션 7 — "3일 무료 체험"

`customer.subscription.trial_will_end`, `customer.subscription.updated` 이벤트를 처리하지 않으면 체험 만료 후에도 `is_premium = true` 상태가 유지될 수 있다.

---

## 2. 보안

### [HIGH] 모더레이션을 클라이언트에서 invoke — 우회 가능
**위치**: 섹션 6 Edge Functions 표 — `moderation` 트리거: "클라이언트 invoke (브로드캐스트 전)"

클라이언트가 `moderation` Edge Function을 호출하지 않고 직접 `voice_messages` 테이블에 `moderation_status = 'approved'`로 INSERT하면 필터링을 완전히 우회할 수 있다.

**해결**: `voice_messages` 테이블에 INSERT 시 DB 트리거 또는 RLS 정책으로 `moderation_status`를 강제로 `'pending'`으로 고정. 모더레이션은 서버 사이드(DB 트리거 → Edge Function 비동기 호출)에서만 처리해야 한다.

---

### [HIGH] 음성 파일 Signed URL 1시간 만료 — 피드 UX 파괴
**위치**: 섹션 8 — "signed URL (만료 시간 1시간)"

브로드캐스트 피드에서 오래된 메시지를 재생하거나, 앱을 백그라운드에 뒀다가 돌아왔을 때 URL이 만료되어 재생 불가. 클라이언트에서 매번 새로운 signed URL을 요청해야 한다.

**해결**: `voice_messages` 테이블에 파일 경로(`storage_path`)만 저장하고, 재생 시점에 서버에서 signed URL을 동적으로 발급하거나, 만료 시간을 24시간으로 조정.

---

### [MEDIUM] Rate Limiting을 IP 기반으로 구현 — 모바일 환경 부적합
**위치**: 섹션 8 — "Rate Limiting: Edge Function 레벨에서 IP 기반"

모바일 사용자는 NAT 뒤에 있어 여러 사용자가 동일 IP를 공유한다. IP 기반 Rate Limit은 정상 사용자를 차단하거나, 반대로 동일 IP의 공격을 막지 못한다.

**해결**: `user_id` 기반 Rate Limit으로 변경. Supabase Edge Function에서 JWT 토큰의 `sub`(user ID)로 Redis(Upstash) 또는 Supabase `rate_limit_log` 테이블로 카운트.

---

## 3. 데이터베이스 / 스키마

### [HIGH] 모더레이션 타임아웃 시 메시지 영구 'pending' 상태
**위치**: 섹션 5-2 — `moderation_status DEFAULT 'pending'`

모더레이션 Edge Function이 실패하거나 OpenAI API가 응답하지 않으면 메시지가 `'pending'` 상태로 영구히 묶인다. 사용자 입장에서는 보내진 것 같지만 피드에 노출되지 않아 혼란 발생.

**해결**:
- `moderation_checked_at`이 일정 시간(예: 5분) 경과 후에도 여전히 `'pending'`이면 재시도하는 cron 추가.
- 실패 시 `'failed'` 상태로 전환하고 사용자에게 알림.

---

### [HIGH] `check_conversation_limit` — 동시성 레이스 컨디션
**위치**: 섹션 5-3 — `check_conversation_limit(p_user_id, p_other_user_id) RETURNS BOOLEAN`

함수가 BOOLEAN을 반환하고 클라이언트가 이를 체크한 후 INSERT하는 구조라면, 동시 요청 시 두 요청 모두 `TRUE`를 받고 동시에 INSERT할 수 있다 (TOCTOU 문제).

**해결**: 함수 내에서 체크와 INSERT를 하나의 트랜잭션으로 처리 (`SELECT ... FOR UPDATE` 또는 DB 레벨 `INSERT ... WHERE count < 10`).

---

### [MEDIUM] 인덱스 정의 없음 — 피드 쿼리 성능 미보장
**위치**: 섹션 6 — `voice_messages` 피드 조회

```sql
.eq('broadcast_status', 'broadcasted')
.eq('moderation_status', 'approved')
```

이 쿼리는 `broadcast_status`, `moderation_status`, `created_at` 복합 인덱스 없이는 full table scan이 발생한다. 초기에는 무관하지만 수천 건 이후 심각한 성능 저하.

**해결**: 스키마 마이그레이션에 인덱스 명시적 추가:
```sql
CREATE INDEX idx_voice_messages_feed ON voice_messages(broadcast_status, moderation_status, created_at DESC);
```

---

### [MEDIUM] `daily_voice_broadcasts_count` 컬럼 위치 미정의
**위치**: 섹션 5-1, 5-3 — `reset_daily_broadcast_limit()` 참조

`daily_voice_broadcasts_count`가 어느 테이블에 존재하는지 스키마 섹션에 명시되지 않았다. `users` 테이블에 있다고 가정되나, 이 경우 `users` 테이블에 UPDATE가 빈번하게 발생해 쓰기 경합 문제가 생길 수 있다.

**해결**: 별도 `user_daily_stats` 테이블로 분리하거나 컬럼 위치를 명시.

---

### [MEDIUM] 스트릭 업데이트의 타임존 미처리
**위치**: 섹션 5-3 — `update_user_streak(p_user_id UUID)`

UTC 기준 자정에 날짜가 변경되므로, 한국(UTC+9) 사용자가 오전 8시 55분에 학습해도 UTC 기준 전날로 기록될 수 있다. 도쿄 사용자가 밤 11시에 학습하면 다음 날 계산이 틀려 스트릭이 끊긴다.

**해결**: `users` 테이블에 `timezone` 컬럼 추가. 스트릭 계산 시 사용자 로컬 날짜 기준으로 비교.

---

### [LOW] 소프트 삭제(Soft Delete) 전략 없음

사용자 계정 삭제 또는 보이스메일 삭제 시 관련 데이터(대화 스레드, 음성 파일)의 처리 방식이 정의되지 않았다. GDPR 삭제 권리(Right to Erasure) 이행 시 어떤 데이터를 어떻게 지울지 구현 기준 없음.

---

## 4. Edge Functions / AI

### [MEDIUM] `stt-feedback` — STT와 GPT 피드백이 단일 함수에 결합
**위치**: 섹션 6 — `stt-feedback: 음성 URL → Whisper STT → GPT-4o-mini 피드백 → JSON 반환`

Whisper API 실패 시 GPT 피드백도 함께 실패하며, 어떤 단계에서 실패했는지 클라이언트가 알 수 없다. Deno Edge Function의 실행 제한(최대 150초)을 초과하면 타임아웃 발생.

**해결**: Whisper STT 결과를 먼저 DB에 저장하고, GPT 피드백은 별도 비동기 처리로 분리. 각 단계의 오류를 독립적으로 핸들링.

---

### [MEDIUM] 학습 TTS 사전 생성 비용 및 Storage 계획 없음
**위치**: 섹션 4 — "OpenAI TTS: 학습 스크립트 AI 음성 (사전 생성 후 Storage에 저장)"

7개 언어 × 6스텝 × 스크립트 수 = 수백~수천 개 음성 파일. TTS 사전 생성 비용, Storage 용량 계획, 언어 추가 시 재생성 프로세스가 섹션 9 비용 예측에 누락되어 있다.

---

### [MEDIUM] OpenAI API 다운 시 폴백 없음

Moderation, STT, 피드백 생성 모두 OpenAI에 의존한다. OpenAI API 장애 시:
- 모더레이션 불가 → 브로드캐스트 전체 불가
- STT 불가 → 학습 탭 음성 입력 불가

**해결**: 최소한 모더레이션 실패 시 메시지를 `'pending'`으로 유지하되 재시도 큐에 넣는 로직 필요. 학습 탭은 STT 실패 시 "잠시 후 다시 시도" 안내 UX 필요.

---

### [MEDIUM] Whisper STT 다국어 정확도 편차 미반영

중국어(간체/번체), 일본어는 Whisper 오류율이 영어 대비 높다. 오인식된 텍스트로 GPT 피드백이 생성되면 품질이 크게 저하된다.

**해결**: STT 결과에 `confidence score` 임계값(예: 0.7 이하) 설정. 낮은 경우 "다시 녹음" 유도 UX 추가.

---

## 5. 실시간 / 네트워킹

### [MEDIUM] Realtime 채널 구독 해제 로직 미정의
**위치**: 섹션 6 — `supabase.channel('conv-{id}')`

사용자가 여러 대화를 오가면 채널 구독이 누적된다. 화면을 벗어날 때 `.unsubscribe()` 호출이 없으면 메모리 누수 및 불필요한 WebSocket 연결 유지.

**해결**: React Native 화면의 `useEffect` cleanup에서 채널 구독 해제 반드시 명시.

---

### [LOW] Supabase Realtime 동시 연결 수 제한
**위치**: 섹션 4 — Realtime WebSocket

Supabase Pro 기준 동시 Realtime 연결 500개. 활성 사용자 100명이 각각 복수의 대화를 열면 연결 수가 빠르게 소진될 수 있다.

---

## 6. 비용 / 운영

### [MEDIUM] OpenAI 비용 과소 추정 가능성
**위치**: 섹션 9 — "Whisper: $30~60/월"

Whisper 요금: $0.006/분. 100명 × 5분/일 × 30일 = 15,000분 × $0.006 = **$90/월**.
계획의 $30~60 추정치는 하한선 기준으로 과소 추정. 소통 탭 보이스메일 STT까지 합산하면 $150+ 가능.

---

### [LOW] Storage 비용 누락
**위치**: 섹션 9 비용 예측

100명 × 3 브로드캐스트/일 × 60초 ≈ 하루 약 300MB 음성 파일 축적. 30일 기준 ~9GB. Supabase Pro 포함 Storage는 100GB이나 월별 bandwidth가 $0.09/GB이며, 이 비용이 예측에 없다.

---

### [LOW] pg_cron 의존성 명시 없음
**위치**: 섹션 5-3 — `reset_daily_broadcast_limit() -- cron via pg_cron`

pg_cron은 Supabase Pro에서 활성화 가능하나 기본 활성화 상태가 아니다. Day 1-2 인프라 설정 단계에 pg_cron 활성화 항목이 누락되어 있다.

---

## 7. 비즈니스 로직

### [MEDIUM] 스텝 "완료" 기준 미정의
**위치**: 섹션 3-1, 섹션 6 — 소통 탭 잠금 해제 조건

"6스텝 완료"가 무엇을 의미하는지 정의 없음: 스텝 내 모든 스크립트 통과? 최소 점수 이상? 한 번만 시도해도 완료?

`user_lesson_progress` 테이블에 어떤 값이 기록될 때 잠금 해제 트리거가 발동되는지 스키마 및 함수 레벨에서 명시 필요.

---

### [MEDIUM] 레벨 퀴즈 결과 활용 로직 미정의
**위치**: 섹션 2, 3-1 — "레벨 간단 퀴즈 3문항 (초급/중급 판별, 스크립트 추천용)"

퀴즈 결과가 어떻게 스크립트 추천에 반영되는지 DB 설계에 없음. `lesson_scripts` 테이블에 `level` 컬럼이 있는지, 사용자 레벨에 따라 어떤 스크립트를 보여줄지 로직 미구현.

---

### [LOW] 미성년자 보호 / COPPA 고려 없음

7개 언어 대상 글로벌 앱에서 13세 미만 사용자 접근 시 COPPA(미국), GDPR-K(EU) 위반 가능. 온보딩에 생년월일 입력 또는 연령 확인 단계 없음.

---

## 요약 — 우선순위 수정 목록

| 순위 | 항목 | 심각도 |
|------|------|--------|
| 1 | iOS IAP를 Stripe로 처리 → Apple IAP로 교체 | CRITICAL |
| 2 | 모더레이션 클라이언트 invoke → 서버 사이드 트리거로 변경 | HIGH |
| 3 | Stripe 웹훅 미수신 시 premium 동기화 로직 추가 | HIGH |
| 4 | Early Bird Lifetime 플랜 DB 컬럼 및 웹훅 예외 처리 | HIGH |
| 5 | `check_conversation_limit` 레이스 컨디션 수정 | HIGH |
| 6 | `moderation_status` pending 타임아웃 재시도 로직 | HIGH |
| 7 | 음성 파일 Signed URL 만료 전략 수정 | HIGH |
| 8 | Rate Limit을 user_id 기반으로 변경 | MEDIUM |
| 9 | 피드 쿼리 복합 인덱스 추가 | MEDIUM |
| 10 | 스트릭 타임존 처리 | MEDIUM |
| 11 | `stt-feedback` 단계별 오류 분리 | MEDIUM |
| 12 | OpenAI 비용 재추정 ($90+/월 Whisper 기준) | MEDIUM |
| 13 | pg_cron 활성화를 Day 1 셋업 체크리스트에 추가 | LOW |
