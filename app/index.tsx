import { View, ActivityIndicator } from 'react-native';

// 세션 복원 중 표시되는 스플래시
export default function Index() {
  return (
    <View className="flex-1 items-center justify-center bg-white">
      <ActivityIndicator size="large" color="#3B82F6" />
    </View>
  );
}
