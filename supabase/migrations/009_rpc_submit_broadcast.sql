-- ============================================================
-- 009_rpc_submit_broadcast.sql
-- RPC: submit_broadcast
-- Atomically deactivates previous broadcasts and inserts a new one.
--
-- Client usage:
--   supabase.rpc('submit_broadcast', {
--     p_language_id:      '<uuid>',
--     p_storage_path:     'user-recordings/...',
--     p_duration_seconds: 42,
--     p_transcript:       '...'   -- optional
--   })
-- Returns the new voice_message UUID.
-- ============================================================
CREATE OR REPLACE FUNCTION public.submit_broadcast(
  p_language_id      UUID,
  p_storage_path     TEXT,
  p_duration_seconds INTEGER,
  p_transcript       TEXT DEFAULT NULL
)
RETURNS UUID AS $$
DECLARE
  v_user_id UUID := auth.uid();
  v_new_id  UUID;
BEGIN
  -- a. Deactivate all previous broadcasts from this user
  UPDATE public.voice_messages
  SET    is_active = FALSE
  WHERE  sender_id        = v_user_id
    AND  broadcast_status = 'broadcasted'
    AND  is_active        = TRUE;

  -- b. Insert the new broadcast (moderation trigger forces moderation_status = 'pending')
  INSERT INTO public.voice_messages (
    sender_id,
    language_id,
    storage_path,
    duration_seconds,
    transcript,
    broadcast_status,
    expires_at,
    is_active
  ) VALUES (
    v_user_id,
    p_language_id,
    p_storage_path,
    p_duration_seconds,
    p_transcript,
    'pending',                          -- awaiting moderation; becomes 'broadcasted' after approval
    NOW() + INTERVAL '24 hours',
    TRUE
  )
  RETURNING id INTO v_new_id;

  RETURN v_new_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Grant to authenticated users only
REVOKE ALL ON FUNCTION public.submit_broadcast FROM PUBLIC;
GRANT  EXECUTE ON FUNCTION public.submit_broadcast TO authenticated;
