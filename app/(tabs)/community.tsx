import { View, Text, Pressable, ScrollView, Image } from 'react-native';
import { Ionicons } from '@expo/vector-icons';

// TODO(Day 8): DB에서 user_lesson_progress 완료 수 가져오기
const COMPLETED_STEPS = 0; // 임시 하드코딩

type CommunityState = 'locked' | 'preview' | 'full';

function getCommunityState(completedSteps: number): CommunityState {
  if (completedSteps >= 6) return 'full';
  if (completedSteps >= 3) return 'preview';
  return 'locked';
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
      {/* 진행도 바 */}
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
            {/* 음성 재생 바 (비활성) */}
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

// ─── 전체 활성화 (6스텝 완료) ────────────────────────────────
function FullView() {
  return (
    <View className="flex-1">
      {/* 탭: 브로드캐스트 / 내 대화 */}
      {/* TODO(Day 8): 탭 전환 로직 추가 */}
      <View className="flex-row border-b border-gray-100 px-4">
        <Pressable className="flex-1 py-3 border-b-2 border-blue-500 items-center">
          <Text className="text-blue-600 font-semibold text-sm">브로드캐스트</Text>
        </Pressable>
        <Pressable className="flex-1 py-3 items-center">
          <Text className="text-gray-400 text-sm">내 대화</Text>
        </Pressable>
      </View>

      {/* 피드 — Empty State */}
      <View className="flex-1 items-center justify-center">
        <View className="w-20 h-20 rounded-full bg-orange-100 items-center justify-center mb-4">
          <Text className="text-3xl">🐦</Text>
        </View>
        <Text className="text-gray-800 font-semibold mb-1">첫 보이스메일을 남겨보세요</Text>
        <Text className="text-gray-400 text-sm text-center px-8">
          전 세계 학습자들에게 내 목소리를 들려주세요
        </Text>
      </View>

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
  const state = getCommunityState(COMPLETED_STEPS);

  return (
    <View className="flex-1 bg-white">
      {state === 'locked' && <LockedView completedSteps={COMPLETED_STEPS} />}
      {state === 'preview' && <PreviewView />}
      {state === 'full' && <FullView />}
    </View>
  );
}
