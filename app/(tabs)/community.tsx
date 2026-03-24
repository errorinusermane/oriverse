import { useState, useEffect, useCallback } from 'react';
import { View, Text, Pressable, ScrollView, ActivityIndicator } from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import { useRouter } from 'expo-router';
import { useAudioStore } from '../../src/store/audioStore';
import { useAuthStore } from '../../src/store/authStore';
import { supabase } from '../../src/lib/supabase';

type CommunityState = 'locked' | 'preview' | 'full';
type CommunityTab = 'feed' | 'conversations';

function getCommunityState(completedSteps: number): CommunityState {
  if (completedSteps >= 6) return 'full';
  if (completedSteps >= 3) return 'preview';
  return 'locked';
}

// ─── 브로드캐스트 아이템 타입 ────────────────────────────────
type ModerationStatus = 'pending' | 'approved' | 'rejected';

interface BroadcastItem {
  id: string;
  sender_id: string;
  userName: string;
  flag: string;
  learningLang: string;
  durationSecs: number;
  moderation_status: ModerationStatus;
  audioUrl: string | null;
}

async function fetchBroadcasts(currentUserId: string | null): Promise<{ items: BroadcastItem[]; error: string | null }> {
  let query = supabase
    .from('voice_messages')
    .select(`
      id,
      sender_id,
      storage_path,
      duration_seconds,
      moderation_status,
      language:languages!language_id(flag_emoji, name)
    `)
    .eq('broadcast_status', 'broadcasted')
    .eq('is_active', true)
    .gt('expires_at', new Date().toISOString());

  if (currentUserId) {
    // Show approved posts from everyone + own pending/rejected posts
    query = query.or(
      `moderation_status.eq.approved,and(sender_id.eq.${currentUserId},moderation_status.in.(pending,rejected))`
    );
  } else {
    query = query.eq('moderation_status', 'approved');
  }

  const { data: messages, error } = await query.order('created_at', { ascending: false });

  if (error) return { items: [], error: error.message };
  if (!messages) return { items: [], error: null };

  const items = await Promise.all(
    messages.map(async (msg) => {
      let audioUrl: string | null = null;
      try {
        const { data } = await supabase.functions.invoke('get-signed-url', {
          body: { storage_path: msg.storage_path, bucket: 'user-recordings' },
        });
        audioUrl = data?.signedUrl ?? null;
      } catch {
        // leave null — item renders as disabled
      }

      const lang = Array.isArray(msg.language) ? msg.language[0] : msg.language;
      return {
        id: msg.id,
        sender_id: msg.sender_id,
        userName: '익명 학습자',
        flag: lang?.flag_emoji ?? '🌐',
        learningLang: lang ? `${lang.name} 학습 중` : '언어 학습 중',
        durationSecs: msg.duration_seconds ?? 0,
        moderation_status: msg.moderation_status as ModerationStatus,
        audioUrl,
      } as BroadcastItem;
    })
  );

  return { items, error: null };
}

function formatDuration(secs: number): string {
  const m = Math.floor(secs / 60);
  const s = secs % 60;
  return `${m}:${String(s).padStart(2, '0')}`;
}

// ─── 검수 상태 뱃지 ──────────────────────────────────────────
function ModerationBadge({ status }: { status: ModerationStatus }) {
  if (status === 'approved') return null;
  if (status === 'pending') {
    return (
      <View className="bg-gray-200 rounded-full px-2 py-0.5">
        <Text className="text-xs text-gray-500">검토중</Text>
      </View>
    );
  }
  return (
    <View className="bg-red-100 rounded-full px-2 py-0.5">
      <Text className="text-xs text-red-500">거부됨</Text>
    </View>
  );
}

