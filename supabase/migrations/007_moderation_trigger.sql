-- ============================================================
-- 007_moderation_trigger.sql
-- voice_messages INSERT 후 content-moderation Edge Function 호출
-- pg_net 확장 사용
-- ============================================================

-- pg_net 확장 활성화 (이미 활성화된 경우 무시)
CREATE EXTENSION IF NOT EXISTS pg_net WITH SCHEMA extensions;

-- ── 사전 설정 필요 (마이그레이션 후 1회 실행) ────────────────
-- 아래 두 값을 실제 프로젝트 값으로 교체한 뒤 psql 또는 Supabase SQL Editor에서 실행:
--
--   ALTER DATABASE postgres
--     SET app.settings.supabase_url = 'https://<project-ref>.supabase.co';
--
--   ALTER DATABASE postgres
--     SET app.settings.moderation_webhook_secret = '<your-moderation-webhook-secret>';
--
-- MODERATION_WEBHOOK_SECRET은 Edge Function 환경 변수와 동일한 값이어야 합니다.
-- supabase secrets set MODERATION_WEBHOOK_SECRET=<your-secret>
-- ─────────────────────────────────────────────────────────────

-- DB 트리거 함수: AFTER INSERT → content-moderation Edge Function 호출
CREATE OR REPLACE FUNCTION public.notify_content_moderation()
RETURNS TRIGGER AS $$
DECLARE
  v_url    TEXT;
  v_secret TEXT;
BEGIN
  -- DB 설정에서 URL과 시크릿 읽기 (설정되지 않으면 빈 문자열)
  v_url    := current_setting('app.settings.supabase_url', true);
  v_secret := current_setting('app.settings.moderation_webhook_secret', true);

  -- 설정이 없으면 트리거 스킵 (개발 환경 안전 처리)
  IF v_url IS NULL OR v_url = '' THEN
    RETURN NEW;
  END IF;

  -- pg_net으로 비동기 HTTP POST (트랜잭션 완료 후 실행)
  PERFORM net.http_post(
    url     := v_url || '/functions/v1/content-moderation',
    headers := jsonb_build_object(
      'Content-Type',       'application/json',
      'x-webhook-secret',   v_secret
    ),
    body    := jsonb_build_object('voice_message_id', NEW.id::text)
  );

  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- AFTER INSERT 트리거 (BEFORE 트리거인 enforce_moderation_pending 이후 실행)
CREATE OR REPLACE TRIGGER voice_messages_notify_moderation
  AFTER INSERT ON public.voice_messages
  FOR EACH ROW EXECUTE FUNCTION public.notify_content_moderation();
