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
    // 앱 시작 시 기존 세션 복원
    supabase.auth.getSession().then(async ({ data: { session } }) => {
      setSession(session);
      setLoading(false);
      if (session) {
        router.replace((await resolveRoute(session.user.id)) as any);
      } else {
        router.replace('/auth');
      }
    });

    // 세션 변경 리스너 (로그인/로그아웃만 처리 — 토큰 갱신 시 내비게이션 방지)
    const { data: { subscription } } = supabase.auth.onAuthStateChange(async (event, session) => {
      setSession(session);
      if (event === 'SIGNED_IN' && session) {
        router.replace((await resolveRoute(session.user.id)) as any);
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
