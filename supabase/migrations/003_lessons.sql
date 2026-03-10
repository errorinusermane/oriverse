-- ============================================================
-- 003_lessons.sql
-- lessons / lesson_scripts / user_lesson_progress
-- ============================================================

-- ── lessons ──────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.lessons (
  id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  language_id     UUID NOT NULL REFERENCES public.languages(id),
  step_number     INTEGER NOT NULL,                               -- 1~7
  title           TEXT NOT NULL,
  description     TEXT,
  level_required  TEXT NOT NULL DEFAULT 'beginner'
                    CHECK (level_required IN ('beginner', 'intermediate')),
  is_premium      BOOLEAN DEFAULT FALSE,                          -- step 7만 TRUE
  sort_order      INTEGER DEFAULT 0,
  created_at      TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(language_id, step_number)
);

ALTER TABLE public.lessons ENABLE ROW LEVEL SECURITY;
CREATE POLICY "lessons_read_all" ON public.lessons FOR SELECT USING (TRUE);

-- ── lesson_scripts ───────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.lesson_scripts (
  id                 UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  lesson_id          UUID NOT NULL REFERENCES public.lessons(id) ON DELETE CASCADE,
  sequence_order     INTEGER NOT NULL,                            -- 대화 순서
  speaker            TEXT NOT NULL CHECK (speaker IN ('ai', 'user')),
  script_text        TEXT NOT NULL,
  audio_storage_path TEXT,                                        -- Storage 경로 (URL 아님)
  created_at         TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

ALTER TABLE public.lesson_scripts ENABLE ROW LEVEL SECURITY;
CREATE POLICY "lesson_scripts_read_all" ON public.lesson_scripts FOR SELECT USING (TRUE);

CREATE INDEX idx_lesson_scripts_lesson ON public.lesson_scripts(lesson_id, sequence_order);

-- ── user_lesson_progress ─────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.user_lesson_progress (
  id             UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id        UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  lesson_id      UUID NOT NULL REFERENCES public.lessons(id),
  script_id      UUID NOT NULL REFERENCES public.lesson_scripts(id),
  status         TEXT NOT NULL DEFAULT 'not_started'
                   CHECK (status IN ('not_started', 'attempted', 'completed')),
  recording_path TEXT,                                            -- Storage 경로
  transcription  TEXT,
  confidence_score NUMERIC(4,3),                                  -- 0.000 ~ 1.000
  ai_feedback    TEXT,
  attempted_at   TIMESTAMP WITH TIME ZONE,
  completed_at   TIMESTAMP WITH TIME ZONE,
  UNIQUE(user_id, script_id)
);

ALTER TABLE public.user_lesson_progress ENABLE ROW LEVEL SECURITY;
CREATE POLICY "progress_select_own" ON public.user_lesson_progress
  FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "progress_insert_own" ON public.user_lesson_progress
  FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "progress_update_own" ON public.user_lesson_progress
  FOR UPDATE USING (auth.uid() = user_id);

CREATE INDEX idx_progress_user_lesson ON public.user_lesson_progress(user_id, lesson_id);

-- ── 시드: 영어 lessons 7개 ───────────────────────────────────
-- language_id는 런타임에 조회해서 사용 (시드는 DO 블록으로 처리)
DO $$
DECLARE
  en_id UUID;
BEGIN
  SELECT id INTO en_id FROM public.languages WHERE code = 'en';

  IF en_id IS NULL THEN
    RAISE EXCEPTION '002_languages.sql이 먼저 실행되지 않았습니다. languages 테이블에 en 레코드 없음';
  END IF;

  INSERT INTO public.lessons (language_id, step_number, title, description, level_required, is_premium, sort_order)
  VALUES
    (en_id, 1, 'Basic Grammar',        'Word order, statements, questions, commands',        'beginner',      FALSE, 1),
    (en_id, 2, 'Café Conversation',    'Ordering drinks and food politely',                   'beginner',      FALSE, 2),
    (en_id, 3, 'Restaurant Talk',      'Reading menus, allergies, paying the bill',           'beginner',      FALSE, 3),
    (en_id, 4, 'Supermarket',          'Asking for locations, quantities',                    'beginner',      FALSE, 4),
    (en_id, 5, 'Hobbies & Past',       'Past tense, passive voice, past participles',         'intermediate',  FALSE, 5),
    (en_id, 6, 'Reactions & Emotions', 'Emotional expressions, fillers, exclamations',        'intermediate',  FALSE, 6),
    (en_id, 7, '50 Essential Verbs',   '50 high-frequency verbs in real conversations',       'intermediate',  TRUE,  7)
  ON CONFLICT (language_id, step_number) DO NOTHING;
END $$;
