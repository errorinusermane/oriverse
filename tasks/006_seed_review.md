# 006_lesson_scripts_seed.sql — 데이터베이스 리뷰

> 리뷰 기준일: 2026-03-13
> 스키마 참조: 002_languages.sql, 003_lessons.sql, 006_lesson_scripts_seed.sql

---

## 🔴 Critical

### 1. `ON CONFLICT DO NOTHING`이 실제로 작동하지 않음

**위치:** 모든 INSERT 블록 (line 39, 48, 57, 66, 75, 84, 93)

`lesson_scripts` 테이블에는 `(lesson_id, sequence_order)` 조합에 대한 **UNIQUE 제약이 없다.**
PostgreSQL의 `ON CONFLICT DO NOTHING`은 UNIQUE 또는 PRIMARY KEY 충돌이 있을 때만 동작한다.
현재 상태에서는 마이그레이션을 두 번 실행하면 동일한 스크립트 35개가 그대로 중복 삽입된다.

**결과:**
- 앱에서 레슨 조회 시 동일 대사가 2배, 3배로 반환됨
- `sequence_order` 기반 정렬이 예측 불가능해짐

**해결 방향:**
```sql
-- 003_lessons.sql에 UNIQUE 제약 추가
ALTER TABLE public.lesson_scripts
  ADD CONSTRAINT uq_lesson_scripts_lesson_seq
    UNIQUE (lesson_id, sequence_order);
```
그 후 006에서 `ON CONFLICT (lesson_id, sequence_order) DO NOTHING`으로 변경해야 한다.

---

## 🟠 High

### 2. lesson_id NULL 검증 누락

**위치:** line 24~30 (lesson ID 조회), 이후 INSERT 전체

`l1_id` ~ `l7_id`를 `SELECT INTO`로 조회한 후 NULL 여부를 검사하지 않는다.
003_lessons.sql이 실행되지 않았거나 시드가 실패한 경우, 모든 lesson_id가 NULL인 상태로 INSERT가 시도된다.

**결과:**
- PostgreSQL이 `null value in column "lesson_id"` 에러를 반환
- 어떤 lesson이 없는지, 왜 없는지 알 수 없음

**해결 방향:**
```sql
IF l1_id IS NULL THEN
  RAISE EXCEPTION '003_lessons.sql 시드 실패: step_number=1 (Basic Grammar) 없음';
END IF;
-- l2~l7도 동일하게 체크
```

---

### 3. 003_lessons.sql 의존성이 에러 메시지에서 누락됨

**위치:** line 20~22

에러 메시지가 `002_languages.sql이 먼저 실행되지 않았습니다`라고만 되어 있다.
그러나 006은 실제로 **003_lessons.sql (lessons 시드 포함)에도 의존**한다.
002가 있어도 003이 없으면 l1_id~l7_id 전부 NULL이 되어 INSERT가 실패한다.

**해결 방향:**
```sql
IF en_id IS NULL THEN
  RAISE EXCEPTION '선행 조건 불충족: 002_languages.sql 또는 003_lessons.sql을 먼저 실행하세요.';
END IF;
```
또는 lesson ID 검증 로직과 합쳐서 단계별 안내를 제공한다.

---

## 🟡 Medium

### 4. 레슨 제목과 스크립트 내용 불일치

| 레슨 | 제목 (003 시드) | 스크립트 실제 내용 | 불일치 여부 |
|------|----------------|---------------------|------------|
| L1 | Basic Grammar | 카페 주문 대화 | ⚠️ 불일치 |
| L2 | Café Conversation | 카페 주문 대화 | ✅ 일치 |
| L3 | Restaurant Talk | 레스토랑 대화 | ✅ 일치 |
| L4 | Supermarket | 마트 결제 대화 | ✅ 일치 |
| L5 | Hobbies & Past | 취미/현재완료 대화 | ✅ 일치 |
| L6 | Reactions & Emotions | 감정 표현 대화 | ✅ 일치 |
| L7 | 50 Essential Verbs | 직업 관련 기본 대화 | ⚠️ 약한 불일치 |

- **L1 문제**: "Basic Grammar" 주제인데 내용이 카페 주문 대화 → L2와 주제 중복 가능성
- **L7 문제**: "50 Essential Verbs" 개념을 보여주려면 더 다양한 동사 활용이 나와야 하는데, 5턴 대화가 단순함

---

## 🔵 Low

### 5. Lesson 5에서 AI 역할 컨셉 혼란

**위치:** line 69~75

주석에는 `'ai' = Waiter/Employee/A 역할`이라 명시되어 있다.
그런데 Lesson 5에서 AI는 `"I made something recently too. Want to see?"`, `"We're performing next month — would you like to come?"` 등 **동료/친구** 역할로 말한다.

레슨 콘텐츠 자체는 자연스럽지만, 시스템 전반의 역할 정의(`speaker = 'ai'`)와 불일치하므로 문서 또는 speaker 정의 확장이 필요하다.

---

## 체크리스트 요약

| 우선순위 | 항목 | 상태 |
|---------|------|------|
| 🔴 Critical | `lesson_scripts`에 `UNIQUE(lesson_id, sequence_order)` 추가 | ❌ 미조치 |
| 🔴 Critical | `ON CONFLICT (lesson_id, sequence_order) DO NOTHING`으로 수정 | ❌ 미조치 |
| 🟠 High | lesson_id NULL 검증 추가 | ❌ 미조치 |
| 🟠 High | 에러 메시지에 003 의존성 명시 | ❌ 미조치 |
| 🟡 Medium | L1 스크립트를 Grammar 주제에 맞게 수정 또는 제목 재검토 | ❌ 미조치 |
| 🔵 Low | AI speaker 역할 정의 확장 (Waiter / Friend 구분 등) | 선택 사항 |
