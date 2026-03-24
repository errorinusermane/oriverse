import { useEffect, useRef } from 'react';
import { Animated, Text, View } from 'react-native';

const BAR_COUNT = 4;
const MIN_HEIGHT = 8;
const MAX_HEIGHT = 32;
const CYCLE_DURATION = 600; // ms for one full up-down pulse

export function RecordingWaveform({ countdown }: { countdown: number }) {
  const animValues = useRef(
    Array.from({ length: BAR_COUNT }, () => new Animated.Value(MIN_HEIGHT))
  ).current;

  useEffect(() => {
    const loops: Animated.CompositeAnimation[] = [];
    const timeouts: ReturnType<typeof setTimeout>[] = [];

    animValues.forEach((val, i) => {
      const loop = Animated.loop(
        Animated.sequence([
          Animated.timing(val, {
            toValue: MAX_HEIGHT,
            duration: CYCLE_DURATION / 2,
            useNativeDriver: false,
          }),
          Animated.timing(val, {
            toValue: MIN_HEIGHT,
            duration: CYCLE_DURATION / 2,
            useNativeDriver: false,
          }),
        ])
      );
      loops.push(loop);
      // stagger each bar by 1/BAR_COUNT of a half-cycle for sine-wave effect
      const t = setTimeout(() => loop.start(), i * (CYCLE_DURATION / (BAR_COUNT * 2)));
      timeouts.push(t);
    });

    return () => {
      timeouts.forEach(clearTimeout);
      loops.forEach((l) => l.stop());
      animValues.forEach((v) => v.setValue(MIN_HEIGHT));
    };
  }, []);

  return (
    <View style={{ alignItems: 'center', gap: 6 }}>
      <View style={{ flexDirection: 'row', alignItems: 'center', gap: 10 }}>
        {/* REC badge */}
        <View
          style={{
            backgroundColor: '#EF4444',
            borderRadius: 4,
            paddingHorizontal: 6,
            paddingVertical: 2,
          }}
        >
          <Text style={{ color: 'white', fontSize: 11, fontWeight: '700', letterSpacing: 1.5 }}>
            REC
          </Text>
        </View>

        {/* Animated bars */}
        <View style={{ flexDirection: 'row', alignItems: 'center', gap: 4 }}>
          {animValues.map((val, i) => (
            <Animated.View
              key={i}
              style={{
                width: 5,
                height: val,
                backgroundColor: '#EF4444',
                borderRadius: 3,
              }}
            />
          ))}
        </View>
      </View>

      {/* Countdown below waveform */}
      <Text style={{ color: '#EF4444', fontSize: 13, fontWeight: '600' }}>
        {countdown}
      </Text>
    </View>
  );
}
