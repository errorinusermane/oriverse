-- ============================================================
-- 011_fix_en_scripts.sql
-- Fix: 006_lesson_scripts_seed.sql inserted 5-turn placeholder
--      scripts for EN lessons 2-6.  When 010_multilang_scripts.sql
--      ran, ON CONFLICT DO NOTHING silently skipped the correct
--      multi-turn replacements.
--
-- This migration:
--   1. DELETEs every lesson_scripts row whose lesson belongs to an
--      English-language lesson (languages.code = 'en').
--   2. Re-INSERTs the correct EN scripts verbatim from 010, WITHOUT
--      ON CONFLICT DO NOTHING, so the data is always authoritative.
--
-- Idempotent: DELETE then INSERT — safe to run multiple times.
-- ============================================================
DO $$
DECLARE
  en_id UUID;
  ko_id UUID;

  -- step-1 (native_language_id = ko)
  l1_en UUID;

  -- steps 2-6 (native_language_id IS NULL)
  l2_en UUID;
  l3_en UUID;
  l4_en UUID;
  l5_en UUID;
  l6_en UUID;
BEGIN
  -- ── 1. Resolve language IDs ───────────────────────────────
  SELECT id INTO en_id FROM public.languages WHERE code = 'en';
  SELECT id INTO ko_id FROM public.languages WHERE code = 'ko';

  IF en_id IS NULL THEN
    RAISE EXCEPTION 'Prerequisite not met: language code ''en'' not found.';
  END IF;

  -- ── 2. Resolve EN lesson IDs ─────────────────────────────
  SELECT id INTO l1_en FROM public.lessons
    WHERE language_id = en_id AND native_language_id = ko_id AND step_number = 1;

  SELECT id INTO l2_en FROM public.lessons
    WHERE language_id = en_id AND native_language_id IS NULL AND step_number = 2;
  SELECT id INTO l3_en FROM public.lessons
    WHERE language_id = en_id AND native_language_id IS NULL AND step_number = 3;
  SELECT id INTO l4_en FROM public.lessons
    WHERE language_id = en_id AND native_language_id IS NULL AND step_number = 4;
  SELECT id INTO l5_en FROM public.lessons
    WHERE language_id = en_id AND native_language_id IS NULL AND step_number = 5;
  SELECT id INTO l6_en FROM public.lessons
    WHERE language_id = en_id AND native_language_id IS NULL AND step_number = 6;

  -- ── 3. DELETE all existing EN lesson_scripts ─────────────
  --      First remove referencing progress rows, then scripts.
  DELETE FROM public.user_lesson_progress
    WHERE script_id IN (
      SELECT ls.id FROM public.lesson_scripts ls
      JOIN public.lessons l ON l.id = ls.lesson_id
      WHERE l.language_id = en_id
    );

  DELETE FROM public.lesson_scripts
    WHERE lesson_id IN (
      SELECT id FROM public.lessons WHERE language_id = en_id
    );

  -- ── 4. Re-INSERT correct EN scripts verbatim from 010 ────

  -- ── script_1_en  (step 1, Korean-native, 24 turns) ───────
  IF l1_en IS NOT NULL THEN
    INSERT INTO public.lesson_scripts (lesson_id, sequence_order, speaker, script_text, section_title) VALUES
      (l1_en,  1, 'user', '나 요즘 영어 배운다ㅋㅋ 개잘함.', NULL),
      (l1_en,  2, 'user', 'I, you, she, he, they, this, that', NULL),
      (l1_en,  3, 'ai',   '아니ㅋㅋㅋㅋ 걍 대명사잖아. 문장은?', NULL),
      (l1_en,  4, 'user', 'This, please. That, please.', NULL),
      (l1_en,  5, 'user', '여행 가는 데 이거면 되지 않음?', NULL),
      (l1_en,  6, 'ai',   'ㅋㅋㅋㅋ 걍 생존 언어잖아.', NULL),
      (l1_en,  7, 'user', '아니 진짜 할 수 있다니까?', NULL),
      (l1_en,  8, 'user', 'I coffee want.', NULL),
      (l1_en,  9, 'ai',   '아니 ㅋㅋㅋㅋ 어순이 달라.', NULL),
      (l1_en, 10, 'ai',   '"I want coffee."', NULL),
      (l1_en, 11, 'ai',   '이래야지.', NULL),
      (l1_en, 12, 'user', '어 맞아 맞아 그거! 어쨌든 어순만 바꾸면 되는 거 아니야?', NULL),
      (l1_en, 13, 'ai',   '기본은 그렇지. 평서문은 그냥 나 + 동사 + 목적어 (실제 learner 어순)', NULL),
      (l1_en, 14, 'ai',   '나 사실 영어 할 줄 알아. ㅋㅋ 귀엽네 ^^', NULL),
      (l1_en, 15, 'user', '헐 ㅋㅋㅋ 그럼 얼마예요를', NULL),
      (l1_en, 16, 'user', 'How do you say "How much is it?" in English?', NULL),
      (l1_en, 17, 'ai',   '질문이니까 순서만 바꿔.', NULL),
      (l1_en, 18, 'user', '화장실 어디예요는?', NULL),
      (l1_en, 19, 'ai',   '똑같이 순서 바꾼 상태로', NULL),
      (l1_en, 20, 'ai',   '"where"', NULL),
      (l1_en, 21, 'ai',   '만 넣으면 되지.', NULL),
      (l1_en, 22, 'user', '오… 그럼 나 이제 말 걸 수 있겠다 너 어디가냐', NULL),
      (l1_en, 23, 'ai',   '너무 앉아있기 싫어! 여기를 뜨겠어.', NULL),
      (l1_en, 24, 'ai',   'I can run away from you, I should run away, and I will run away. ㅂㅂ', NULL);
  END IF;

  -- ── script_2_en  (step 2, Café Conversation, 25 turns) ───
  IF l2_en IS NOT NULL THEN
    INSERT INTO public.lesson_scripts (lesson_id, sequence_order, speaker, script_text, section_title) VALUES
      (l2_en,  1, 'user', 'Hi, should we order here?', NULL),
      (l2_en,  2, 'ai',   'For here or to go?', '### 1. 들어가자마자'),
      (l2_en,  3, 'user', 'For here, please.', NULL),
      (l2_en,  4, 'ai',   'Ah, then please take a seat and I''ll bring your order over.', NULL),
      (l2_en,  5, 'ai',   'Can I take your order?', '### 2. 주문하기'),
      (l2_en,  6, 'user', 'Yes, do you have almond milk?', NULL),
      (l2_en,  7, 'ai',   'Yes, of course.', NULL),
      (l2_en,  8, 'user', 'Great. Then could I get a cappuccino with almond milk instead?', NULL),
      (l2_en,  9, 'ai',   'Would you like it hot or iced?', NULL),
      (l2_en, 10, 'user', 'Hot, please.', NULL),
      (l2_en, 11, 'ai',   'Would you like anything else?', NULL),
      (l2_en, 12, 'user', 'No, that''s all.', NULL),
      (l2_en, 13, 'ai',   'Would you like me to clear the menu?', NULL),
      (l2_en, 14, 'user', 'No, I''ll look at it a bit more.', NULL),
      (l2_en, 15, 'ai',   'I''ll be right back.', NULL),
      (l2_en, 16, 'user', 'Excuse me, do you have Wi-Fi?', NULL),
      (l2_en, 17, 'ai',   'Yes. This is the network name, and this is the password.', '### 3. 주문을 기다리며'),
      (l2_en, 18, 'user', 'Perfect, thank you.', NULL),
      (l2_en, 19, 'ai',   'Would you like the bill?', '### 4. 결제하기'),
      (l2_en, 20, 'user', 'Yes, I''ll pay now. Can I pay by card?', NULL),
      (l2_en, 21, 'ai',   'Yes, I''ll bring the card terminal. One moment, please.', NULL),
      (l2_en, 22, 'user', 'Please add a 15% tip.', NULL),
      (l2_en, 23, 'ai',   'Of course, thank you.', NULL),
      (l2_en, 24, 'user', 'Here is your card. Have a great day.', NULL),
      (l2_en, 25, 'ai',   'Thank you. I''ll come again.', NULL);
  END IF;

  -- ── script_3_en  (step 3, Restaurant Talk, 37 turns) ─────
  IF l3_en IS NOT NULL THEN
    INSERT INTO public.lesson_scripts (lesson_id, sequence_order, speaker, script_text, section_title) VALUES
      (l3_en,  1, 'ai',   'Welcome.', '### 1. 들어가자마자'),
      (l3_en,  2, 'user', 'Table for 1. Table for 2. Table for 3.', NULL),
      (l3_en,  3, 'ai',   'Please come this way.', NULL),
      (l3_en,  4, 'ai',   'Here''s the menu. What would you like for drinks?', '### 2. 음료 주문'),
      (l3_en,  5, 'user', 'By any chance, is water free?', NULL),
      (l3_en,  6, 'ai',   'No, the prices are written on the menu.', NULL),
      (l3_en,  7, 'user', 'Then could I get tap water, please?', NULL),
      (l3_en,  8, 'ai',   'Of course.', NULL),
      (l3_en,  9, 'user', 'I''ll have a Coke Zero, please.', NULL),
      (l3_en, 10, 'ai',   'Ah, a Coke Zero. Let me check if we have it in stock, just a moment.', NULL),
      (l3_en, 11, 'user', 'Yes, take your time.', NULL),
      (l3_en, 12, 'ai',   'Thank you. We''re out of Zero right now.', NULL),
      (l3_en, 13, 'user', 'Then just a regular Coke, please.', NULL),
      (l3_en, 14, 'ai',   'Sure, I''ll bring it right away.', NULL),
      (l3_en, 15, 'ai',   'Would you like to order food?', '### 3. 음식 주문'),
      (l3_en, 16, 'user', 'Ah, just a moment.', NULL),
      (l3_en, 17, 'ai',   'Are you ready?', NULL),
      (l3_en, 18, 'user', 'Yes, thank you. One cream pasta, one steak, and one vegetable bibimbap, please.', NULL),
      (l3_en, 19, 'ai',   'Sure, how would you like your steak cooked?', NULL),
      (l3_en, 20, 'user', 'Medium, please.', NULL),
      (l3_en, 21, 'ai',   'What would you like for a side?', NULL),
      (l3_en, 22, 'user', 'No side is fine. Ah, and What''s it called again? Ah, one order of fries, please.', NULL),
      (l3_en, 23, 'ai',   'Okay, let me confirm your order. One cream pasta, one medium steak, one vegetable bibimbap, and one order of fries, correct?', NULL),
      (l3_en, 24, 'user', 'That''s right, thank you.', NULL),
      (l3_en, 25, 'ai',   'Sure, please wait a moment.', NULL),
      (l3_en, 26, 'ai',   'Is everything okay?', '### 4. 밥 먹다가 중간에'),
      (l3_en, 27, 'user', 'Yes, it''s really delicious. It''s perfect. Ah, could I add one more order?', NULL),
      (l3_en, 28, 'ai',   'Of course! What would you like?', NULL),
      (l3_en, 29, 'user', 'One more anchovy pizza, please.', NULL),
      (l3_en, 30, 'ai',   'Sure, what size would you like?', NULL),
      (l3_en, 31, 'user', 'Small, please. Also, can I get a Coke refill?', NULL),
      (l3_en, 32, 'ai',   'Of course, I''ll bring it right away. Do you need anything else?', NULL),
      (l3_en, 33, 'user', 'That''s all. Ah, could we get a little more water?', NULL),
      (l3_en, 34, 'ai',   'Sure, I''ll bring it right away.', NULL),
      (l3_en, 35, 'ai',   'Your anchovy pizza and fries are here. Where should I put them?', '### 5. 음식 받기'),
      (l3_en, 36, 'user', 'Ah, please put that on this side. We''ll share the pizza. Please put the Coke over there.', NULL),
      (l3_en, 37, 'ai',   'Sure, enjoy your meal.', NULL);
  END IF;

  -- ── script_4_en  (step 4, Supermarket, 17 turns) ─────────
  IF l4_en IS NOT NULL THEN
    INSERT INTO public.lesson_scripts (lesson_id, sequence_order, speaker, script_text, section_title) VALUES
      (l4_en,  1, 'user', 'Hello.', NULL),
      (l4_en,  2, 'ai',   'Hello. Do you have a membership card?', '### 1. 계산대에서'),
      (l4_en,  3, 'user', 'No, I don''t. Can I make one now?', NULL),
      (l4_en,  4, 'ai',   'Ah, if you want to sign up, you need to go to the service desk and fill out a form.', NULL),
      (l4_en,  5, 'user', 'Ah, then I''ll just pay.', NULL),
      (l4_en,  6, 'user', 'I''ll pay by card.', NULL),
      (l4_en,  7, 'ai',   'Okay, please insert it there. Do you need a plastic bag?', '### 2. 계산하기'),
      (l4_en,  8, 'user', 'Ah, I have a small bag. It probably won''t fit, right? Please give me one.', NULL),
      (l4_en,  9, 'ai',   'Okay, I''ll put the rest in it. Please sign in the white box and press the check mark.', NULL),
      (l4_en, 10, 'user', 'Yes, now?', NULL),
      (l4_en, 11, 'ai',   'Yes, it''s completed now.', NULL),
      (l4_en, 12, 'ai',   'Would you like to top up your phone credit?', '### 3. 짐 돌려받기'),
      (l4_en, 13, 'user', 'No, I''m okay.', NULL),
      (l4_en, 14, 'ai',   'Here you go.', NULL),
      (l4_en, 15, 'user', 'Yes, thank you.', NULL),
      (l4_en, 16, 'ai',   'Have a nice day.', NULL),
      (l4_en, 17, 'user', 'Thank you, You too.', NULL);
  END IF;

  -- ── script_5_en  (step 5, Hobbies & Past, 16 turns) ──────
  IF l5_en IS NOT NULL THEN
    INSERT INTO public.lesson_scripts (lesson_id, sequence_order, speaker, script_text, section_title) VALUES
      (l5_en,  1, 'ai',   'Hi, how did you hear about this place?', NULL),
      (l5_en,  2, 'user', 'I found it through an online meetup! It''s my first time at a networking event like this, so I''m really nervous. And I''m not very good at English.', NULL),
      (l5_en,  3, 'ai',   'No, you''re doing great.', NULL),
      (l5_en,  4, 'user', 'Haha, thank you.', NULL),
      (l5_en,  5, 'ai',   'What do you usually do? What are your hobbies?', NULL),
      (l5_en,  6, 'user', 'Vibe coding is really popular these days, right? So I''m building an app. I finished one last month. Want to see it?', NULL),
      (l5_en,  7, 'ai',   'Wow, that''s impressive. I made something recently too. Want to see it?', NULL),
      (l5_en,  8, 'user', 'I''d love to!', NULL),
      (l5_en,  9, 'user', 'Ah, what are your hobbies?', NULL),
      (l5_en, 10, 'ai',   'I usually like listening to music.', NULL),
      (l5_en, 11, 'user', 'Me too! Actually, I''m a drummer. I even played a band show last month. What kind of music do you like?', NULL),
      (l5_en, 12, 'ai',   'Wow, that''s awesome! I''m in a band too. I like band music and rock.', NULL),
      (l5_en, 13, 'user', 'Wow, me too! We really click.', NULL),
      (l5_en, 14, 'ai',   'I have another show next month. Want to come?', NULL),
      (l5_en, 15, 'user', 'I''d love that! Can I get your Instagram? Let''s be friends!', NULL),
      (l5_en, 16, 'ai',   'Sure!', NULL);
  END IF;

  -- ── script_6_en  (step 6, Reactions & Emotions, 41 turns) ─
  IF l6_en IS NOT NULL THEN
    INSERT INTO public.lesson_scripts (lesson_id, sequence_order, speaker, script_text, section_title) VALUES
      (l6_en,  1, 'ai',       'Do you know when this bus is coming?', '### 1. 친구 만나러 가는 길, 버스 정류장에서'),
      (l6_en,  2, 'user',     'Huh? Sorry?', NULL),
      (l6_en,  3, 'ai',       'When is this bus coming?', NULL),
      (l6_en,  4, 'user',     'Could you speak a little slower? I didn''t get it. I''m not a native speaker. What was that?', NULL),
      (l6_en,  5, 'ai',       'I said, when is this bus coming?', NULL),
      (l6_en,  6, 'user',     'Ah, it just left.', NULL),
      (l6_en,  7, 'ai',       'Ugh, I should''ve taken that one.', NULL),
      (l6_en,  8, 'user',     'Too bad.', NULL),
      (l6_en,  9, 'ai',       'Anyway, thanks.', NULL),
      (l6_en, 10, 'ai',       'How have you been lately?', '### 2. 안부 묻기'),
      (l6_en, 11, 'user',     'Couldn''t be better. I''ve been playing guitar these days. I played all day yesterday.', NULL),
      (l6_en, 12, 'ai',       'That must''ve been fun.', NULL),
      (l6_en, 13, 'user',     'Yeah, definitely. How about you?', NULL),
      (l6_en, 14, 'ai',       'Same as usual. <Same as always, you know.> I''m so tired these days.', NULL),
      (l6_en, 15, 'user',     'I know, me too. Tell me about it.', NULL),
      (l6_en, 16, 'narrator', 'Suddenly, an elderly woman sets down her heavy bags next to them.', NULL),
      (l6_en, 17, 'user',     'I''ll help you. Are you okay?', NULL),
      (l6_en, 18, 'narrator', 'Grandma: Thank you so much. You saved me!', NULL),
      (l6_en, 19, 'narrator', 'They come back.', NULL),
      (l6_en, 20, 'ai',       'That''s very kind of you.', NULL),
      (l6_en, 21, 'user',     'Sorry, where were we? Could you repeat the last part?', NULL),
      (l6_en, 22, 'ai',       'Ah, it''s nothing major, but I think I''ve been a bit tired lately.', NULL),
      (l6_en, 23, 'user',     'Ah right, did something happen? Tell me.', NULL),
      (l6_en, 24, 'ai',       'I didn''t get the job.', NULL),
      (l6_en, 25, 'user',     'That sucks. I can''t believe they didn''t recognize your talent!', NULL),
      (l6_en, 26, 'ai',       'Right? lol It is disappointing...', NULL),
      (l6_en, 27, 'user',     'That must be tough, but it''s okay. You''ve got this.', NULL),
      (l6_en, 28, 'ai',       'Thanks for listening today. You made my day.', NULL),
      (l6_en, 29, 'user',     'Don''t mention it. I should be the one thanking you. Thanks for sharing. Let''s meet on Saturday.', NULL),
      (l6_en, 30, 'ai',       'Sounds good. Want to grab a drink?', NULL),
      (l6_en, 31, 'user',     'Ah, I can''t this time. How about next week instead? We could grab a drink then.', NULL),
      (l6_en, 32, 'ai',       'Sounds perfect. I''m all for it.', NULL),
      (l6_en, 33, 'user',     'I got a promotion!', NULL),
      (l6_en, 34, 'ai',       'Good for you! That''s awesome!', '### 3. 이후 술집에서'),
      (l6_en, 35, 'ai',       'You deserve it. I knew you could do it.', NULL),
      (l6_en, 36, 'user',     'Thanks. It still doesn''t feel real. It''s my first time taking a management role, so I''m a little scared.', NULL),
      (l6_en, 37, 'ai',       'That''s a big deal. Why are you doubting yourself? You''re good at this. You''ll do great.', NULL),
      (l6_en, 38, 'user',     'Do you really think so?', NULL),
      (l6_en, 39, 'ai',       'Go for it. I''m rooting for you.', NULL),
      (l6_en, 40, 'user',     'Thanks. Then I''ll try to be brave.', NULL),
      (l6_en, 41, 'ai',       'Good choice. I''ve got your back.', NULL);
  END IF;

END $$;
