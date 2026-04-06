-- ============================================================
-- 012_fix_script_errors.sql
-- QA fixes across all 6 target languages:
--
-- FIX 1+2: script_2 seq 24-25 speaker swap
--          seq24 user→ai (cashier returns card), seq25 ai→user (customer thanks)
-- FIX 3:   script_6 seq 14 — remove <...> style notation, keep natural form
-- FIX 4:   script_5 — insert narrator row at seq 1, add section_titles
--          (requires DELETE + re-INSERT with new seq numbering)
-- FIX 5:   script_6 seq 21 — simpler "where were we? The last part?" style
-- FIX 6:   script_6 seq 29 — replace specific "Saturday" reference with open-ended
-- ============================================================
DO $$
DECLARE
  en_id UUID; es_id UUID; de_id UUID; fr_id UUID;
  zh_id UUID; ja_id UUID;

  l2_en UUID; l2_es UUID; l2_fr UUID; l2_de UUID; l2_zh UUID; l2_ja UUID;
  l5_en UUID; l5_es UUID; l5_fr UUID; l5_de UUID; l5_zh UUID; l5_ja UUID;
  l6_en UUID; l6_es UUID; l6_fr UUID; l6_de UUID; l6_zh UUID; l6_ja UUID;
BEGIN
  -- ── Language IDs ─────────────────────────────────────────
  SELECT id INTO en_id FROM public.languages WHERE code = 'en';
  SELECT id INTO es_id FROM public.languages WHERE code = 'es';
  SELECT id INTO de_id FROM public.languages WHERE code = 'de';
  SELECT id INTO fr_id FROM public.languages WHERE code = 'fr';
  SELECT id INTO zh_id FROM public.languages WHERE code = 'zh';
  SELECT id INTO ja_id FROM public.languages WHERE code = 'ja';

  -- ── Lesson IDs ───────────────────────────────────────────
  SELECT id INTO l2_en FROM public.lessons WHERE language_id = en_id AND native_language_id IS NULL AND step_number = 2;
  SELECT id INTO l2_es FROM public.lessons WHERE language_id = es_id AND native_language_id IS NULL AND step_number = 2;
  SELECT id INTO l2_fr FROM public.lessons WHERE language_id = fr_id AND native_language_id IS NULL AND step_number = 2;
  SELECT id INTO l2_de FROM public.lessons WHERE language_id = de_id AND native_language_id IS NULL AND step_number = 2;
  SELECT id INTO l2_zh FROM public.lessons WHERE language_id = zh_id AND native_language_id IS NULL AND step_number = 2;
  SELECT id INTO l2_ja FROM public.lessons WHERE language_id = ja_id AND native_language_id IS NULL AND step_number = 2;

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
  -- FIX 1+2: script_2 seq 24→ai, seq 25→user (all 6 languages)
  -- ══════════════════════════════════════════════════════════
  UPDATE public.lesson_scripts SET speaker = 'ai'
    WHERE sequence_order = 24
      AND lesson_id IN (l2_en, l2_es, l2_fr, l2_de, l2_zh, l2_ja);

  UPDATE public.lesson_scripts SET speaker = 'user'
    WHERE sequence_order = 25
      AND lesson_id IN (l2_en, l2_es, l2_fr, l2_de, l2_zh, l2_ja);

  -- ══════════════════════════════════════════════════════════
  -- FIX 3: script_6 seq 14 — natural form only, no <...>
  -- ══════════════════════════════════════════════════════════
  UPDATE public.lesson_scripts SET script_text = 'Same as always, you know. I''m so tired these days.'
    WHERE lesson_id = l6_en AND sequence_order = 14;
  UPDATE public.lesson_scripts SET script_text = 'Lo de siempre, pues. Estos días estoy muy cansada.'
    WHERE lesson_id = l6_es AND sequence_order = 14;
  UPDATE public.lesson_scripts SET script_text = 'Toujours pareil, quoi. Ces jours-ci je suis trop fatiguée.'
    WHERE lesson_id = l6_fr AND sequence_order = 14;
  UPDATE public.lesson_scripts SET script_text = 'Wie immer halt. Ich bin in letzter Zeit so müde.'
    WHERE lesson_id = l6_de AND sequence_order = 14;
  UPDATE public.lesson_scripts SET script_text = '还是老样子啦。最近太累了。'
    WHERE lesson_id = l6_zh AND sequence_order = 14;
  UPDATE public.lesson_scripts SET script_text = 'まあ、いつも通りかな。最近すごく疲れてる。'
    WHERE lesson_id = l6_ja AND sequence_order = 14;

  -- ══════════════════════════════════════════════════════════
  -- FIX 4: script_5 — add narrator row + section_titles
  -- Structure: narrator(1) + 16 dialogue rows = 17 total
  -- Section 1 (1. 네트워킹 행사에서): seq 1-5
  -- Section 2 (2. 취미 묻기):         seq 6-9
  -- Section 3 (3. 친구 맺기):         seq 10-17
  -- section_title on first AI row of each section:
  --   seq 2 (ai), seq 6 (ai), seq 11 (ai)
  -- ══════════════════════════════════════════════════════════
  -- Delete progress references first (FK constraint)
  DELETE FROM public.user_lesson_progress
    WHERE script_id IN (
      SELECT id FROM public.lesson_scripts
        WHERE lesson_id IN (l5_en, l5_es, l5_fr, l5_de, l5_zh, l5_ja)
    );
  DELETE FROM public.lesson_scripts
    WHERE lesson_id IN (l5_en, l5_es, l5_fr, l5_de, l5_zh, l5_ja);

  -- ── script_5_en ───────────────────────────────────────────
  INSERT INTO public.lesson_scripts (lesson_id, sequence_order, speaker, script_text, section_title) VALUES
    (l5_en,  1, 'narrator', 'At a networking event. A stranger walks over.', NULL),
    (l5_en,  2, 'ai',       'Hi, how did you hear about this place?', '### 1. 네트워킹 행사에서'),
    (l5_en,  3, 'user',     'I found it through an online meetup! It''s my first time at a networking event like this, so I''m really nervous. And I''m not very good at English.', NULL),
    (l5_en,  4, 'ai',       'No, you''re doing great.', NULL),
    (l5_en,  5, 'user',     'Haha, thank you.', NULL),
    (l5_en,  6, 'ai',       'What do you usually do? What are your hobbies?', '### 2. 취미 묻기'),
    (l5_en,  7, 'user',     'Vibe coding is really popular these days, right? So I''m building an app. I finished one last month. Want to see it?', NULL),
    (l5_en,  8, 'ai',       'Wow, that''s impressive. I made something recently too. Want to see it?', NULL),
    (l5_en,  9, 'user',     'I''d love to!', NULL),
    (l5_en, 10, 'user',     'Ah, what are your hobbies?', NULL),
    (l5_en, 11, 'ai',       'I usually like listening to music.', '### 3. 친구 맺기'),
    (l5_en, 12, 'user',     'Me too! Actually, I''m a drummer. I even played a band show last month. What kind of music do you like?', NULL),
    (l5_en, 13, 'ai',       'Wow, that''s awesome! I''m in a band too. I like band music and rock.', NULL),
    (l5_en, 14, 'user',     'Wow, me too! We really click.', NULL),
    (l5_en, 15, 'ai',       'I have another show next month. Want to come?', NULL),
    (l5_en, 16, 'user',     'I''d love that! Can I get your Instagram? Let''s be friends!', NULL),
    (l5_en, 17, 'ai',       'Sure!', NULL);

  -- ── script_5_es ───────────────────────────────────────────
  INSERT INTO public.lesson_scripts (lesson_id, sequence_order, speaker, script_text, section_title) VALUES
    (l5_es,  1, 'narrator', 'En un evento de networking. Un desconocido se acerca.', NULL),
    (l5_es,  2, 'ai',       'Hola, ¿cómo llegaste aquí?', '### 1. 네트워킹 행사에서'),
    (l5_es,  3, 'user',     '¡Lo vi en un meetup en línea y vine! Es la primera vez que vengo a un evento de networking así, así que estoy muy nerviosa. Y no hablo muy bien español.', NULL),
    (l5_es,  4, 'ai',       'No, lo estás haciendo muy bien.', NULL),
    (l5_es,  5, 'user',     'Jaja, gracias.', NULL),
    (l5_es,  6, 'ai',       '¿Qué haces normalmente? ¿Cuáles son tus pasatiempos?', '### 2. 취미 묻기'),
    (l5_es,  7, 'user',     'Últimamente vibe coding está de moda, ¿no? Por eso estoy haciendo una app. Terminé una el mes pasado, ¿quieres verla?', NULL),
    (l5_es,  8, 'ai',       '¡Guau, qué increíble! Yo también hice algo hace poco, ¿quieres verlo?', NULL),
    (l5_es,  9, 'user',     '¡Me encanta la idea!', NULL),
    (l5_es, 10, 'user',     'Ah, ¿y cuáles son tus pasatiempos?', NULL),
    (l5_es, 11, 'ai',       'Normalmente me gusta escuchar música.', '### 3. 친구 맺기'),
    (l5_es, 12, 'user',     '¡A mí también! De hecho, soy baterista. El mes pasado incluso toqué en un concierto con mi banda. ¿Qué tipo de música te gusta?', NULL),
    (l5_es, 13, 'ai',       '¡Guau, qué genial! Yo también estoy en una banda. Me gusta la música de banda y el rock.', NULL),
    (l5_es, 14, 'user',     '¡Guau, a mí también! Tenemos mucha química.', NULL),
    (l5_es, 15, 'ai',       'El próximo mes también tengo concierto, ¿quieres venir?', NULL),
    (l5_es, 16, 'user',     '¡Me encantaría! ¿Me pasas tu Instagram? ¡Seamos amigas!', NULL),
    (l5_es, 17, 'ai',       '¡Claro!', NULL);

  -- ── script_5_fr ───────────────────────────────────────────
  INSERT INTO public.lesson_scripts (lesson_id, sequence_order, speaker, script_text, section_title) VALUES
    (l5_fr,  1, 'narrator', 'Lors d''un événement networking. Un inconnu s''approche.', NULL),
    (l5_fr,  2, 'ai',       'Bonjour, comment tu es arrivé(e) ici ?', '### 1. 네트워킹 행사에서'),
    (l5_fr,  3, 'user',     'Je l''ai vu sur un meetup en ligne et je suis venue ! C''est la première fois que je viens à ce genre d''événement de networking, donc je suis super stressée. Et je ne parle pas très bien français.', NULL),
    (l5_fr,  4, 'ai',       'Mais non, tu te débrouilles très bien.', NULL),
    (l5_fr,  5, 'user',     'Haha, merci.', NULL),
    (l5_fr,  6, 'ai',       'D''habitude, tu fais quoi ? C''est quoi tes hobbies ?', '### 2. 취미 묻기'),
    (l5_fr,  7, 'user',     'En ce moment, le vibe coding est à la mode, non ? Du coup je suis en train de créer une appli. J''en ai terminé une le mois dernier, tu veux voir ?', NULL),
    (l5_fr,  8, 'ai',       'Waouh, c''est impressionnant ! Moi aussi, j''ai créé quelque chose récemment, tu veux voir ?', NULL),
    (l5_fr,  9, 'user',     'J''adore !', NULL),
    (l5_fr, 10, 'user',     'Ah, et toi, c''est quoi tes hobbies ?', NULL),
    (l5_fr, 11, 'ai',       'Moi, en général, j''aime écouter de la musique.', '### 3. 친구 맺기'),
    (l5_fr, 12, 'user',     'Moi aussi ! En fait, je suis batteuse. J''ai même fait un concert avec mon groupe le mois dernier. Tu aimes quel genre de musique ?', NULL),
    (l5_fr, 13, 'ai',       'Waouh, trop bien ! Moi aussi je fais partie d''un groupe. J''aime la musique de groupe et le rock.', NULL),
    (l5_fr, 14, 'user',     'Waouh, moi aussi ! On s''entend super bien.', NULL),
    (l5_fr, 15, 'ai',       'J''ai encore un concert le mois prochain, tu veux venir ?', NULL),
    (l5_fr, 16, 'user',     'Avec grand plaisir ! Tu peux me donner ton Instagram ? On devient amies !', NULL),
    (l5_fr, 17, 'ai',       'Avec plaisir !', NULL);

  -- ── script_5_de ───────────────────────────────────────────
  INSERT INTO public.lesson_scripts (lesson_id, sequence_order, speaker, script_text, section_title) VALUES
    (l5_de,  1, 'narrator', 'Bei einem Networking-Event. Eine fremde Person kommt heran.', NULL),
    (l5_de,  2, 'ai',       'Hallo, wie bist du hierher gekommen?', '### 1. 네트워킹 행사에서'),
    (l5_de,  3, 'user',     'Ich habe es bei einem Online-Meetup gesehen und bin gekommen! Es ist mein erstes Networking-Event dieser Art, deshalb bin ich total nervös. Und ich bin nicht gut in Deutsch.', NULL),
    (l5_de,  4, 'ai',       'Nein, du machst das doch gut.', NULL),
    (l5_de,  5, 'user',     'Haha, danke.', NULL),
    (l5_de,  6, 'ai',       'Was machst du normalerweise so? Was sind deine Hobbys?', '### 2. 취미 묻기'),
    (l5_de,  7, 'user',     'Vibe Coding ist ja gerade im Trend, oder? Deshalb baue ich eine App. Letzten Monat habe ich eine fertiggestellt, möchtest du sie sehen?', NULL),
    (l5_de,  8, 'ai',       'Wow, das ist beeindruckend. Ich habe auch neulich etwas gemacht, möchtest du es sehen?', NULL),
    (l5_de,  9, 'user',     'Sehr gern!', NULL),
    (l5_de, 10, 'user',     'Ah, was sind denn deine Hobbys?', NULL),
    (l5_de, 11, 'ai',       'Ich höre normalerweise gern Musik.', '### 3. 친구 맺기'),
    (l5_de, 12, 'user',     'Ich auch! Eigentlich bin ich Schlagzeugerin. Letzten Monat hatte ich sogar einen Bandauftritt. Welche Musik magst du?', NULL),
    (l5_de, 13, 'ai',       'Wow, wie cool! Ich spiele auch in einer Band. Ich mag Bandmusik und Rockmusik.', NULL),
    (l5_de, 14, 'user',     'Wow, ich auch! Wir passen echt gut zusammen.', NULL),
    (l5_de, 15, 'ai',       'Ich habe nächsten Monat wieder einen Auftritt, kommst du?', NULL),
    (l5_de, 16, 'user',     'Sehr gern! Gibst du mir dein Instagram? Lass uns Freunde sein!', NULL),
    (l5_de, 17, 'ai',       'Gerne!', NULL);

  -- ── script_5_zh ───────────────────────────────────────────
  INSERT INTO public.lesson_scripts (lesson_id, sequence_order, speaker, script_text, section_title) VALUES
    (l5_zh,  1, 'narrator', '在一个networking活动上，一个陌生人走了过来。', NULL),
    (l5_zh,  2, 'ai',       '你好，你是怎么来这里的？', '### 1. 네트워킹 행사에서'),
    (l5_zh,  3, 'user',     '我是在线上 meetup 看到后来的！这种 networking 活动我还是第一次来，特别紧张。而且我不太会说中文。', NULL),
    (l5_zh,  4, 'ai',       '没有，你说得很好啊。', NULL),
    (l5_zh,  5, 'user',     '哈哈，谢谢。', NULL),
    (l5_zh,  6, 'ai',       '你平时都做什么？有什么爱好吗？', '### 2. 취미 묻기'),
    (l5_zh,  7, 'user',     '最近 vibe coding 很流行嘛。所以我在做 app。上个月刚完成一个，你要看看吗？', NULL),
    (l5_zh,  8, 'ai',       '哇，好厉害！我最近也做了一个，要不要看看？', NULL),
    (l5_zh,  9, 'user',     '太好了！', NULL),
    (l5_zh, 10, 'user',     '啊，那你有什么爱好？', NULL),
    (l5_zh, 11, 'ai',       '我平时比较喜欢听歌。', '### 3. 친구 맺기'),
    (l5_zh, 12, 'user',     '我也是！其实我是鼓手。上个月还参加了乐队演出。你喜欢什么歌？', NULL),
    (l5_zh, 13, 'ai',       '哇，太棒了！我也玩乐队。我喜欢乐队音乐和摇滚。', NULL),
    (l5_zh, 14, 'user',     '哇我也是！我们很合拍耶。', NULL),
    (l5_zh, 15, 'ai',       '我下个月也有演出，你要来吗？', NULL),
    (l5_zh, 16, 'user',     '太好了！可以告诉我你的 Instagram 吗？我们加个朋友吧！', NULL),
    (l5_zh, 17, 'ai',       '好啊！', NULL);

  -- ── script_5_ja ───────────────────────────────────────────
  INSERT INTO public.lesson_scripts (lesson_id, sequence_order, speaker, script_text, section_title) VALUES
    (l5_ja,  1, 'narrator', 'ネットワーキングイベントにて。見知らぬ人が話しかけてくる。', NULL),
    (l5_ja,  2, 'ai',       'こんにちは、どうやってここに来たんですか？', '### 1. 네트워킹 행사에서'),
    (l5_ja,  3, 'user',     'オンラインのミートアップで見て来ました！こういうネットワーキングイベントは初めてなので、すごく緊張しています。それに、日本語があまり上手じゃないです。', NULL),
    (l5_ja,  4, 'ai',       'いいえ、上手ですよ。', NULL),
    (l5_ja,  5, 'user',     'はは、ありがとうございます。', NULL),
    (l5_ja,  6, 'ai',       '普段は何をしていますか？趣味は何ですか？', '### 2. 취미 묻기'),
    (l5_ja,  7, 'user',     '最近 vibe coding が流行ってるじゃないですか。だからアプリを作ってます。先月ひとつ完성したんですけど、見ますか？', NULL),
    (l5_ja,  8, 'ai',       'わあ、すごいですね。私も最近作ったものがあるんですが、見ますか？', NULL),
    (l5_ja,  9, 'user',     'ぜひ！', NULL),
    (l5_ja, 10, 'user',     'あ、あなたの趣味は何ですか？', NULL),
    (l5_ja, 11, 'ai',       '私は普段、音楽を聴くのが好きです。', '### 3. 친구 맺기'),
    (l5_ja, 12, 'user',     '私もです！実は私、ドラマーなんです。先月はバンドのライブもしました。どんな音楽が好きですか？', NULL),
    (l5_ja, 13, 'ai',       'わあ、すごい！私もバンドやってます。バンド音楽とロックが好きです。', NULL),
    (l5_ja, 14, 'user',     'わあ、私もです！私たち気が合いますね。', NULL),
    (l5_ja, 15, 'ai',       '来月もライブがあるんですが、来ますか？', NULL),
    (l5_ja, 16, 'user',     'すごくいいですね！インスタ教えてもらえますか？友達になりましょう！', NULL),
    (l5_ja, 17, 'ai',       'いいですよ！', NULL);

  -- ══════════════════════════════════════════════════════════
  -- FIX 5: script_6 seq 21 — casual "where were we? The last part?" style
  -- ══════════════════════════════════════════════════════════
  UPDATE public.lesson_scripts SET script_text = 'Sorry, where were we? The last part?'
    WHERE lesson_id = l6_en AND sequence_order = 21;
  UPDATE public.lesson_scripts SET script_text = 'Perdón, ¿por dónde íbamos? ¿La última parte?'
    WHERE lesson_id = l6_es AND sequence_order = 21;
  UPDATE public.lesson_scripts SET script_text = 'Désolée, on en était où ? La dernière partie ?'
    WHERE lesson_id = l6_fr AND sequence_order = 21;
  UPDATE public.lesson_scripts SET script_text = 'Sorry, wo waren wir? Der letzte Teil?'
    WHERE lesson_id = l6_de AND sequence_order = 21;
  UPDATE public.lesson_scripts SET script_text = '不好意思，我们刚才说到哪了？最后那部分？'
    WHERE lesson_id = l6_zh AND sequence_order = 21;
  UPDATE public.lesson_scripts SET script_text = 'ごめん、どこまで話してたっけ？最後のところ？'
    WHERE lesson_id = l6_ja AND sequence_order = 21;

  -- ══════════════════════════════════════════════════════════
  -- FIX 6: script_6 seq 29 — casual tone, open invite (no specific day)
  --        flows into seq30 ai "Want to grab a drink?" → seq31 user "I can't this time"
  -- ══════════════════════════════════════════════════════════
  UPDATE public.lesson_scripts SET script_text = 'Nah, thank YOU! Thanks for opening up. We should hang out more often!'
    WHERE lesson_id = l6_en AND sequence_order = 29;
  UPDATE public.lesson_scripts SET script_text = '¡Qué va, gracias a ti! Gracias por contármelo. ¡Deberíamos quedar más seguido!'
    WHERE lesson_id = l6_es AND sequence_order = 29;
  UPDATE public.lesson_scripts SET script_text = 'Mais non, c''est moi ! Merci de m''avoir tout dit. On devrait se voir plus souvent !'
    WHERE lesson_id = l6_fr AND sequence_order = 29;
  UPDATE public.lesson_scripts SET script_text = 'Quatsch, ich danke dir! Danke, dass du mir alles erzählt hast. Wir sollten öfter was machen!'
    WHERE lesson_id = l6_de AND sequence_order = 29;
  UPDATE public.lesson_scripts SET script_text = '哪里哦，是我谢谢你！谢谢你告诉我这些。我们应该多聚聚！'
    WHERE lesson_id = l6_zh AND sequence_order = 29;
  UPDATE public.lesson_scripts SET script_text = 'そんなことないよ、こちらこそ！話してくれてありがとう。もっとよく会おうよ！'
    WHERE lesson_id = l6_ja AND sequence_order = 29;

END $$;
