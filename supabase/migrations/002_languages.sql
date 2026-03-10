-- ============================================================
-- 002_languages.sql
-- languages 테이블 + users FK 연결
-- ============================================================

-- uuid_generate_v4() 확장 (이미 활성화돼 있으면 무시됨)
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- languages 테이블
CREATE TABLE IF NOT EXISTS public.languages (
  id          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  code        TEXT NOT NULL UNIQUE,   -- 'en', 'es', 'de', 'fr', 'zh', 'ja', 'ko'
  name        TEXT NOT NULL,          -- 'English', 'Spanish', ...
  native_name TEXT NOT NULL,          -- 'English', 'Español', ...
  flag_emoji  TEXT NOT NULL,
  is_active   BOOLEAN DEFAULT TRUE,
  sort_order  INTEGER DEFAULT 0
);

-- RLS
ALTER TABLE public.languages ENABLE ROW LEVEL SECURITY;
CREATE POLICY "languages_read_all" ON public.languages FOR SELECT USING (TRUE);

-- 시드: 7개 지원 언어
INSERT INTO public.languages (code, name, native_name, flag_emoji, sort_order) VALUES
  ('en', 'English',  'English',   '🇺🇸', 1),
  ('es', 'Spanish',  'Español',   '🇪🇸', 2),
  ('de', 'German',   'Deutsch',   '🇩🇪', 3),
  ('fr', 'French',   'Français',  '🇫🇷', 4),
  ('zh', 'Chinese',  '中文',       '🇨🇳', 5),
  ('ja', 'Japanese', '日本語',     '🇯🇵', 6),
  ('ko', 'Korean',   '한국어',     '🇰🇷', 7)
ON CONFLICT (code) DO NOTHING;

-- users 테이블에 FK 추가 (001에서 UUID로만 선언해둔 것)
ALTER TABLE public.users
  ADD CONSTRAINT fk_users_native_language
    FOREIGN KEY (native_language_id)  REFERENCES public.languages(id),
  ADD CONSTRAINT fk_users_learning_language
    FOREIGN KEY (learning_language_id) REFERENCES public.languages(id);

-- 언어별 사용자 조회 인덱스
CREATE INDEX idx_users_native_language   ON public.users(native_language_id);
CREATE INDEX idx_users_learning_language ON public.users(learning_language_id);
