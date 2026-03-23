# Day 9 피드백 — 로그인 후 학습/소통 탭 무한로딩 진단

작성일: 2026-03-23
상태: 원인 파악 완료 (수정 전)

---

## 증상

- 앱 설치/실행/로그인 성공
- 프로필 화면은 진입 가능
- 학습 탭, 소통 탭은 로딩 스피너가 계속 유지됨

즉, **인증은 되지만 탭 데이터 로드 루프에서 빠져나오지 못하는 상태**.

---

## 1차 원인 후보 (우선순위 순)

## 1) 소통 탭 컬럼명 불일치 (가장 유력)

현재 소통 탭 쿼리에서 `voice_messages.user_id`를 조회/필터링하고 있음.

- 사용 코드: [app/(tabs)/community.tsx](app/(tabs)/community.tsx#L36-L51)
- 실제 스키마: `voice_messages.sender_id`
  - 확인: [supabase/migrations/004_voice_messages.sql](supabase/migrations/004_voice_messages.sql#L9-L10)

영향:
- 쿼리 에러 또는 빈 데이터 처리 비정상 가능
- 본인 게시물 필터(`or(...)`)도 `user_id` 기준이라 로직이 어긋남

필수 수정:
- `user_id` → `sender_id`로 전면 교체
  - select 필드
  - OR 필터
  - 아이템 타입 필드
  - UI에서 current user 비교 필드

---

## 2) 로딩 종료 보장이 없음 (try/catch/finally 부재)

두 탭 모두 `loading=true`로 시작하지만, 예외 발생 시 `false`로 내려가지 못하는 경로가 있음.

- 학습 탭: [app/(tabs)/learn.tsx](app/(tabs)/learn.tsx#L113-L181)
- 소통 탭: [app/(tabs)/community.tsx](app/(tabs)/community.tsx#L303-L309)

현재 문제:
- `await` 체인 중 예외 발생하면 로딩 상태가 유지될 수 있음
- 에러 UI/재시도 버튼이 없어 원인 파악이 어려움

필수 수정:
- `loadData()` 및 `fetchBroadcasts` 호출부에 `try/catch/finally` 적용
- `finally`에서 무조건 `setLoading(false)`
- `error` 상태를 화면에 표시

---

## 3) 소통 탭 게이트가 하드코딩됨

- `COMPLETED_STEPS = 6` 고정으로 항상 FullView 진입
- 위치: [app/(tabs)/community.tsx](app/(tabs)/community.tsx#L10-L11)

영향:
- 실제 진행도와 무관하게 네트워크 호출 강제
- 장애 상황에서 사용자에게 무한로딩 체감이 커짐

권장 수정:
- 실제 `user_lesson_progress` 집계로 상태 계산
- 집계 실패 시 `preview`로 안전 폴백

---

## 4) 학습 탭도 예외 시 복구 UI 없음

학습 탭은 여러 쿼리를 연속 실행함:
- `users` 조회
- `lessons` 조회
- `lesson_scripts` / `user_lesson_progress` 병렬 조회

중간 실패 시 사용자에게 에러 안내가 없고 스피너만 보여줄 위험이 큼.

권장 수정:
- 실패 시 빈 상태 + “다시 시도” 버튼 제공
- 쿼리별 에러 로그(`console.error`) 추가

---

## 5) 프로필 "학습 언어 변경"이 항상 잠김 문구를 표시함 (별도 버그)

증상:
- 온보딩 완료 사용자(`onboarding_step = 3`)인데도
- 프로필에서 "학습 언어 변경" 클릭 시 항상 "온보딩 완료 후 이용 가능합니다." 알럿 표시

원인:
- 현재 버튼 핸들러가 DB 상태를 보지 않고 고정 알럿만 띄움
- 확인 코드: [app/profile/index.tsx](app/profile/index.tsx#L102-L107)

판단:
- 이 이슈는 "학습/소통 무한로딩"과 별개지만,
- **사용자 상태 불일치(이미 완료인데 잠금 메시지 표시)**라는 점에서 반드시 수정 대상

필수 수정:
- 프로필 진입 시 `users.onboarding_step` 조회
- `onboarding_step >= 3`이면 언어 변경 플로우 진입
- `< 3`이면 현재 알럿 유지

권장 구현:
- 언어 변경 라우트(예: `/profile/language`) 추가
- 변경 전 확인 모달: "언어별 진행도는 독립 저장됩니다"
- 변경 후 `users.learning_language_id` 업데이트 + 학습/소통 탭 리프레시

---

## 즉시 수정 체크리스트 (실행 순서)

1. **community 컬럼명 정합성 수정** (`user_id` → `sender_id`)
2. **learn/community 로딩 종료 보장** (`finally` 적용)
3. **에러 상태 UI 추가** (한 줄 메시지 + 재시도 버튼)
4. **COMPLETED_STEPS 하드코딩 제거**
5. **프로필 학습 언어 변경 잠금 로직 수정** (`onboarding_step` 기반 분기)
6. APK 재빌드 후 재검증

---

## 재검증 시나리오

1. 로그인
2. 학습 탭 진입
   - 로딩 3초 내 종료
   - 데이터 있으면 카드 표시, 없으면 빈 상태 표시
3. 소통 탭 진입
   - 로딩 종료 후 피드/빈상태 중 하나 표시
4. 프로필 진입 후 다시 학습/소통 복귀
   - 무한로딩 재발 없어야 함
5. 프로필 > 학습 언어 변경 클릭
   - 온보딩 완료 계정: 변경 플로우 진입
   - 미완료 계정: 잠금 알럿 표시

---

## AI 병렬 작업 할당안 (역할 포함)

아래 3개는 파일 충돌이 작아서 병렬 진행 가능.

### AI #1 — Community 데이터/RLS 정합성 담당

역할:
- **Supabase + RN 데이터 정합성 엔지니어**

담당 범위:
- [app/(tabs)/community.tsx](app/(tabs)/community.tsx)에서 `user_id` → `sender_id` 교체
- 본인글 필터 `or(...)` 로직 수정
- fetch 실패 시 빈 배열 + 에러 상태 처리

완료 기준:
- 소통 탭 진입 시 무한로딩 없음
- 본인 pending/rejected가 의도대로 보임

---

### AI #2 — Learn/Community 로딩 안정화 담당

역할:
- **React Native 상태머신/에러핸들링 엔지니어**

담당 범위:
- [app/(tabs)/learn.tsx](app/(tabs)/learn.tsx) `loadData()`에 `try/catch/finally`
- [app/(tabs)/community.tsx](app/(tabs)/community.tsx) `loadingBroadcasts` 종료 보장
- 에러 UI + 재시도 버튼 추가

완료 기준:
- 네트워크 실패 시에도 스피너 고착 없음
- 사용자에게 실패 메시지/재시도 제공

---

### AI #3 — 프로필 온보딩 분기/언어변경 UX 담당

역할:
- **프로필/온보딩 UX 엔지니어**

담당 범위:
- [app/profile/index.tsx](app/profile/index.tsx)에서 하드코딩 알럿 제거
- `onboarding_step` 기반 분기
- 완료 사용자 언어 변경 진입, 미완료 사용자 잠금 안내

완료 기준:
- 온보딩 완료 계정에서 잠금 메시지가 더 이상 뜨지 않음
- 미완료 계정에서만 잠금 메시지 표시

---

### 병렬 실행 규칙

1. AI #1, #2를 먼저 병렬 실행
2. AI #3은 #2와 병렬 가능 (파일 충돌 적음)
3. 마지막에 통합 리뷰 1회: 로딩/권한/분기 회귀 테스트

---

## 결론

이번 이슈는

- **무한로딩 계열(탭 데이터 로드 안정성)**
- **상태 불일치 계열(온보딩 완료인데 잠금 메시지)**

두 축으로 나뉜다.

- **소통 탭 스키마 불일치** +
- **로딩 종료 보장 부재**

조합으로 발생했을 가능성이 높다.

우선 컬럼 정합성/로딩 보장/온보딩 분기 3가지를 함께 수정하면 재현 빈도가 크게 줄어든다.
