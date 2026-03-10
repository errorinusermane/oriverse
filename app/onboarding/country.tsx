import { useState, useEffect } from 'react';
import {
  View,
  Text,
  TouchableOpacity,
  ActivityIndicator,
  Alert,
  ScrollView,
} from 'react-native';
import { router } from 'expo-router';
import { supabase } from '../../src/lib/supabase';
import { useAuthStore } from '../../src/store/authStore';

type Language = {
  id: string;
  name: string;
  code: string;
  flag_emoji: string;
};

function getOsLanguageCode(): string {
  try {
    const locale = Intl.DateTimeFormat().resolvedOptions().locale;
    return locale.split('-')[0];
  } catch {
    return 'en';
  }
}

export default function OnboardingNativeLanguage() {
  const { user } = useAuthStore();
  const [languages, setLanguages] = useState<Language[]>([]);
  const [selected, setSelected] = useState<Language | null>(null);
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);

  useEffect(() => {
    supabase
      .from('languages')
      .select('*')
      .eq('is_active', true)
      .order('name')
      .then(({ data, error }) => {
        if (error) { Alert.alert('오류', error.message); return; }
        const langs = data ?? [];
        setLanguages(langs);

        // OS 언어로 기본 선택
        const osCode = getOsLanguageCode();
        const match = langs.find((l) => l.code === osCode) ?? langs.find((l) => l.code === 'en');
        if (match) setSelected(match);

        setLoading(false);
      });
  }, []);

  const handleContinue = async () => {
    if (!selected || !user) return;
    setSaving(true);
    const { error } = await supabase
      .from('users')
      .update({ native_language_id: selected.id, onboarding_step: 2 })
      .eq('id', user.id);
    setSaving(false);
    if (error) { Alert.alert('오류', error.message); return; }
    router.push('/onboarding/quiz');
  };

  if (loading) {
    return (
      <View className="flex-1 items-center justify-center bg-white">
        <ActivityIndicator size="large" color="#3B82F6" />
      </View>
    );
  }

  return (
    <View className="flex-1 bg-white">
      {/* Progress bar */}
      <View className="pt-14 px-6 pb-4">
        <View className="flex-row gap-2 mb-6">
          <View className="flex-1 h-1 rounded-full bg-blue-500" />
          <View className="flex-1 h-1 rounded-full bg-blue-500" />
          <View className="flex-1 h-1 rounded-full bg-gray-200" />
        </View>
        <Text className="text-sm font-medium text-gray-400">2 / 3단계</Text>
        <Text className="text-2xl font-bold text-gray-900 mt-1">
          모국어를 선택해주세요
        </Text>
        <Text className="text-gray-500 mt-1">평소에 사용하는 언어를 선택해주세요</Text>
      </View>

      {/* Language grid */}
      <ScrollView className="flex-1 px-6" showsVerticalScrollIndicator={false}>
        <View className="flex-row flex-wrap gap-3">
          {languages.map((lang) => {
            const isSelected = selected?.id === lang.id;
            return (
              <TouchableOpacity
                key={lang.id}
                onPress={() => setSelected(lang)}
                className={
                  isSelected
                    ? 'w-[47%] p-4 rounded-2xl border-2 border-blue-500 bg-blue-50 items-center'
                    : 'w-[47%] p-4 rounded-2xl border-2 border-gray-200 bg-white items-center'
                }
              >
                <Text className="text-4xl mb-2">{lang.flag_emoji}</Text>
                <Text
                  className={
                    isSelected
                      ? 'text-base font-semibold text-blue-600'
                      : 'text-base font-semibold text-gray-800'
                  }
                >
                  {lang.name}
                </Text>
                {isSelected && (
                  <View className="absolute top-2 right-2 w-5 h-5 rounded-full bg-blue-500 items-center justify-center">
                    <Text className="text-white text-xs font-bold">✓</Text>
                  </View>
                )}
              </TouchableOpacity>
            );
          })}
        </View>
        <View className="h-32" />
      </ScrollView>

      {/* CTA */}
      <View className="px-6 pb-10 pt-4 border-t border-gray-100">
        <TouchableOpacity
          onPress={handleContinue}
          disabled={!selected || saving}
          className={
            selected && !saving
              ? 'py-4 rounded-2xl items-center bg-blue-500'
              : 'py-4 rounded-2xl items-center bg-gray-200'
          }
        >
          {saving ? (
            <ActivityIndicator color="white" />
          ) : (
            <Text
              className={
                selected
                  ? 'text-base font-bold text-white'
                  : 'text-base font-bold text-gray-400'
              }
            >
              계속하기
            </Text>
          )}
        </TouchableOpacity>
      </View>
    </View>
  );
}
