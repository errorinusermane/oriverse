-- public.users 테이블
-- auth.users(id)를 UUID로 참조. 소셜 로그인 시 자동 생성.
CREATE TABLE IF NOT EXISTS public.users (
  id              UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  email           TEXT,
  display_name    TEXT,
  avatar_url      TEXT,
  -- 학습 상태
  native_language_id    UUID,  -- REFERENCES languages(id) — Day 3에서 FK 추가
  learning_language_id  UUID,
  onboarding_step       INTEGER DEFAULT 0 CHECK (onboarding_step BETWEEN 0 AND 3),  -- 0: 미시작, 1~3: 진행 중, 3: 완료
  -- 게임화
  streak_days           INTEGER DEFAULT 0,
  last_active_date      DATE,
  points                INTEGER DEFAULT 0,
  -- 구독
  is_premium            BOOLEAN DEFAULT FALSE,
  subscription_type     TEXT DEFAULT 'free' CHECK (subscription_type IN ('free', 'monthly', 'annual', 'lifetime')),
  -- 기타
  timezone              TEXT DEFAULT 'UTC',
  is_banned             BOOLEAN DEFAULT FALSE,
  created_at            TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at            TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- RLS 활성화
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;

-- 본인 row만 읽기/수정 가능
CREATE POLICY "users_select_own" ON public.users FOR SELECT USING (auth.uid() = id);
CREATE POLICY "users_update_own" ON public.users FOR UPDATE USING (auth.uid() = id);

-- 소셜 로그인 시 public.users row 자동 생성 트리거
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.users (id, email, display_name, avatar_url)
  VALUES (
    NEW.id,
    NEW.email,
    COALESCE(NEW.raw_user_meta_data->>'full_name', NEW.raw_user_meta_data->>'name'),
    NEW.raw_user_meta_data->>'avatar_url'
  )
  ON CONFLICT (id) DO NOTHING;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE OR REPLACE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- updated_at 자동 갱신 트리거
CREATE OR REPLACE FUNCTION public.set_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER users_set_updated_at
  BEFORE UPDATE ON public.users
  FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
