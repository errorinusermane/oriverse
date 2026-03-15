import { useCallback, useEffect, useRef, useState } from 'react';
import {
  View,
  Text,
  Pressable,
  ActivityIndicator,
  SafeAreaView,
  Alert,
} from 'react-native';
import { router, useLocalSearchParams } from 'expo-router';
import { Ionicons } from '@expo/vector-icons';
import AsyncStorage from '@react-native-async-storage/async-storage';
import { supabase } from '../../src/lib/supabase';
import { useAuthStore } from '../../src/store/authStore';
import { useTTS } from '../../src/hooks/useTTS';
import { useRecorder } from '../../src/hooks/useRecorder';

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
      <View
        className={`w-24 h-24 rounded-full items-center justify-center ${
          isAI ? 'bg-blue-100' : 'bg-amber-100'
        }`}
      >
        <Text style={{ fontSize: 48 }}>{isAI ? '🤖' : '🙋'}</Text>
      </View>
      <View
        className={`px-3 py-1 rounded-full ${
          phase === 'speaking'
            ? isAI
              ? 'bg-blue-500'
              : 'bg-amber-500'
            : 'bg-gray-200'
        }`}
      >
        <Text
          className={`text-xs font-semibold ${
            phase === 'speaking' ? 'text-white' : 'text-gray-500'
          }`}
        >
          {phase === 'speaking'
            ? isAI
              ? '말하는 중...'
              : '녹음하세요'
            : isAI
            ? '기다리는 중'
            : '준비 중'}
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
      <Pressable onPress={onBack} className="bg-blue-500 px-8 py-3 rounded-2xl">
        <Text className="text-white font-semibold text-base">학습으로 돌아가기</Text>
      </Pressable>
    </View>
  );
}

