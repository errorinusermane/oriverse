import { Tabs, router } from 'expo-router';
import { Pressable } from 'react-native';
import { Ionicons } from '@expo/vector-icons';

export default function TabsLayout() {
  return (
    <Tabs
      screenOptions={{
        tabBarActiveTintColor: '#3B82F6',
        tabBarInactiveTintColor: '#9CA3AF',
        tabBarStyle: { borderTopWidth: 1, borderTopColor: '#F3F4F6' },
        headerStyle: { backgroundColor: '#FFFFFF' },
        headerShadowVisible: false,
        headerRight: () => (
          <Pressable
            onPress={() => router.push('/profile')}
            className="mr-4"
            hitSlop={12}
          >
            <Ionicons name="person-circle-outline" size={28} color="#374151" />
          </Pressable>
        ),
      }}
    >
      <Tabs.Screen
        name="learn"
        options={{
          title: '학습',
          tabBarIcon: ({ color, size }) => (
            <Ionicons name="book-outline" size={size} color={color} />
          ),
        }}
      />
      <Tabs.Screen
        name="community"
        options={{
          title: '소통',
          tabBarIcon: ({ color, size }) => (
            <Ionicons name="mic-outline" size={size} color={color} />
          ),
        }}
      />
    </Tabs>
  );
}
