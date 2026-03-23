// src/components/PaywallModal.tsx
// 무료 메시지 한도(7회) 소진 시 표시되는 페이월 바텀 시트 (플레이스홀더).

import { Modal, View, Text, Pressable } from 'react-native';

interface Props {
  visible: boolean;
  onDismiss: () => void;
  /** 구독 화면으로 이동하는 CTA 핸들러 */
  onSubscribe: () => void;
}

export function PaywallModal({ visible, onDismiss, onSubscribe }: Props) {
  return (
    <Modal
      visible={visible}
      transparent
      animationType="slide"
      onRequestClose={onDismiss}
    >
      <View className="flex-1 justify-end">
        {/* 딤 배경 */}
        <Pressable
          className="absolute inset-0 bg-black/40"
          onPress={onDismiss}
        />

        {/* 바텀 시트 */}
        <View className="bg-white rounded-t-3xl px-6 pt-6 pb-10">
          {/* 드래그 핸들 */}
          <View className="w-10 h-1 rounded-full bg-gray-200 self-center mb-6" />

          {/* 아이콘 */}
          <View className="w-20 h-20 rounded-full bg-orange-100 items-center justify-center self-center mb-4">
            <Text style={{ fontSize: 36 }}>🐦</Text>
          </View>

          <Text className="text-2xl font-bold text-gray-900 text-center mb-2">
            무료 대화 횟수를 다 사용했어요
          </Text>
          <Text className="text-gray-500 text-center leading-6 mb-8">
            프리미엄으로 업그레이드하면{'\n'}무제한으로 대화할 수 있어요
          </Text>

          {/* CTA 버튼 */}
          <Pressable
            onPress={onSubscribe}
            className="bg-blue-500 rounded-2xl py-4 items-center mb-3"
          >
            <Text className="text-white font-bold text-base">
              프리미엄 시작하기
            </Text>
          </Pressable>

          <Pressable onPress={onDismiss} className="py-3 items-center">
            <Text className="text-gray-400 text-sm">나중에</Text>
          </Pressable>
        </View>
      </View>
    </Modal>
  );
}