// ─── 브로드캐스트 피드 아이템 ────────────────────────────────
function BroadcastFeedItem({ item, currentUserId }: { item: BroadcastItem; currentUserId: string | null }) {
  const { activeId, status, play, stop } = useAudioStore();

  const isActive = activeId === item.id;
  const isLoading = isActive && status === 'loading';
  const isPlaying = isActive && status === 'playing';
  const hasError = isActive && status === 'error';
  const canPlay = item.audioUrl !== null;

  function handlePress() {
    if (!canPlay) return;
    if (isPlaying) {
      stop();
    } else {
      play(item.id, async () => item.audioUrl);
    }
  }

  return (
    <View className="bg-white rounded-2xl p-4 mb-3 border border-gray-100">
      {/* 유저 정보 */}
      <View className="flex-row items-center gap-3 mb-3">
        <View className="w-10 h-10 rounded-full bg-gray-200 items-center justify-center">
          <Text style={{ fontSize: 18 }}>{item.flag}</Text>
        </View>
        <View className="flex-1">
          <View className="flex-row items-center gap-2">
            <Text className="font-medium text-gray-800">{item.userName}</Text>
            {item.sender_id === currentUserId && (
              <ModerationBadge status={item.moderation_status} />
            )}
          </View>
          <Text className="text-xs text-gray-400">{item.flag} {item.learningLang}</Text>
        </View>
      </View>

      {/* 오디오 재생 바 */}
      <Pressable
        onPress={handlePress}
        disabled={!canPlay}
        className={`flex-row items-center gap-3 rounded-xl px-3 py-2.5 ${
          isPlaying ? 'bg-blue-50' : 'bg-gray-50'
        }`}
      >
        {isLoading ? (
          <ActivityIndicator size="small" color="#3B82F6" />
        ) : (
          <Ionicons
            name={isPlaying ? 'pause-circle' : 'play-circle'}
            size={28}
            color={canPlay ? (isPlaying ? '#3B82F6' : '#9CA3AF') : '#D1D5DB'}
          />
        )}

        {/* 진행 바 */}
        <View className="flex-1 h-1 rounded-full overflow-hidden bg-gray-200">
          <View
            className={`h-1 rounded-full ${isPlaying ? 'bg-blue-400' : 'bg-gray-300'}`}
            style={{ width: isPlaying ? '45%' : '0%' }}
          />
        </View>

        <Text className={`text-xs ${isPlaying ? 'text-blue-500' : 'text-gray-400'}`}>
          {hasError ? '오류' : formatDuration(item.durationSecs)}
        </Text>
      </Pressable>

      {!canPlay && (
        <Text className="text-xs text-gray-300 mt-1 text-center">
          오디오 준비 중
        </Text>
      )}
    </View>
  );
}

// ─── 잠금 화면 (< 3스텝) ──────────────────────────────────────
function LockedView({ completedSteps }: { completedSteps: number }) {
  const remaining = 3 - completedSteps;
  return (
    <View className="flex-1 items-center justify-center px-8">
      {/* TODO: Ori 캐릭터 PNG로 교체 */}
      <View className="w-24 h-24 rounded-full bg-orange-100 items-center justify-center mb-6">
        <Text className="text-4xl">🐦</Text>
      </View>
      <Text className="text-xl font-bold text-gray-800 text-center mb-2">
        소통 탭이 잠겨 있어요
      </Text>
      <Text className="text-gray-500 text-center leading-6 mb-6">
        스텝 {remaining}개를 더 완료하면{'\n'}전 세계 학습자의 보이스메일을 들을 수 있어요.
      </Text>
      <View className="w-full bg-gray-100 rounded-full h-2 mb-2">
        <View
          className="bg-blue-500 h-2 rounded-full"
          style={{ width: `${(completedSteps / 3) * 100}%` }}
        />
      </View>
      <Text className="text-sm text-gray-400">{completedSteps} / 3 스텝 완료</Text>
    </View>
  );
}

