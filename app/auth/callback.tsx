import { useEffect } from 'react';
import { View, ActivityIndicator } from 'react-native';
import { useLocalSearchParams, router } from 'expo-router';
import { supabase } from '../../src/lib/supabase';

// OAuth 딥링크 콜백 처리 화면
export default function AuthCallback() {
  const params = useLocalSearchParams();

  useEffect(() => {
    const accessToken = params.access_token as string;
    const refreshToken = params.refresh_token as string;

    if (accessToken && refreshToken) {
      supabase.auth
        .setSession({ access_token: accessToken, refresh_token: refreshToken })
        .then(() => router.replace('/(tabs)/learn'));
    } else {
      router.replace('/auth');
    }
  }, []);

  return (
    <View className="flex-1 items-center justify-center bg-white">
      <ActivityIndicator size="large" color="#3B82F6" />
    </View>
  );
}
