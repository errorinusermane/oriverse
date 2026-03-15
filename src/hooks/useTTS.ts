// src/hooks/useTTS.ts
// 🟠 Fix: URL 캐시에 만료 시간 추가 (55분, signed URL TTL 1시간보다 짧게)
// 🔴 Fix: stop()에서 완전한 unload (Audio Session 충돌 방지)
// 🔴 Fix: 모든 catch에 console.error 추가

import { useEffect, useRef, useState } from 'react';
import { Audio } from 'expo-av';
import { supabase } from '../lib/supabase';

type TTSStatus = 'idle' | 'loading' | 'ready' | 'playing' | 'error';

// 🟠 Fix: 만료 시간 포함 캐시 (55분 = signed URL TTL 1시간보다 5분 여유)
const CACHE_TTL_MS = 55 * 60 * 1000;
const urlCache = new Map<string, { url: string; expiresAt: number }>();

export function useTTS(scriptId: string | null) {
  const [status, setStatus] = useState<TTSStatus>('idle');
  const soundRef = useRef<Audio.Sound | null>(null);

  // scriptId 바뀌면 이전 사운드 언로드
  useEffect(() => {
    soundRef.current?.unloadAsync().catch(() => {});
    soundRef.current = null;
    setStatus('idle');
  }, [scriptId]);

  // 언마운트 시 정리
  useEffect(() => {
    return () => {
      soundRef.current?.unloadAsync().catch(() => {});
    };
  }, []);

  async function fetchSignedUrl(id: string): Promise<string | null> {
    // 🟠 Fix: 만료 시간 검사
    const cached = urlCache.get(id);
    if (cached && cached.expiresAt > Date.now()) return cached.url;

    const supabaseUrl = process.env.EXPO_PUBLIC_SUPABASE_URL!;
    const anonKey = process.env.EXPO_PUBLIC_SUPABASE_ANON_KEY!;
    try {
      const res = await fetch(`${supabaseUrl}/functions/v1/tts-generate`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          // anon key를 Bearer로 사용 (user JWT는 Edge Function gateway에서 검증 실패 가능)
          // Function 내부는 service role key로 처리하므로 anon key로 충분
          Authorization: `Bearer ${anonKey}`,
          apikey: anonKey,
        },
        body: JSON.stringify({ script_id: id, voice: 'nova' }),
      });
      if (!res.ok) {
        console.error('[fetchSignedUrl] Edge Function error:', res.status);
        return null;
      }
      const { url } = await res.json();
      if (url) urlCache.set(id, { url, expiresAt: Date.now() + CACHE_TTL_MS });
      return url ?? null;
    } catch (e) {
      console.error('[fetchSignedUrl] Exception:', e);
      return null;
    }
  }

  async function play() {
    if (!scriptId || status === 'playing') return;

    setStatus('loading');
    try {
      await Audio.setAudioModeAsync({
        allowsRecordingIOS: false,
        playsInSilentModeIOS: true,
      });

      const url = await fetchSignedUrl(scriptId);
      if (!url) {
        setStatus('error');
        return;
      }

      await soundRef.current?.unloadAsync().catch(() => {});

      const { sound } = await Audio.Sound.createAsync(
        { uri: url },
        { shouldPlay: true },
        (playbackStatus) => {
          if (playbackStatus.isLoaded && playbackStatus.didJustFinish) {
            setStatus('ready');
          }
        }
      );
      soundRef.current = sound;
      setStatus('playing');
    } catch (e) {
      console.error('[play] Exception:', e);
      setStatus('error');
    }
  }

  // 🔴 Fix: stop()에서 stopAsync + unloadAsync 완전 정리
  // advance() 에서 await tts.stop() 호출 시 Audio Session이 완전히 해제됨을 보장
  async function stop() {
    try {
      if (soundRef.current) {
        await soundRef.current.stopAsync().catch(() => {});
        await soundRef.current.unloadAsync().catch(() => {});
        soundRef.current = null;
      }
    } catch (e) {
      console.error('[stop] Exception:', e);
    }
    setStatus('idle');
  }

  // 백그라운드 캐싱 (재생 없음)
  async function prefetch(id: string) {
    const cached = urlCache.get(id);
    if (!cached || cached.expiresAt <= Date.now()) {
      fetchSignedUrl(id).catch(() => {});
    }
  }

  return { status, play, stop, prefetch };
}
