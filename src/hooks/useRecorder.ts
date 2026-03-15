// src/hooks/useRecorder.ts
// 🔴 Fix: countdown state updater에서 async 제거 (React anti-pattern)
// 🔴 Fix: getURI()를 stopAndUnloadAsync() 이전에 호출
// 🔴 Fix: 모든 catch에 console.error 추가
// 🟠 Fix: base64/ArrayBuffer → FileSystem.uploadAsync 스트리밍 업로드

import { useEffect, useRef, useState } from 'react';
import { AppState, AppStateStatus } from 'react-native';
import { Audio } from 'expo-av';
import * as FileSystem from 'expo-file-system/legacy';
import { supabase } from '../lib/supabase';

const LIMIT_SECONDS = 60;
const SUPABASE_URL = process.env.EXPO_PUBLIC_SUPABASE_URL!;
const SUPABASE_ANON_KEY = process.env.EXPO_PUBLIC_SUPABASE_ANON_KEY!;

export function useRecorder(userId: string | null) {
  const [isRecording, setIsRecording] = useState(false);
  const [countdown, setCountdown] = useState(LIMIT_SECONDS);
  const [isUploading, setIsUploading] = useState(false);

  const recordingRef = useRef<Audio.Recording | null>(null);
  const timerRef = useRef<ReturnType<typeof setInterval> | null>(null);
  const appStateRef = useRef<AppStateStatus>(AppState.currentState);

  // AppState: 백그라운드 진입 시 녹음 강제 중단
  useEffect(() => {
    const sub = AppState.addEventListener('change', (nextState: AppStateStatus) => {
      if (
        appStateRef.current === 'active' &&
        nextState.match(/inactive|background/) &&
        recordingRef.current
      ) {
        stopRecording();
      }
      appStateRef.current = nextState;
    });
    return () => sub.remove();
  }, []);

  // 카운트다운 타이머 — state updater는 순수 함수만 (side effect 없음)
  // 자동 중단은 [id].tsx에서 countdown === 0 감지 후 handleStopRecording() 호출
  useEffect(() => {
    if (isRecording) {
      setCountdown(LIMIT_SECONDS);
      timerRef.current = setInterval(() => {
        setCountdown((c) => (c <= 1 ? 0 : c - 1));
      }, 1000);
    } else {
      if (timerRef.current) clearInterval(timerRef.current);
    }
    return () => {
      if (timerRef.current) clearInterval(timerRef.current);
    };
  }, [isRecording]);

  async function startRecording(): Promise<boolean> {
    try {
      const { granted } = await Audio.requestPermissionsAsync();
      if (!granted) return false;

      await Audio.setAudioModeAsync({
        allowsRecordingIOS: true,
        playsInSilentModeIOS: true,
      });

      const { recording } = await Audio.Recording.createAsync(
        Audio.RecordingOptionsPresets.HIGH_QUALITY
      );
      recordingRef.current = recording;
      setIsRecording(true);
      return true;
    } catch (e) {
      console.error('[startRecording] failed:', e);
      return false;
    }
  }

  // 🔴 Fix: getURI() 먼저 취득 → stopAndUnloadAsync() 후 반환
  // 일부 expo-av 버전에서 unload 후 getURI()가 null 반환하는 버그 방어
  async function stopRecording(): Promise<string | null> {
    if (!recordingRef.current) return null;
    setIsRecording(false);
    try {
      const uri = recordingRef.current.getURI(); // ← 먼저 취득
      await recordingRef.current.stopAndUnloadAsync();
      recordingRef.current = null;
      return uri ?? null;
    } catch (e) {
      console.error('[stopRecording] error:', e);
      recordingRef.current = null;
      return null;
    }
  }

  // expo-file-system/legacy 사용: uploadAsync는 file:// URI를 네이티브로 처리
  // fetch(file://)는 whatwg-fetch XHR 폴리필이 로컬 파일을 지원하지 않아 실패
  async function uploadRecording(uri: string, scriptId: string): Promise<string | null> {
    if (!userId) return null;
    setIsUploading(true);
    try {
      const ext = uri.split('.').pop() ?? 'm4a';
      const path = `${userId}/${scriptId}.${ext}`;

      const { data: { session } } = await supabase.auth.getSession();
      if (!session) {
        console.error('[uploadRecording] no session');
        return null;
      }

      const uploadUrl = `${SUPABASE_URL}/storage/v1/object/user-recordings/${path}`;
      const result = await FileSystem.uploadAsync(uploadUrl, uri, {
        httpMethod: 'POST',
        headers: {
          Authorization: `Bearer ${session.access_token}`,
          apikey: SUPABASE_ANON_KEY,
          'x-upsert': 'true',
        },
        uploadType: FileSystem.FileSystemUploadType.BINARY_CONTENT,
      });

      if (result.status >= 400) {
        console.error('[uploadRecording] HTTP error:', result.status, result.body);
        return null;
      }
      return path;
    } catch (e) {
      console.error('[uploadRecording] Exception:', e);
      return null;
    } finally {
      setIsUploading(false);
    }
  }

  return {
    isRecording,
    countdown,
    isUploading,
    startRecording,
    stopRecording,
    uploadRecording,
  };
}
