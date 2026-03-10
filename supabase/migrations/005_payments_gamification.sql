-- ============================================================
-- 005_payments_gamification.sql
-- payments / user_achievements / user_daily_stats / user_level_quiz
-- + streak 함수
-- ============================================================

-- ── payments ─────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.payments (
  id               UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id          UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  payment_provider TEXT NOT NULL DEFAULT 'google_play'
                     CHECK (payment_provider IN ('google_play', 'apple_iap', 'stripe')),
  product_id       TEXT NOT NULL,                                 -- Google Play / Stripe product ID
  purchase_token   TEXT UNIQUE,                                   -- 중복 결제 방지: 동일 토큰 재삽입 불가
  amount_usd       NUMERIC(10,2),
  currency         TEXT DEFAULT 'USD',
  status           TEXT NOT NULL DEFAULT 'pending'
                     CHECK (status IN ('pending', 'verified', 'failed', 'refunded')),
  subscription_type TEXT
                     CHECK (subscription_type IN ('monthly', 'annual', 'lifetime')),
  expires_at       TIMESTAMP WITH TIME ZONE,
  raw_receipt      JSONB,                                         -- 서버 검증 원본 응답
  created_at       TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

ALTER TABLE public.payments ENABLE ROW LEVEL SECURITY;
CREATE POLICY "payments_select_own" ON public.payments
  FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "payments_insert_own" ON public.payments
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE INDEX idx_payments_user ON public.payments(user_id, created_at DESC);

-- INSERT 시 status 강제 'pending' (클라이언트가 status='verified'로 직접 삽입해 프리미엄 획득하는 공격 차단)
CREATE OR REPLACE FUNCTION public.enforce_payment_pending()
RETURNS TRIGGER AS $$
BEGIN
  NEW.status := 'pending';
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER payments_status_check
  BEFORE INSERT ON public.payments
  FOR EACH ROW EXECUTE FUNCTION public.enforce_payment_pending();

-- ── user_achievements ─────────────────────────────────────────
-- INSERT 정책 없음 (의도적): 클라이언트 직접 삽입 차단. 서버사이드 Edge Function 또는 SECURITY DEFINER 함수를 통해서만 업적 부여.
CREATE TABLE IF NOT EXISTS public.user_achievements (
  id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id         UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  achievement_key TEXT NOT NULL,                                  -- 'streak_7', 'step_complete_1', ...
  earned_at       TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(user_id, achievement_key)
);

ALTER TABLE public.user_achievements ENABLE ROW LEVEL SECURITY;
CREATE POLICY "achievements_select_own" ON public.user_achievements
  FOR SELECT USING (auth.uid() = user_id);

-- ── user_daily_stats ──────────────────────────────────────────
-- users 테이블에서 일일 카운트 분리 → 쓰기 경합 방지
CREATE TABLE IF NOT EXISTS public.user_daily_stats (
  id                UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id           UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  stat_date         DATE NOT NULL DEFAULT CURRENT_DATE,
  broadcasts_count  INTEGER DEFAULT 0,  -- 오늘 브로드캐스트 횟수 (무료 상한: 5)
  ai_feedback_count INTEGER DEFAULT 0,  -- 오늘 AI 피드백 횟수  (무료 상한: 5)
  UNIQUE(user_id, stat_date)
);

ALTER TABLE public.user_daily_stats ENABLE ROW LEVEL SECURITY;
CREATE POLICY "daily_stats_select_own" ON public.user_daily_stats
  FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "daily_stats_upsert_own" ON public.user_daily_stats
  FOR ALL USING (auth.uid() = user_id);

CREATE INDEX idx_daily_stats_user_date ON public.user_daily_stats(user_id, stat_date);

-- ── user_level_quiz ───────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.user_level_quiz (
  id          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id     UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  language_id UUID NOT NULL REFERENCES public.languages(id),
  result      TEXT CHECK (result IN ('beginner', 'intermediate')),
  taken_at    TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(user_id, language_id)
);

ALTER TABLE public.user_level_quiz ENABLE ROW LEVEL SECURITY;
-- FOR ALL 대신 명시적으로 분리 (DELETE 허용 방지)
CREATE POLICY "quiz_select_own" ON public.user_level_quiz
  FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "quiz_insert_own" ON public.user_level_quiz
  FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "quiz_update_own" ON public.user_level_quiz
  FOR UPDATE USING (auth.uid() = user_id);

-- ── 스트릭 업데이트 함수 ──────────────────────────────────────
-- 사용자 timezone 기준 로컬 날짜 비교
CREATE OR REPLACE FUNCTION public.update_user_streak(p_user_id UUID)
RETURNS VOID AS $$
DECLARE
  user_tz       TEXT;
  local_today   DATE;
  local_last    DATE;
  current_streak INTEGER;
BEGIN
  SELECT timezone, last_active_date, streak_days
  INTO user_tz, local_last, current_streak
  FROM public.users WHERE id = p_user_id;

  local_today := (NOW() AT TIME ZONE COALESCE(user_tz, 'UTC'))::DATE;

  IF local_last = local_today THEN
    -- 오늘 이미 처리됨
    RETURN;
  ELSIF local_last = local_today - 1 THEN   -- DATE - INTEGER = DATE (INTERVAL 타입 불일치 버그 수정)
    -- 연속 학습
    UPDATE public.users
    SET streak_days = streak_days + 1,
        last_active_date = local_today
    WHERE id = p_user_id;
  ELSE
    -- 스트릭 초기화
    UPDATE public.users
    SET streak_days = 1,
        last_active_date = local_today
    WHERE id = p_user_id;
  END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
