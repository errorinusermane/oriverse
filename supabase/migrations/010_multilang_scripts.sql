-- ============================================================
-- 008_multilang_scripts_seed.sql
-- Seeds lesson_scripts for en/es/fr/de/zh/ja × steps 1–6
-- step-1: native_language_id = ko  (Korean-native learners)
-- steps 2-6: native_language_id IS NULL
-- ============================================================
DO $$
DECLARE
  ko_id UUID; en_id UUID; es_id UUID; fr_id UUID; de_id UUID; zh_id UUID; ja_id UUID;
  l1_en UUID; l1_es UUID; l1_fr UUID; l1_de UUID; l1_zh UUID; l1_ja UUID;
  l2_en UUID; l2_es UUID; l2_fr UUID; l2_de UUID; l2_zh UUID; l2_ja UUID;
  l3_en UUID; l3_es UUID; l3_fr UUID; l3_de UUID; l3_zh UUID; l3_ja UUID;
  l4_en UUID; l4_es UUID; l4_fr UUID; l4_de UUID; l4_zh UUID; l4_ja UUID;
  l5_en UUID; l5_es UUID; l5_fr UUID; l5_de UUID; l5_zh UUID; l5_ja UUID;
  l6_en UUID; l6_es UUID; l6_fr UUID; l6_de UUID; l6_zh UUID; l6_ja UUID;
