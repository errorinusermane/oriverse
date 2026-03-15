
⏺ Day 6 — TTS (On-demand + 캐시) + 녹음

  AI가 할 일

  AI #1 — Edge Function
  - tts-generate Edge Function 작성
    - Storage tts-cache 버킷에 mp3 캐시 확인
    - 없으면 OpenAI TTS 호출 → Storage 저장
    - 서명 URL 반환

  AI #2 — 앱 클라이언트
  - expo-av 재생 컴포넌트
  - 녹음 컴포넌트 (60초 카운트다운)
  - AppState 리스너 (백그라운드 시 녹음 자동 중단)
  - 녹음 파일 → user-recordings Storage 업로드
  - 스크립트 콘텐츠 로컬 캐싱 (오프라인 텍스트 읽기)

  ---
  인간이 할 일

  Supabase Storage 버킷 2개 직접 생성:
  - tts-cache — private (원어민 음성, public 금지)
  - user-recordings — private (사용자 녹음)

  실제 Android 디바이스에서:
  - TTS 재생 확인
  - 녹음 + Storage 업로드 확인
  - 2회차 요청 시 캐시 재생 확인 (속도 차이 느껴지면 OK)

  ---
  병목 3개

  ┌─────┬─────────────────────────────────┬──────────────────────────────────┐
  │  #  │              병목               │               해결               │
  ├─────┼─────────────────────────────────┼──────────────────────────────────┤
  │ 1   │ 콜드 딜레이 — 첫 TTS 요청 1~2초 │ 스크립트 화면 진입 시 pre-fetch  │
  │     │  지연                           │ (백그라운드 캐싱)                │
  ├─────┼─────────────────────────────────┼──────────────────────────────────┤
  │ 2   │ 에뮬레이터 마이크 — 마이크 지원 │ 녹음 테스트는 반드시 실제        │
  │     │  불안정                         │ 디바이스에서                     │
  ├─────┼─────────────────────────────────┼──────────────────────────────────┤
  │ 3   │ Storage RLS 누락 —              │ 버킷 정책에 auth.uid() = user_id │
  │     │ user-recordings 업로드 403      │  조건 확인                       │
  └─────┴─────────────────────────────────┴──────────────────────────────────┘

  ---
  시작 순서 제안: AI #1 Edge Function 먼저 → 인간이 버킷 생성 + 환경변수 세팅 →
  AI #2 클라이언트 연결 → 실디바이스 테스트

❯ AI #1 시작해                                                                   

⏺ Searched for 3 patterns, read 2 files (ctrl+o to expand)

⏺ 스키마 확인했습니다. lesson_scripts 테이블에 audio_storage_path 컬럼 있고, 캐시
   경로 패턴 잡아서 바로 작성합니다.

⏺ Bash(mkdir -p /Users/susie/Desktop/Temp_Laptop3/Vibe_Files/oriverse/supabase/fu
      nctions/tts-generate)
  ⎿  Done

⏺ Write(supabase/functions/tts-generate/index.ts)
  ⎿  Wrote 140 lines to supabase/functions/tts-generate/index.ts
       1 // supabase/functions/tts-generate/index.ts
       2 // Flow: Storage 캐시 확인 → 없으면 OpenAI TTS 생성 → St
         orage 저장 → 서명 URL 반환
       3
       4 import { serve } from 'https://deno.land/std@0.168.0/htt
         p/server.ts'
       5 import { createClient } from 'https://esm.sh/@supabase/s
         upabase-js@2'
       6
       7 const BUCKET = 'tts-cache'
       8 const SIGNED_URL_TTL = 3600 // 1시간
       9
      10 const corsHeaders = {
     … +130 lines (ctrl+o to expand)

⏺ 완료입니다. 파일: supabase/functions/tts-generate/index.ts

  ---
  구현 내용 요약

  플로우:
  요청 (script_id, voice?)
    → Storage에 {voice}/{script_id}.mp3 있음?
        YES → 서명 URL 바로 반환 (캐시 히트)
        NO  → DB에서 script_text 조회
            → speaker='user'이면 400 (사용자 줄은 TTS 불필요)
            → OpenAI tts-1 호출
            → Storage 업로드
            → lesson_scripts.audio_storage_path 업데이트
            → 서명 URL 반환

  응답 예시:
  { "url": "https://...", "cached": false, "path": "nova/abc-123.mp3" }

  기본 voice: nova (영어 학습에 적합한 여성 목소리)

  ---
  인간이 할 일 (배포 전 필수)

  1. Supabase Dashboard → Storage → 버킷 생성:
    - tts-cache — Private
    - user-recordings — Private
  2. Supabase Dashboard → Edge Functions → Secrets 등록:
    - OPENAI_API_KEY
  3. 배포:
  supabase functions deploy tts-generate

  버킷 생성 확인되면 AI #2 (expo-av 재생 + 녹음 컴포넌트) 바로 시작할 수
  있습니다.

✻ Cogitated for 54s

─────────────────────────────────────────────────────────────────────────────────
❯  
─────────────────────────────────────────────────────────────────────────────────
  ⏵⏵ accept edits on (shift+tab to cycle)
