# Day 9 피드백 2 — 반영 점검 결과

작성일: 2026-03-23
기준 문서: [susie/guide/day9_feedback.md](susie/guide/day9_feedback.md)

---

## 반영 여부 요약

| 항목 | 상태 | 점검 결과 |
|---|---|---|
| community 컬럼 정합성 (`user_id` → `sender_id`) | ✅ 완료 | [app/(tabs)/community.tsx](app/(tabs)/community.tsx#L24-L51), [app/(tabs)/community.tsx](app/(tabs)/community.tsx#L140-L142)에서 반영 확인 |
| learn/community 로딩 종료 보장 (`finally`) | ✅ 완료 | Learn: [app/(tabs)/learn.tsx](app/(tabs)/learn.tsx#L124-L192), Community: [app/(tabs)/community.tsx](app/(tabs)/community.tsx#L305-L319) |
| 에러 상태 UI + 재시도 버튼 | ✅ 완료 | Learn: [app/(tabs)/learn.tsx](app/(tabs)/learn.tsx#L209-L223), Community: [app/(tabs)/community.tsx](app/(tabs)/community.tsx#L354-L366) |
| `COMPLETED_STEPS` 하드코딩 제거 | ❌ 미완료 | 여전히 [app/(tabs)/community.tsx](app/(tabs)/community.tsx#L10-L11)에 하드코딩 존재 |
| 프로필 온보딩 분기 잠금 로직 수정 | ⚠️ 부분완료 | `onboarding_step` 조회/분기는 반영됨: [app/profile/index.tsx](app/profile/index.tsx#L34-L46), [app/profile/index.tsx](app/profile/index.tsx#L105-L111). 다만 완료 시 이동 경로가 `/onboarding`으로 설정되어 언어변경 전용 플로우는 아님 |

---

## 미완료/보완 필요 항목

## 1) Community 게이트 하드코딩 제거 필요

현재 `COMPLETED_STEPS = 6` 고정이라 실제 사용자 진행도와 무관하게 `full` 상태로 진입함.

- 위치: [app/(tabs)/community.tsx](app/(tabs)/community.tsx#L10-L11), [app/(tabs)/community.tsx](app/(tabs)/community.tsx#L386)
- 영향: 진행도 기반 잠금/미리보기 정책 불일치, 불필요한 네트워크 호출

필수 조치:
- `user_lesson_progress`에서 완료 스텝 수 집계
- 집계 실패 시 `preview` 폴백

---

## 2) 프로필 "학습 언어 변경"은 증상은 해결됐지만 경로가 임시

현재는 온보딩 완료 시 잠금 알럿 대신 `/onboarding`으로 이동함.

- 위치: [app/profile/index.tsx](app/profile/index.tsx#L107)
- 판단: "항상 잠김" 증상은 해결. 다만 UX 목표였던 "언어 변경 플로우"와는 다름.

권장 조치:
- `/profile/language` 같은 전용 화면 추가 또는 온보딩 라우트 내 언어 변경 모드 분기
- 변경 확인 모달 후 `users.learning_language_id` 업데이트

---

## 결론

핵심 무한로딩 원인(컬럼 불일치 + 로딩 종료 미보장)은 대부분 반영되어 개선 방향이 맞음.

다만 Day9 피드백 기준으로는 아래 2개가 남아 있어 **완전 완료는 아님**:
1. Community 완료 스텝 하드코딩 제거
2. 프로필 언어 변경의 전용 플로우 정리