// ─── 읽기 전용 미리보기 (3~5스텝) ───────────────────────────
function PreviewView() {
  return (
    <View className="flex-1">
      <View className="bg-blue-50 mx-4 mt-4 p-3 rounded-xl flex-row items-center gap-2">
        <Ionicons name="information-circle-outline" size={18} color="#3B82F6" />
        <Text className="text-blue-700 text-sm flex-1">
          스텝 6 완료 후 녹음·답장이 활성화돼요
        </Text>
      </View>
      {/* 피드 미리보기 — TODO(Day 8): 실제 데이터 연결 */}
      <ScrollView className="flex-1 px-4 mt-3">
        {[1, 2, 3].map((i) => (
          <View key={i} className="bg-white rounded-2xl p-4 mb-3 border border-gray-100">
            <View className="flex-row items-center gap-3 mb-3">
              <View className="w-10 h-10 rounded-full bg-gray-200" />
              <View>
                <Text className="font-medium text-gray-800">익명 학습자</Text>
                <Text className="text-xs text-gray-400">🇺🇸 영어 학습 중</Text>
              </View>
            </View>
            <View className="flex-row items-center gap-3 bg-gray-50 rounded-xl px-3 py-2.5">
              <Ionicons name="play-circle" size={28} color="#D1D5DB" />
              <View className="flex-1 h-1 bg-gray-200 rounded-full" />
              <Text className="text-xs text-gray-400">0:32</Text>
            </View>
          </View>
        ))}
      </ScrollView>
    </View>
  );
}

// ─── 내 대화 ──────────────────────────────────────────────────
interface ConversationItem {
  id: string;
  partnerFlag: string;
  partnerName: string;
  lastMessageAt: string | null;
  messageCount: number;
}

async function fetchConversations(
  userId: string
): Promise<{ items: ConversationItem[]; error: string | null }> {
  const { data, error } = await supabase
    .from('conversations')
    .select(`
      id,
      participant1,
      participant2,
      conversation_messages(sender_id, created_at, message_order)
    `)
    .order('created_at', { ascending: false });

  if (error) return { items: [], error: error.message };
  if (!data) return { items: [], error: null };

  const items: ConversationItem[] = data.map((conv) => {
    const messages = Array.isArray(conv.conversation_messages)
      ? (conv.conversation_messages as { sender_id: string; created_at: string; message_order: number }[])
      : [];

    const sorted = [...messages].sort(
      (a, b) => new Date(b.created_at).getTime() - new Date(a.created_at).getTime()
    );

    return {
      id: conv.id,
      partnerFlag: '🌐',
      partnerName: '익명 학습자',
      lastMessageAt: sorted[0]?.created_at ?? null,
      messageCount: messages.length,
    };
  });

  return { items, error: null };
}

function formatRelativeTime(iso: string): string {
  const diffMs = Date.now() - new Date(iso).getTime();
  const mins = Math.floor(diffMs / 60_000);
  if (mins < 1) return '방금 전';
  if (mins < 60) return `${mins}분 전`;
  const hours = Math.floor(mins / 60);
  if (hours < 24) return `${hours}시간 전`;
  const days = Math.floor(hours / 24);
  if (days < 7) return `${days}일 전`;
  return new Date(iso).toLocaleDateString('ko-KR');
}

