import { View, Text, ScrollView, Pressable, Alert } from 'react-native';
import { Ionicons } from '@expo/vector-icons';

// Day 5에서 DB 연결. 지금은 UI 뼈대용 하드코딩.
const STEPS = [
  { id: 1, title: '기본 문법', subtitle: '어순, 평서문, 의문문, 조동사', isPremium: false },
  { id: 2, title: '카페 대화', subtitle: '주문 표현, 정중한 요청', isPremium: false },
  { id: 3, title: '음식점 대화', subtitle: '메뉴 묻기, 알레르기, 계산', isPremium: false },
  { id: 4, title: '마트 대화', subtitle: '위치 묻기, 수량 표현', isPremium: false },
  { id: 5, title: '취미 / 과거 경험', subtitle: '과거형, 수동태, 과거분사', isPremium: false },
  { id: 6, title: '리액션 모음', subtitle: '감정 표현, 맞장구, 감탄사', isPremium: false },
  { id: 7, title: '50동사 회화', subtitle: '빈도 높은 동사 50개 실전 회화', isPremium: true },
];

type StepStatus = 'available' | 'locked' | 'completed' | 'review';

// TODO(Day 5): DB에서 user_lesson_progress 불러와 실제 상태 계산
function getStepStatus(stepId: number): StepStatus {
  if (stepId === 1) return 'available';
  return 'locked';
}

function StepCard({ step }: { step: (typeof STEPS)[0] }) {
  const status = getStepStatus(step.id);

  const handlePress = () => {
    if (status === 'locked') {
      Alert.alert('', '이전 스텝을 먼저 완료하세요.');
      return;
    }
    // TODO(Day 5): router.push(`/learn/${step.id}`)
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
          status === 'locked' ? 'bg-gray-200' : 'bg-blue-100'
        }`}
      >
        {status === 'completed' ? (
          <Ionicons name="checkmark" size={22} color="white" />
        ) : status === 'locked' ? (
          <Ionicons name="lock-closed" size={18} color="#9CA3AF" />
        ) : (
          <Text className="text-blue-600 font-bold text-base">{step.id}</Text>
        )}
      </View>

      {/* 텍스트 */}
      <View className="flex-1">
        <View className="flex-row items-center gap-2">
          <Text className={`font-semibold text-base ${status === 'locked' ? 'text-gray-400' : 'text-gray-800'}`}>
            {step.title}
          </Text>
          {step.isPremium && (
            <View className="bg-amber-100 px-2 py-0.5 rounded-full">
              <Text className="text-amber-700 text-xs font-medium">프리미엄</Text>
            </View>
          )}
        </View>
        <Text className={`text-sm mt-0.5 ${status === 'locked' ? 'text-gray-300' : 'text-gray-500'}`}>
          {step.subtitle}
        </Text>
      </View>

      {/* 우측 화살표 / 복습 */}
      {status === 'completed' && (
        <View className="bg-gray-100 px-2 py-1 rounded-lg">
          <Text className="text-xs text-gray-500">복습</Text>
        </View>
      )}
      {(status === 'available' || status === 'review') && (
        <Ionicons name="chevron-forward" size={18} color="#9CA3AF" />
      )}
    </Pressable>
  );
}

export default function LearnScreen() {
  return (
    <ScrollView className="flex-1 bg-gray-50" contentContainerClassName="p-4 pb-8">
      {/* 진행도 요약 — TODO(Day 5): 실제 데이터 연결 */}
      <View className="bg-white rounded-2xl p-4 mb-5 border border-gray-100">
        <View className="flex-row justify-between items-center">
          <View className="items-center">
            <Text className="text-2xl font-bold text-gray-800">0</Text>
            <Text className="text-xs text-gray-500 mt-0.5">스트릭</Text>
          </View>
          <View className="items-center">
            <Text className="text-2xl font-bold text-blue-500">0</Text>
            <Text className="text-xs text-gray-500 mt-0.5">완료 스텝</Text>
          </View>
          <View className="items-center">
            <Text className="text-2xl font-bold text-gray-800">0</Text>
            <Text className="text-xs text-gray-500 mt-0.5">포인트</Text>
          </View>
        </View>
      </View>

      {/* 스텝 목록 */}
      <Text className="text-xs font-semibold text-gray-400 uppercase tracking-wider mb-3 ml-1">
        학습 스텝
      </Text>
      {STEPS.map((step) => (
        <StepCard key={step.id} step={step} />
      ))}
    </ScrollView>
  );
}
