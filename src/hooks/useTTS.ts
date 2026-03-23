// src/hooks/useTTS.ts
// 🟠 Fix: URL 캐시에 만료 시간 추가 (55분, signed URL TTL 1시간보다 짧게)
// 🔴 Fix: 사운드 관리를 audioStore에 위임 — 전역 단일 인스턴스 보장

import { useEffect } from 'react';
import { useAudioStore } from '../store/audioStore';

type TTSStatus = 'idle' | 'loading' | 'playing' | 'error';

// 🟠 Fix: 만료 시간 포함 캐시 (55분 = signed URL TTL 1시간보다 5분 여유)
const CACHE_TTL_MS = 55 * 60 * 1000;
const urlCache = new Map<string, { url: string; expiresAt: number }>();

export function useTTS(scriptId: string | null) {
  const { activeId, status: storeStatus, play, stop } = useAudioStore();

  // Derive this hook's status from the global store
  const status: TTSStatus =
    scriptId !== null && activeId === scriptId ? (storeStatus as TTSStatus) : 'idle';

  // Cleanup: if this hook's scriptId is still active when the component unmounts, stop it.
  // This handles navigating away from the lesson screen mid-playback.
  useEffect(() => {
    return () => {
      if (scriptId && useAudioStore.getState().activeId === scriptId) {
        useAudioStore.getState().stop();
      }
    };
  }, [scriptId]);

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
          Authorization: `Bearer ${anonKey}`,
          apikey: anonKey,
        },
        body: JSON.stringify({ script_id: id, voice: 'nova' }),
      });
      if (!res.ok) {
        console.error('[useTTS fetchSignedUrl] Edge Function error:', res.status);
        return null;
      }
      const { url } = await res.json();
      if (url) urlCache.set(id, { url, expiresAt: Date.now() + CACHE_TTL_MS });
      return url ?? null;
    } catch (e) {
      console.error('[useTTS fetchSignedUrl] Exception:', e);
      return null;
    }
  }

  async function playTTS() {
    if (!scriptId) return;
    await play(scriptId, () => fetchSignedUrl(scriptId));
  }

  // 백그라운드 캐싱 (재생 없음)
  async function prefetch(id: string) {
    const cached = urlCache.get(id);
    if (!cached || cached.expiresAt <= Date.now()) {
      fetchSignedUrl(id).catch(() => {});
    }
  }

  return { status, play: playTTS, stop, prefetch };
}
