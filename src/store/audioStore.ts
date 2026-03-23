// src/store/audioStore.ts
// Global single-audio-instance store.
// Only ONE audio can play at a time across the entire app (TTS + broadcast feed).

import { create } from 'zustand';
import { Audio } from 'expo-av';

type AudioStatus = 'idle' | 'loading' | 'playing' | 'error';

// Module-level sound ref — mutations are intentionally outside reactive state.
let _sound: Audio.Sound | null = null;

interface AudioState {
  activeId: string | null;
  status: AudioStatus;
  /** Start playing id. Stops whatever is currently playing first. Toggle-stops if id is already playing. */
  play: (id: string, getUri: () => Promise<string | null>) => Promise<void>;
  /** Stop and unload current audio. */
  stop: () => Promise<void>;
}

export const useAudioStore = create<AudioState>((set, get) => ({
  activeId: null,
  status: 'idle',

  play: async (id, getUri) => {
    const { activeId, status, stop } = get();

    // Toggle: tapping same item while playing → stop
    if (activeId === id && status === 'playing') {
      await stop();
      return;
    }

    // Preempt any in-flight audio
    await stop();

    set({ activeId: id, status: 'loading' });

    try {
      await Audio.setAudioModeAsync({
        allowsRecordingIOS: false,
        playsInSilentModeIOS: true,
      });

      const uri = await getUri();
      if (!uri) {
        console.error('[audioStore.play] getUri returned null for id:', id);
        set({ status: 'error', activeId: null });
        return;
      }

      // Guard: another play() may have superseded us during the async gap
      if (get().activeId !== id) return;

      const { sound } = await Audio.Sound.createAsync(
        { uri },
        { shouldPlay: true },
        (playbackStatus) => {
          if (playbackStatus.isLoaded && playbackStatus.didJustFinish) {
            _sound?.unloadAsync().catch(() => {});
            _sound = null;
            set({ status: 'idle', activeId: null });
          }
        }
      );

      // Guard again — another call may have run stop() while we awaited createAsync
      if (get().activeId !== id) {
        sound.unloadAsync().catch(() => {});
        return;
      }

      _sound = sound;
      set({ status: 'playing' });
    } catch (e) {
      console.error('[audioStore.play] Exception:', e);
      set({ status: 'error', activeId: null });
    }
  },

  stop: async () => {
    try {
      if (_sound) {
        await _sound.stopAsync().catch(() => {});
        await _sound.unloadAsync().catch(() => {});
        _sound = null;
      }
    } catch (e) {
      console.error('[audioStore.stop] Exception:', e);
    }
    set({ activeId: null, status: 'idle' });
  },
}));
