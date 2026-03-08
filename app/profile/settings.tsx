import { View, Text, Switch, ScrollView } from 'react-native';
import { useState } from 'react';

// TODO(Day 11): expo-notifications 연결 후 실제 설정 저장
export default function SettingsScreen() {
  const [streakAlert, setStreakAlert] = useState(true);
  const [replyAlert, setReplyAlert] = useState(true);
  const [dailyReminder, setDailyReminder] = useState(false);

  return (
    <ScrollView className="flex-1 bg-gray-50">
      <View className="mx-4 mt-5">
        <Text className="text-xs font-semibold text-gray-400 uppercase tracking-wider mb-2">
          알림 설정
        </Text>
        <View className="bg-white rounded-2xl border border-gray-100 overflow-hidden">
          <View className="flex-row items-center justify-between px-4 py-4 border-b border-gray-50">
            <View className="flex-1 mr-4">
              <Text className="font-medium text-gray-800">스트릭 달성 알림</Text>
              <Text className="text-xs text-gray-400 mt-0.5">7일, 30일 달성 시 알림</Text>
            </View>
            <Switch value={streakAlert} onValueChange={setStreakAlert} />
          </View>
          <View className="flex-row items-center justify-between px-4 py-4 border-b border-gray-50">
            <View className="flex-1 mr-4">
              <Text className="font-medium text-gray-800">답장 알림</Text>
              <Text className="text-xs text-gray-400 mt-0.5">보이스메일에 답장이 왔을 때</Text>
            </View>
            <Switch value={replyAlert} onValueChange={setReplyAlert} />
          </View>
          <View className="flex-row items-center justify-between px-4 py-4">
            <View className="flex-1 mr-4">
              <Text className="font-medium text-gray-800">매일 학습 리마인더</Text>
              <Text className="text-xs text-gray-400 mt-0.5">스트릭 유지를 위한 하루 1회</Text>
            </View>
            <Switch value={dailyReminder} onValueChange={setDailyReminder} />
          </View>
        </View>
      </View>
    </ScrollView>
  );
}
