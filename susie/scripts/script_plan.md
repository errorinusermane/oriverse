# Script Plan

## 현황 분석

**scripts 2~6:** 한국어 텍스트는 레퍼런스(설계 문서). 실제 DB엔 target language 대화문이 들어가야 함.

예: script_2 카페 대화 → 스페인어 학습자는 스페인어 대화문, 영어 학습자는 영어 대화문.
이미 스페인어가 써있는 줄(`Hola, pedimos aqui?`)은 스페인어 버전에서 그대로 확정.

**script_1:** 문법 개념을 native language로 설명. `--어` placeholder = target language. 개념 설명(어순, 평서문...)은 native language로, 예시 단어는 target language로.

---

## 핵심 문제: 언어 조합

| 스크립트 | 언어 축 | 필요한 버전 수 |
|----------|---------|--------------|
| Script 1 | native × target | `KO→EN`, `KO→ES`, `KO→DE`, `KO→FR`, `KO→ZH`, `KO→JA` (Korean native 기준 6개, MVP) |
| Scripts 2~6 | target language만 | 6 languages × 5 scripts = **30개** |

---

## 용어 정의

| 개념 | 용어 (코드/문서) |
|------|----------------|
| 배우는 언어 | **target language** / `learning_language` |
| 모국어 | **native language** / `native_language` |
| 언어 코드 | `languages.code` — `en`, `es`, `de`, `fr`, `zh`, `ja`, `ko` |

---

## DB 스키마 변경

현재 `lessons` 테이블: `language_id` (= target language만 있음)

**추가 필요:** `native_language_id UUID NULLABLE REFERENCES languages(id)`

- Script 1용 lesson row: `language_id = target` + `native_language_id = native`
- Scripts 2~6용 lesson row: `language_id = target`, `native_language_id = NULL`

앱에서 script 1 fetch 시: `language_id = target AND native_language_id = native`로 쿼리.

---

## 전체 실행 계획

### Step 1. DB 스키마 수정
- `lessons` 테이블에 `native_language_id UUID NULLABLE` 컬럼 추가

### Step 2. 스크립트 번역 생성 (AI 병렬 작업)

**Script 1 (6개):**
- KO 레퍼런스 → 6개 target language 버전 생성
- 설명(어순, 평서문 등)은 한국어 유지
- 예시 단어(`--어` placeholder)만 target language로 치환
- 버전: `KO→EN`, `KO→ES`, `KO→DE`, `KO→FR`, `KO→ZH`, `KO→JA`

**Scripts 2~6 (30개):**
- KO 레퍼런스 → 각 target language 대화문 생성
- 이미 확정된 표현(스페인어/영어 줄)은 해당 언어 버전에 그대로 삽입
- 버전: `EN`, `ES`, `DE`, `FR`, `ZH`, `JA` × 5 scripts

### Step 3. 새 seed SQL 작성
- `006_lesson_scripts_seed.sql` 교체
- `lessons` rows: 각 언어 조합별 step 1~6 rows
- `lesson_scripts` rows: 각 `lesson_id`에 대화문 turn들

### Step 4. learn.tsx 쿼리 수정
- Script 1 fetch: `native_language_id` 조건 추가
- Scripts 2~6: 기존 `language_id` 쿼리 유지

---

## 확정 결정사항

**Q1. Turn 언어:**
- Scripts 2~6: AI turn + user turn 모두 target language
- Script 1: AI turn + user turn 모두 native language (Korean)

**Q2. Script 1 native language 범위:**
- MVP: Korean native만 (6개: KO→EN, KO→ES, KO→DE, KO→FR, KO→ZH, KO→JA)
- 이후 다른 native language 추가
