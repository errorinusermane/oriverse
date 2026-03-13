-- ============================================================
-- 006_lesson_scripts_seed.sql
-- lesson_scripts 시드: 영어 lessons 7개 × 5턴
-- 선행 조건: 002_languages.sql, 003_lessons.sql 실행 완료
-- speaker: 'ai' = 상대방 역할(Waiter/Employee/Friend), 'user' = 학습자 역할
-- ============================================================

-- 🔴 Critical: (lesson_id, sequence_order) UNIQUE 제약 추가
-- lesson_scripts 테이블에 없던 제약 — 이 마이그레이션에서 추가
ALTER TABLE public.lesson_scripts
  ADD CONSTRAINT uq_lesson_scripts_lesson_seq
    UNIQUE (lesson_id, sequence_order);

DO $$
DECLARE
  en_id    UUID;
  l1_id    UUID;  -- Basic Grammar
  l2_id    UUID;  -- Café Conversation
  l3_id    UUID;  -- Restaurant Talk
  l4_id    UUID;  -- Supermarket
  l5_id    UUID;  -- Hobbies & Past
  l6_id    UUID;  -- Reactions & Emotions
  l7_id    UUID;  -- 50 Essential Verbs
BEGIN
  -- 🟠 High: 에러 메시지에 003 의존성 명시
  SELECT id INTO en_id FROM public.languages WHERE code = 'en';
  IF en_id IS NULL THEN
    RAISE EXCEPTION '선행 조건 불충족: 002_languages.sql과 003_lessons.sql을 먼저 실행하세요.';
  END IF;

  SELECT id INTO l1_id FROM public.lessons WHERE language_id = en_id AND step_number = 1;
  SELECT id INTO l2_id FROM public.lessons WHERE language_id = en_id AND step_number = 2;
  SELECT id INTO l3_id FROM public.lessons WHERE language_id = en_id AND step_number = 3;
  SELECT id INTO l4_id FROM public.lessons WHERE language_id = en_id AND step_number = 4;
  SELECT id INTO l5_id FROM public.lessons WHERE language_id = en_id AND step_number = 5;
  SELECT id INTO l6_id FROM public.lessons WHERE language_id = en_id AND step_number = 6;
  SELECT id INTO l7_id FROM public.lessons WHERE language_id = en_id AND step_number = 7;

  -- 🟠 High: lesson_id NULL 검증
  IF l1_id IS NULL THEN RAISE EXCEPTION '003_lessons.sql 시드 실패: step_number=1 (Basic Grammar) 없음'; END IF;
  IF l2_id IS NULL THEN RAISE EXCEPTION '003_lessons.sql 시드 실패: step_number=2 (Café Conversation) 없음'; END IF;
  IF l3_id IS NULL THEN RAISE EXCEPTION '003_lessons.sql 시드 실패: step_number=3 (Restaurant Talk) 없음'; END IF;
  IF l4_id IS NULL THEN RAISE EXCEPTION '003_lessons.sql 시드 실패: step_number=4 (Supermarket) 없음'; END IF;
  IF l5_id IS NULL THEN RAISE EXCEPTION '003_lessons.sql 시드 실패: step_number=5 (Hobbies & Past) 없음'; END IF;
  IF l6_id IS NULL THEN RAISE EXCEPTION '003_lessons.sql 시드 실패: step_number=6 (Reactions & Emotions) 없음'; END IF;
  IF l7_id IS NULL THEN RAISE EXCEPTION '003_lessons.sql 시드 실패: step_number=7 (50 Essential Verbs) 없음'; END IF;

  -- ── Lesson 1: Basic Grammar ───────────────────────────────
  -- 🟡 Medium: 문법 패턴(의문문/평서문/I'd like/Can/Would) 직접 시연
  INSERT INTO public.lesson_scripts (lesson_id, sequence_order, speaker, script_text) VALUES
    (l1_id, 1, 'ai',   'Hello! What''s your name?'),
    (l1_id, 2, 'user', 'My name is Susie. I''m from Korea.'),
    (l1_id, 3, 'ai',   'Nice to meet you! Can you speak English?'),
    (l1_id, 4, 'user', 'A little. I''d like to practice.'),
    (l1_id, 5, 'ai',   'Great! Would you like to start with some basics?')
  ON CONFLICT (lesson_id, sequence_order) DO NOTHING;

  -- ── Lesson 2: Café Conversation ──────────────────────────
  INSERT INTO public.lesson_scripts (lesson_id, sequence_order, speaker, script_text) VALUES
    (l2_id, 1, 'ai',   'May I take your order?'),
    (l2_id, 2, 'user', 'Yes, do you have almond milk?'),
    (l2_id, 3, 'ai',   'Yes, of course.'),
    (l2_id, 4, 'user', 'Then can I get a cappuccino with almond milk instead?'),
    (l2_id, 5, 'ai',   'Of course. Would it be cold or hot?')
  ON CONFLICT (lesson_id, sequence_order) DO NOTHING;

  -- ── Lesson 3: Restaurant Talk ─────────────────────────────
  INSERT INTO public.lesson_scripts (lesson_id, sequence_order, speaker, script_text) VALUES
    (l3_id, 1, 'ai',   'Good afternoon. Table for one?'),
    (l3_id, 2, 'user', 'Yes, please.'),
    (l3_id, 3, 'ai',   'Here is the menu. Would you like something to drink while you decide?'),
    (l3_id, 4, 'user', 'Yes, I''d like an orange juice, please.'),
    (l3_id, 5, 'ai',   'Very well. Do you know what you would like to eat?')
  ON CONFLICT (lesson_id, sequence_order) DO NOTHING;

  -- ── Lesson 4: Supermarket ─────────────────────────────────
  INSERT INTO public.lesson_scripts (lesson_id, sequence_order, speaker, script_text) VALUES
    (l4_id, 1, 'ai',   'Good afternoon. Rewards card?'),
    (l4_id, 2, 'user', 'No, I don''t have one.'),
    (l4_id, 3, 'ai',   'Alright. Cash or card?'),
    (l4_id, 4, 'user', 'Card, please.'),
    (l4_id, 5, 'ai',   'Please sign in the white space and press the check mark.')
  ON CONFLICT (lesson_id, sequence_order) DO NOTHING;

  -- ── Lesson 5: Hobbies & Past ──────────────────────────────
  -- speaker='ai' = 네트워킹 행사에서 만난 친구 역할
  INSERT INTO public.lesson_scripts (lesson_id, sequence_order, speaker, script_text) VALUES
    (l5_id, 1, 'ai',   'What do you usually do for fun? What are your hobbies?'),
    (l5_id, 2, 'user', 'I''ve been building apps lately. I finished one last month!'),
    (l5_id, 3, 'ai',   'Wow, that''s impressive! I made something recently too. Want to see?'),
    (l5_id, 4, 'user', 'I''d love to! I also play in a band. We performed last month.'),
    (l5_id, 5, 'ai',   'No way! Me too. We''re performing next month — would you like to come?')
  ON CONFLICT (lesson_id, sequence_order) DO NOTHING;

  -- ── Lesson 6: Reactions & Emotions ───────────────────────
  INSERT INTO public.lesson_scripts (lesson_id, sequence_order, speaker, script_text) VALUES
    (l6_id, 1, 'ai',   'How are you?'),
    (l6_id, 2, 'user', 'Couldn''t be better. And you?'),
    (l6_id, 3, 'ai',   'I got a promotion!'),
    (l6_id, 4, 'user', 'That''s awesome! You deserve it. I knew you could do it.'),
    (l6_id, 5, 'ai',   'Thank you so much. You made my day!')
  ON CONFLICT (lesson_id, sequence_order) DO NOTHING;

  -- ── Lesson 7: 50 Essential Verbs ─────────────────────────
  -- 빈도 높은 동사 다양하게 활용: do, work, make, sound, like, love, learn, keep
  INSERT INTO public.lesson_scripts (lesson_id, sequence_order, speaker, script_text) VALUES
    (l7_id, 1, 'ai',   'What do you do for work?'),
    (l7_id, 2, 'user', 'I work at a tech company. I make apps.'),
    (l7_id, 3, 'ai',   'That sounds interesting! Do you like it?'),
    (l7_id, 4, 'user', 'Yes, I love it. I learn something new every day.'),
    (l7_id, 5, 'ai',   'That''s great. Keep up the good work!')
  ON CONFLICT (lesson_id, sequence_order) DO NOTHING;

END $$;
