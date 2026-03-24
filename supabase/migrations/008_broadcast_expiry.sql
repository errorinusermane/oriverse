-- ============================================================
-- 008_broadcast_expiry.sql
-- Adds is_active / expires_at to voice_messages.
-- Adds 'pending' to the broadcast_status allowed values so the
-- submit flow can be: draft → pending (awaiting moderation) → broadcasted.
-- ============================================================

-- 1. New columns
ALTER TABLE public.voice_messages
  ADD COLUMN IF NOT EXISTS expires_at  TIMESTAMPTZ,
  ADD COLUMN IF NOT EXISTS is_active   BOOLEAN NOT NULL DEFAULT TRUE;

-- 2. Expand broadcast_status CHECK to include 'pending'
ALTER TABLE public.voice_messages
  DROP CONSTRAINT IF EXISTS voice_messages_broadcast_status_check;

ALTER TABLE public.voice_messages
  ADD CONSTRAINT voice_messages_broadcast_status_check
    CHECK (broadcast_status IN ('draft', 'pending', 'broadcasted'));

-- 3. Replace the feed RLS policy to enforce expiry + active flag
DROP POLICY IF EXISTS "vm_select_feed" ON public.voice_messages;
CREATE POLICY "vm_select_feed" ON public.voice_messages
  FOR SELECT USING (
    broadcast_status    = 'broadcasted'
    AND moderation_status = 'approved'
    AND is_active         = TRUE
    AND expires_at        > NOW()
    AND is_deleted        = FALSE
  );

-- 4. Replace the feed index to cover new filter columns
DROP INDEX IF EXISTS idx_voice_messages_feed;
CREATE INDEX idx_voice_messages_feed
  ON public.voice_messages (broadcast_status, moderation_status, is_active, expires_at DESC)
  WHERE is_deleted = FALSE;
