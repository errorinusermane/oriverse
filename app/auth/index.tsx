import { View, Text, Pressable, ActivityIndicator, Alert } from 'react-native';
import { useState, useEffect } from 'react';
import * as WebBrowser from 'expo-web-browser';
import { makeRedirectUri } from 'expo-auth-session';
import { supabase } from '../../src/lib/supabase';
import { router } from 'expo-router';

WebBrowser.maybeCompleteAuthSession();

export default function AuthScreen() {
  const [loading, setLoading] = useState(false);

  // 세션 체크 - 이미 로그인되어 있으면 홈으로
  useEffect(() => {
    supabase.auth.getSession().then(({ data: { session } }) => {
      if (session) {
        router.replace('/(tabs)/learn');
      }
    });

    const { data: { subscription } } = supabase.auth.onAuthStateChange((_event, session) => {
      if (session) {
        router.replace('/(tabs)/learn');
      }
    });

    return () => subscription.unsubscribe();
  }, []);

  const handleGoogleLogin = async () => {
    setLoading(true);
    try {
      const redirectTo = makeRedirectUri({ 
        scheme: 'oriverse',
        path: 'auth/callback',
        preferLocalhost: false,
      });
      console.log('📍 Redirect URI:', redirectTo);

      const { data, error } = await supabase.auth.signInWithOAuth({
        provider: 'google',
        options: {
          redirectTo,
          skipBrowserRedirect: true,
          queryParams: {
            access_type: 'offline',
            prompt: 'consent',
          }
        },
      });

      if (error) throw error;
      if (!data.url) throw new Error('OAuth URL을 가져오지 못했습니다.');

      console.log('🔗 OAuth URL:', data.url);

      const result = await WebBrowser.openAuthSessionAsync(
        data.url, 
        redirectTo,
        { showInRecents: true }
      );

      console.log('✅ WebBrowser result:', result);

      if (result.type === 'success') {
        const url = new URL(result.url);
        const accessToken = url.searchParams.get('access_token') ??
          new URLSearchParams(url.hash.slice(1)).get('access_token');
        const refreshToken = url.searchParams.get('refresh_token') ??
          new URLSearchParams(url.hash.slice(1)).get('refresh_token');

        console.log('🔑 Tokens found:', { accessToken: !!accessToken, refreshToken: !!refreshToken });

        if (accessToken && refreshToken) {
          const { error: sessionError } = await supabase.auth.setSession({ 
            access_token: accessToken, 
            refresh_token: refreshToken 
          });
          
          if (sessionError) throw sessionError;
          console.log('✅ Session set successfully');
        }
      }
    } catch (e: any) {
      console.error('❌ Login error:', e);
      Alert.alert('로그인 실패', e.message);
    } finally {
      setLoading(false);
    }
  };

  return (
    <View className="flex-1 bg-white items-center justify-center px-8">
      {/* 로고 영역 */}
      <View className="mb-16 items-center">
        {/* TODO: Ori 캐릭터 PNG */}
        <View className="w-24 h-24 rounded-full bg-orange-100 items-center justify-center mb-4">
          <Text className="text-5xl">🐦</Text>
        </View>
        <Text className="text-3xl font-bold text-gray-800">Oriverse</Text>
        <Text className="text-gray-400 mt-2 text-center">언어는 학습이 아니라 소통이다.</Text>
      </View>

      {/* Google 로그인 버튼 */}
      <Pressable
        onPress={handleGoogleLogin}
        disabled={loading}
        className="w-full flex-row items-center justify-center bg-white border border-gray-200 rounded-2xl py-4 px-6 gap-3 shadow-sm"
      >
        {loading ? (
          <ActivityIndicator size="small" color="#374151" />
        ) : (
          <>
            {/* Google 아이콘 (텍스트 대체) */}
            <Text className="text-lg font-bold" style={{ color: '#4285F4' }}>G</Text>
            <Text className="text-gray-700 font-semibold text-base">Google로 계속하기</Text>
          </>
        )}
      </Pressable>

      {/* Facebook — TODO(Day X): 추후 추가 */}

      <Text className="text-xs text-gray-300 mt-10 text-center px-4">
        계속하면 개인정보 처리방침 및 이용약관에 동의하는 것으로 간주됩니다.
      </Text>
    </View>
  );
}
