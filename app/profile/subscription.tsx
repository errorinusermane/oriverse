import { View, Text, Pressable, ScrollView } from 'react-native';
import { Ionicons } from '@expo/vector-icons';

// TODO(Day 9): react-native-iap 연결, Google Play Billing 구독 플로우
export default function SubscriptionScreen() {
  return (
    <ScrollView className="flex-1 bg-gray-50">
      {/* 현재 플랜 */}
      <View className="bg-white mx-4 mt-5 rounded-2xl p-5 border border-gray-100">
        <Text className="text-xs font-semibold text-gray-400 uppercase tracking-wider mb-3">
          현재 플랜
        </Text>
        <View className="flex-row items-center justify-between">
          <Text className="text-lg font-bold text-gray-800">무료 플랜</Text>
          <View className="bg-gray-100 px-3 py-1 rounded-full">
            <Text className="text-xs text-gray-500">사용 중</Text>
          </View>
        </View>
        <Text className="text-sm text-gray-400 mt-1">
          브로드캐스트 하루 5회 · AI 피드백 하루 5회 · 1:1 대화 7회
        </Text>
      </View>

      {/* 요금제 선택 — 앵커링: 연간 먼저 표시 */}
      <View className="mx-4 mt-5 gap-3">
        <Text className="text-xs font-semibold text-gray-400 uppercase tracking-wider mb-1">
          프리미엄으로 업그레이드
        </Text>

        {/* 연간 플랜 ★ */}
        <Pressable className="bg-blue-500 rounded-2xl p-5 border-2 border-blue-500">
          <View className="flex-row items-start justify-between">
            <View>
              <View className="flex-row items-center gap-2 mb-1">
                <Text className="text-white font-bold text-base">연간 플랜</Text>
                <View className="bg-white/20 px-2 py-0.5 rounded-full">
                  <Text className="text-white text-xs font-semibold">MOST POPULAR</Text>
                </View>
              </View>
              <Text className="text-blue-100 text-sm">월 $3.33 · 5개월 무료</Text>
            </View>
            <View className="items-end">
              <Text className="text-white font-bold text-xl">$39.99</Text>
              <Text className="text-blue-200 text-xs">/년</Text>
            </View>
          </View>
        </Pressable>

        {/* 월간 플랜 */}
        <Pressable className="bg-white rounded-2xl p-5 border border-gray-200">
          <View className="flex-row items-start justify-between">
            <View>
              <Text className="text-gray-800 font-bold text-base mb-1">월간 플랜</Text>
              <Text className="text-gray-400 text-sm">언제든 해지 가능</Text>
            </View>
            <View className="items-end">
              <Text className="text-gray-800 font-bold text-xl">$4.99</Text>
              <Text className="text-gray-400 text-xs">/월</Text>
            </View>
          </View>
        </Pressable>
      </View>

      {/* 소비성 IAP */}
      <View className="mx-4 mt-5 gap-3">
        <Text className="text-xs font-semibold text-gray-400 uppercase tracking-wider mb-1">
          단품 구매
        </Text>
        <View className="bg-white rounded-2xl border border-gray-100 overflow-hidden">
          <View className="flex-row items-center justify-between px-4 py-4 border-b border-gray-50">
            <View>
              <Text className="font-medium text-gray-800">대화 팩</Text>
              <Text className="text-xs text-gray-400">1:1 대화 +10회</Text>
            </View>
            <Text className="font-semibold text-gray-700">$1.99</Text>
          </View>
          <View className="flex-row items-center justify-between px-4 py-4">
            <View>
              <Text className="font-medium text-gray-800">일일 브로드캐스트 패스</Text>
              <Text className="text-xs text-gray-400">오늘 하루 무제한</Text>
            </View>
            <Text className="font-semibold text-gray-700">$1.99</Text>
          </View>
        </View>
      </View>

      {/* 구독 복원 */}
      <Pressable className="items-center mt-6 mb-10">
        <Text className="text-sm text-gray-400 underline">구독 복원</Text>
      </Pressable>
    </ScrollView>
  );
}