BEGIN
  -- ── language IDs ──────────────────────────────────────────
  SELECT id INTO ko_id FROM public.languages WHERE code = 'ko';
  SELECT id INTO en_id FROM public.languages WHERE code = 'en';
  SELECT id INTO es_id FROM public.languages WHERE code = 'es';
  SELECT id INTO fr_id FROM public.languages WHERE code = 'fr';
  SELECT id INTO de_id FROM public.languages WHERE code = 'de';
  SELECT id INTO zh_id FROM public.languages WHERE code = 'zh';
  SELECT id INTO ja_id FROM public.languages WHERE code = 'ja';

  -- ── step-1 lesson IDs (native_language_id = ko) ───────────
  SELECT id INTO l1_en FROM public.lessons WHERE language_id = en_id AND native_language_id = ko_id AND step_number = 1;
  SELECT id INTO l1_es FROM public.lessons WHERE language_id = es_id AND native_language_id = ko_id AND step_number = 1;
  SELECT id INTO l1_fr FROM public.lessons WHERE language_id = fr_id AND native_language_id = ko_id AND step_number = 1;
  SELECT id INTO l1_de FROM public.lessons WHERE language_id = de_id AND native_language_id = ko_id AND step_number = 1;
  SELECT id INTO l1_zh FROM public.lessons WHERE language_id = zh_id AND native_language_id = ko_id AND step_number = 1;
  SELECT id INTO l1_ja FROM public.lessons WHERE language_id = ja_id AND native_language_id = ko_id AND step_number = 1;

  -- ── steps 2-6 lesson IDs (native_language_id IS NULL) ─────
  SELECT id INTO l2_en FROM public.lessons WHERE language_id = en_id AND native_language_id IS NULL AND step_number = 2;
  SELECT id INTO l2_es FROM public.lessons WHERE language_id = es_id AND native_language_id IS NULL AND step_number = 2;
  SELECT id INTO l2_fr FROM public.lessons WHERE language_id = fr_id AND native_language_id IS NULL AND step_number = 2;
  SELECT id INTO l2_de FROM public.lessons WHERE language_id = de_id AND native_language_id IS NULL AND step_number = 2;
  SELECT id INTO l2_zh FROM public.lessons WHERE language_id = zh_id AND native_language_id IS NULL AND step_number = 2;
  SELECT id INTO l2_ja FROM public.lessons WHERE language_id = ja_id AND native_language_id IS NULL AND step_number = 2;
  SELECT id INTO l3_en FROM public.lessons WHERE language_id = en_id AND native_language_id IS NULL AND step_number = 3;
  SELECT id INTO l3_es FROM public.lessons WHERE language_id = es_id AND native_language_id IS NULL AND step_number = 3;
  SELECT id INTO l3_fr FROM public.lessons WHERE language_id = fr_id AND native_language_id IS NULL AND step_number = 3;
  SELECT id INTO l3_de FROM public.lessons WHERE language_id = de_id AND native_language_id IS NULL AND step_number = 3;
  SELECT id INTO l3_zh FROM public.lessons WHERE language_id = zh_id AND native_language_id IS NULL AND step_number = 3;
  SELECT id INTO l3_ja FROM public.lessons WHERE language_id = ja_id AND native_language_id IS NULL AND step_number = 3;
  SELECT id INTO l4_en FROM public.lessons WHERE language_id = en_id AND native_language_id IS NULL AND step_number = 4;
  SELECT id INTO l4_es FROM public.lessons WHERE language_id = es_id AND native_language_id IS NULL AND step_number = 4;
  SELECT id INTO l4_fr FROM public.lessons WHERE language_id = fr_id AND native_language_id IS NULL AND step_number = 4;
  SELECT id INTO l4_de FROM public.lessons WHERE language_id = de_id AND native_language_id IS NULL AND step_number = 4;
  SELECT id INTO l4_zh FROM public.lessons WHERE language_id = zh_id AND native_language_id IS NULL AND step_number = 4;
  SELECT id INTO l4_ja FROM public.lessons WHERE language_id = ja_id AND native_language_id IS NULL AND step_number = 4;
  SELECT id INTO l5_en FROM public.lessons WHERE language_id = en_id AND native_language_id IS NULL AND step_number = 5;
  SELECT id INTO l5_es FROM public.lessons WHERE language_id = es_id AND native_language_id IS NULL AND step_number = 5;
  SELECT id INTO l5_fr FROM public.lessons WHERE language_id = fr_id AND native_language_id IS NULL AND step_number = 5;
  SELECT id INTO l5_de FROM public.lessons WHERE language_id = de_id AND native_language_id IS NULL AND step_number = 5;
  SELECT id INTO l5_zh FROM public.lessons WHERE language_id = zh_id AND native_language_id IS NULL AND step_number = 5;
  SELECT id INTO l5_ja FROM public.lessons WHERE language_id = ja_id AND native_language_id IS NULL AND step_number = 5;
  SELECT id INTO l6_en FROM public.lessons WHERE language_id = en_id AND native_language_id IS NULL AND step_number = 6;
  SELECT id INTO l6_es FROM public.lessons WHERE language_id = es_id AND native_language_id IS NULL AND step_number = 6;
  SELECT id INTO l6_fr FROM public.lessons WHERE language_id = fr_id AND native_language_id IS NULL AND step_number = 6;
  SELECT id INTO l6_de FROM public.lessons WHERE language_id = de_id AND native_language_id IS NULL AND step_number = 6;
  SELECT id INTO l6_zh FROM public.lessons WHERE language_id = zh_id AND native_language_id IS NULL AND step_number = 6;
  SELECT id INTO l6_ja FROM public.lessons WHERE language_id = ja_id AND native_language_id IS NULL AND step_number = 6;

  -- ══════════════════════════════════════════════════════════
  -- STEP 1 — Basic Grammar (Korean-native, 24 rows each)
  -- No section headings → all section_title = NULL
  -- ══════════════════════════════════════════════════════════

  -- ── script_1_en ───────────────────────────────────────────
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
    (l1_en, 24, 'ai',   'I can run away from you, I should run away, and I will run away. ㅂㅂ', NULL)
  ON CONFLICT (lesson_id, sequence_order) DO NOTHING;

  -- ── script_1_es ───────────────────────────────────────────
  INSERT INTO public.lesson_scripts (lesson_id, sequence_order, speaker, script_text, section_title) VALUES
    (l1_es,  1, 'user', '나 요즘 스페인어 배운다ㅋㅋ 개잘함.', NULL),
    (l1_es,  2, 'user', 'yo, tú, ella, él, ellos, esto, eso', NULL),
    (l1_es,  3, 'ai',   '아니ㅋㅋㅋㅋ 걍 대명사잖아. 문장은?', NULL),
    (l1_es,  4, 'user', 'Esto, por favor. Eso, por favor.', NULL),
    (l1_es,  5, 'user', '여행 가는 데 이거면 되지 않음?', NULL),
    (l1_es,  6, 'ai',   'ㅋㅋㅋㅋ 걍 생존 언어잖아.', NULL),
    (l1_es,  7, 'user', '아니 진짜 할 수 있다니까?', NULL),
    (l1_es,  8, 'user', 'Yo café quiero.', NULL),
    (l1_es,  9, 'ai',   '아니 ㅋㅋㅋㅋ 어순이 달라.', NULL),
    (l1_es, 10, 'ai',   '"Quiero café."', NULL),
    (l1_es, 11, 'ai',   '이래야지.', NULL),
    (l1_es, 12, 'user', '어 맞아 맞아 그거! 어쨌든 어순만 바꾸면 되는 거 아니야?', NULL),
    (l1_es, 13, 'ai',   '기본은 그렇지. 평서문은 그냥 나 + 동사 + 목적어 (실제 learner 어순)', NULL),
    (l1_es, 14, 'ai',   '나 사실 스페인어 할 줄 알아. ㅋㅋ 귀엽네 ^^', NULL),
    (l1_es, 15, 'user', '헐 ㅋㅋㅋ 그럼 얼마예요를', NULL),
    (l1_es, 16, 'user', '¿Cómo se dice «¿Cuánto cuesta?» en español?', NULL),
    (l1_es, 17, 'ai',   '질문이니까 순서만 바꿔.', NULL),
    (l1_es, 18, 'user', '화장실 어디예요는?', NULL),
    (l1_es, 19, 'ai',   '똑같이 순서 바꾼 상태로', NULL),
    (l1_es, 20, 'ai',   '"dónde"', NULL),
    (l1_es, 21, 'ai',   '만 넣으면 되지.', NULL),
    (l1_es, 22, 'user', '오… 그럼 나 이제 말 걸 수 있겠다 너 어디가냐', NULL),
    (l1_es, 23, 'ai',   '너무 앉아있기 싫어! 여기를 뜨겠어.', NULL),
    (l1_es, 24, 'ai',   'Puedo escapar de ti, debería escapar de ti y me voy a escapar de ti. ㅂㅂ', NULL)
  ON CONFLICT (lesson_id, sequence_order) DO NOTHING;

  -- ── script_1_fr ───────────────────────────────────────────
  INSERT INTO public.lesson_scripts (lesson_id, sequence_order, speaker, script_text, section_title) VALUES
    (l1_fr,  1, 'user', '나 요즘 프랑스어 배운다ㅋㅋ 개잘함.', NULL),
    (l1_fr,  2, 'user', 'je, tu, elle, il, ils, ceci, cela', NULL),
    (l1_fr,  3, 'ai',   '아니ㅋㅋㅋㅋ 걍 대명사잖아. 문장은?', NULL),
    (l1_fr,  4, 'user', 'Ceci, s''il vous plaît. Cela, s''il vous plaît.', NULL),
    (l1_fr,  5, 'user', '여행 가는 데 이거면 되지 않음?', NULL),
    (l1_fr,  6, 'ai',   'ㅋㅋㅋㅋ 걍 생존 언어잖아.', NULL),
    (l1_fr,  7, 'user', '아니 진짜 할 수 있다니까?', NULL),
    (l1_fr,  8, 'user', 'Je du café veux.', NULL),
    (l1_fr,  9, 'ai',   '아니 ㅋㅋㅋㅋ 어순이 달라.', NULL),
    (l1_fr, 10, 'ai',   '« Je veux du café. »', NULL),
    (l1_fr, 11, 'ai',   '이래야지.', NULL),
    (l1_fr, 12, 'user', '어 맞아 맞아 그거! 어쨌든 어순만 바꾸면 되는 거 아니야?', NULL),
    (l1_fr, 13, 'ai',   '기본은 그렇지. 평서문은 그냥 나 + 동사 + 목적어 (실제 learner 어순)', NULL),
    (l1_fr, 14, 'ai',   '나 사실 프랑스어 할 줄 알아. ㅋㅋ 귀엽네 ^^', NULL),
    (l1_fr, 15, 'user', '헐 ㅋㅋㅋ 그럼 얼마예요를', NULL),
    (l1_fr, 16, 'user', 'Comment on dit « C''est combien ? » en français ?', NULL),
    (l1_fr, 17, 'ai',   '질문이니까 순서만 바꿔.', NULL),
    (l1_fr, 18, 'user', '화장실 어디예요는?', NULL),
    (l1_fr, 19, 'ai',   '똑같이 순서 바꾼 상태로', NULL),
    (l1_fr, 20, 'ai',   '« où »', NULL),
    (l1_fr, 21, 'ai',   '만 넣으면 되지.', NULL),
    (l1_fr, 22, 'user', '오… 그럼 나 이제 말 걸 수 있겠다 너 어디가냐', NULL),
    (l1_fr, 23, 'ai',   '너무 앉아있기 싫어! 여기를 뜨겠어.', NULL),
    (l1_fr, 24, 'ai',   'Je peux m''enfuir de toi, je devrais m''enfuir de toi et je vais m''enfuir de toi. ㅂㅂ', NULL)
  ON CONFLICT (lesson_id, sequence_order) DO NOTHING;

  -- ── script_1_de ───────────────────────────────────────────
  INSERT INTO public.lesson_scripts (lesson_id, sequence_order, speaker, script_text, section_title) VALUES
    (l1_de,  1, 'user', '나 요즘 독일어 배운다ㅋㅋ 개잘함.', NULL),
    (l1_de,  2, 'user', 'ich, du, sie, er, sie, das hier, das da', NULL),
    (l1_de,  3, 'ai',   '아니ㅋㅋㅋㅋ 걍 대명사잖아. 문장은?', NULL),
    (l1_de,  4, 'user', 'Das hier, bitte. Das da, bitte.', NULL),
    (l1_de,  5, 'user', '여행 가는 데 이거면 되지 않음?', NULL),
    (l1_de,  6, 'ai',   'ㅋㅋㅋㅋ 걍 생존 언어잖아.', NULL),
    (l1_de,  7, 'user', '아니 진짜 할 수 있다니까?', NULL),
    (l1_de,  8, 'user', 'Ich Kaffee will.', NULL),
    (l1_de,  9, 'ai',   '아니 ㅋㅋㅋㅋ 어순이 달라.', NULL),
    (l1_de, 10, 'ai',   '„Ich will Kaffee."', NULL),
    (l1_de, 11, 'ai',   '이래야지.', NULL),
    (l1_de, 12, 'user', '어 맞아 맞아 그거! 어쨌든 어순만 바꾸면 되는 거 아니야?', NULL),
    (l1_de, 13, 'ai',   '기본은 그렇지. 평서문은 그냥 나 + 동사 + 목적어 (실제 learner 어순)', NULL),
    (l1_de, 14, 'ai',   '나 사실 독일어 할 줄 알아. ㅋㅋ 귀엽네 ^^', NULL),
    (l1_de, 15, 'user', '헐 ㅋㅋㅋ 그럼 얼마예요를', NULL),
    (l1_de, 16, 'user', 'Wie sagt man „Wie viel kostet das?" auf Deutsch?', NULL),
    (l1_de, 17, 'ai',   '질문이니까 순서만 바꿔.', NULL),
    (l1_de, 18, 'user', '화장실 어디예요는?', NULL),
    (l1_de, 19, 'ai',   '똑같이 순서 바꾼 상태로', NULL),
    (l1_de, 20, 'ai',   '„wo"', NULL),
    (l1_de, 21, 'ai',   '만 넣으면 되지.', NULL),
    (l1_de, 22, 'user', '오… 그럼 나 이제 말 걸 수 있겠다 너 어디가냐', NULL),
    (l1_de, 23, 'ai',   '너무 앉아있기 싫어! 여기를 뜨겠어.', NULL),
    (l1_de, 24, 'ai',   'Ich kann vor dir weglaufen, ich sollte vor dir weglaufen und ich werde vor dir weglaufen. ㅂㅂ', NULL)
  ON CONFLICT (lesson_id, sequence_order) DO NOTHING;

  -- ── script_1_zh ───────────────────────────────────────────
  INSERT INTO public.lesson_scripts (lesson_id, sequence_order, speaker, script_text, section_title) VALUES
    (l1_zh,  1, 'user', '나 요즘 중국어 배운다ㅋㅋ 개잘함.', NULL),
    (l1_zh,  2, 'user', '我，你，她，他，他们，这个，那个', NULL),
    (l1_zh,  3, 'ai',   '아니ㅋㅋㅋㅋ 걍 대명사잖아. 문장은?', NULL),
    (l1_zh,  4, 'user', '这个，请给我。那个，请给我。', NULL),
    (l1_zh,  5, 'user', '여행 가는 데 이거면 되지 않음?', NULL),
    (l1_zh,  6, 'ai',   'ㅋㅋㅋㅋ 걍 생존 언어잖아.', NULL),
    (l1_zh,  7, 'user', '아니 진짜 할 수 있다니까?', NULL),
    (l1_zh,  8, 'user', '我咖啡要。', NULL),
    (l1_zh,  9, 'ai',   '아니 ㅋㅋㅋㅋ 어순이 달라.', NULL),
    (l1_zh, 10, 'ai',   '"我要咖啡。"', NULL),
    (l1_zh, 11, 'ai',   '이래야지.', NULL),
    (l1_zh, 12, 'user', '어 맞아 맞아 그거! 어쨌든 어순만 바꾸면 되는 거 아니야?', NULL),
    (l1_zh, 13, 'ai',   '기본은 그렇지. 평서문은 그냥 나 + 동사 + 목적어 (실제 learner 어순)', NULL),
    (l1_zh, 14, 'ai',   '나 사실 중국어 할 줄 알아. ㅋㅋ 귀엽네 ^^', NULL),
    (l1_zh, 15, 'user', '헐 ㅋㅋㅋ 그럼 얼마예요를', NULL),
    (l1_zh, 16, 'user', '用中文怎么说"这个多少钱？"', NULL),
    (l1_zh, 17, 'ai',   '질문이니까 순서만 바꿔.', NULL),
    (l1_zh, 18, 'user', '화장실 어디예요는?', NULL),
    (l1_zh, 19, 'ai',   '똑같이 순서 바꾼 상태로', NULL),
    (l1_zh, 20, 'ai',   '"哪里"', NULL),
    (l1_zh, 21, 'ai',   '만 넣으면 되지.', NULL),
    (l1_zh, 22, 'user', '오… 그럼 나 이제 말 걸 수 있겠다 너 어디가냐', NULL),
    (l1_zh, 23, 'ai',   '너무 앉아있기 싫어! 여기를 뜨겠어.', NULL),
    (l1_zh, 24, 'ai',   '我可以从你这儿逃跑，我应该从你这儿逃跑，而且我会从你这儿逃跑。ㅂㅂ', NULL)
  ON CONFLICT (lesson_id, sequence_order) DO NOTHING;

  -- ── script_1_ja ───────────────────────────────────────────
  INSERT INTO public.lesson_scripts (lesson_id, sequence_order, speaker, script_text, section_title) VALUES
    (l1_ja,  1, 'user', '나 요즘 일본어 배운다ㅋㅋ 개잘함.', NULL),
    (l1_ja,  2, 'user', '私、あなた、彼女、彼、彼ら、これ、それ', NULL),
    (l1_ja,  3, 'ai',   '아니ㅋㅋㅋㅋ 걍 대명사잖아. 문장은?', NULL),
    (l1_ja,  4, 'user', 'これをください。それをください。', NULL),
    (l1_ja,  5, 'user', '여행 가는 데 이거면 되지 않음?', NULL),
    (l1_ja,  6, 'ai',   'ㅋㅋㅋㅋ 걍 생존 언어잖아.', NULL),
    (l1_ja,  7, 'user', '아니 진짜 할 수 있다니까?', NULL),
    (l1_ja,  8, 'user', '私はコーヒーを欲しい。', NULL),
    (l1_ja,  9, 'ai',   '아니 ㅋㅋㅋㅋ 조사가 달라.', NULL),
    (l1_ja, 10, 'ai',   '「私はコーヒーが欲しい。」', NULL),
    (l1_ja, 11, 'ai',   '이래야지.', NULL),
    (l1_ja, 12, 'user', '어 맞아 맞아 그거! 어쨌든 어순만 바꾸면 되는 거 아니야?', NULL),
    (l1_ja, 13, 'ai',   '기본은 그렇지. 평서문은 그냥 나 + 동사 + 목적어 (실제 learner 어순)', NULL),
    (l1_ja, 14, 'ai',   '나 사실 일본어 할 줄 알아. ㅋㅋ 귀엽네 ^^', NULL),
    (l1_ja, 15, 'user', '헐 ㅋㅋㅋ 그럼 얼마예요를', NULL),
    (l1_ja, 16, 'user', '日本語で「いくらですか？」は何て言うの？', NULL),
    (l1_ja, 17, 'ai',   '질문이니까 순서만 바꿔.', NULL),
    (l1_ja, 18, 'user', '화장실 어디예요는?', NULL),
    (l1_ja, 19, 'ai',   '똑같이 순서 바꾼 상태로', NULL),
    (l1_ja, 20, 'ai',   '「どこ」', NULL),
    (l1_ja, 21, 'ai',   '만 넣으면 되지.', NULL),
    (l1_ja, 22, 'user', '오… 그럼 나 이제 말 걸 수 있겠다 너 어디가냐', NULL),
    (l1_ja, 23, 'ai',   '너무 앉아있기 싫어! 여기를 뜨겠어.', NULL),
    (l1_ja, 24, 'ai',   '君から逃げることができるし、逃げたほうがいいし、これから逃げるよ。ㅂㅂ', NULL)
  ON CONFLICT (lesson_id, sequence_order) DO NOTHING;

  -- ══════════════════════════════════════════════════════════
  -- STEP 2 — Café Conversation (25 rows each)
  -- Sections: 1→seq2, 2→seq5, 3→seq17, 4→seq19
  -- ══════════════════════════════════════════════════════════

  -- ── script_2_en ───────────────────────────────────────────
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
    (l2_en, 25, 'ai',   'Thank you. I''ll come again.', NULL)
  ON CONFLICT (lesson_id, sequence_order) DO NOTHING;

  -- ── script_2_es ───────────────────────────────────────────
  INSERT INTO public.lesson_scripts (lesson_id, sequence_order, speaker, script_text, section_title) VALUES
    (l2_es,  1, 'user', 'Hola, ¿pedimos aquí?', NULL),
    (l2_es,  2, 'ai',   '¿Para tomar aquí o para llevar?', '### 1. 들어가자마자'),
    (l2_es,  3, 'user', 'Para aquí.', NULL),
    (l2_es,  4, 'ai',   'Ah, entonces tomen asiento y les llevo la orden.', NULL),
    (l2_es,  5, 'ai',   '¿Les tomo la orden?', '### 2. 주문하기'),
    (l2_es,  6, 'user', 'Sí, ¿tienen leche de almendra?', NULL),
    (l2_es,  7, 'ai',   'Sí, claro.', NULL),
    (l2_es,  8, 'user', 'Ah, genial. Entonces, ¿me puede cambiar el capuchino con leche de almendra?', NULL),
    (l2_es,  9, 'ai',   '¿Lo quiere caliente o frío?', NULL),
    (l2_es, 10, 'user', 'Caliente, por favor.', NULL),
    (l2_es, 11, 'ai',   '¿Algo más?', NULL),
    (l2_es, 12, 'user', 'No, eso es todo.', NULL),
    (l2_es, 13, 'ai',   '¿Les retiro el menú?', NULL),
    (l2_es, 14, 'user', 'No, lo voy a ver un poco más.', NULL),
    (l2_es, 15, 'ai',   'Enseguida regreso.', NULL),
    (l2_es, 16, 'user', 'Disculpe, ¿tienen wifi?', NULL),
    (l2_es, 17, 'ai',   'Sí. Este es el nombre de la red y esta es la contraseña.', '### 3. 주문을 기다리며'),
    (l2_es, 18, 'user', 'Perfecto, muchas gracias.', NULL),
    (l2_es, 19, 'ai',   '¿Les traigo la cuenta?', '### 4. 결제하기'),
    (l2_es, 20, 'user', 'Sí, pago ahora mismo. ¿Se puede pagar con tarjeta?', NULL),
    (l2_es, 21, 'ai',   'Sí, les traigo la terminal. Un momento, por favor.', NULL),
    (l2_es, 22, 'user', 'Por favor, añada el 15% de propina.', NULL),
    (l2_es, 23, 'ai',   'Claro, gracias.', NULL),
    (l2_es, 24, 'user', 'Aquí tiene su tarjeta. Que tenga un excelente día.', NULL),
    (l2_es, 25, 'ai',   'Gracias. Volveré la próxima vez.', NULL)
  ON CONFLICT (lesson_id, sequence_order) DO NOTHING;

  -- ── script_2_fr ───────────────────────────────────────────
  INSERT INTO public.lesson_scripts (lesson_id, sequence_order, speaker, script_text, section_title) VALUES
    (l2_fr,  1, 'user', 'Bonjour, on commande ici ?', NULL),
    (l2_fr,  2, 'ai',   'Sur place ou à emporter ?', '### 1. 들어가자마자'),
    (l2_fr,  3, 'user', 'Sur place, s''il vous plaît.', NULL),
    (l2_fr,  4, 'ai',   'Ah, alors installez-vous, je vous apporte votre commande.', NULL),
    (l2_fr,  5, 'ai',   'Je peux prendre votre commande ?', '### 2. 주문하기'),
    (l2_fr,  6, 'user', 'Oui, vous avez du lait d''amande ?', NULL),
    (l2_fr,  7, 'ai',   'Oui, bien sûr.', NULL),
    (l2_fr,  8, 'user', 'Super. Alors, je peux avoir un cappuccino avec du lait d''amande à la place ?', NULL),
    (l2_fr,  9, 'ai',   'Vous le voulez chaud ou froid ?', NULL),
    (l2_fr, 10, 'user', 'Chaud, s''il vous plaît.', NULL),
    (l2_fr, 11, 'ai',   'Autre chose ?', NULL),
    (l2_fr, 12, 'user', 'Non, c''est tout.', NULL),
    (l2_fr, 13, 'ai',   'Je retire le menu ?', NULL),
    (l2_fr, 14, 'user', 'Non, je vais encore regarder un peu.', NULL),
    (l2_fr, 15, 'ai',   'Je reviens tout de suite.', NULL),
    (l2_fr, 16, 'user', 'Excusez-moi, vous avez le Wi-Fi ?', NULL),
    (l2_fr, 17, 'ai',   'Oui. Voici le nom du réseau et voici le mot de passe.', '### 3. 주문을 기다리며'),
    (l2_fr, 18, 'user', 'Parfait, merci beaucoup.', NULL),
    (l2_fr, 19, 'ai',   'Je vous apporte l''addition ?', '### 4. 결제하기'),
    (l2_fr, 20, 'user', 'Oui, je paie tout de suite. On peut payer par carte ?', NULL),
    (l2_fr, 21, 'ai',   'Oui, je vous apporte le terminal de carte. Un instant, s''il vous plaît.', NULL),
    (l2_fr, 22, 'user', 'Ajoutez 15 % de pourboire, s''il vous plaît.', NULL),
    (l2_fr, 23, 'ai',   'Bien sûr, merci.', NULL),
    (l2_fr, 24, 'user', 'Voici votre carte. Passez une excellente journée.', NULL),
    (l2_fr, 25, 'ai',   'Merci. Je reviendrai la prochaine fois.', NULL)
  ON CONFLICT (lesson_id, sequence_order) DO NOTHING;

  -- ── script_2_de ───────────────────────────────────────────
  INSERT INTO public.lesson_scripts (lesson_id, sequence_order, speaker, script_text, section_title) VALUES
    (l2_de,  1, 'user', 'Hallo, bestellen wir hier?', NULL),
    (l2_de,  2, 'ai',   'Zum Hieressen oder zum Mitnehmen?', '### 1. 들어가자마자'),
    (l2_de,  3, 'user', 'Ich esse hier.', NULL),
    (l2_de,  4, 'ai',   'Ah, dann setzen Sie sich bitte, ich bringe Ihnen gleich die Bestellung.', NULL),
    (l2_de,  5, 'ai',   'Kann ich Ihre Bestellung aufnehmen?', '### 2. 주문하기'),
    (l2_de,  6, 'user', 'Ja, haben Sie vielleicht Mandelmilch?', NULL),
    (l2_de,  7, 'ai',   'Ja, natürlich.', NULL),
    (l2_de,  8, 'user', 'Super. Dann hätte ich gern einen Cappuccino mit Mandelmilch.', NULL),
    (l2_de,  9, 'ai',   'Möchten Sie ihn heiß oder kalt?', NULL),
    (l2_de, 10, 'user', 'Heiß, bitte.', NULL),
    (l2_de, 11, 'ai',   'Möchten Sie noch etwas?', NULL),
    (l2_de, 12, 'user', 'Nein, das ist alles.', NULL),
    (l2_de, 13, 'ai',   'Soll ich die Speisekarte mitnehmen?', NULL),
    (l2_de, 14, 'user', 'Nein, ich schaue noch kurz.', NULL),
    (l2_de, 15, 'ai',   'Ich bin gleich wieder da.', NULL),
    (l2_de, 16, 'user', 'Entschuldigung, haben Sie WLAN?', NULL),
    (l2_de, 17, 'ai',   'Ja. Das ist der Netzwerkname und das ist das Passwort.', '### 3. 주문을 기다리며'),
    (l2_de, 18, 'user', 'Perfekt, vielen Dank.', NULL),
    (l2_de, 19, 'ai',   'Möchten Sie die Rechnung?', '### 4. 결제하기'),
    (l2_de, 20, 'user', 'Ja, ich zahle gleich. Kann ich mit Karte zahlen?', NULL),
    (l2_de, 21, 'ai',   'Ja, ich bringe das Kartenlesegerät. Einen Moment bitte.', NULL),
    (l2_de, 22, 'user', 'Bitte fügen Sie 15 % Trinkgeld hinzu.', NULL),
    (l2_de, 23, 'ai',   'Natürlich, danke.', NULL),
    (l2_de, 24, 'user', 'Hier ist Ihre Karte. Ich wünsche Ihnen einen schönen Tag.', NULL),
    (l2_de, 25, 'ai',   'Danke. Ich komme beim nächsten Mal wieder.', NULL)
  ON CONFLICT (lesson_id, sequence_order) DO NOTHING;

  -- ── script_2_zh ───────────────────────────────────────────
  INSERT INTO public.lesson_scripts (lesson_id, sequence_order, speaker, script_text, section_title) VALUES
    (l2_zh,  1, 'user', '你好，我们在这里点单吗？', NULL),
    (l2_zh,  2, 'ai',   '堂食还是打包？', '### 1. 들어가자마자'),
    (l2_zh,  3, 'user', '堂食。', NULL),
    (l2_zh,  4, 'ai',   '啊，那您先坐下，我把点单拿过来。', NULL),
    (l2_zh,  5, 'ai',   '我来帮您点单吗？', '### 2. 주문하기'),
    (l2_zh,  6, 'user', '请问有杏仁奶吗？', NULL),
    (l2_zh,  7, 'ai',   '有的，当然有。', NULL),
    (l2_zh,  8, 'user', '太好了，那请把卡布奇诺换成杏仁奶。', NULL),
    (l2_zh,  9, 'ai',   '要热的还是冰的？', NULL),
    (l2_zh, 10, 'user', '热的。', NULL),
    (l2_zh, 11, 'ai',   '还需要别的吗？', NULL),
    (l2_zh, 12, 'user', '不用了，就这些。', NULL),
    (l2_zh, 13, 'ai',   '菜单要先收走吗？', NULL),
    (l2_zh, 14, 'user', '不用，我再看一下。', NULL),
    (l2_zh, 15, 'ai',   '我马上回来。', NULL),
    (l2_zh, 16, 'user', '不好意思，请问有 Wi-Fi 吗？', NULL),
    (l2_zh, 17, 'ai',   '有的。这是网络名，这是密码。', '### 3. 주문을 기다리며'),
    (l2_zh, 18, 'user', '太好了，谢谢。', NULL),
    (l2_zh, 19, 'ai',   '要给您账单吗？', '### 4. 결제하기'),
    (l2_zh, 20, 'user', '好，我现在结账。可以刷卡吗？', NULL),
    (l2_zh, 21, 'ai',   '可以，我去拿刷卡机。请稍等。', NULL),
    (l2_zh, 22, 'user', '请加 15% 的小费。', NULL),
    (l2_zh, 23, 'ai',   '当然可以，谢谢。', NULL),
    (l2_zh, 24, 'user', '这是您的卡。祝您今天愉快。', NULL),
    (l2_zh, 25, 'ai',   '谢谢，下次再来。', NULL)
  ON CONFLICT (lesson_id, sequence_order) DO NOTHING;

  -- ── script_2_ja ───────────────────────────────────────────
  INSERT INTO public.lesson_scripts (lesson_id, sequence_order, speaker, script_text, section_title) VALUES
    (l2_ja,  1, 'user', 'こんにちは、ここで注文しますか？', NULL),
    (l2_ja,  2, 'ai',   '店内でお召し上がりですか、それともお持ち帰りですか？', '### 1. 들어가자마자'),
    (l2_ja,  3, 'user', '店内でお願いします。', NULL),
    (l2_ja,  4, 'ai',   'では、お席に座ってお待ちください。注文をお持ちします。', NULL),
    (l2_ja,  5, 'ai',   'ご注文をお伺いしますか？', '### 2. 주문하기'),
    (l2_ja,  6, 'user', 'はい、アーモンドミルクはありますか？', NULL),
    (l2_ja,  7, 'ai',   'はい、もちろんございます。', NULL),
    (l2_ja,  8, 'user', 'よかったです。では、カプチーノをアーモンドミルクに変更してください。', NULL),
    (l2_ja,  9, 'ai',   'ホットとアイス、どちらになさいますか？', NULL),
    (l2_ja, 10, 'user', 'ホットでお願いします。', NULL),
    (l2_ja, 11, 'ai',   'ほかにご注文はありますか？', NULL),
    (l2_ja, 12, 'user', 'いいえ、以上です。', NULL),
    (l2_ja, 13, 'ai',   'メニューはお下げしてもよろしいですか？', NULL),
    (l2_ja, 14, 'user', 'いいえ、もう少し見ます。', NULL),
    (l2_ja, 15, 'ai',   'すぐに戻ります。', NULL),
    (l2_ja, 16, 'user', 'すみません、Wi-Fi はありますか？', NULL),
    (l2_ja, 17, 'ai',   'はい。こちらがネットワーク名で、こちらがパスワードです。', '### 3. 주문을 기다리며'),
    (l2_ja, 18, 'user', '完璧です、ありがとうございます。', NULL),
    (l2_ja, 19, 'ai',   'お会計をお持ちしましょうか？', '### 4. 결제하기'),
    (l2_ja, 20, 'user', 'はい、今すぐ払います。カードは使えますか？', NULL),
    (l2_ja, 21, 'ai',   'はい、カード端末をお持ちします。少々お待ちください。', NULL),
    (l2_ja, 22, 'user', '15% のチップを追加してください。', NULL),
    (l2_ja, 23, 'ai',   'もちろんです、ありがとうございます。', NULL),
    (l2_ja, 24, 'user', 'こちらがカードです。よい一日をお過ごしください。', NULL),
    (l2_ja, 25, 'ai',   'ありがとうございます。また来ます。', NULL)
  ON CONFLICT (lesson_id, sequence_order) DO NOTHING;

  -- ══════════════════════════════════════════════════════════
  -- STEP 3 — Restaurant Talk (37 rows each)
  -- Sections: 1→seq1, 2→seq4, 3→seq15, 4→seq26, 5→seq35
  -- ══════════════════════════════════════════════════════════

  -- ── script_3_en ───────────────────────────────────────────
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
    (l3_en, 37, 'ai',   'Sure, enjoy your meal.', NULL)
  ON CONFLICT (lesson_id, sequence_order) DO NOTHING;

  -- ── script_3_es ───────────────────────────────────────────
  INSERT INTO public.lesson_scripts (lesson_id, sequence_order, speaker, script_text, section_title) VALUES
    (l3_es,  1, 'ai',   'Bienvenidos.', '### 1. 들어가자마자'),
    (l3_es,  2, 'user', 'Para 1 persona. Para 2 personas. Para 3 personas.', NULL),
    (l3_es,  3, 'ai',   'Por aquí, por favor.', NULL),
    (l3_es,  4, 'ai',   'Aquí está el menú. ¿Qué quieren para tomar?', '### 2. 음료 주문'),
    (l3_es,  5, 'user', 'Disculpe, ¿el agua es gratis?', NULL),
    (l3_es,  6, 'ai',   'No, el precio está en el menú.', NULL),
    (l3_es,  7, 'user', 'Entonces, ¿me puede dar agua del grifo, por favor?', NULL),
    (l3_es,  8, 'ai',   'Claro que sí.', NULL),
    (l3_es,  9, 'user', 'Entonces para mí, una Coca-Cola Zero, por favor.', NULL),
    (l3_es, 10, 'ai',   'Ah, una Coca-Cola Zero. Déjeme revisar si hay en stock, un momento por favor.', NULL),
    (l3_es, 11, 'user', 'Sí, tómese su tiempo.', NULL),
    (l3_es, 12, 'ai',   'Gracias, ahora mismo no tenemos Zero.', NULL),
    (l3_es, 13, 'user', 'Entonces, una Coca-Cola normal, por favor.', NULL),
    (l3_es, 14, 'ai',   'Sí, se la traigo enseguida.', NULL),
    (l3_es, 15, 'ai',   '¿Ya van a pedir la comida?', '### 3. 음식 주문'),
    (l3_es, 16, 'user', 'Ah, un momento, por favor.', NULL),
    (l3_es, 17, 'ai',   '¿Ya están listos?', NULL),
    (l3_es, 18, 'user', 'Sí, gracias. Una pasta con crema, un bistec y un bibimbap de verduras, por favor.', NULL),
    (l3_es, 19, 'ai',   'Claro, ¿qué término quiere para el bistec?', NULL),
    (l3_es, 20, 'user', 'Término medio, por favor.', NULL),
    (l3_es, 21, 'ai',   '¿Qué guarnición quiere?', NULL),
    (l3_es, 22, 'user', 'Sin guarnición está bien. Ah, ¿cómo se llamaba? Ah, una orden de papas fritas, por favor.', NULL),
    (l3_es, 23, 'ai',   'Perfecto, le confirmo su pedido. Una pasta con crema, un bistec término medio, un bibimbap de verduras y una orden de papas fritas, ¿correcto?', NULL),
    (l3_es, 24, 'user', 'Sí, correcto. Gracias.', NULL),
    (l3_es, 25, 'ai',   'Muy bien, espere un momento, por favor.', NULL),
    (l3_es, 26, 'ai',   '¿Todo bien?', '### 4. 밥 먹다가 중간에'),
    (l3_es, 27, 'user', 'Sí, está muy rico. Está perfecto. Ah, ¿puedo pedir una cosa más?', NULL),
    (l3_es, 28, 'ai',   '¡Claro! ¿Qué le traigo?', NULL),
    (l3_es, 29, 'user', 'Una pizza de anchoas más, por favor.', NULL),
    (l3_es, 30, 'ai',   'Claro, ¿qué tamaño quiere?', NULL),
    (l3_es, 31, 'user', 'Tamaño pequeño, por favor. Ah, y ¿se puede rellenar la Coca-Cola?', NULL),
    (l3_es, 32, 'ai',   'Claro, se la traigo enseguida. ¿Necesita algo más?', NULL),
    (l3_es, 33, 'user', 'Eso es todo. Nos podrais poner dos vasitos de agua, porfa?', NULL),
    (l3_es, 34, 'ai',   'Sí, ahora mismo se la traigo.', NULL),
    (l3_es, 35, 'ai',   'Aquí tienen su pizza de anchoas y sus papas fritas. ¿Dónde se los pongo?', '### 5. 음식 받기'),
    (l3_es, 36, 'user', 'Ah, eso póngalo de este lado, por favor. La pizza la vamos a compartir. Y la Coca-Cola póngala por allá.', NULL),
    (l3_es, 37, 'ai',   'Perfecto, que aproveche.', NULL)
  ON CONFLICT (lesson_id, sequence_order) DO NOTHING;

  -- ── script_3_fr ───────────────────────────────────────────
  INSERT INTO public.lesson_scripts (lesson_id, sequence_order, speaker, script_text, section_title) VALUES
    (l3_fr,  1, 'ai',   'Bienvenue.', '### 1. 들어가자마자'),
    (l3_fr,  2, 'user', 'Une personne. Deux personnes. Trois personnes.', NULL),
    (l3_fr,  3, 'ai',   'Par ici, s''il vous plaît.', NULL),
    (l3_fr,  4, 'ai',   'Voici la carte. Qu''est-ce que vous voulez boire ?', '### 2. 음료 주문'),
    (l3_fr,  5, 'user', 'Excusez-moi, est-ce que l''eau est gratuite ?', NULL),
    (l3_fr,  6, 'ai',   'Non, les prix sont indiqués sur la carte.', NULL),
    (l3_fr,  7, 'user', 'Alors, je pourrais avoir de l''eau du robinet, s''il vous plaît ?', NULL),
    (l3_fr,  8, 'ai',   'Bien sûr.', NULL),
    (l3_fr,  9, 'user', 'Alors, pour moi, un Coca Zéro, s''il vous plaît.', NULL),
    (l3_fr, 10, 'ai',   'Ah, un Coca Zéro. Je vais vérifier s''il nous en reste, un instant s''il vous plaît.', NULL),
    (l3_fr, 11, 'user', 'Oui, prenez votre temps.', NULL),
    (l3_fr, 12, 'ai',   'Merci, on n''a plus de Zéro pour le moment.', NULL),
    (l3_fr, 13, 'user', 'Alors, un Coca normal, s''il vous plaît.', NULL),
    (l3_fr, 14, 'ai',   'D''accord, je vous l''apporte tout de suite.', NULL),
    (l3_fr, 15, 'ai',   'Vous voulez commander les plats ?', '### 3. 음식 주문'),
    (l3_fr, 16, 'user', 'Ah, un instant s''il vous plaît.', NULL),
    (l3_fr, 17, 'ai',   'Vous êtes prêts ?', NULL),
    (l3_fr, 18, 'user', 'Oui, merci. Une pasta à la crème, un steak et un bibimbap aux légumes, s''il vous plaît.', NULL),
    (l3_fr, 19, 'ai',   'D''accord, vous voulez quelle cuisson pour le steak ?', NULL),
    (l3_fr, 20, 'user', 'À point, s''il vous plaît.', NULL),
    (l3_fr, 21, 'ai',   'Vous voulez quoi comme accompagnement ?', NULL),
    (l3_fr, 22, 'user', 'Sans accompagnement, ça va. Ah, comment ça s''appelait déjà ? Ah, une portion de frites, s''il vous plaît.', NULL),
    (l3_fr, 23, 'ai',   'Très bien, je confirme votre commande. Une pasta à la crème, un steak à point, un bibimbap aux légumes et une portion de frites, c''est bien ça ?', NULL),
    (l3_fr, 24, 'user', 'Oui, c''est ça. Merci.', NULL),
    (l3_fr, 25, 'ai',   'D''accord, veuillez patienter un moment.', NULL),
    (l3_fr, 26, 'ai',   'Tout se passe bien ?', '### 4. 밥 먹다가 중간에'),
    (l3_fr, 27, 'user', 'Oui, c''est vraiment délicieux. C''est parfait. Ah, je peux ajouter une commande ?', NULL),
    (l3_fr, 28, 'ai',   'Bien sûr ! Qu''est-ce que vous voulez ?', NULL),
    (l3_fr, 29, 'user', 'Une pizza aux anchois en plus, s''il vous plaît.', NULL),
    (l3_fr, 30, 'ai',   'D''accord, quelle taille ?', NULL),
    (l3_fr, 31, 'user', 'Petite, s''il vous plaît. Et est-ce qu''on peut avoir un refill de Coca ?', NULL),
    (l3_fr, 32, 'ai',   'Bien sûr, je vous l''apporte tout de suite. Vous avez besoin d''autre chose ?', NULL),
    (l3_fr, 33, 'user', 'C''est tout. Ah, on pourrait avoir encore un peu d''eau ?', NULL),
    (l3_fr, 34, 'ai',   'Oui, je vous apporte ça tout de suite.', NULL),
    (l3_fr, 35, 'ai',   'Votre pizza aux anchois et vos frites sont arrivées. Je les pose où ?', '### 5. 음식 받기'),
    (l3_fr, 36, 'user', 'Ah, mettez ça de ce côté, s''il vous plaît. On va partager la pizza. Et mettez le Coca là-bas.', NULL),
    (l3_fr, 37, 'ai',   'D''accord, bon appétit.', NULL)
  ON CONFLICT (lesson_id, sequence_order) DO NOTHING;

  -- ── script_3_de ───────────────────────────────────────────
  INSERT INTO public.lesson_scripts (lesson_id, sequence_order, speaker, script_text, section_title) VALUES
    (l3_de,  1, 'ai',   'Willkommen.', '### 1. 들어가자마자'),
    (l3_de,  2, 'user', 'Für 1 Person. Für 2 Personen. Für 3 Personen.', NULL),
    (l3_de,  3, 'ai',   'Bitte kommen Sie hier entlang.', NULL),
    (l3_de,  4, 'ai',   'Hier ist die Speisekarte. Was möchten Sie trinken?', '### 2. 음료 주문'),
    (l3_de,  5, 'user', 'Wird Wasser vielleicht kostenlos angeboten?', NULL),
    (l3_de,  6, 'ai',   'Nein, die Preise stehen auf der Speisekarte.', NULL),
    (l3_de,  7, 'user', 'Dann könnte ich bitte Leitungswasser bekommen?', NULL),
    (l3_de,  8, 'ai',   'Natürlich.', NULL),
    (l3_de,  9, 'user', 'Dann hätte ich gern eine Coke Zero.', NULL),
    (l3_de, 10, 'ai',   'Ah, eine Coke Zero. Ich prüfe kurz, ob wir sie auf Lager haben, einen Moment bitte.', NULL),
    (l3_de, 11, 'user', 'Ja, lassen Sie sich ruhig Zeit.', NULL),
    (l3_de, 12, 'ai',   'Danke, leider haben wir Zero gerade nicht.', NULL),
    (l3_de, 13, 'user', 'Dann bitte einfach eine normale Cola.', NULL),
    (l3_de, 14, 'ai',   'Ja, ich bringe sie sofort.', NULL),
    (l3_de, 15, 'ai',   'Möchten Sie das Essen bestellen?', '### 3. 음식 주문'),
    (l3_de, 16, 'user', 'Ah, einen Moment bitte.', NULL),
    (l3_de, 17, 'ai',   'Sind Sie bereit?', NULL),
    (l3_de, 18, 'user', 'Ja, danke. Einmal Sahnepasta, einmal Steak und einmal Gemüse-Bibimbap, bitte.', NULL),
    (l3_de, 19, 'ai',   'Ja, wie möchten Sie das Steak gegart haben?', NULL),
    (l3_de, 20, 'user', 'Medium, bitte.', NULL),
    (l3_de, 21, 'ai',   'Was möchten Sie als Beilage?', NULL),
    (l3_de, 22, 'user', 'Keine Beilage ist okay. Ah, wie hieß das nochmal? Ah, einmal Pommes, bitte.', NULL),
    (l3_de, 23, 'ai',   'Ja, ich bestätige kurz Ihre Bestellung. Einmal Sahnepasta, einmal Steak medium, einmal Gemüse-Bibimbap und einmal Pommes, stimmt das?', NULL),
    (l3_de, 24, 'user', 'Ja, stimmt. Danke.', NULL),
    (l3_de, 25, 'ai',   'Bitte warten Sie einen Moment.', NULL),
    (l3_de, 26, 'ai',   'Ist geschmacklich alles in Ordnung?', '### 4. 밥 먹다가 중간에'),
    (l3_de, 27, 'user', 'Ja, es ist sehr lecker. Perfekt. Ah, dürfte ich noch etwas bestellen?', NULL),
    (l3_de, 28, 'ai',   'Natürlich! Was möchten Sie?', NULL),
    (l3_de, 29, 'user', 'Eine Anchovis-Pizza zusätzlich, bitte.', NULL),
    (l3_de, 30, 'ai',   'Ja, welche Größe möchten Sie?', NULL),
    (l3_de, 31, 'user', 'In klein, bitte. Und ist Cola-Nachfüllung möglich?', NULL),
    (l3_de, 32, 'ai',   'Natürlich, ich bringe sie sofort. Brauchen Sie sonst noch etwas?', NULL),
    (l3_de, 33, 'user', 'Das ist alles. Ah, könnten wir noch etwas mehr Wasser bekommen?', NULL),
    (l3_de, 34, 'ai',   'Ja, ich bringe es sofort.', NULL),
    (l3_de, 35, 'ai',   'Ihre Anchovis-Pizza und die Pommes sind da. Wo soll ich sie hinstellen?', '### 5. 음식 받기'),
    (l3_de, 36, 'user', 'Ah, bitte stellen Sie das hierhin. Die Pizza teilen wir uns. Die Cola bitte dorthin.', NULL),
    (l3_de, 37, 'ai',   'Ja, guten Appetit.', NULL)
  ON CONFLICT (lesson_id, sequence_order) DO NOTHING;

  -- ── script_3_zh ───────────────────────────────────────────
  INSERT INTO public.lesson_scripts (lesson_id, sequence_order, speaker, script_text, section_title) VALUES
    (l3_zh,  1, 'ai',   '欢迎光临。', '### 1. 들어가자마자'),
    (l3_zh,  2, 'user', '1位。2位。3位。', NULL),
    (l3_zh,  3, 'ai',   '请这边走。', NULL),
    (l3_zh,  4, 'ai',   '菜单在这里。您想喝点什么？', '### 2. 음료 주문'),
    (l3_zh,  5, 'user', '请问有免费提供水吗？', NULL),
    (l3_zh,  6, 'ai',   '没有，菜单上写了价格。', NULL),
    (l3_zh,  7, 'user', '那可以给我自来水吗？', NULL),
    (l3_zh,  8, 'ai',   '当然可以。', NULL),
    (l3_zh,  9, 'user', '那我来一杯零度可乐。', NULL),
    (l3_zh, 10, 'ai',   '啊，零度可乐。我先确认一下有没有库存，请稍等。', NULL),
    (l3_zh, 11, 'user', '好的，您慢慢来。', NULL),
    (l3_zh, 12, 'ai',   '谢谢，现在零度可乐没有了。', NULL),
    (l3_zh, 13, 'user', '那就给我普通可乐吧。', NULL),
    (l3_zh, 14, 'ai',   '好的，马上给您拿来。', NULL),
    (l3_zh, 15, 'ai',   '要点餐吗？', '### 3. 음식 주문'),
    (l3_zh, 16, 'user', '啊，请稍等一下。', NULL),
    (l3_zh, 17, 'ai',   '准备好了吗？', NULL),
    (l3_zh, 18, 'user', '好了，谢谢。请给我一份奶油意面、一份牛排、一份蔬菜拌饭。', NULL),
    (l3_zh, 19, 'ai',   '好的，牛排要几分熟？', NULL),
    (l3_zh, 20, 'user', '五分熟。', NULL),
    (l3_zh, 21, 'ai',   '配菜您想要什么？', NULL),
    (l3_zh, 22, 'user', '配菜不用了。啊，那个叫什么来着？啊，请再来一份薯条。', NULL),
    (l3_zh, 23, 'ai',   '好的，我确认一下您的订单：一份奶油意面、一份五分熟牛排、一份蔬菜拌饭、一份薯条，对吗？', NULL),
    (l3_zh, 24, 'user', '对，谢谢。', NULL),
    (l3_zh, 25, 'ai',   '好的，请稍等。', NULL),
    (l3_zh, 26, 'ai',   '味道还可以吗？', '### 4. 밥 먹다가 중간에'),
    (l3_zh, 27, 'user', '嗯，非常好吃，很完美。啊，我可以再加一份吗？', NULL),
    (l3_zh, 28, 'ai',   '当然可以！您想要什么？', NULL),
    (l3_zh, 29, 'user', '请再来一份凤尾鱼披萨。', NULL),
    (l3_zh, 30, 'ai',   '好的，您要什么尺寸？', NULL),
    (l3_zh, 31, 'user', '小份就可以。还有，可乐可以续杯吗？', NULL),
    (l3_zh, 32, 'ai',   '当然可以，我马上拿来。还需要别的吗？', NULL),
    (l3_zh, 33, 'user', '就这些。啊，可以再给我们一点水吗？', NULL),
    (l3_zh, 34, 'ai',   '好的，马上给您。', NULL),
    (l3_zh, 35, 'ai',   '您点的凤尾鱼披萨和薯条来了。要放在哪里？', '### 5. 음식 받기'),
    (l3_zh, 36, 'user', '啊，请放这边。披萨我们一起分着吃。可乐放那边就好。', NULL),
    (l3_zh, 37, 'ai',   '好的，请慢用。', NULL)
  ON CONFLICT (lesson_id, sequence_order) DO NOTHING;

  -- ── script_3_ja ───────────────────────────────────────────
  INSERT INTO public.lesson_scripts (lesson_id, sequence_order, speaker, script_text, section_title) VALUES
    (l3_ja,  1, 'ai',   'いらっしゃいませ。', '### 1. 들어가자마자'),
    (l3_ja,  2, 'user', '1名です。2名です。3名です。', NULL),
    (l3_ja,  3, 'ai',   'こちらへどうぞ。', NULL),
    (l3_ja,  4, 'ai',   'メニューはこちらです。お飲み物は何になさいますか？', '### 2. 음료 주문'),
    (l3_ja,  5, 'user', 'お水は無料でもらえますか？', NULL),
    (l3_ja,  6, 'ai',   'いいえ、メニューに価格が書いてあります。', NULL),
    (l3_ja,  7, 'user', 'では、水道水をいただけますか？', NULL),
    (l3_ja,  8, 'ai',   'もちろんです。', NULL),
    (l3_ja,  9, 'user', 'では、コカ・コーラゼロをお願いします。', NULL),
    (l3_ja, 10, 'ai',   'あ、コカ・コーラゼロですね。在庫があるか確認しますので、少々お待ちください。', NULL),
    (l3_ja, 11, 'user', 'はい、ゆっくりで大丈夫です。', NULL),
    (l3_ja, 12, 'ai',   'ありがとうございます。今ゼロは在庫がありません。', NULL),
    (l3_ja, 13, 'user', 'では、普通のコーラをください。', NULL),
    (l3_ja, 14, 'ai',   'はい、すぐにお持ちします。', NULL),
    (l3_ja, 15, 'ai',   'お料理をご注文されますか？', '### 3. 음식 주문'),
    (l3_ja, 16, 'user', 'あ、少々お待ちください。', NULL),
    (l3_ja, 17, 'ai',   'ご準備できましたか？', NULL),
    (l3_ja, 18, 'user', 'はい、ありがとうございます。クリームパスタを1つ、ステーキを1つ、ナムルビビンバを1つお願いします。', NULL),
    (l3_ja, 19, 'ai',   'かしこまりました。ステーキの焼き加減はどうなさいますか？', NULL),
    (l3_ja, 20, 'user', 'ミディアムでお願いします。', NULL),
    (l3_ja, 21, 'ai',   'サイドは何になさいますか？', NULL),
    (l3_ja, 22, 'user', 'サイドは大丈夫です。あ、それなんて言うんだっけ？あ、フライドポテトを1つお願いします。', NULL),
    (l3_ja, 23, 'ai',   'はい、ご注文を確認します。クリームパスタ1つ、ミディアムのステーキ1つ、ナムルビビンバ1つ、フライドポテト1つでよろしいですか？', NULL),
    (l3_ja, 24, 'user', 'はい、ありがとうございます。', NULL),
    (l3_ja, 25, 'ai',   'はい、少々お待ちください。', NULL),
    (l3_ja, 26, 'ai',   'お味は大丈夫ですか？', '### 4. 밥 먹다가 중간에'),
    (l3_ja, 27, 'user', 'はい、とてもおいしいです。完璧です。あ、もう1つ注文してもいいですか？', NULL),
    (l3_ja, 28, 'ai',   'もちろんです！何になさいますか？', NULL),
    (l3_ja, 29, 'user', 'アンチョビピザをもう1つください。', NULL),
    (l3_ja, 30, 'ai',   'はい、サイズはどうなさいますか？', NULL),
    (l3_ja, 31, 'user', '小さいサイズでお願いします。あと、コーラはおかわりできますか？', NULL),
    (l3_ja, 32, 'ai',   'もちろんです。すぐにお持ちします。ほかに必要なものはありますか？', NULL),
    (l3_ja, 33, 'user', 'これで全部です。あ、お水をもう少しいただけますか？', NULL),
    (l3_ja, 34, 'ai',   'はい、すぐにお持ちします。', NULL),
    (l3_ja, 35, 'ai',   'ご注文のアンチョビピザとフライドポテトです。どちらに置きましょうか？', '### 5. 음식 받기'),
    (l3_ja, 36, 'user', 'あ、それはこっちに置いてください。ピザは分けて食べます。コーラはあちらにお願いします。', NULL),
    (l3_ja, 37, 'ai',   'はい、ごゆっくりどうぞ。', NULL)
  ON CONFLICT (lesson_id, sequence_order) DO NOTHING;

  -- ══════════════════════════════════════════════════════════
  -- STEP 4 — Supermarket (17 rows each)
  -- Sections: 1→seq2, 2→seq7, 3→seq12
  -- ══════════════════════════════════════════════════════════

  -- ── script_4_en ───────────────────────────────────────────
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
    (l4_en, 17, 'user', 'Thank you, You too.', NULL)
  ON CONFLICT (lesson_id, sequence_order) DO NOTHING;

  -- ── script_4_es ───────────────────────────────────────────
  INSERT INTO public.lesson_scripts (lesson_id, sequence_order, speaker, script_text, section_title) VALUES
    (l4_es,  1, 'user', 'Hola.', NULL),
    (l4_es,  2, 'ai',   'Hola. ¿Tiene tarjeta de membresía?', '### 1. 계산대에서'),
    (l4_es,  3, 'user', 'No, no tengo. ¿Puedo hacerla ahora?', NULL),
    (l4_es,  4, 'ai',   'Ah, si quiere hacerla, tiene que ir al mostrador de atención y llenar un formulario.', NULL),
    (l4_es,  5, 'user', 'Ah, entonces solo pagaré.', NULL),
    (l4_es,  6, 'user', 'Voy a pagar con tarjeta.', NULL),
    (l4_es,  7, 'ai',   'Sí, insértela ahí. ¿Le doy una bolsa de plástico?', '### 2. 계산하기'),
    (l4_es,  8, 'user', 'Ah, tengo una bolsa pequeña. No va a caber, ¿verdad? Entonces deme una.', NULL),
    (l4_es,  9, 'ai',   'Sí, le pongo el resto ahí. Firme en el recuadro blanco y presione la marca de verificación.', NULL),
    (l4_es, 10, 'user', 'Sí, ¿ahora?', NULL),
    (l4_es, 11, 'ai',   'Sí, ya se completó.', NULL),
    (l4_es, 12, 'ai',   '¿Quiere recargar saldo del celular?', '### 3. 짐 돌려받기'),
    (l4_es, 13, 'user', 'No, está bien.', NULL),
    (l4_es, 14, 'ai',   'Aquí tiene.', NULL),
    (l4_es, 15, 'user', 'Sí, gracias.', NULL),
    (l4_es, 16, 'ai',   'Que tenga un buen día.', NULL),
    (l4_es, 17, 'user', 'Gracias, igualmente.', NULL)
  ON CONFLICT (lesson_id, sequence_order) DO NOTHING;

  -- ── script_4_fr ───────────────────────────────────────────
  INSERT INTO public.lesson_scripts (lesson_id, sequence_order, speaker, script_text, section_title) VALUES
    (l4_fr,  1, 'user', 'Bonjour.', NULL),
    (l4_fr,  2, 'ai',   'Bonjour. Vous avez une carte de fidélité ?', '### 1. 계산대에서'),
    (l4_fr,  3, 'user', 'Non, je n''en ai pas. Je peux en faire une maintenant ?', NULL),
    (l4_fr,  4, 'ai',   'Ah, si vous voulez en faire une, vous devez aller au comptoir d''accueil et remplir un formulaire.', NULL),
    (l4_fr,  5, 'user', 'Ah, alors je vais juste payer.', NULL),
    (l4_fr,  6, 'user', 'Je vais payer par carte.', NULL),
    (l4_fr,  7, 'ai',   'D''accord, insérez-la là. Vous voulez un sac plastique ?', '### 2. 계산하기'),
    (l4_fr,  8, 'user', 'Ah, j''ai un petit sac. Ça ne rentrera pas, non ? Donnez-m''en un, s''il vous plaît.', NULL),
    (l4_fr,  9, 'ai',   'D''accord, je mets le reste dedans. Signez dans la case blanche et appuyez sur la coche.', NULL),
    (l4_fr, 10, 'user', 'Oui, maintenant ?', NULL),
    (l4_fr, 11, 'ai',   'Oui, c''est bon, c''est terminé.', NULL),
    (l4_fr, 12, 'ai',   'Vous voulez recharger votre crédit téléphone ?', '### 3. 짐 돌려받기'),
    (l4_fr, 13, 'user', 'Non, ça va.', NULL),
    (l4_fr, 14, 'ai',   'Voilà.', NULL),
    (l4_fr, 15, 'user', 'Oui, merci.', NULL),
    (l4_fr, 16, 'ai',   'Bonne journée.', NULL),
    (l4_fr, 17, 'user', 'Merci, vous aussi.', NULL)
  ON CONFLICT (lesson_id, sequence_order) DO NOTHING;

  -- ── script_4_de ───────────────────────────────────────────
  INSERT INTO public.lesson_scripts (lesson_id, sequence_order, speaker, script_text, section_title) VALUES
    (l4_de,  1, 'user', 'Hallo.', NULL),
    (l4_de,  2, 'ai',   'Hallo. Haben Sie eine Mitgliedskarte?', '### 1. 계산대에서'),
    (l4_de,  3, 'user', 'Nein, habe ich nicht. Kann ich jetzt eine machen?', NULL),
    (l4_de,  4, 'ai',   'Ah, wenn Sie eine machen möchten, müssen Sie zum Informationsschalter gehen und ein Formular ausfüllen.', NULL),
    (l4_de,  5, 'user', 'Ah, dann zahle ich einfach so.', NULL),
    (l4_de,  6, 'user', 'Ich zahle mit Karte.', NULL),
    (l4_de,  7, 'ai',   'Ja, bitte dort einstecken. Möchten Sie eine Plastiktüte?', '### 2. 계산하기'),
    (l4_de,  8, 'user', 'Ah, ich habe eine kleine Tasche. Da passt es wohl nicht rein, oder? Dann geben Sie mir bitte eine.', NULL),
    (l4_de,  9, 'ai',   'Ja, ich packe den Rest hinein. Bitte unterschreiben Sie im weißen Feld und drücken Sie auf das Häkchen.', NULL),
    (l4_de, 10, 'user', 'Ja, jetzt?', NULL),
    (l4_de, 11, 'ai',   'Ja, jetzt ist es abgeschlossen.', NULL),
    (l4_de, 12, 'ai',   'Möchten Sie Ihr Handy-Guthaben aufladen?', '### 3. 짐 돌려받기'),
    (l4_de, 13, 'user', 'Nein, ist okay.', NULL),
    (l4_de, 14, 'ai',   'Hier bitte.', NULL),
    (l4_de, 15, 'user', 'Ja, danke.', NULL),
    (l4_de, 16, 'ai',   'Schönen Tag noch.', NULL),
    (l4_de, 17, 'user', 'Danke, Ihnen auch.', NULL)
  ON CONFLICT (lesson_id, sequence_order) DO NOTHING;

  -- ── script_4_zh ───────────────────────────────────────────
  INSERT INTO public.lesson_scripts (lesson_id, sequence_order, speaker, script_text, section_title) VALUES
    (l4_zh,  1, 'user', '您好。', NULL),
    (l4_zh,  2, 'ai',   '您好。您有会员卡吗？', '### 1. 계산대에서'),
    (l4_zh,  3, 'user', '没有。现在可以办吗？', NULL),
    (l4_zh,  4, 'ai',   '啊，如果要办的话，您得去服务台填写表格。', NULL),
    (l4_zh,  5, 'user', '啊，那我就直接结账吧。', NULL),
    (l4_zh,  6, 'user', '我刷卡付款。', NULL),
    (l4_zh,  7, 'ai',   '好的，请插在那里。需要塑料袋吗？', '### 2. 계산하기'),
    (l4_zh,  8, 'user', '啊，我有个小包。应该装不下吧？给我一个吧。', NULL),
    (l4_zh,  9, 'ai',   '好的，我把其余的给您装进去。请在白色框里签名，然后按勾选键。', NULL),
    (l4_zh, 10, 'user', '好的，现在吗？', NULL),
    (l4_zh, 11, 'ai',   '对，现在已经完成了。', NULL),
    (l4_zh, 12, 'ai',   '要给手机充值吗？', '### 3. 짐 돌려받기'),
    (l4_zh, 13, 'user', '不用了，没关系。', NULL),
    (l4_zh, 14, 'ai',   '给您。', NULL),
    (l4_zh, 15, 'user', '好的，谢谢。', NULL),
    (l4_zh, 16, 'ai',   '祝您今天愉快。', NULL),
    (l4_zh, 17, 'user', '谢谢，您也是。', NULL)
  ON CONFLICT (lesson_id, sequence_order) DO NOTHING;

  -- ── script_4_ja ───────────────────────────────────────────
  INSERT INTO public.lesson_scripts (lesson_id, sequence_order, speaker, script_text, section_title) VALUES
    (l4_ja,  1, 'user', 'こんにちは。', NULL),
    (l4_ja,  2, 'ai',   'こんにちは。メンバーシップカードはお持ちですか？', '### 1. 계산대에서'),
    (l4_ja,  3, 'user', 'いいえ、ありません。今作れますか？', NULL),
    (l4_ja,  4, 'ai',   'あ、作る場合は案内デスクで用紙をご記入いただく必要があります。', NULL),
    (l4_ja,  5, 'user', 'あ、じゃあこのまま会計します。', NULL),
    (l4_ja,  6, 'user', 'カードで支払います。', NULL),
    (l4_ja,  7, 'ai',   'はい、そこに差し込んでください。レジ袋はご利用ですか？', '### 2. 계산하기'),
    (l4_ja,  8, 'user', 'あ、小さいバッグがあります。入りませんよね？1枚ください。', NULL),
    (l4_ja,  9, 'ai',   'はい、残りはこちらに入れておきます。白い枠にサインして、チェックマークを押してください。', NULL),
    (l4_ja, 10, 'user', 'はい、今ですか？', NULL),
    (l4_ja, 11, 'ai',   'はい、今完了しました。', NULL),
    (l4_ja, 12, 'ai',   '携帯のチャージ（料金チャージ）はされますか？', '### 3. 짐 돌려받기'),
    (l4_ja, 13, 'user', 'いいえ、大丈夫です。', NULL),
    (l4_ja, 14, 'ai',   'こちらです。', NULL),
    (l4_ja, 15, 'user', 'はい、ありがとうございます。', NULL),
    (l4_ja, 16, 'ai',   '良い一日をお過ごしください。', NULL),
    (l4_ja, 17, 'user', 'ありがとうございます、あなたも。', NULL)
  ON CONFLICT (lesson_id, sequence_order) DO NOTHING;

  -- ══════════════════════════════════════════════════════════
  -- STEP 5 — Hobbies & Past (16 rows each)
  -- No section headings → all section_title = NULL
  -- ══════════════════════════════════════════════════════════

  -- ── script_5_en ───────────────────────────────────────────
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
    (l5_en, 16, 'ai',   'Sure!', NULL)
  ON CONFLICT (lesson_id, sequence_order) DO NOTHING;

  -- ── script_5_es ───────────────────────────────────────────
  INSERT INTO public.lesson_scripts (lesson_id, sequence_order, speaker, script_text, section_title) VALUES
    (l5_es,  1, 'ai',   'Hola, ¿cómo llegaste aquí?', NULL),
    (l5_es,  2, 'user', '¡Lo vi en un meetup en línea y vine! Es la primera vez que vengo a un evento de networking así, así que estoy muy nerviosa. Y no hablo muy bien español.', NULL),
    (l5_es,  3, 'ai',   'No, lo estás haciendo muy bien.', NULL),
    (l5_es,  4, 'user', 'Jaja, gracias.', NULL),
    (l5_es,  5, 'ai',   '¿Qué haces normalmente? ¿Cuáles son tus pasatiempos?', NULL),
    (l5_es,  6, 'user', 'Últimamente vibe coding está de moda, ¿no? Por eso estoy haciendo una app. Terminé una el mes pasado, ¿quieres verla?', NULL),
    (l5_es,  7, 'ai',   '¡Guau, qué increíble! Yo también hice algo hace poco, ¿quieres verlo?', NULL),
    (l5_es,  8, 'user', '¡Me encanta la idea!', NULL),
    (l5_es,  9, 'user', 'Ah, ¿y cuáles son tus pasatiempos?', NULL),
    (l5_es, 10, 'ai',   'Normalmente me gusta escuchar música.', NULL),
    (l5_es, 11, 'user', '¡A mí también! De hecho, soy baterista. El mes pasado incluso toqué en un concierto con mi banda. ¿Qué tipo de música te gusta?', NULL),
    (l5_es, 12, 'ai',   '¡Guau, qué genial! Yo también estoy en una banda. Me gusta la música de banda y el rock.', NULL),
    (l5_es, 13, 'user', '¡Guau, a mí también! Tenemos mucha química.', NULL),
    (l5_es, 14, 'ai',   'El próximo mes también tengo concierto, ¿quieres venir?', NULL),
    (l5_es, 15, 'user', '¡Me encantaría! ¿Me pasas tu Instagram? ¡Seamos amigas!', NULL),
    (l5_es, 16, 'ai',   '¡Claro!', NULL)
  ON CONFLICT (lesson_id, sequence_order) DO NOTHING;

  -- ── script_5_fr ───────────────────────────────────────────
  INSERT INTO public.lesson_scripts (lesson_id, sequence_order, speaker, script_text, section_title) VALUES
    (l5_fr,  1, 'ai',   'Bonjour, comment tu es arrivé(e) ici ?', NULL),
    (l5_fr,  2, 'user', 'Je l''ai vu sur un meetup en ligne et je suis venue ! C''est la première fois que je viens à ce genre d''événement de networking, donc je suis super stressée. Et je ne parle pas très bien français.', NULL),
    (l5_fr,  3, 'ai',   'Mais non, tu te débrouilles très bien.', NULL),
    (l5_fr,  4, 'user', 'Haha, merci.', NULL),
    (l5_fr,  5, 'ai',   'D''habitude, tu fais quoi ? C''est quoi tes hobbies ?', NULL),
    (l5_fr,  6, 'user', 'En ce moment, le vibe coding est à la mode, non ? Du coup je suis en train de créer une appli. J''en ai terminé une le mois dernier, tu veux voir ?', NULL),
    (l5_fr,  7, 'ai',   'Waouh, c''est impressionnant ! Moi aussi, j''ai créé quelque chose récemment, tu veux voir ?', NULL),
    (l5_fr,  8, 'user', 'J''adore !', NULL),
    (l5_fr,  9, 'user', 'Ah, et toi, c''est quoi tes hobbies ?', NULL),
    (l5_fr, 10, 'ai',   'Moi, en général, j''aime écouter de la musique.', NULL),
    (l5_fr, 11, 'user', 'Moi aussi ! En fait, je suis batteuse. J''ai même fait un concert avec mon groupe le mois dernier. Tu aimes quel genre de musique ?', NULL),
    (l5_fr, 12, 'ai',   'Waouh, trop bien ! Moi aussi je fais partie d''un groupe. J''aime la musique de groupe et le rock.', NULL),
    (l5_fr, 13, 'user', 'Waouh, moi aussi ! On s''entend super bien.', NULL),
    (l5_fr, 14, 'ai',   'J''ai encore un concert le mois prochain, tu veux venir ?', NULL),
    (l5_fr, 15, 'user', 'Avec grand plaisir ! Tu peux me donner ton Instagram ? On devient amies !', NULL),
    (l5_fr, 16, 'ai',   'Avec plaisir !', NULL)
  ON CONFLICT (lesson_id, sequence_order) DO NOTHING;

  -- ── script_5_de ───────────────────────────────────────────
  INSERT INTO public.lesson_scripts (lesson_id, sequence_order, speaker, script_text, section_title) VALUES
    (l5_de,  1, 'ai',   'Hallo, wie bist du hierher gekommen?', NULL),
    (l5_de,  2, 'user', 'Ich habe es bei einem Online-Meetup gesehen und bin gekommen! Es ist mein erstes Networking-Event dieser Art, deshalb bin ich total nervös. Und ich bin nicht gut in Deutsch.', NULL),
    (l5_de,  3, 'ai',   'Nein, du machst das doch gut.', NULL),
    (l5_de,  4, 'user', 'Haha, danke.', NULL),
    (l5_de,  5, 'ai',   'Was machst du normalerweise so? Was sind deine Hobbys?', NULL),
    (l5_de,  6, 'user', 'Vibe Coding ist ja gerade im Trend, oder? Deshalb baue ich eine App. Letzten Monat habe ich eine fertiggestellt, möchtest du sie sehen?', NULL),
    (l5_de,  7, 'ai',   'Wow, das ist beeindruckend. Ich habe auch neulich etwas gemacht, möchtest du es sehen?', NULL),
    (l5_de,  8, 'user', 'Sehr gern!', NULL),
    (l5_de,  9, 'user', 'Ah, was sind denn deine Hobbys?', NULL),
    (l5_de, 10, 'ai',   'Ich höre normalerweise gern Musik.', NULL),
    (l5_de, 11, 'user', 'Ich auch! Eigentlich bin ich Schlagzeugerin. Letzten Monat hatte ich sogar einen Bandauftritt. Welche Musik magst du?', NULL),
    (l5_de, 12, 'ai',   'Wow, wie cool! Ich spiele auch in einer Band. Ich mag Bandmusik und Rockmusik.', NULL),
    (l5_de, 13, 'user', 'Wow, ich auch! Wir passen echt gut zusammen.', NULL),
    (l5_de, 14, 'ai',   'Ich habe nächsten Monat wieder einen Auftritt, kommst du?', NULL),
    (l5_de, 15, 'user', 'Sehr gern! Gibst du mir dein Instagram? Lass uns Freunde sein!', NULL),
    (l5_de, 16, 'ai',   'Gerne!', NULL)
  ON CONFLICT (lesson_id, sequence_order) DO NOTHING;

  -- ── script_5_zh ───────────────────────────────────────────
  INSERT INTO public.lesson_scripts (lesson_id, sequence_order, speaker, script_text, section_title) VALUES
    (l5_zh,  1, 'ai',   '你好，你是怎么来这里的？', NULL),
    (l5_zh,  2, 'user', '我是在线上 meetup 看到后来的！这种 networking 活动我还是第一次来，特别紧张。而且我不太会说中文。', NULL),
    (l5_zh,  3, 'ai',   '没有，你说得很好啊。', NULL),
    (l5_zh,  4, 'user', '哈哈，谢谢。', NULL),
    (l5_zh,  5, 'ai',   '你平时都做什么？有什么爱好吗？', NULL),
    (l5_zh,  6, 'user', '最近 vibe coding 很流行嘛。所以我在做 app。上个月刚完成一个，你要看看吗？', NULL),
    (l5_zh,  7, 'ai',   '哇，好厉害！我最近也做了一个，要不要看看？', NULL),
    (l5_zh,  8, 'user', '太好了！', NULL),
    (l5_zh,  9, 'user', '啊，那你有什么爱好？', NULL),
    (l5_zh, 10, 'ai',   '我平时比较喜欢听歌。', NULL),
    (l5_zh, 11, 'user', '我也是！其实我是鼓手。上个月还参加了乐队演出。你喜欢什么歌？', NULL),
    (l5_zh, 12, 'ai',   '哇，太棒了！我也玩乐队。我喜欢乐队音乐和摇滚。', NULL),
    (l5_zh, 13, 'user', '哇我也是！我们很合拍耶。', NULL),
    (l5_zh, 14, 'ai',   '我下个月也有演出，你要来吗？', NULL),
    (l5_zh, 15, 'user', '太好了！可以告诉我你的 Instagram 吗？我们加个朋友吧！', NULL),
    (l5_zh, 16, 'ai',   '好啊！', NULL)
  ON CONFLICT (lesson_id, sequence_order) DO NOTHING;

  -- ── script_5_ja ───────────────────────────────────────────
  INSERT INTO public.lesson_scripts (lesson_id, sequence_order, speaker, script_text, section_title) VALUES
    (l5_ja,  1, 'ai',   'こんにちは、どうやってここに来たんですか？', NULL),
    (l5_ja,  2, 'user', 'オンラインのミートアップで見て来ました！こういうネットワーキングイベントは初めてなので、すごく緊張しています。それに、日本語があまり上手じゃないです。', NULL),
    (l5_ja,  3, 'ai',   'いいえ、上手ですよ。', NULL),
    (l5_ja,  4, 'user', 'はは、ありがとうございます。', NULL),
    (l5_ja,  5, 'ai',   '普段は何をしていますか？趣味は何ですか？', NULL),
    (l5_ja,  6, 'user', '最近 vibe coding が流行ってるじゃないですか。だからアプリを作ってます。先月ひとつ完成したんですけど、見ますか？', NULL),
    (l5_ja,  7, 'ai',   'わあ、すごいですね。私も最近作ったものがあるんですが、見ますか？', NULL),
    (l5_ja,  8, 'user', 'ぜひ！', NULL),
    (l5_ja,  9, 'user', 'あ、あなたの趣味は何ですか？', NULL),
    (l5_ja, 10, 'ai',   '私は普段、音楽を聴くのが好きです。', NULL),
    (l5_ja, 11, 'user', '私もです！実は私、ドラマーなんです。先月はバンドのライブもしました。どんな音楽が好きですか？', NULL),
    (l5_ja, 12, 'ai',   'わあ、すごい！私もバンドやってます。バンド音楽とロックが好きです。', NULL),
    (l5_ja, 13, 'user', 'わあ、私もです！私たち気が合いますね。', NULL),
    (l5_ja, 14, 'ai',   '来月もライブがあるんですが、来ますか？', NULL),
    (l5_ja, 15, 'user', 'すごくいいですね！インスタ教えてもらえますか？友達になりましょう！', NULL),
    (l5_ja, 16, 'ai',   'いいですよ！', NULL)
  ON CONFLICT (lesson_id, sequence_order) DO NOTHING;

  -- ══════════════════════════════════════════════════════════
  -- STEP 6 — Reactions & Emotions (41 rows each)
  -- Sections: 1→seq1, 2→seq10, 3→seq34
  -- seq16,18,19 = narrator; section-3 opens with user(seq33)→pending→ai seq34
  -- ══════════════════════════════════════════════════════════

  -- ── script_6_en ───────────────────────────────────────────
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
    (l6_en, 41, 'ai',       'Good choice. I''ve got your back.', NULL)
  ON CONFLICT (lesson_id, sequence_order) DO NOTHING;

  -- ── script_6_es ───────────────────────────────────────────
  INSERT INTO public.lesson_scripts (lesson_id, sequence_order, speaker, script_text, section_title) VALUES
    (l6_es,  1, 'ai',       'Oye, ¿sabes cuándo llega este autobús?', '### 1. 친구 만나러 가는 길, 버스 정류장에서'),
    (l6_es,  2, 'user',     '¿Eh? ¿Perdón?', NULL),
    (l6_es,  3, 'ai',       '¿Cuándo llega este autobús?', NULL),
    (l6_es,  4, 'user',     '¿Puedes hablar un poco más despacio? No entendí. No soy hablante nativa. ¿Qué dijiste?', NULL),
    (l6_es,  5, 'ai',       'Que cuándo llega este autobús.', NULL),
    (l6_es,  6, 'user',     'Ah, acaba de pasar.', NULL),
    (l6_es,  7, 'ai',       'Ay, tenía que haber tomado ese.', NULL),
    (l6_es,  8, 'user',     'Qué mal.', NULL),
    (l6_es,  9, 'ai',       'De todos modos, gracias.', NULL),
    (l6_es, 10, 'ai',       '¿Cómo has estado últimamente?', '### 2. 안부 묻기'),
    (l6_es, 11, 'user',     'Mejor, imposible. Últimamente toco guitarra. Ayer también estuve tocando todo el día.', NULL),
    (l6_es, 12, 'ai',       'Seguro estuvo divertido.', NULL),
    (l6_es, 13, 'user',     'Sí. ¿Y tú?', NULL),
    (l6_es, 14, 'ai',       'Igual que siempre. <Lo de siempre, pues.> Estos días estoy muy cansada.', NULL),
    (l6_es, 15, 'user',     'Ya, totalmente. Yo también.', NULL),
    (l6_es, 16, 'narrator', 'De repente, una abuelita deja unas bolsas pesadas al lado.', NULL),
    (l6_es, 17, 'user',     'Yo le ayudo. ¿Está bien?', NULL),
    (l6_es, 18, 'narrator', 'Abuelita: ¡Muchas gracias! ¡Me salvaste!', NULL),
    (l6_es, 19, 'narrator', 'Vuelve a la conversación.', NULL),
    (l6_es, 20, 'ai',       'Qué amable de tu parte.', NULL),
    (l6_es, 21, 'user',     'Perdón, ¿me repites la última parte?', NULL),
    (l6_es, 22, 'ai',       'Ah, no era gran cosa, pero creo que últimamente estoy un poco cansada.', NULL),
    (l6_es, 23, 'user',     'Ah, ya. ¿Te pasó algo? Cuéntame.', NULL),
    (l6_es, 24, 'ai',       'No me dieron el trabajo.', NULL),
    (l6_es, 25, 'user',     'Qué pena. ¡No puedo creer que no reconocieran a alguien tan talentosa!', NULL),
    (l6_es, 26, 'ai',       'Ya ves jajaja, sí da pena...', NULL),
    (l6_es, 27, 'user',     'Debe ser duro, pero tranquila. Tú puedes.', NULL),
    (l6_es, 28, 'ai',       'Gracias por escucharme hoy. Gracias a ti me siento mejor.', NULL),
    (l6_es, 29, 'user',     'No digas eso. Más bien gracias a ti por contármelo. Nos vemos el sábado.', NULL),
    (l6_es, 30, 'ai',       'Perfecto, ¿vamos por una copa?', NULL),
    (l6_es, 31, 'user',     'Ah, esta vez no puedo. ¿Qué tal la próxima semana? Podemos tomar algo entonces.', NULL),
    (l6_es, 32, 'ai',       'Me encanta. Estoy totalmente a favor.', NULL),
    (l6_es, 33, 'user',     '¡Me ascendieron!', NULL),
    (l6_es, 34, 'ai',       '¡Qué bien! ¡Qué increíble!', '### 3. 이후 술집에서'),
    (l6_es, 35, 'ai',       'Te lo mereces. Sabía que lo lograrías.', NULL),
    (l6_es, 36, 'user',     'Gracias. Todavía no me lo creo. Es la primera vez que me dan un puesto de gestión, así que me da un poco de miedo.', NULL),
    (l6_es, 37, 'ai',       'Eso es grande. ¿Por qué dudas de ti? Lo vas a hacer genial.', NULL),
    (l6_es, 38, 'user',     '¿De verdad lo crees?', NULL),
    (l6_es, 39, 'ai',       'Hazlo. Yo te apoyo.', NULL),
    (l6_es, 40, 'user',     'Gracias. Entonces voy a animarme y hacerlo.', NULL),
    (l6_es, 41, 'ai',       'Buena decisión. Te cubro la espalda.', NULL)
  ON CONFLICT (lesson_id, sequence_order) DO NOTHING;

  -- ── script_6_fr ───────────────────────────────────────────
  INSERT INTO public.lesson_scripts (lesson_id, sequence_order, speaker, script_text, section_title) VALUES
    (l6_fr,  1, 'ai',       'Excuse-moi, ce bus arrive quand ?', '### 1. 친구 만나러 가는 길, 버스 정류장에서'),
    (l6_fr,  2, 'user',     'Pardon ?', NULL),
    (l6_fr,  3, 'ai',       'Ce bus arrive quand ?', NULL),
    (l6_fr,  4, 'user',     'Tu peux parler un peu plus lentement ? Je n''ai pas compris. Je ne suis pas locutrice native. Qu''est-ce que tu as dit ?', NULL),
    (l6_fr,  5, 'ai',       'Je disais, ce bus arrive quand.', NULL),
    (l6_fr,  6, 'user',     'Ah, il vient juste de passer.', NULL),
    (l6_fr,  7, 'ai',       'Ah non, j''aurais dû le prendre.', NULL),
    (l6_fr,  8, 'user',     'Dommage.', NULL),
    (l6_fr,  9, 'ai',       'En tout cas, merci.', NULL),
    (l6_fr, 10, 'ai',       'Ça va ces jours-ci ?', '### 2. 안부 묻기'),
    (l6_fr, 11, 'user',     'Je ne pourrais pas aller mieux. En ce moment je joue de la guitare. Hier aussi, j''ai joué toute la journée.', NULL),
    (l6_fr, 12, 'ai',       'Ça devait être super.', NULL),
    (l6_fr, 13, 'user',     'Oui. Et toi ?', NULL),
    (l6_fr, 14, 'ai',       'Comme d''habitude. <Toujours pareil, quoi.> Ces jours-ci je suis trop fatiguée.', NULL),
    (l6_fr, 15, 'user',     'Je te jure, moi aussi.', NULL),
    (l6_fr, 16, 'narrator', 'Soudain, une grand-mère pose un sac très lourd à côté.', NULL),
    (l6_fr, 17, 'user',     'Je vais vous aider. Vous allez bien ?', NULL),
    (l6_fr, 18, 'narrator', 'Grand-mère : Merci beaucoup. Tu m''as vraiment sauvée !', NULL),
    (l6_fr, 19, 'narrator', 'Elle revient à la conversation.', NULL),
    (l6_fr, 20, 'ai',       'C''est vraiment gentil de ta part.', NULL),
    (l6_fr, 21, 'user',     'Désolée, tu peux répéter la dernière partie ?', NULL),
    (l6_fr, 22, 'ai',       'Ah, ce n''est rien de spécial, mais je crois que je suis un peu fatiguée en ce moment.', NULL),
    (l6_fr, 23, 'user',     'Ah oui, il s''est passé quelque chose ? Raconte-moi.', NULL),
    (l6_fr, 24, 'ai',       'Je n''ai pas eu le poste.', NULL),
    (l6_fr, 25, 'user',     'C''est dommage. Ne pas reconnaître un talent pareil !', NULL),
    (l6_fr, 26, 'ai',       'Grave hahaha, oui c''est un peu dommage...', NULL),
    (l6_fr, 27, 'user',     'Ça doit être dur, mais ça va aller. Tu peux le faire.', NULL),
    (l6_fr, 28, 'ai',       'Merci de m''avoir écoutée aujourd''hui. Grâce à toi, je me sens mieux.', NULL),
    (l6_fr, 29, 'user',     'Mais non, c''est moi qui te remercie. Merci de m''en avoir parlé. On se voit samedi.', NULL),
    (l6_fr, 30, 'ai',       'Carrément, on va boire un verre ?', NULL),
    (l6_fr, 31, 'user',     'Ah, cette fois je ne peux pas. On se voit la semaine prochaine à la place ? On pourrait boire un verre à ce moment-là.', NULL),
    (l6_fr, 32, 'ai',       'Trop bien. Je suis totalement partante.', NULL),
    (l6_fr, 33, 'user',     'J''ai eu une promotion !', NULL),
    (l6_fr, 34, 'ai',       'Trop bien ! C''est énorme !', '### 3. 이후 술집에서'),
    (l6_fr, 35, 'ai',       'Tu le mérites. Je savais que tu allais y arriver.', NULL),
    (l6_fr, 36, 'user',     'Merci. J''ai encore du mal à y croire. C''est la première fois que j''ai un poste de management, donc ça me fait un peu peur.', NULL),
    (l6_fr, 37, 'ai',       'C''est énorme. Pourquoi tu doutes de toi ? Tu vas très bien t''en sortir.', NULL),
    (l6_fr, 38, 'user',     'Tu crois vraiment ?', NULL),
    (l6_fr, 39, 'ai',       'Vas-y. Je te soutiens.', NULL),
    (l6_fr, 40, 'user',     'Merci. Alors je vais prendre mon courage et essayer.', NULL),
    (l6_fr, 41, 'ai',       'Tu as bien fait. Je suis là pour toi.', NULL)
  ON CONFLICT (lesson_id, sequence_order) DO NOTHING;

  -- ── script_6_de ───────────────────────────────────────────
  INSERT INTO public.lesson_scripts (lesson_id, sequence_order, speaker, script_text, section_title) VALUES
    (l6_de,  1, 'ai',       'Weißt du, wann dieser Bus kommt?', '### 1. 친구 만나러 가는 길, 버스 정류장에서'),
    (l6_de,  2, 'user',     'Hä? Wie bitte?', NULL),
    (l6_de,  3, 'ai',       'Wann kommt dieser Bus?', NULL),
    (l6_de,  4, 'user',     'Kannst du etwas langsamer sprechen? Ich habe es nicht verstanden. Ich bin keine Muttersprachlerin. Was war das?', NULL),
    (l6_de,  5, 'ai',       'Ich sagte, wann dieser Bus kommt.', NULL),
    (l6_de,  6, 'user',     'Ah, der ist gerade weg.', NULL),
    (l6_de,  7, 'ai',       'Mist, den hätte ich nehmen sollen.', NULL),
    (l6_de,  8, 'user',     'Zu schade.', NULL),
    (l6_de,  9, 'ai',       'Egal, danke dir.', NULL),
    (l6_de, 10, 'ai',       'Wie geht''s dir in letzter Zeit?', '### 2. 안부 묻기'),
    (l6_de, 11, 'user',     'Besser geht''s nicht. Ich spiele in letzter Zeit Gitarre. Gestern habe ich sogar den ganzen Tag Gitarre gespielt.', NULL),
    (l6_de, 12, 'ai',       'Das muss Spaß gemacht haben.', NULL),
    (l6_de, 13, 'user',     'Ja. Und du?', NULL),
    (l6_de, 14, 'ai',       'Wie immer. <Wie immer halt.> Ich bin in letzter Zeit so müde.', NULL),
    (l6_de, 15, 'user',     'Genau, ich auch.', NULL),
    (l6_de, 16, 'narrator', 'Plötzlich stellt eine Oma neben ihnen schweres Gepäck ab.', NULL),
    (l6_de, 17, 'user',     'Ich helfe Ihnen. Geht''s Ihnen gut?', NULL),
    (l6_de, 18, 'narrator', 'Oma: Vielen lieben Dank. Du hast mir wirklich geholfen!', NULL),
    (l6_de, 19, 'narrator', 'Sie kommen wieder zurück.', NULL),
    (l6_de, 20, 'ai',       'Das ist wirklich nett von dir.', NULL),
    (l6_de, 21, 'user',     'Sorry, kannst du den letzten Teil nochmal sagen?', NULL),
    (l6_de, 22, 'ai',       'Ach, nichts Besonderes, aber ich glaube, ich bin in letzter Zeit etwas müde.', NULL),
    (l6_de, 23, 'user',     'Ah stimmt, ist etwas passiert? Erzähl mal.', NULL),
    (l6_de, 24, 'ai',       'Ich habe den Job nicht bekommen.', NULL),
    (l6_de, 25, 'user',     'Wie schade. So ein Talent nicht zu erkennen!', NULL),
    (l6_de, 26, 'ai',       'Stimmt hahaha, ist schon schade...', NULL),
    (l6_de, 27, 'user',     'Das muss hart sein, aber es wird schon. Du schaffst das.', NULL),
    (l6_de, 28, 'ai',       'Danke, dass du mir heute zugehört hast. Mir geht''s dank dir besser.', NULL),
    (l6_de, 29, 'user',     'Ach was, eher danke ich dir. Danke, dass du''s erzählt hast. Lass uns am Samstag treffen.', NULL),
    (l6_de, 30, 'ai',       'Klingt gut, wollen wir was trinken gehen?', NULL),
    (l6_de, 31, 'user',     'Ah, dieses Mal geht''s bei mir nicht. Wie wäre es stattdessen nächste Woche? Dann könnten wir was trinken gehen.', NULL),
    (l6_de, 32, 'ai',       'Sehr gern. Ich bin voll dabei.', NULL),
    (l6_de, 33, 'user',     'Ich wurde befördert!', NULL),
    (l6_de, 34, 'ai',       'Glückwunsch! Das ist ja mega!', '### 3. 이후 술집에서'),
    (l6_de, 35, 'ai',       'Du hast es verdient. Ich wusste, dass du das schaffst.', NULL),
    (l6_de, 36, 'user',     'Danke. Es fühlt sich noch nicht echt an. Es ist mein erstes Mal in einer Führungsrolle, deshalb habe ich ein bisschen Angst.', NULL),
    (l6_de, 37, 'ai',       'Das ist wirklich eine große Sache. Warum zweifelst du an dir? Du wirst das super machen.', NULL),
    (l6_de, 38, 'user',     'Glaubst du wirklich?', NULL),
    (l6_de, 39, 'ai',       'Versuch''s. Ich feuere dich an.', NULL),
    (l6_de, 40, 'user',     'Danke. Dann nehme ich meinen Mut zusammen und probiere es.', NULL),
    (l6_de, 41, 'ai',       'Gute Entscheidung. Ich stehe hinter dir.', NULL)
  ON CONFLICT (lesson_id, sequence_order) DO NOTHING;

  -- ── script_6_zh ───────────────────────────────────────────
  INSERT INTO public.lesson_scripts (lesson_id, sequence_order, speaker, script_text, section_title) VALUES
    (l6_zh,  1, 'ai',       '请问这辆公交什么时候来？', '### 1. 친구 만나러 가는 길, 버스 정류장에서'),
    (l6_zh,  2, 'user',     '啊？不好意思？', NULL),
    (l6_zh,  3, 'ai',       '这辆公交什么时候到？', NULL),
    (l6_zh,  4, 'user',     '你可以说慢一点吗？我没听懂。我不是母语者。你刚刚说什么？', NULL),
    (l6_zh,  5, 'ai',       '我说这辆公交什么时候来。', NULL),
    (l6_zh,  6, 'user',     '啊，刚刚开走了。', NULL),
    (l6_zh,  7, 'ai',       '哎呀，这班我应该坐的。', NULL),
    (l6_zh,  8, 'user',     '太可惜了。', NULL),
    (l6_zh,  9, 'ai',       '总之谢谢你。', NULL),
    (l6_zh, 10, 'ai',       '最近过得怎么样？', '### 2. 안부 묻기'),
    (l6_zh, 11, 'user',     '好得不能再好了。最近我在弹吉他。昨天也弹了一整天。', NULL),
    (l6_zh, 12, 'ai',       '那一定很有意思。', NULL),
    (l6_zh, 13, 'user',     '对。你呢？', NULL),
    (l6_zh, 14, 'ai',       '老样子。<还是老样子啦。> 最近太累了。', NULL),
    (l6_zh, 15, 'user',     '就是啊，我也是。', NULL),
    (l6_zh, 16, 'narrator', '突然旁边一位奶奶放下了很重的行李。', NULL),
    (l6_zh, 17, 'user',     '我来帮您。您还好吗？', NULL),
    (l6_zh, 18, 'narrator', '奶奶：太谢谢你了。你真是帮了我大忙！', NULL),
    (l6_zh, 19, 'narrator', '回到对话。', NULL),
    (l6_zh, 20, 'ai',       '你真是太善良了。', NULL),
    (l6_zh, 21, 'user',     '不好意思，你能再说一下最后那部分吗？', NULL),
    (l6_zh, 22, 'ai',       '啊，也没什么大事，就是我最近有点累。', NULL),
    (l6_zh, 23, 'user',     '啊对，发生什么了吗？跟我说说。', NULL),
    (l6_zh, 24, 'ai',       '我面试没过。', NULL),
    (l6_zh, 25, 'user',     '太可惜了。居然看不出你这么有实力！', NULL),
    (l6_zh, 26, 'ai',       '对吧哈哈哈，是挺可惜的...', NULL),
    (l6_zh, 27, 'user',     '肯定很难受，不过没事。你一定可以的。', NULL),
    (l6_zh, 28, 'ai',       '谢谢你今天听我说。多亏你，我心情好多了。', NULL),
    (l6_zh, 29, 'user',     '别这么说。反而是我谢谢你。谢谢你愿意告诉我。我们周六见吧。', NULL),
    (l6_zh, 30, 'ai',       '好啊，要不要去喝一杯？', NULL),
    (l6_zh, 31, 'user',     '啊，这次可能不行。那下周见怎么样？到时候我们可以喝一杯。', NULL),
    (l6_zh, 32, 'ai',       '太好了。我完全同意。', NULL),
    (l6_zh, 33, 'user',     '我升职了！', NULL),
    (l6_zh, 34, 'ai',       '太棒了！太厉害了！', '### 3. 이후 술집에서'),
    (l6_zh, 35, 'ai',       '这是你应得的。我就知道你一定行。', NULL),
    (l6_zh, 36, 'user',     '谢谢。我现在还没什么实感。第一次做管理岗，有点害怕。', NULL),
    (l6_zh, 37, 'ai',       '这可是大事啊。你为什么没自信？你很擅长这种事。你一定会做得很好。', NULL),
    (l6_zh, 38, 'user',     '真的会吗？', NULL),
    (l6_zh, 39, 'ai',       '去做吧。我支持你。', NULL),
    (l6_zh, 40, 'user',     '谢谢。那我鼓起勇气试试看。', NULL),
    (l6_zh, 41, 'ai',       '这个决定很好。我会一直支持你。', NULL)
  ON CONFLICT (lesson_id, sequence_order) DO NOTHING;

  -- ── script_6_ja ───────────────────────────────────────────
  INSERT INTO public.lesson_scripts (lesson_id, sequence_order, speaker, script_text, section_title) VALUES
    (l6_ja,  1, 'ai',       'このバス、いつ来ますか？', '### 1. 친구 만나러 가는 길, 버스 정류장에서'),
    (l6_ja,  2, 'user',     'え？ごめん？', NULL),
    (l6_ja,  3, 'ai',       'このバス、いつ来るの？', NULL),
    (l6_ja,  4, 'user',     'もう少しゆっくり話してくれる？聞き取れなかった。私はネイティブじゃないから。今なんて言った？', NULL),
    (l6_ja,  5, 'ai',       'このバスがいつ来るかって。', NULL),
    (l6_ja,  6, 'user',     'あ、今行っちゃったよ。', NULL),
    (l6_ja,  7, 'ai',       'うわ、あれ乗ればよかった。', NULL),
    (l6_ja,  8, 'user',     '残念だね。', NULL),
    (l6_ja,  9, 'ai',       'とにかくありがとう。', NULL),
    (l6_ja, 10, 'ai',       '最近どう？', '### 2. 안부 묻기'),
    (l6_ja, 11, 'user',     '最高だよ。これ以上ないくらい。最近ギター弾いてる。昨日も一日中弾いてた。', NULL),
    (l6_ja, 12, 'ai',       'それは楽しそうだったね。', NULL),
    (l6_ja, 13, 'user',     'うん。君は？', NULL),
    (l6_ja, 14, 'ai',       'いつも通り。<まあ、いつも通りかな。> 最近すごく疲れてる。', NULL),
    (l6_ja, 15, 'user',     'わかる、私も。', NULL),
    (l6_ja, 16, 'narrator', '突然、隣でおばあさんが重い荷物を置く。', NULL),
    (l6_ja, 17, 'user',     'お手伝いします。大丈夫ですか？', NULL),
    (l6_ja, 18, 'narrator', 'おばあさん：本当にありがとう。助かったよ！', NULL),
    (l6_ja, 19, 'narrator', 'また会話に戻る。', NULL),
    (l6_ja, 20, 'ai',       '本当に優しいね。', NULL),
    (l6_ja, 21, 'user',     'ごめん、最後のところもう一回言ってくれる？', NULL),
    (l6_ja, 22, 'ai',       'あ、たいしたことじゃないんだけど、最近ちょっと疲れてる気がして。', NULL),
    (l6_ja, 23, 'user',     'あ、そっか。何かあった？話して。', NULL),
    (l6_ja, 24, 'ai',       '面接落ちたんだ。', NULL),
    (l6_ja, 25, 'user',     '残念だね。こんな人材を見抜けないなんて！', NULL),
    (l6_ja, 26, 'ai',       'でしょｗｗ まあ、ちょっと悔しい...', NULL),
    (l6_ja, 27, 'user',     'つらいと思うけど大丈夫。君ならできるよ。', NULL),
    (l6_ja, 28, 'ai',       '今日話を聞いてくれてありがとう。おかげで気分がよくなった。', NULL),
    (l6_ja, 29, 'user',     'そんなことないよ。むしろ私こそありがとう。話してくれてありがとう。土曜日に会おう。', NULL),
    (l6_ja, 30, 'ai',       'いいね、一杯行く？', NULL),
    (l6_ja, 31, 'user',     'あ、今回は難しそう。来週にしない？そのとき一杯飲もうよ。', NULL),
    (l6_ja, 32, 'ai',       'めっちゃいい。大賛成。', NULL),
    (l6_ja, 33, 'user',     '昇進した！', NULL),
    (l6_ja, 34, 'ai',       'よかった！最高じゃん！', '### 3. 이후 술집에서'),
    (l6_ja, 35, 'ai',       '君にふさわしいよ。絶対できるって思ってた。', NULL),
    (l6_ja, 36, 'user',     'ありがとう。まだ実感がないんだ。管理職を任されるの初めてで、ちょっと怖くて。', NULL),
    (l6_ja, 37, 'ai',       'それは本当に大きなことだよ。なんで自信ないの？君なら絶対できるよ。', NULL),
    (l6_ja, 38, 'user',     '本当にそうかな？', NULL),
    (l6_ja, 39, 'ai',       'やってみな。私は君の味方だよ。', NULL),
    (l6_ja, 40, 'user',     'ありがとう。じゃあ勇気出してやってみる。', NULL),
    (l6_ja, 41, 'ai',       'いい判断だよ。私がついてる。', NULL)
  ON CONFLICT (lesson_id, sequence_order) DO NOTHING;

END $$;
