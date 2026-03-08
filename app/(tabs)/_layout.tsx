import { Tabs } from 'expo-router';

export default function TabsLayout() {
  return (
    <Tabs
      screenOptions={{
        headerShown: false,
        tabBarActiveTintColor: '#3B82F6',
        tabBarInactiveTintColor: '#9CA3AF',
      }}
    >
      <Tabs.Screen
        name="learn"
        options={{ title: '학습' }}
      />
      <Tabs.Screen
        name="community"
        options={{ title: '소통' }}
      />
      <Tabs.Screen
        name="profile"
        options={{ title: '프로필' }}
      />
    </Tabs>
  );
}
