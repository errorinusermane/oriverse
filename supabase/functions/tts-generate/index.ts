// supabase/functions/tts-generate/index.ts
// Flow: Storage 캐시 확인 → 없으면 OpenAI TTS 생성 → Storage 저장 → 서명 URL 반환

import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const BUCKET = 'tts-cache'
const SIGNED_URL_TTL = 3600 // 1시간

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const { script_id, voice = 'nova' } = await req.json()

    if (!script_id) {
      return new Response(
        JSON.stringify({ error: 'script_id is required' }),
        { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    const supabase = createClient(
      Deno.env.get('SUPABASE_URL')!,
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
    )

    const storagePath = `${voice}/${script_id}.mp3`

    // 1. Storage 캐시 확인
    const { data: existingFile } = await supabase.storage
      .from(BUCKET)
      .list(voice, { search: `${script_id}.mp3` })

    const isCached = existingFile && existingFile.length > 0

    if (!isCached) {
      // 2. DB에서 스크립트 텍스트 조회
      const { data: script, error: scriptError } = await supabase
        .from('lesson_scripts')
        .select('script_text, speaker')
        .eq('id', script_id)
        .single()

      if (scriptError || !script) {
        return new Response(
          JSON.stringify({ error: 'Script not found', detail: scriptError?.message }),
          { status: 404, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
        )
      }

      // speaker='user' 줄은 TTS 생성 불필요 (사용자가 직접 말함)
      if (script.speaker === 'user') {
        return new Response(
          JSON.stringify({ error: 'TTS is not generated for user speaker lines' }),
          { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
        )
      }

      // 3. OpenAI TTS 호출
      const openaiRes = await fetch('https://api.openai.com/v1/audio/speech', {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${Deno.env.get('OPENAI_API_KEY')}`,
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          model: 'tts-1',
          input: script.script_text,
          voice,
          response_format: 'mp3',
        }),
      })

      if (!openaiRes.ok) {
        const errorText = await openaiRes.text()
        return new Response(
          JSON.stringify({ error: 'OpenAI TTS failed', detail: errorText }),
          { status: 502, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
        )
      }

      const audioBuffer = await openaiRes.arrayBuffer()

      // 4. Storage 저장
      const { error: uploadError } = await supabase.storage
        .from(BUCKET)
        .upload(storagePath, audioBuffer, {
          contentType: 'audio/mpeg',
          upsert: false,
        })

      if (uploadError) {
        return new Response(
          JSON.stringify({ error: 'Storage upload failed', detail: uploadError.message }),
          { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
        )
      }

      // 5. lesson_scripts.audio_storage_path 업데이트
      await supabase
        .from('lesson_scripts')
        .update({ audio_storage_path: storagePath })
        .eq('id', script_id)
    }

    // 6. 서명 URL 반환 (캐시 히트 / 신규 생성 공통)
    const { data: signedUrlData, error: signedUrlError } = await supabase.storage
      .from(BUCKET)
      .createSignedUrl(storagePath, SIGNED_URL_TTL)

    if (signedUrlError || !signedUrlData) {
      return new Response(
        JSON.stringify({ error: 'Failed to create signed URL', detail: signedUrlError?.message }),
        { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    return new Response(
      JSON.stringify({
        url: signedUrlData.signedUrl,
        cached: isCached,
        path: storagePath,
      }),
      { status: 200, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )
  } catch (err) {
    return new Response(
      JSON.stringify({ error: 'Internal server error', detail: String(err) }),
      { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )
  }
})
