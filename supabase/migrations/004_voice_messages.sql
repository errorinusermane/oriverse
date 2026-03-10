-- ============================================================
-- 004_voice_messages.sql
-- voice_messages / conversations / conversation_messages
-- + moderation 트리거
-- ============================================================

-- ── voice_messages ───────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.voice_messages (
  id                    UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  sender_id             UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  language_id           UUID REFERENCES public.languages(id),
  storage_path          TEXT NOT NULL,                            -- Storage 경로 (URL 아님)
  duration_seconds      INTEGER,
  transcript            TEXT,
  broadcast_status      TEXT NOT NULL DEFAULT 'draft'
                          CHECK (broadcast_status IN ('draft', 'broadcasted')),
  moderation_status     TEXT NOT NULL DEFAULT 'pending'
                          CHECK (moderation_status IN ('pending', 'approved', 'rejected', 'failed')),
  moderation_checked_at TIMESTAMP WITH TIME ZONE,
  is_deleted            BOOLEAN DEFAULT FALSE,
  created_at            TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

ALTER TABLE public.voice_messages ENABLE ROW LEVEL SECURITY;

-- 본인 메시지 CRUD
CREATE POLICY "vm_select_own" ON public.voice_messages
  FOR SELECT USING (auth.uid() = sender_id);
CREATE POLICY "vm_insert_own" ON public.voice_messages
  FOR INSERT WITH CHECK (auth.uid() = sender_id);
CREATE POLICY "vm_update_own" ON public.voice_messages
  FOR UPDATE USING (auth.uid() = sender_id);

-- 피드: 승인된 브로드캐스트는 전체 공개
CREATE POLICY "vm_select_feed" ON public.voice_messages
  FOR SELECT USING (
    broadcast_status   = 'broadcasted'
    AND moderation_status = 'approved'
    AND is_deleted = FALSE
  );

-- 피드 쿼리 복합 인덱스
CREATE INDEX idx_voice_messages_feed
  ON public.voice_messages(broadcast_status, moderation_status, created_at DESC)
  WHERE is_deleted = FALSE;

-- 본인 메시지 조회 인덱스
CREATE INDEX idx_voice_messages_sender ON public.voice_messages(sender_id);

-- DB 트리거: INSERT 시 moderation_status 강제 'pending' (클라이언트 우회 불가)
CREATE OR REPLACE FUNCTION public.enforce_moderation_pending()
RETURNS TRIGGER AS $$
BEGIN
  NEW.moderation_status := 'pending';
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER voice_messages_moderation_check
  BEFORE INSERT ON public.voice_messages
  FOR EACH ROW EXECUTE FUNCTION public.enforce_moderation_pending();

-- ── conversations ────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.conversations (
  id           UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  participant1 UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  participant2 UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  created_at   TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(participant1, participant2),
  -- 중복 대화방 방지: 항상 participant1 < participant2 순서 강제
  -- 클라이언트는 LEAST(uid1, uid2) / GREATEST(uid1, uid2) 순서로 삽입
  CONSTRAINT conversations_ordered_participants CHECK (participant1 < participant2)
);

ALTER TABLE public.conversations ENABLE ROW LEVEL SECURITY;
CREATE POLICY "conv_select_participant" ON public.conversations
  FOR SELECT USING (auth.uid() = participant1 OR auth.uid() = participant2);
CREATE POLICY "conv_insert_participant" ON public.conversations
  FOR INSERT WITH CHECK (auth.uid() = participant1 OR auth.uid() = participant2);

-- ── conversation_messages ────────────────────────────────────
-- INSERT 정책 없음 (의도적): 반드시 send_conversation_message() 함수를 통해서만 삽입.
CREATE TABLE IF NOT EXISTS public.conversation_messages (
  id               UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  conversation_id  UUID NOT NULL REFERENCES public.conversations(id) ON DELETE CASCADE,
  voice_message_id UUID NOT NULL REFERENCES public.voice_messages(id),
  sender_id        UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  message_order    INTEGER NOT NULL,
  created_at       TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

ALTER TABLE public.conversation_messages ENABLE ROW LEVEL SECURITY;
CREATE POLICY "cm_select_participant" ON public.conversation_messages
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM public.conversations c
      WHERE c.id = conversation_id
        AND (c.participant1 = auth.uid() OR c.participant2 = auth.uid())
    )
  );

CREATE INDEX idx_cm_conversation ON public.conversation_messages(conversation_id, message_order);

-- ── 대화 제한 체크 + INSERT 단일 트랜잭션 (TOCTOU 방지) ───────
-- p_user_id 파라미터 제거 → 내부에서 auth.uid() 사용 (사용자 사칭 취약점 수정)
CREATE OR REPLACE FUNCTION public.send_conversation_message(
  p_conversation_id  UUID,
  p_voice_message_id UUID,
  p_message_order    INTEGER
) RETURNS BOOLEAN AS $$
DECLARE
  v_user_id    UUID := auth.uid();
  v_is_premium BOOLEAN;
  v_msg_count  INTEGER;
BEGIN
  SELECT is_premium INTO v_is_premium
  FROM public.users WHERE id = v_user_id FOR UPDATE;

  IF NOT v_is_premium THEN
    SELECT COUNT(*) INTO v_msg_count
    FROM public.conversation_messages
    WHERE conversation_id = p_conversation_id AND sender_id = v_user_id;

    -- 무료 제한: 7회 (A/B 테스트 시 10으로 변경 가능)
    IF v_msg_count >= 7 THEN
      RETURN FALSE;
    END IF;
  END IF;

  INSERT INTO public.conversation_messages
    (conversation_id, voice_message_id, sender_id, message_order)
  VALUES
    (p_conversation_id, p_voice_message_id, v_user_id, p_message_order);

  RETURN TRUE;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