function MyConversationsView({ userId }: { userId: string | null }) {
  const router = useRouter();
  const [conversations, setConversations] = useState<ConversationItem[]>([]);
  const [loading, setLoading] = useState(true);
  const [fetchError, setFetchError] = useState<string | null>(null);

  useEffect(() => {
    if (!userId) {
      setLoading(false);
      return;
    }
    setLoading(true);
    fetchConversations(userId)
      .then(({ items, error }) => {
        setConversations(items);
        setFetchError(error);
      })
      .finally(() => setLoading(false));
  }, [userId]);

  if (loading) {
    return (
      <View className="flex-1 items-center justify-center">
        <ActivityIndicator size="large" color="#3B82F6" />
      </View>
    );
  }

  if (fetchError) {
    return (
      <View className="flex-1 items-center justify-center px-8">
        <Ionicons name="alert-circle-outline" size={40} color="#EF4444" />
        <Text className="text-gray-800 font-semibold mt-3 mb-1">불러오기 실패</Text>
        <Text className="text-gray-400 text-sm text-center">{fetchError}</Text>
      </View>
    );
  }

  if (conversations.length === 0) {
    return (
      <View className="flex-1 items-center justify-center">
        <View className="w-20 h-20 rounded-full bg-gray-100 items-center justify-center mb-4">
          <Text className="text-3xl">💬</Text>
        </View>
        <Text className="text-gray-800 font-semibold mb-1">아직 대화가 없어요</Text>
        <Text className="text-gray-400 text-sm text-center px-8">
          브로드캐스트에 답장을 남기면 여기에 표시돼요
        </Text>
      </View>
    );
  }

  return (
    <ScrollView className="flex-1 px-4 mt-3">
      {conversations.map((conv) => (
        <Pressable
          key={conv.id}
          onPress={() => router.push(`/conversation/${conv.id}`)}
          className="bg-white rounded-2xl p-4 mb-3 border border-gray-100 flex-row items-center gap-3"
        >
          <View className="w-10 h-10 rounded-full bg-gray-200 items-center justify-center">
            <Text style={{ fontSize: 18 }}>{conv.partnerFlag}</Text>
          </View>
          <View className="flex-1">
            <Text className="font-medium text-gray-800">{conv.partnerName}</Text>
            <Text className="text-xs text-gray-400">
              {conv.lastMessageAt
                ? formatRelativeTime(conv.lastMessageAt)
                : '아직 메시지 없음'}
            </Text>
          </View>
          <Ionicons name="chevron-forward" size={18} color="#D1D5DB" />
        </Pressable>
      ))}
    </ScrollView>
  );
}

