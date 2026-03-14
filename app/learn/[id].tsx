import { useEffect, useState } from 'react';
import { View, Text, Pressable, ActivityIndicator, SafeAreaView } from 'react-native';
import { router, useLocalSearchParams } from 'expo-router';
import { Ionicons } from '@expo/vector-icons';
import { supabase } from '../../src/lib/supabase';
import { useAuthStore } from '../../src/store/authStore';

interface Script {
  id: string;
  sequence_order: number;
  speaker: 'ai' | 'user';
  script_text: string;
}

// ── 캐릭터 버블 ──────────────────────────────────────────────
function CharacterBubble({
  speaker,
  phase,
}: {
  speaker: 'ai' | 'user';
  phase: 'speaking' | 'waiting';
}) {
  const isAI = speaker === 'ai';

  return (
    <View className="items-center gap-3">
      {/* 캐릭터 아이콘 */}
      <View
        className={`w-24 h-24 rounded-full items-center justify-center ${
          isAI ? 'bg-blue-100' : 'bg-amber-100'
        }`}
      >
        <Text style={{ fontSize: 48 }}>{isAI ? '🤖' : '🙋'}</Text>
      </View>

      {/* 상태 라벨 */}
      <View
        className={`px-3 py-1 rounded-full ${
          phase === 'speaking'
            ? isAI ? 'bg-blue-500' : 'bg-amber-500'
            : 'bg-gray-200'
        }`}
      >
        <Text
          className={`text-xs font-semibold ${
            phase === 'speaking' ? 'text-white' : 'text-gray-500'
          }`}
        >
          {phase === 'speaking'
            ? isAI ? '말하는 중...' : '녹음하세요'
            : isAI ? '기다리는 중' : '준비 중'}
        </Text>
      </View>
    </View>
  );
}

// ── 완료 화면 ─────────────────────────────────────────────────
function CompletedView({ title, onBack }: { title: string; onBack: () => void }) {
  return (
    <View className="flex-1 items-center justify-center px-8 gap-6">
      <Text style={{ fontSize: 64 }}>🎉</Text>
      <Text className="text-2xl font-bold text-gray-800 text-center">{title} 완료!</Text>
      <Text className="text-gray-500 text-center">대화를 모두 완료했어요.</Text>
      <Pressable
        onPress={onBack}
        className="bg-blue-500 px-8 py-3 rounded-2xl"
      >
        <Text className="text-white font-semibold text-base">학습으로 돌아가기</Text>
      </Pressable>
    </View>
  );
}

// ── 메인 ─────────────────────────────────────────────────────
export default function LessonScreen() {
  const { id } = useLocalSearchParams<{ id: string }>();
  const { user } = useAuthStore();
  const [lessonTitle, setLessonTitle] = useState('');
  const [scripts, setScripts] = useState<Script[]>([]);
  const [currentIndex, setCurrentIndex] = useState(0);
  const [loading, setLoading] = useState(true);
  const [done, setDone] = useState(false);

  useEffect(() => {
    if (!id || !user) return;
    loadLesson();
  }, [id, user]);

  async function loadLesson() {
    const [{ data: lessonData }, { data: scriptRows }] = await Promise.all([
      supabase.from('lessons').select('title').eq('id', id).single(),
      supabase
        .from('lesson_scripts')
        .select('id, sequence_order, speaker, script_text')
        .eq('lesson_id', id)
        .order('sequence_order'),
    ]);

    if (lessonData) setLessonTitle(lessonData.title);
    if (scriptRows) setScripts(scriptRows as Script[]);
    setLoading(false);
  }

  async function advance() {
    if (currentIndex + 1 >= scripts.length) {
      await saveProgress();
      setDone(true);
    } else {
      setCurrentIndex((i) => i + 1);
    }
  }

  async function saveProgress() {
    if (!user || !id) return;
    const rows = scripts.map((s) => ({
      user_id: user.id,
      lesson_id: id,
      script_id: s.id,
      status: 'completed' as const,
      completed_at: new Date().toISOString(),
    }));
    await supabase
      .from('user_lesson_progress')
      .upsert(rows, { onConflict: 'user_id,script_id' });
  }

  if (loading) {
    return (
      <View className="flex-1 items-center justify-center bg-gray-50">
        <ActivityIndicator size="large" color="#3B82F6" />
      </View>
    );
  }

  const current = scripts[currentIndex];

  return (
    <SafeAreaView className="flex-1 bg-gray-50">
      {/* 헤더 */}
      <View className="flex-row items-center px-4 py-3 bg-white border-b border-gray-100">
        <Pressable onPress={() => router.back()} className="mr-3">
          <Ionicons name="chevron-back" size={24} color="#374151" />
        </Pressable>
        <Text className="flex-1 text-base font-bold text-gray-800">{lessonTitle}</Text>
        <Text className="text-sm text-gray-400">
          {done ? scripts.length : currentIndex + 1} / {scripts.length}
        </Text>
      </View>

      {/* 진행 바 */}
      <View className="h-1 bg-gray-200">
        <View
          className="h-1 bg-blue-500"
          style={{
            width: `${((done ? scripts.length : currentIndex + 1) / scripts.length) * 100}%`,
          }}
        />
      </View>

      {done ? (
        <CompletedView title={lessonTitle} onBack={() => router.replace('/(tabs)/learn' as any)} />
      ) : (
        <View className="flex-1 justify-between px-6 py-8">
          {/* 캐릭터 */}
          <View className="items-center mt-4">
            <CharacterBubble
              speaker={current.speaker}
              phase={current.speaker === 'ai' ? 'speaking' : 'waiting'}
            />
          </View>

          {/* 말풍선 */}
          <View
            className={`rounded-3xl p-5 mx-2 ${
              current.speaker === 'ai' ? 'bg-white border border-blue-100' : 'bg-amber-50 border border-amber-100'
            }`}
          >
            <Text className="text-lg text-gray-800 leading-7 text-center">
              {current.script_text}
            </Text>
          </View>

          {/* 하단 버튼 */}
          {current.speaker === 'ai' ? (
            // AI 턴: 다음으로 넘어가기
            <View className="items-center gap-3">
              {/* Day 6: TTS 재생 버튼 자리 */}
              <View className="flex-row items-center gap-2 bg-blue-50 px-4 py-2 rounded-full">
                <Ionicons name="volume-medium-outline" size={16} color="#93C5FD" />
                <Text className="text-xs text-blue-300">TTS 재생 (Day 6에서 연결)</Text>
              </View>
              <Pressable
                onPress={advance}
                className="bg-blue-500 flex-row items-center gap-2 px-8 py-4 rounded-2xl w-full justify-center"
              >
                <Text className="text-white font-semibold text-base">다음</Text>
                <Ionicons name="chevron-forward" size={18} color="white" />
              </Pressable>
            </View>
          ) : (
            // User 턴: 녹음
            <View className="items-center gap-3">
              {/* Day 6: 실제 녹음 */}
              <Pressable
                disabled
                className="bg-amber-400 flex-row items-center gap-2 px-8 py-4 rounded-2xl w-full justify-center opacity-50"
              >
                <Ionicons name="mic" size={20} color="white" />
                <Text className="text-white font-semibold text-base">녹음 (Day 6에서 연결)</Text>
              </Pressable>
              <Pressable onPress={advance}>
                <Text className="text-gray-400 text-sm underline">건너뛰기</Text>
              </Pressable>
            </View>
          )}
        </View>
      )}
    </SafeAreaView>
  );
}
