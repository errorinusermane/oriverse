// src/store/conversationStore.ts
// 1:1 대화 상태 관리. 무료 메시지 한도(7회) 추적 + 페이월 트리거.
// audioStore를 import해 메시지 전송 전 재생 중인 오디오를 정지한다 (충돌 방지).

import { create } from 'zustand';
import { supabase } from '../lib/supabase';
import { useAudioStore } from './audioStore';

const FREE_LIMIT = 7;

export interface ConversationMessage {
  id: string;
  senderId: string;
  voiceMessageId: string;
  messageOrder: number;
  createdAt: string;
}

interface ConversationState {
  conversationId: string | null;
  messages: ConversationMessage[];
  /** 현재 유저의 남은 무료 메시지 수 (0이면 페이월 표시) */
  remaining: number;
  isLoading: boolean;
  isSending: boolean;
  showPaywall: boolean;
  /** 대화 로드: 메시지 목록 + 잔여 횟수 계산 */
  loadConversation: (conversationId: string, userId: string) => Promise<void>;
  /**
   * 메시지 전송
   * 1. 잔여 횟수가 0이면 페이월 즉시 표시 (RPC 생략)
   * 2. audioStore.stop() 호출 → 재생 중인 오디오와 충돌 방지
   * 3. send_conversation_message RPC 호출
   * 4. DB 가 false 반환(한도 초과) 시 페이월 표시
   */
  sendMessage: (voiceMessageId: string, messageOrder: number) => Promise<void>;
  dismissPaywall: () => void;
}

export const useConversationStore = create<ConversationState>((set, get) => ({
  conversationId: null,
  messages: [],
  remaining: FREE_LIMIT,
  isLoading: false,
  isSending: false,
  showPaywall: false,

  loadConversation: async (conversationId, userId) => {
    set({ isLoading: true, conversationId });

    const { data, error } = await supabase
      .from('conversation_messages')
      .select('id, sender_id, voice_message_id, message_order, created_at')
      .eq('conversation_id', conversationId)
      .order('message_order', { ascending: true });

    if (error) {
      console.error('[conversationStore.loadConversation]', error);
      set({ isLoading: false });
      return;
    }

    const messages: ConversationMessage[] = (data ?? []).map((row) => ({
      id: row.id,
      senderId: row.sender_id,
      voiceMessageId: row.voice_message_id,
      messageOrder: row.message_order,
      createdAt: row.created_at,
    }));

    const sentByUser = messages.filter((m) => m.senderId === userId).length;
    const remaining = Math.max(0, FREE_LIMIT - sentByUser);

    set({ messages, remaining, isLoading: false });
  },

  sendMessage: async (voiceMessageId, messageOrder) => {
    const { conversationId, remaining } = get();
    if (!conversationId) return;

    // 잔여 횟수 0 → 페이월 즉시 표시 (RPC 불필요)
    if (remaining === 0) {
      set({ showPaywall: true });
      return;
    }

    // 오디오 충돌 방지: 재생 중인 오디오 정지
    await useAudioStore.getState().stop();

    set({ isSending: true });

    try {
      const { data, error } = await supabase.rpc('send_conversation_message', {
        p_conversation_id: conversationId,
        p_voice_message_id: voiceMessageId,
        p_message_order: messageOrder,
      });

      if (error) {
        console.error('[conversationStore.sendMessage] RPC error:', error);
        set({ isSending: false });
        return;
      }

      const success = data as boolean;

      if (!success) {
        // DB 레벨에서 한도 초과 판정 (TOCTOU 방어)
        set({ remaining: 0, showPaywall: true, isSending: false });
        return;
      }

      // 전송 성공 → 잔여 횟수 1 감소, 페이월 조건 재확인
      set((state) => {
        const next = Math.max(0, state.remaining - 1);
        return { remaining: next, isSending: false, showPaywall: next === 0 };
      });
    } catch (e) {
      console.error('[conversationStore.sendMessage] Exception:', e);
      set({ isSending: false });
    }
  },

  dismissPaywall: () => set({ showPaywall: false }),
}));
