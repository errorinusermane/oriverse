import { useCallback, useState } from 'react';
import { View, Text, ScrollView, Pressable, Alert, ActivityIndicator } from 'react-native';
import { router, useFocusEffect } from 'expo-router';
import { Ionicons } from '@expo/vector-icons';
import { supabase } from '../../src/lib/supabase';
import { useAuthStore } from '../../src/store/authStore';

type StepStatus = 'available' | 'locked' | 'completed';

interface Lesson {
  id: string;
  step_number: number;
  title: string;
  description: string | null;
  is_premium: boolean;
  script_count: number;
  completed_count: number;
}

interface UserStats {
  streak_days: number;
  points: number;
}

function calcStatus(lesson: Lesson, lessons: Lesson[]): StepStatus {
  const allScriptsDone = lesson.script_count > 0 && lesson.completed_count >= lesson.script_count;
  if (allScriptsDone) return 'completed';

  if (lesson.step_number === 1) return 'available';

  const prev = lessons.find((l) => l.step_number === lesson.step_number - 1);
  if (prev && prev.script_count > 0 && prev.completed_count >= prev.script_count) return 'available';

  return 'locked';
}

function StepCard({ lesson, status }: { lesson: Lesson; status: StepStatus }) {
  const handlePress = () => {
    if (status === 'locked') {
      Alert.alert('', '이전 스텝을 먼저 완료하세요.');
      return;
    }
    router.push(`/learn/${lesson.id}` as any);
  };

  return (
    <Pressable
      onPress={handlePress}
      className={`flex-row items-center p-4 mb-3 rounded-2xl border ${
        status === 'locked' ? 'bg-gray-50 border-gray-100' : 'bg-white border-gray-200'
      }`}
    >
      {/* 스텝 번호 / 상태 아이콘 */}
      <View
        className={`w-12 h-12 rounded-full items-center justify-center mr-4 ${
          status === 'completed' ? 'bg-blue-500' :
          status === 'locked'    ? 'bg-gray-200' : 'bg-blue-100'
        }`}
      >
        {status === 'completed' ? (
          <Ionicons name="checkmark" size={22} color="white" />
        ) : status === 'locked' ? (
          <Ionicons name="lock-closed" size={18} color="#9CA3AF" />
        ) : (
          <Text className="text-blue-600 font-bold text-base">{lesson.step_number}</Text>
        )}
      </View>

      {/* 텍스트 */}
      <View className="flex-1">
        <View className="flex-row items-center gap-2">
          <Text className={`font-semibold text-base ${status === 'locked' ? 'text-gray-400' : 'text-gray-800'}`}>
            {lesson.title}
          </Text>
          {lesson.is_premium && (
            <View className="bg-amber-100 px-2 py-0.5 rounded-full">
              <Text className="text-amber-700 text-xs font-medium">프리미엄</Text>
            </View>
          )}
        </View>
        {lesson.description && (
          <Text className={`text-sm mt-0.5 ${status === 'locked' ? 'text-gray-300' : 'text-gray-500'}`}>
            {lesson.description}
          </Text>
        )}
      </View>

      {/* 우측 */}
      {status === 'completed' && (
        <View className="bg-gray-100 px-2 py-1 rounded-lg">
          <Text className="text-xs text-gray-500">복습</Text>
        </View>
      )}
      {status === 'available' && (
        <Ionicons name="chevron-forward" size={18} color="#9CA3AF" />
      )}
    </Pressable>
  );
}

export default function LearnScreen() {
  const { user } = useAuthStore();
  const [lessons, setLessons] = useState<Lesson[]>([]);
  const [stats, setStats] = useState<UserStats>({ streak_days: 0, points: 0 });
  const [loading, setLoading] = useState(true);

  // 탭 복귀 시마다 재로드 (useEffect는 탭 마운트 유지로 미실행)
  useFocusEffect(
    useCallback(() => {
      if (!user) return;
      loadData();
    }, [user])
  );

  async function loadData() {
    if (!user) return;
    setLoading(true);

    // 1. 유저 stats + learning_language_id 조회
    const { data: userData } = await supabase
      .from('users')
      .select('learning_language_id, streak_days, points')
      .eq('id', user.id)
      .single();

    if (userData?.streak_days != null || userData?.points != null) {
      setStats({ streak_days: userData.streak_days ?? 0, points: userData.points ?? 0 });
    }

    const langId = userData?.learning_language_id;
    if (!langId) {
      setLoading(false);
      return;
    }

    // 2. lessons 조회
    const { data: lessonRows } = await supabase
      .from('lessons')
      .select('id, step_number, title, description, is_premium')
      .eq('language_id', langId)
      .order('step_number');

    if (!lessonRows) {
      setLoading(false);
      return;
    }

    const lessonIds = lessonRows.map((l) => l.id);

    // 3. script 개수 직접 집계 (embedded count는 문자열 반환 이슈)
    const [{ data: scriptRows }, { data: progressRows }] = await Promise.all([
      supabase.from('lesson_scripts').select('lesson_id').in('lesson_id', lessonIds),
      supabase
        .from('user_lesson_progress')
        .select('lesson_id')
        .eq('user_id', user.id)
        .eq('status', 'completed')
        .in('lesson_id', lessonIds),
    ]);

    const scriptCountByLesson: Record<string, number> = {};
    for (const row of scriptRows ?? []) {
      scriptCountByLesson[row.lesson_id] = (scriptCountByLesson[row.lesson_id] ?? 0) + 1;
    }

    const completedByLesson: Record<string, number> = {};
    for (const row of progressRows ?? []) {
      completedByLesson[row.lesson_id] = (completedByLesson[row.lesson_id] ?? 0) + 1;
    }

    const mapped: Lesson[] = lessonRows.map((l) => ({
      id: l.id,
      step_number: l.step_number,
      title: l.title,
      description: l.description,
      is_premium: l.is_premium,
      script_count: scriptCountByLesson[l.id] ?? 0,
      completed_count: completedByLesson[l.id] ?? 0,
    }));

    setLessons(mapped);
    setLoading(false);
  }

  const completedSteps = lessons.filter(
    (l) => l.script_count > 0 && l.completed_count >= l.script_count
  ).length;

  if (loading) {
    return (
      <View className="flex-1 items-center justify-center bg-gray-50">
        <ActivityIndicator size="large" color="#3B82F6" />
      </View>
    );
  }

  return (
    <ScrollView className="flex-1 bg-gray-50" contentContainerClassName="p-4 pb-8">
      {/* 진행도 요약 */}
      <View className="bg-white rounded-2xl p-4 mb-5 border border-gray-100">
        <View className="flex-row justify-between items-center">
          <View className="items-center">
            <Text className="text-2xl font-bold text-gray-800">{stats.streak_days}</Text>
            <Text className="text-xs text-gray-500 mt-0.5">스트릭</Text>
          </View>
          <View className="items-center">
            <Text className="text-2xl font-bold text-blue-500">{completedSteps}</Text>
            <Text className="text-xs text-gray-500 mt-0.5">완료 스텝</Text>
          </View>
          <View className="items-center">
            <Text className="text-2xl font-bold text-gray-800">{stats.points}</Text>
            <Text className="text-xs text-gray-500 mt-0.5">포인트</Text>
          </View>
        </View>
      </View>

      {/* 스텝 목록 */}
      <Text className="text-xs font-semibold text-gray-400 uppercase tracking-wider mb-3 ml-1">
        학습 스텝
      </Text>
      {lessons.map((lesson) => (
        <StepCard key={lesson.id} lesson={lesson} status={calcStatus(lesson, lessons)} />
      ))}
    </ScrollView>
  );
}
