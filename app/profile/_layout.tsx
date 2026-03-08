import { Stack } from 'expo-router';

export default function ProfileLayout() {
  return (
    <Stack>
      <Stack.Screen name="index" options={{ title: '프로필' }} />
      <Stack.Screen name="subscription" options={{ title: '구독 관리' }} />
      <Stack.Screen name="settings" options={{ title: '설정' }} />
    </Stack>
  );
}