// ── TTS 재생 버튼 ──────────────────────────────────────────────
function TTSButton({ onPress, status }: { onPress: () => void; status: string }) {
  const isLoading = status === 'loading';
  const isPlaying = status === 'playing';

  return (
    <Pressable
      onPress={onPress}
      disabled={isLoading}
      className={`flex-row items-center gap-2 px-4 py-2 rounded-full ${
        isPlaying ? 'bg-blue-100' : 'bg-blue-50'
      }`}
    >
      {isLoading ? (
        <ActivityIndicator size="small" color="#3B82F6" />
      ) : (
        <Ionicons
          name={isPlaying ? 'pause-circle' : 'volume-medium'}
          size={18}
          color="#3B82F6"
        />
      )}
      <Text className="text-blue-500 text-sm font-medium">
        {isLoading ? '로딩 중...' : isPlaying ? '재생 중' : '듣기'}
      </Text>
    </Pressable>
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

  const current = scripts[currentIndex];

  // TTS 훅: AI 턴일 때만 script_id 전달
  const tts = useTTS(current?.speaker === 'ai' ? current.id : null);

  // 녹음 훅
  const recorder = useRecorder(user?.id ?? null);

  // 녹음 플로우 상태
  const [recordingUri, setRecordingUri] = useState<string | null>(null);
  const prefetchedRef = useRef<Set<string>>(new Set());

  // ── 데이터 로드 (AsyncStorage 오프라인 캐시) ─────────────────
  useEffect(() => {
    if (!id || !user) return;
    loadLesson();
  }, [id, user]);

  async function loadLesson() {
    const cacheKey = `lesson_scripts_${id}`;

    // 오프라인 캐시 먼저 읽기 (텍스트 즉시 표시)
    try {
      const cached = await AsyncStorage.getItem(cacheKey);
      if (cached) {
        const { title, scripts: cachedScripts } = JSON.parse(cached);
        setLessonTitle(title);
        setScripts(cachedScripts);
        setLoading(false);
      }
    } catch {}

    // 최신 데이터 fetch
    const [{ data: lessonData }, { data: scriptRows }] = await Promise.all([
      supabase.from('lessons').select('title').eq('id', id).single(),
      supabase
        .from('lesson_scripts')
        .select('id, sequence_order, speaker, script_text')
        .eq('lesson_id', id)
        .order('sequence_order'),
    ]);

    if (lessonData && scriptRows) {
      setLessonTitle(lessonData.title);
      setScripts(scriptRows as Script[]);
      setLoading(false);

      // AsyncStorage에 캐시 저장
      try {
        await AsyncStorage.setItem(
          cacheKey,
          JSON.stringify({ title: lessonData.title, scripts: scriptRows })
        );
      } catch {}
    }
  }

  // ── TTS pre-fetch: AI 스크립트 전체 백그라운드 캐싱 ──────────
  useEffect(() => {
    if (scripts.length === 0) return;
    scripts.forEach((s) => {
      if (s.speaker === 'ai' && !prefetchedRef.current.has(s.id)) {
        prefetchedRef.current.add(s.id);
        tts.prefetch(s.id);
      }
    });
  }, [scripts]);

  // ── AI 턴 전환 시 TTS 자동 재생 ──────────────────────────────
  useEffect(() => {
    if (!current) return;
    if (current.speaker === 'ai') {
      // 짧은 딜레이 후 자동 재생 (화면 전환 애니메이션 끝난 후)
      const timer = setTimeout(() => tts.play(), 300);
      return () => clearTimeout(timer);
    }
    // 녹음 상태 초기화
    setRecordingUri(null);
  }, [currentIndex]);

  // ── countdown 0 도달 시 자동 중단 ────────────────────────────
  // 🔴 Fix: state updater 안에서 async stopRecording() 호출 제거 → 여기서 처리
  useEffect(() => {
    if (recorder.countdown === 0 && recorder.isRecording) {
      handleStopRecording();
    }
  }, [recorder.countdown, handleStopRecording]);

  // ── 진행 ─────────────────────────────────────────────────────
  async function advance() {
    // 🔴 Fix: User 턴 전환 전 TTS Audio Session 완전 해제 (세션 충돌 방지)
    await tts.stop();
    if (currentIndex + 1 >= scripts.length) {
      await saveAllCompleted();
      setDone(true);
    } else {
      setCurrentIndex((i) => i + 1);
    }
  }

  async function saveAllCompleted() {
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

  // ── 녹음 완료 후 처리 ─────────────────────────────────────────
  // useCallback: countdown useEffect 의존성 배열에 넣기 위해 필요 (stale closure 방지)
  const handleStopRecording = useCallback(async () => {
    const uri = await recorder.stopRecording();
    if (!uri || !current) return;
    setRecordingUri(uri);

    // 백그라운드 업로드 (완료 기다리지 않고 즉시 다음으로)
    recorder.uploadRecording(uri, current.id).then(async (path) => {
      if (path && user && id) {
        await supabase.from('user_lesson_progress').upsert(
          {
            user_id: user.id,
            lesson_id: id,
            script_id: current.id,
            status: 'attempted',
            recording_path: path,
            attempted_at: new Date().toISOString(),
          },
          { onConflict: 'user_id,script_id' }
        );
      }
    });

    advance();
  }, [current, recorder, user, id]);

  async function handleStartRecording() {
    const ok = await recorder.startRecording();
    if (!ok) {
      Alert.alert('마이크 권한 필요', '설정에서 마이크 접근을 허용해주세요.');
    }
  }

  // ── 렌더 ─────────────────────────────────────────────────────
  if (loading) {
    return (
      <View className="flex-1 items-center justify-center bg-gray-50">
        <ActivityIndicator size="large" color="#3B82F6" />
      </View>
    );
  }

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
        <CompletedView
          title={lessonTitle}
          onBack={() => router.replace('/(tabs)/learn' as any)}
        />
      ) : (
        <View className="flex-1 justify-between px-6 py-8">
          {/* 캐릭터 */}
          <View className="items-center mt-4">
            <CharacterBubble
              speaker={current.speaker}
              phase={
                current.speaker === 'ai'
                  ? tts.status === 'playing'
                    ? 'speaking'
                    : 'waiting'
                  : recorder.isRecording
                  ? 'speaking'
                  : 'waiting'
              }
            />
          </View>

          {/* 말풍선 */}
          <View
            className={`rounded-3xl p-5 mx-2 ${
              current.speaker === 'ai'
                ? 'bg-white border border-blue-100'
                : 'bg-amber-50 border border-amber-100'
            }`}
          >
            <Text className="text-lg text-gray-800 leading-7 text-center">
              {current.script_text}
            </Text>
          </View>

          {/* 하단 버튼 */}
          {current.speaker === 'ai' ? (
            // AI 턴: TTS 재생 버튼 + 다음
            <View className="items-center gap-3">
              <TTSButton
                status={tts.status}
                onPress={() => (tts.status === 'playing' ? tts.stop() : tts.play())}
              />
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
              {recorder.isRecording ? (
                // 녹음 중: 카운트다운 + 완료 버튼
                <>
                  <View className="flex-row items-center gap-2 bg-red-50 px-4 py-2 rounded-full">
                    <View className="w-2 h-2 rounded-full bg-red-500" />
                    <Text className="text-red-500 text-sm font-semibold">
                      {recorder.countdown}초
                    </Text>
                  </View>
                  <Pressable
                    onPress={handleStopRecording}
                    className="bg-red-500 flex-row items-center gap-2 px-8 py-4 rounded-2xl w-full justify-center"
                  >
                    <Ionicons name="stop-circle" size={20} color="white" />
                    <Text className="text-white font-semibold text-base">녹음 완료</Text>
                  </Pressable>
                </>
              ) : recorder.isUploading ? (
                // 업로드 중
                <View className="flex-row items-center gap-2 py-4">
                  <ActivityIndicator size="small" color="#F59E0B" />
                  <Text className="text-amber-500 text-sm">업로드 중...</Text>
                </View>
              ) : (
                // 대기: 녹음 시작 버튼
                <Pressable
                  onPress={handleStartRecording}
                  className="bg-amber-400 flex-row items-center gap-2 px-8 py-4 rounded-2xl w-full justify-center"
                >
                  <Ionicons name="mic" size={20} color="white" />
                  <Text className="text-white font-semibold text-base">녹음 시작</Text>
                </Pressable>
              )}
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
