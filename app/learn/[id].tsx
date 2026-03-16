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

// ── 발음 점수 결과 화면 ───────────────────────────────────────
interface ScoreResult {
  score: number;
  passed: boolean;
  feedback_tokens: string[];
}

interface AiFeedbackResult {
  suggestions: string[];
  corrected: string;
}

function ScoreResultView({
  result,
  onContinue,
  onRetry,
  onRequestFeedback,
  aiFeedback,
  aiFeedbackLoading,
  aiFeedbackError,
}: {
  result: ScoreResult;
  onContinue: () => void;
  onRetry: () => void;
  onRequestFeedback: () => void;
  aiFeedback: AiFeedbackResult | null;
  aiFeedbackLoading: boolean;
  aiFeedbackError: string | null;
}) {
  const { score, passed, feedback_tokens } = result;
  return (
    <View className="items-center gap-4">
      <View
        className={`w-20 h-20 rounded-full items-center justify-center ${
          passed ? 'bg-green-100' : 'bg-red-100'
        }`}
      >
        <Text style={{ fontSize: 40 }}>{passed ? '✅' : '❌'}</Text>
      </View>
      <Text className={`text-3xl font-bold ${passed ? 'text-green-600' : 'text-red-500'}`}>
        {score}점
      </Text>
      <Text className={`text-sm font-semibold ${passed ? 'text-green-600' : 'text-red-500'}`}>
        {passed ? '통과! 잘했어요 🎉' : '60점 이상이면 통과예요'}
      </Text>
      {!passed && feedback_tokens.length > 0 && (
        <View className="bg-red-50 rounded-2xl px-4 py-3 w-full">
          <Text className="text-xs text-red-400 font-semibold mb-1">놓친 단어</Text>
          <Text className="text-red-600 text-sm">{feedback_tokens.join('  ·  ')}</Text>
        </View>
      )}

      {/* AI 피드백 */}
      {aiFeedback ? (
        <View className="bg-blue-50 rounded-2xl px-4 py-3 w-full gap-2">
          <Text className="text-xs text-blue-400 font-semibold">AI 피드백</Text>
          {aiFeedback.suggestions.map((s, i) => (
            <Text key={i} className="text-blue-700 text-sm">• {s}</Text>
          ))}
          {aiFeedback.corrected && (
            <View className="bg-white rounded-xl px-3 py-2 mt-1">
              <Text className="text-xs text-gray-400 mb-1">교정된 문장</Text>
              <Text className="text-gray-700 text-sm">{aiFeedback.corrected}</Text>
            </View>
          )}
        </View>
      ) : aiFeedbackError ? (
        <View className="bg-gray-50 rounded-2xl px-4 py-3 w-full items-center">
          <Text className="text-gray-400 text-sm">{aiFeedbackError}</Text>
        </View>
      ) : (
        <Pressable
          onPress={onRequestFeedback}
          disabled={aiFeedbackLoading}
          className="flex-row items-center gap-2 px-4 py-2 rounded-full bg-blue-50 w-full justify-center"
        >
          {aiFeedbackLoading ? (
            <ActivityIndicator size="small" color="#3B82F6" />
          ) : (
            <Ionicons name="sparkles" size={16} color="#3B82F6" />
          )}
          <Text className="text-blue-500 text-sm font-medium">
            {aiFeedbackLoading ? 'AI 분석 중...' : 'AI 피드백 받기'}
          </Text>
        </Pressable>
      )}

      {passed ? (
        <Pressable
          onPress={onContinue}
          className="bg-green-500 flex-row items-center gap-2 px-8 py-4 rounded-2xl w-full justify-center"
        >
          <Text className="text-white font-semibold text-base">다음으로</Text>
          <Ionicons name="chevron-forward" size={18} color="white" />
        </Pressable>
      ) : (
        <View className="gap-2 w-full">
          <Pressable
            onPress={onRetry}
            className="bg-amber-400 flex-row items-center gap-2 px-8 py-4 rounded-2xl w-full justify-center"
          >
            <Ionicons name="refresh" size={18} color="white" />
            <Text className="text-white font-semibold text-base">다시 시도</Text>
          </Pressable>
          <Pressable onPress={onContinue} className="items-center py-2">
            <Text className="text-gray-400 text-sm underline">그냥 넘어가기</Text>
          </Pressable>
        </View>
      )}
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
  const [lessonLanguageCode, setLessonLanguageCode] = useState('en');
  const [scripts, setScripts] = useState<Script[]>([]);
  const [currentIndex, setCurrentIndex] = useState(0);
  const [loading, setLoading] = useState(true);
  const [done, setDone] = useState(false);
  const [scoringPhase, setScoringPhase] = useState<'idle' | 'analyzing' | 'result'>('idle');
  const [scoreResult, setScoreResult] = useState<ScoreResult | null>(null);
  const [lastTranscript, setLastTranscript] = useState('');
  const [aiFeedback, setAiFeedback] = useState<AiFeedbackResult | null>(null);
  const [aiFeedbackLoading, setAiFeedbackLoading] = useState(false);
  const [aiFeedbackError, setAiFeedbackError] = useState<string | null>(null);

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
      supabase.from('lessons').select('title, languages(code)').eq('id', id).single(),
      supabase
        .from('lesson_scripts')
        .select('id, sequence_order, speaker, script_text')
        .eq('lesson_id', id)
        .order('sequence_order'),
    ]);

    if (lessonData && scriptRows) {
      setLessonTitle(lessonData.title);
      setLessonLanguageCode((lessonData as any).languages?.code ?? 'en');
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
    setScoringPhase('idle');
    setScoreResult(null);
    setLastTranscript('');
    setAiFeedback(null);
    setAiFeedbackError(null);
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

  // ── 녹음 완료 후 처리: 업로드 → STT → 발음 점수 ─────────────
  // useCallback: countdown useEffect 의존성 배열에 넣기 위해 필요 (stale closure 방지)
  const handleStopRecording = useCallback(async () => {
    const uri = await recorder.stopRecording();
    if (!uri || !current) return;
    setRecordingUri(uri);
    setScoringPhase('analyzing');

    try {
      // 1. 업로드
      const path = await recorder.uploadRecording(uri, current.id);
      if (!path || !user || !id) {
        advance();
        return;
      }

      // 2. STT
      const sttRes = await supabase.functions.invoke('stt-transcribe', {
        body: { recording_path: path, language: lessonLanguageCode },
      });
      const transcript: string = sttRes.data?.transcript ?? '';

      if (!transcript) {
        Alert.alert('인식 실패', '음성이 인식되지 않았어요. 더 크게 말해보세요.');
        advance();
        return;
      }

      setLastTranscript(transcript);

      // 3. 발음 점수 산출 + DB 저장 (edge function이 upsert 담당)
      const scoreRes = await supabase.functions.invoke('pronunciation-score', {
        body: { lesson_id: id, script_id: current.id, transcript },
      });

      if (scoreRes.data) {
        setScoreResult(scoreRes.data);
        setScoringPhase('result');
      } else {
        Alert.alert('채점 실패', '발음 채점에 실패했어요. 다시 시도해주세요.');
        advance();
      }
    } catch {
      Alert.alert('오류', '분석 중 오류가 발생했어요. 다시 시도해주세요.');
      advance();
    }
  }, [current, recorder, user, id, lessonLanguageCode]);

  const handleRequestAiFeedback = useCallback(async () => {
    if (!user || !current || !lastTranscript) return;
    setAiFeedbackLoading(true);
    try {
      const res = await supabase.functions.invoke('ai-feedback', {
        body: {
          original_script: current.script_text,
          transcript: lastTranscript,
        },
      });
      if (res.error) {
        const status = (res.error as any)?.context?.status;
        if (status === 429) {
          setAiFeedbackError('오늘 AI 피드백을 모두 사용했어요 (5회/일)');
        } else {
          setAiFeedbackError('AI 피드백 요청에 실패했어요.');
        }
      } else if (res.data) {
        setAiFeedback(res.data);
      }
    } catch {
      setAiFeedbackError('AI 피드백 요청에 실패했어요.');
    } finally {
      setAiFeedbackLoading(false);
    }
  }, [user, current, lastTranscript]);

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
            // User 턴: 녹음 → 분석 → 결과
            <View className="items-center gap-3">
              {scoringPhase === 'analyzing' ? (
                // 분석 중
                <View className="items-center gap-3 py-4">
                  <ActivityIndicator size="large" color="#F59E0B" />
                  <Text className="text-amber-500 font-semibold">분석 중...</Text>
                </View>
              ) : scoringPhase === 'result' && scoreResult ? (
                // Pass / Retry 결과
                <ScoreResultView
                  result={scoreResult}
                  onContinue={advance}
                  onRetry={() => {
                    setScoringPhase('idle');
                    setScoreResult(null);
                    setRecordingUri(null);
                    setAiFeedback(null);
                    setAiFeedbackError(null);
                  }}
                  onRequestFeedback={handleRequestAiFeedback}
                  aiFeedback={aiFeedback}
                  aiFeedbackLoading={aiFeedbackLoading}
                  aiFeedbackError={aiFeedbackError}
                />
              ) : recorder.isRecording ? (
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
              ) : (
                // 대기: 녹음 시작 버튼
                <>
                  <Pressable
                    onPress={handleStartRecording}
                    className="bg-amber-400 flex-row items-center gap-2 px-8 py-4 rounded-2xl w-full justify-center"
                  >
                    <Ionicons name="mic" size={20} color="white" />
                    <Text className="text-white font-semibold text-base">녹음 시작</Text>
                  </Pressable>
                  <Pressable onPress={advance}>
                    <Text className="text-gray-400 text-sm underline">건너뛰기</Text>
                  </Pressable>
                </>
              )}
            </View>
          )}
        </View>
      )}
    </SafeAreaView>
  );
}
