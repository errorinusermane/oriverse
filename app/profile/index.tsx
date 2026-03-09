import { View, Text, Pressable, ScrollView, Alert, Image } from 'react-native';
import { router } from 'expo-router';
import { Ionicons } from '@expo/vector-icons';
import { supabase } from '../../src/lib/supabase';
import { useAuthStore } from '../../src/store/authStore';

function MenuItem({
  icon,
  label,
  sublabel,
  onPress,
  destructive,
}: {
  icon: keyof typeof Ionicons.glyphMap;
  label: string;
  sublabel?: string;
  onPress: () => void;
  destructive?: boolean;
}) {
  return (
    <Pressable
      onPress={onPress}
      className="flex-row items-center px-4 py-4 bg-white border-b border-gray-50"
    >
      <View className="w-9 h-9 rounded-xl bg-gray-100 items-center justify-center mr-3">
        <Ionicons name={icon} size={20} color={destructive ? '#EF4444' : '#374151'} />
      </View>
      <View className="flex-1">
        <Text className={`font-medium ${destructive ? 'text-red-500' : 'text-gray-800'}`}>
          {label}
        </Text>
        {sublabel && <Text className="text-xs text-gray-400 mt-0.5">{sublabel}</Text>}
      </View>
      {!destructive && <Ionicons name="chevron-forward" size={16} color="#D1D5DB" />}
    </Pressable>
  );
}

export default function ProfileScreen() {
  const { user } = useAuthStore();

  const displayName = user?.user_metadata?.full_name ?? user?.user_metadata?.name ?? '사용자';
  const email = user?.email ?? '';
  const avatarUrl = user?.user_metadata?.avatar_url as string | undefined;

  const handleSignOut = () => {
    Alert.alert('로그아웃', '로그아웃 하시겠습니까?', [
      { text: '취소', style: 'cancel' },
      {
        text: '로그아웃',
        style: 'destructive',
        onPress: async () => {
          await supabase.auth.signOut();
          // onAuthStateChange가 세션 null 감지 → _layout.tsx에서 /auth로 자동 이동
        },
      },
    ]);
  };

  return (
    <ScrollView className="flex-1 bg-gray-50">
      {/* 프로필 헤더 */}
      <View className="bg-white px-6 py-8 items-center border-b border-gray-100">
        <View className="w-20 h-20 rounded-full bg-blue-100 items-center justify-center mb-3 overflow-hidden">
          {avatarUrl ? (
            <Image source={{ uri: avatarUrl }} className="w-20 h-20" />
          ) : (
            <Ionicons name="person" size={36} color="#3B82F6" />
          )}
        </View>
        <Text className="text-lg font-bold text-gray-800">{displayName}</Text>
        <Text className="text-sm text-gray-400 mt-0.5">{email}</Text>

        {/* 구독 상태 배지 */}
        <View className="mt-3 bg-gray-100 px-3 py-1 rounded-full">
          <Text className="text-xs text-gray-500 font-medium">무료 플랜</Text>
        </View>

        {/* 학습 언어 정보 (TODO Day 3: 온보딩 후 실제 언어 표시) */}
        <View className="flex-row gap-4 mt-4">
          <View className="items-center">
            <Text className="text-xs text-gray-400">학습 언어</Text>
            <Text className="text-sm font-semibold text-gray-700 mt-0.5">—</Text>
          </View>
          <View className="w-px bg-gray-200" />
          <View className="items-center">
            <Text className="text-xs text-gray-400">모국어</Text>
            <Text className="text-sm font-semibold text-gray-700 mt-0.5">—</Text>
          </View>
        </View>
      </View>

      {/* 메뉴 그룹 1: 계정 */}
      <View className="mt-5">
        <Text className="text-xs font-semibold text-gray-400 uppercase tracking-wider px-4 mb-2">
          계정
        </Text>
        <View className="rounded-2xl overflow-hidden mx-4 border border-gray-100">
          <MenuItem
            icon="language-outline"
            label="학습 언어 변경"
            sublabel="변경 시 언어별 진행도는 독립 저장"
            onPress={() => {
              // TODO(Day 3): 언어 변경 확인 팝업
              Alert.alert('학습 언어 변경', '온보딩 완료 후 이용 가능합니다.');
            }}
          />
          <MenuItem
            icon="card-outline"
            label="구독 관리"
            sublabel="현재: 무료 플랜"
            onPress={() => router.push('/profile/subscription')}
          />
        </View>
      </View>

      {/* 메뉴 그룹 2: 설정 */}
      <View className="mt-5">
        <Text className="text-xs font-semibold text-gray-400 uppercase tracking-wider px-4 mb-2">
          설정
        </Text>
        <View className="rounded-2xl overflow-hidden mx-4 border border-gray-100">
          <MenuItem
            icon="notifications-outline"
            label="알림 설정"
            onPress={() => router.push('/profile/settings')}
          />
          <MenuItem
            icon="shield-checkmark-outline"
            label="개인정보 처리방침"
            onPress={() => {/* TODO */ }}
          />
        </View>
      </View>

      {/* 로그아웃 */}
      <View className="mt-5 mb-10">
        <View className="rounded-2xl overflow-hidden mx-4 border border-gray-100">
          <MenuItem
            icon="log-out-outline"
            label="로그아웃"
            destructive
            onPress={handleSignOut}
          />
        </View>
      </View>
    </ScrollView>
  );
}