// ─── 전체 활성화 (6스텝 완료) ────────────────────────────────
function FullView() {
  const [activeTab, setActiveTab] = useState<CommunityTab>('feed');
  const [broadcasts, setBroadcasts] = useState<BroadcastItem[]>([]);
  const [loadingBroadcasts, setLoadingBroadcasts] = useState(true);
  const [fetchError, setFetchError] = useState<string | null>(null);
  const currentUserId = useAuthStore((s) => s.user?.id ?? null);

  const loadBroadcasts = useCallback(async () => {
    setLoadingBroadcasts(true);
    setFetchError(null);
    try {
      const { items, error } = await fetchBroadcasts(currentUserId);
      setBroadcasts(items);
      setFetchError(error);
    } catch (e: unknown) {
      setFetchError(e instanceof Error ? e.message : '불러오기 실패');
    } finally {
      setLoadingBroadcasts(false);
    }
  }, [currentUserId]);

  useEffect(() => {
    loadBroadcasts();
  }, [loadBroadcasts]);

  const myBroadcast = broadcasts.find((b) => b.sender_id === currentUserId) ?? null;
  const otherBroadcasts = broadcasts.filter((b) => b.sender_id !== currentUserId);

  return (
    <View className="flex-1">
      {/* 탭 바 */}
      <View className="flex-row border-b border-gray-100 px-4">
        <Pressable
          onPress={() => setActiveTab('feed')}
          className={`flex-1 py-3 items-center border-b-2 ${
            activeTab === 'feed' ? 'border-blue-500' : 'border-transparent'
          }`}
        >
          <Text
            className={`text-sm font-semibold ${
              activeTab === 'feed' ? 'text-blue-600' : 'text-gray-400'
            }`}
          >
            피드
          </Text>
        </Pressable>
        <Pressable
          onPress={() => setActiveTab('conversations')}
          className={`flex-1 py-3 items-center border-b-2 ${
            activeTab === 'conversations' ? 'border-blue-500' : 'border-transparent'
          }`}
        >
          <Text
            className={`text-sm font-semibold ${
              activeTab === 'conversations' ? 'text-blue-600' : 'text-gray-400'
            }`}
          >
            대화
          </Text>
        </Pressable>
      </View>

      {/* 탭 콘텐츠 */}
      {activeTab === 'feed' ? (
        loadingBroadcasts ? (
          <View className="flex-1 items-center justify-center">
            <ActivityIndicator size="large" color="#3B82F6" />
          </View>
        ) : fetchError ? (
          <View className="flex-1 items-center justify-center px-8">
            <Ionicons name="alert-circle-outline" size={40} color="#EF4444" />
            <Text className="text-gray-800 font-semibold mt-3 mb-1">불러오기 실패</Text>
            <Text className="text-gray-400 text-sm text-center mb-4">{fetchError}</Text>
            <Pressable
              onPress={loadBroadcasts}
              className="bg-blue-500 px-6 py-3 rounded-xl"
            >
              <Text className="text-white font-semibold">다시 시도</Text>
            </Pressable>
          </View>
        ) : (
          <ScrollView className="flex-1 px-4 mt-3">
            {/* 내 브로드캐스트 카드 (활성 중인 경우) */}
            {myBroadcast && (
              <View className="mb-4">
                <Text className="text-xs font-semibold text-gray-400 mb-2 uppercase tracking-wide">
                  내 브로드캐스트
                </Text>
                <BroadcastFeedItem item={myBroadcast} currentUserId={currentUserId} />
              </View>
            )}

            {/* 다른 사용자 피드 */}
            {otherBroadcasts.length === 0 ? (
              <View className="flex-1 items-center justify-center py-20">
                <View className="w-20 h-20 rounded-full bg-orange-100 items-center justify-center mb-4">
                  <Text className="text-3xl">🐦</Text>
                </View>
                <Text className="text-gray-800 font-semibold mb-1">첫 보이스메일을 남겨보세요</Text>
                <Text className="text-gray-400 text-sm text-center px-8">
                  전 세계 학습자들에게 내 목소리를 들려주세요
                </Text>
              </View>
            ) : (
              otherBroadcasts.map((item) => (
                <BroadcastFeedItem key={item.id} item={item} currentUserId={currentUserId} />
              ))
            )}
          </ScrollView>
        )
      ) : (
        <MyConversationsView userId={currentUserId} />
      )}

      {/* 새 녹음 FAB */}
      <Pressable
        className="absolute bottom-6 right-6 w-16 h-16 rounded-full bg-blue-500 items-center justify-center shadow-lg"
        // TODO(Day 8): 녹음 모달 열기
      >
        <Ionicons name="mic" size={28} color="white" />
      </Pressable>
    </View>
  );
}

// ─── 메인 ─────────────────────────────────────────────────────
export default function CommunityScreen() {
  const userId = useAuthStore((s) => s.user?.id ?? null);
  const [completedSteps, setCompletedSteps] = useState<number | null>(null);

  useEffect(() => {
    if (!userId) return;

    supabase
      .from('user_lesson_progress')
      .select('*', { count: 'exact', head: true })
      .eq('user_id', userId)
      .eq('status', 'completed')
      .then(({ count, error }) => {
        if (error || count === null) {
          setCompletedSteps(0); // fail to 'preview' or 'locked', never 'full'
        } else {
          setCompletedSteps(count);
        }
      });
  }, [userId]);

  if (completedSteps === null) {
    return (
      <View className="flex-1 bg-white items-center justify-center">
        <ActivityIndicator size="large" color="#3B82F6" />
      </View>
    );
  }

  const state = getCommunityState(completedSteps);

  return (
    <View className="flex-1 bg-white">
      {state === 'locked' && <LockedView completedSteps={completedSteps} />}
      {state === 'preview' && <PreviewView />}
      {state === 'full' && <FullView />}
    </View>
  );
}
