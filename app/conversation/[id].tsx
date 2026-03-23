// app/conversation/[id].tsx
// 1:1 대화 화면. 메시지 스레드 표시 + 잔여 횟수 배지 + 페이월 모달.

import { useEffect, useRef } from 'react';
import {
  View,
  Text,
  Pressable,
  ScrollView,
  ActivityIndicator,
} from 'react-native';
import { useLocalSearchParams, useRouter } from 'expo-router';
import { Ionicons } from '@expo/vector-icons';
import { useConversationStore } from '../../src/store/conversationStore';
import { useAuthStore } from '../../src/store/authStore';
import { PaywallModal } from '../../src/components/PaywallModal';
import { useRecorder } from '../../src/hooks/useRecorder';
import { supabase } from '../../src/lib/supabase';

const FREE_LIMIT = 7;

// ─── 메시지 버블 ─────────────────────────────────────────────
function MessageBubble({
  isMine,
  order,
  createdAt,
}: {
  isMine: boolean;
  order: number;
  createdAt: string;
}) {
  const time = new Date(createdAt).toLocaleTimeString('ko-KR', {
    hour: '2-digit',
    minute: '2-digit',
  });

  return (
    <View
      className={`flex-row mb-3 ${isMine ? 'justify-end' : 'justify-start'}`}
    >
      <View
        className={`max-w-[75%] rounded-2xl px-4 py-3 ${
          isMine ? 'bg-blue-500' : 'bg-gray-100'
        }`}
      >
        {/* 음성 메시지 플레이스홀더 */}
        <View className="flex-row items-center gap-2">
          <Ionicons
            name="mic-outline"
            size={16}
            color={isMine ? 'white' : '#6B7280'}
          />
          <Text
            className={`text-sm ${isMine ? 'text-white' : 'text-gray-700'}`}
          >
            음성 메시지 #{order}
          </Text>
        </View>
        <Text
          className={`text-xs mt-1 ${
            isMine ? 'text-blue-100' : 'text-gray-400'
          }`}
        >
          {time}
        </Text>
      </View>
    </View>
  );
}

// ─── 잔여 횟수 배지 ──────────────────────────────────────────
function RemainingBadge({ remaining }: { remaining: number }) {
  const isLow = remaining <= 2;

  return (
    <View
      className={`flex-row items-center gap-1 px-3 py-1 rounded-full ${
        isLow ? 'bg-orange-50' : 'bg-gray-50'
      }`}
    >
      <Ionicons
        name="chatbubble-outline"
        size={13}
        color={isLow ? '#F97316' : '#9CA3AF'}
      />
      <Text
        className={`text-xs font-medium ${
          isLow ? 'text-orange-500' : 'text-gray-400'
        }`}
      >
        {remaining === 0 ? '무료 횟수 소진' : `남은 무료 대화 ${remaining}회`}
      </Text>
    </View>
  );
}

