-- ============================================================
-- 007_multilang_lessons.sql
-- Multi-language lesson support: section_title, narrator speaker,
-- native_language_id on lessons, and seed data for 5 languages + KO
-- ============================================================

-- ── 1. ALTER TABLE lesson_scripts ────────────────────────────

ALTER TABLE public.lesson_scripts
  ADD COLUMN IF NOT EXISTS section_title TEXT;

-- Replace CHECK constraint to include 'narrator'
ALTER TABLE public.lesson_scripts
  DROP CONSTRAINT IF EXISTS lesson_scripts_speaker_check;

ALTER TABLE public.lesson_scripts
  ADD CONSTRAINT lesson_scripts_speaker_check
    CHECK (speaker IN ('ai', 'user', 'narrator'));

-- ── 2. ALTER TABLE lessons ────────────────────────────────────

ALTER TABLE public.lessons
  ADD COLUMN IF NOT EXISTS native_language_id UUID REFERENCES public.languages(id);

-- Drop old two-column unique constraint
ALTER TABLE public.lessons
  DROP CONSTRAINT IF EXISTS lessons_language_id_step_number_key;

-- Add three-column unique constraint.
-- NULLS NOT DISTINCT (PG 15+) treats NULL = NULL so ON CONFLICT works
-- correctly for rows where native_language_id IS NULL.
ALTER TABLE public.lessons
  ADD CONSTRAINT lessons_language_id_native_language_id_step_number_key
    UNIQUE NULLS NOT DISTINCT (language_id, native_language_id, step_number);

-- ── 3. Seed lessons for es / de / fr / zh / ja (steps 1-6) ──
--      and Korean-native step-1 rows for all 6 target languages
-- ─────────────────────────────────────────────────────────────
DO $$
DECLARE
  en_id UUID; es_id UUID; de_id UUID; fr_id UUID;
  zh_id UUID; ja_id UUID; ko_id UUID;
  lang_id UUID;
BEGIN
  SELECT id INTO en_id FROM public.languages WHERE code = 'en';
  SELECT id INTO es_id FROM public.languages WHERE code = 'es';
  SELECT id INTO de_id FROM public.languages WHERE code = 'de';
  SELECT id INTO fr_id FROM public.languages WHERE code = 'fr';
  SELECT id INTO zh_id FROM public.languages WHERE code = 'zh';
  SELECT id INTO ja_id FROM public.languages WHERE code = 'ja';
  SELECT id INTO ko_id FROM public.languages WHERE code = 'ko';

  -- ── Steps 1-6 for es, de, fr, zh, ja (native_language_id = NULL) ──
  --    Same title / description / level_required / is_premium / sort_order
  --    as the English rows seeded in 003_lessons.sql.
  FOREACH lang_id IN ARRAY ARRAY[es_id, de_id, fr_id, zh_id, ja_id] LOOP
    INSERT INTO public.lessons
      (language_id, native_language_id, step_number, title, description, level_required, is_premium, sort_order)
    VALUES
      (lang_id, NULL, 1, 'Basic Grammar',        'Word order, statements, questions, commands',   'beginner',     FALSE, 1),
      (lang_id, NULL, 2, 'Café Conversation',    'Ordering drinks and food politely',              'beginner',     FALSE, 2),
      (lang_id, NULL, 3, 'Restaurant Talk',      'Reading menus, allergies, paying the bill',      'beginner',     FALSE, 3),
      (lang_id, NULL, 4, 'Supermarket',          'Asking for locations, quantities',               'beginner',     FALSE, 4),
      (lang_id, NULL, 5, 'Hobbies & Past',       'Past tense, passive voice, past participles',    'intermediate', FALSE, 5),
      (lang_id, NULL, 6, 'Reactions & Emotions', 'Emotional expressions, fillers, exclamations',   'intermediate', FALSE, 6)
    ON CONFLICT (language_id, native_language_id, step_number) DO NOTHING;
  END LOOP;

  -- ── Korean-native step-1 rows for all 6 target languages ──
  --    language_id  = target language (en / es / de / fr / zh / ja)
  --    native_language_id = ko
  --    step_number  = 1  (script_1)
  INSERT INTO public.lessons
    (language_id, native_language_id, step_number, title, description, level_required, is_premium, sort_order)
  VALUES
    (en_id, ko_id, 1, 'Basic Grammar', 'Word order, statements, questions, commands', 'beginner', FALSE, 1),
    (es_id, ko_id, 1, 'Basic Grammar', 'Word order, statements, questions, commands', 'beginner', FALSE, 1),
    (de_id, ko_id, 1, 'Basic Grammar', 'Word order, statements, questions, commands', 'beginner', FALSE, 1),
    (fr_id, ko_id, 1, 'Basic Grammar', 'Word order, statements, questions, commands', 'beginner', FALSE, 1),
    (zh_id, ko_id, 1, 'Basic Grammar', 'Word order, statements, questions, commands', 'beginner', FALSE, 1),
    (ja_id, ko_id, 1, 'Basic Grammar', 'Word order, statements, questions, commands', 'beginner', FALSE, 1)
  ON CONFLICT (language_id, native_language_id, step_number) DO NOTHING;
END $$;
