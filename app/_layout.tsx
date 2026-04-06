import '../global.css';
import { useEffect } from 'react';
import { Stack, router } from 'expo-router';
import { supabase } from '../src/lib/supabase';
import { useAuthStore } from '../src/store/authStore';

async function resolveRoute(userId: string): Promise<string> {
  const { data } = await supabase
    .from('users')
    .select('onboarding_step')
    .eq('id', userId)
    .single();
  const step = data?.onboarding_step ?? 0;
  if (step >= 3) return '/(tabs)/learn';
  if (step === 2) return '/onboarding/quiz';
  if (step === 1) return '/onboarding/country';
  return '/onboarding';
}

export default function RootLayout() {
  const { setSession, setLoading } = useAuthStore();

  useEffect(() => {
    // INITIAL_SESSION: 앱 시작 시 저장된 세션 복원
    // SIGNED_IN: 로그인 완료
    // SIGNED_OUT: 로그아웃
    // TOKEN_REFRESHED 등 나머지 이벤트는 내비게이션 불필요
    const { data: { subscription } } = supabase.auth.onAuthStateChange(async (event, session) => {
      setSession(session);

      if (event === 'INITIAL_SESSION' || event === 'SIGNED_IN') {
        setLoading(false);
        if (session) {
          try {
            const route = await resolveRoute(session.user.id);
            router.replace(route as any);
          } catch (e) {
            console.error('[_layout] resolveRoute failed:', e);
            router.replace('/auth');
          }
        } else {
          router.replace('/auth');
        }
      } else if (event === 'SIGNED_OUT') {
        router.replace('/auth');
      }
    });

    return () => subscription.unsubscribe();
  }, []);

  return (
    <Stack screenOptions={{ headerShown: false }}>
      <Stack.Screen name="auth" />
      <Stack.Screen name="onboarding" />
      <Stack.Screen name="(tabs)" />
      <Stack.Screen name="profile" options={{ presentation: 'modal' }} />
    </Stack>
  );
}