// ─── 메인 ─────────────────────────────────────────────────────
export default function ConversationScreen() {
  const { id: conversationId } = useLocalSearchParams<{ id: string }>();
  const router = useRouter();
  const { user } = useAuthStore();

  const {
    messages,
    remaining,
    isLoading,
    isSending,
    showPaywall,
    loadConversation,
    sendMessage,
    dismissPaywall,
  } = useConversationStore();

  const { isRecording, countdown, isUploading, startRecording, stopRecording, uploadRecording } =
    useRecorder(user?.id ?? null);

  const recordingStartRef = useRef<number | null>(null);

  useEffect(() => {
    if (conversationId && user?.id) {
      loadConversation(conversationId, user.id);
    }
  }, [conversationId, user?.id]);

  // 카운트다운 0 → 자동 전송
  useEffect(() => {
    if (countdown === 0 && isRecording) {
      handleStopAndSend();
    }
  }, [countdown, isRecording]);

  function handleSubscribe() {
    dismissPaywall();
    router.push('/profile/subscription');
  }

  async function handleStopAndSend() {
    const uri = await stopRecording();
    if (!uri || !conversationId || !user?.id) return;

    const durationSeconds = recordingStartRef.current
      ? Math.round((Date.now() - recordingStartRef.current) / 1000)
      : 0;
    recordingStartRef.current = null;

    // Upload: reuse hook's upload logic with conversation-scoped path
    const storagePath = await uploadRecording(
      uri,
      `conversations/${conversationId}/${Date.now()}`
    );
    if (!storagePath) return;

    // Insert voice_message row
    const { data: vmData, error: vmError } = await supabase
      .from('voice_messages')
      .insert({
        sender_id: user.id,
        storage_path: storagePath,
        duration_seconds: durationSeconds,
        transcript: null,
      })
      .select('id')
      .single();

    if (vmError || !vmData) {
      console.error('[ConversationScreen] voice_message insert failed:', vmError);
      return;
    }

    const nextOrder = messages.length + 1;
    await sendMessage(vmData.id, nextOrder);

    // Reload to show new message in thread
    loadConversation(conversationId, user.id);
  }

  async function handleRecordPress() {
    if (remaining === 0) {
      useConversationStore.setState({ showPaywall: true });
      return;
    }

    if (!isRecording) {
      recordingStartRef.current = Date.now();
      await startRecording();
    } else {
      await handleStopAndSend();
    }
  }

  if (isLoading) {
    return (
      <View className="flex-1 bg-white items-center justify-center">
        <ActivityIndicator size="large" color="#3B82F6" />
      </View>
    );
  }

  const usedCount = FREE_LIMIT - remaining;
  const progressWidth = `${Math.min((usedCount / FREE_LIMIT) * 100, 100)}%`;

  return (
    <View className="flex-1 bg-white">
      {/* 잔여 횟수 상태 바 */}
      <View className="px-4 pt-3 pb-2 border-b border-gray-100">
        <View className="flex-row items-center justify-between mb-1.5">
          <RemainingBadge remaining={remaining} />
          <Text className="text-xs text-gray-400">
            {usedCount} / {FREE_LIMIT}
          </Text>
        </View>
        <View className="h-1 rounded-full bg-gray-100 overflow-hidden">
          <View
            className={`h-1 rounded-full ${
              remaining <= 2 ? 'bg-orange-400' : 'bg-blue-400'
            }`}
            style={{ width: progressWidth }}
          />
        </View>
      </View>

      {/* 메시지 목록 */}
      <ScrollView
        className="flex-1 px-4 pt-3"
        contentContainerStyle={{ paddingBottom: 16 }}
      >
        {messages.length === 0 ? (
          <View className="flex-1 items-center justify-center py-20">
            <Text className="text-3xl mb-3">💬</Text>
            <Text className="text-gray-500 text-sm text-center">
              첫 번째 음성 메시지를 보내보세요
            </Text>
          </View>
        ) : (
          messages.map((msg) => (
            <MessageBubble
              key={msg.id}
              isMine={msg.senderId === user?.id}
              order={msg.messageOrder}
              createdAt={msg.createdAt}
            />
          ))
        )}
      </ScrollView>

      {/* 전송 영역 */}
      <View className="px-4 pb-8 pt-3 border-t border-gray-100">
        {remaining === 0 ? (
          // 한도 소진 시 페이월 CTA
          <Pressable
            onPress={() => useConversationStore.setState({ showPaywall: true })}
            className="bg-orange-500 rounded-2xl py-4 items-center"
          >
            <Text className="text-white font-bold text-base">
              프리미엄으로 계속 대화하기
            </Text>
          </Pressable>
        ) : (
          // 녹음 버튼
          <Pressable
            onPress={handleRecordPress}
            disabled={isUploading || isSending}
            className={`rounded-2xl py-4 items-center flex-row justify-center gap-2 ${
              isUploading || isSending
                ? 'bg-gray-200'
                : isRecording
                  ? 'bg-red-500'
                  : 'bg-blue-500'
            }`}
          >
            {isUploading || isSending ? (
              <ActivityIndicator size="small" color="#9CA3AF" />
            ) : (
              <Ionicons
                name={isRecording ? 'stop-circle' : 'mic'}
                size={20}
                color="white"
              />
            )}
            <Text
              className={`font-bold text-base ${
                isUploading || isSending ? 'text-gray-400' : 'text-white'
              }`}
            >
              {isUploading || isSending
                ? '처리 중...'
                : isRecording
                  ? `${countdown}초 · 탭해서 전송`
                  : '녹음하고 보내기'}
            </Text>
          </Pressable>
        )}
      </View>

      {/* 페이월 모달 */}
      <PaywallModal
        visible={showPaywall}
        onDismiss={dismissPaywall}
        onSubscribe={handleSubscribe}
      />
    </View>
  );
}
