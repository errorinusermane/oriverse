// supabase/functions/content-moderation/index.ts
// Flow: DB 트리거 → voice_message 조회 → OpenAI Moderation API → moderation_status 업데이트
// MVP 범위: 텍스트 기반 검수만 (오디오 콘텐츠 분석 제외)

import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type, x-webhook-secret',
}

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    // Webhook 시크릿 검증 (DB 트리거에서 호출 — 유저 JWT 없음)
    const webhookSecret = req.headers.get('x-webhook-secret')
    const expectedSecret = Deno.env.get('MODERATION_WEBHOOK_SECRET')

    if (!expectedSecret || webhookSecret !== expectedSecret) {
      return new Response(
        JSON.stringify({ error: 'Unauthorized' }),
        { status: 401, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    const { voice_message_id } = await req.json()

    if (!voice_message_id) {
      return new Response(
        JSON.stringify({ error: 'voice_message_id is required' }),
        { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    const supabase = createClient(
      Deno.env.get('SUPABASE_URL')!,
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
    )

    // voice_message에서 transcript 조회
    const { data: message, error: fetchError } = await supabase
      .from('voice_messages')
      .select('id, transcript')
      .eq('id', voice_message_id)
      .single()

    if (fetchError || !message) {
      return new Response(
        JSON.stringify({ error: 'Voice message not found', detail: fetchError?.message }),
        { status: 404, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // transcript 없으면 승인 처리 (MVP: 텍스트 검수만)
    if (!message.transcript || message.transcript.trim() === '') {
      await supabase
        .from('voice_messages')
        .update({
          moderation_status: 'approved',
          moderation_checked_at: new Date().toISOString(),
        })
        .eq('id', voice_message_id)

      return new Response(
        JSON.stringify({ result: 'approved', reason: 'no_transcript' }),
        { status: 200, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // OpenAI Moderation API 호출
    const moderationRes = await fetch('https://api.openai.com/v1/moderations', {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${Deno.env.get('OPENAI_API_KEY')}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        model: 'omni-moderation-latest',
        input: message.transcript,
      }),
    })

    if (!moderationRes.ok) {
      const errorText = await moderationRes.text()
      console.error('[content-moderation] OpenAI error:', errorText)

      // API 실패 시 failed 상태로 업데이트 (재시도 가능하도록 pending 유지 안 함)
      await supabase
        .from('voice_messages')
        .update({
          moderation_status: 'failed',
          moderation_checked_at: new Date().toISOString(),
        })
        .eq('id', voice_message_id)

      return new Response(
        JSON.stringify({ error: 'Moderation API request failed', detail: errorText }),
        { status: 502, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    const moderationData = await moderationRes.json()
    const result = moderationData.results?.[0]

    if (!result) {
      return new Response(
        JSON.stringify({ error: 'Unexpected moderation API response' }),
        { status: 502, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    const newStatus = result.flagged ? 'rejected' : 'approved'

    const { error: updateError } = await supabase
      .from('voice_messages')
      .update({
        moderation_status: newStatus,
        moderation_checked_at: new Date().toISOString(),
      })
      .eq('id', voice_message_id)

    if (updateError) {
      console.error('[content-moderation] update failed:', updateError)
      return new Response(
        JSON.stringify({ error: 'Failed to update moderation status', detail: updateError.message }),
        { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    return new Response(
      JSON.stringify({
        result: newStatus,
        flagged: result.flagged,
        categories: result.categories,
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
