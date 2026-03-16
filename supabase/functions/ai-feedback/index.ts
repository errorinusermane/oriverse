// supabase/functions/ai-feedback/index.ts
// Flow: 일일 횟수 확인 → GPT-4o-mini 피드백 생성 → 카운트 증가 → 결과 반환

import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const DAILY_LIMIT = 5

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const { user_id, original_script, transcript } = await req.json()

    if (!user_id || !original_script || !transcript) {
      return new Response(
        JSON.stringify({ error: 'user_id, original_script, transcript are required' }),
        { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    const supabase = createClient(
      Deno.env.get('SUPABASE_URL')!,
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
    )

    const today = new Date().toISOString().split('T')[0] // YYYY-MM-DD

    // 일일 사용량 확인
    const { data: stats, error: statsError } = await supabase
      .from('user_daily_stats')
      .select('ai_feedback_count')
      .eq('user_id', user_id)
      .eq('date', today)
      .single()

    if (statsError && statsError.code !== 'PGRST116') {
      // PGRST116 = row not found (정상 케이스)
      return new Response(
        JSON.stringify({ error: 'Failed to check usage', detail: statsError.message }),
        { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    const currentCount = stats?.ai_feedback_count ?? 0

    if (currentCount >= DAILY_LIMIT) {
      return new Response(
        JSON.stringify({ error: 'Daily limit reached' }),
        { status: 402, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // GPT-4o-mini 피드백 생성
    const openaiRes = await fetch('https://api.openai.com/v1/chat/completions', {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${Deno.env.get('OPENAI_API_KEY')}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        model: 'gpt-4o-mini',
        messages: [
          {
            role: 'system',
            content: `You are a language tutor providing concise, actionable feedback on speaking practice.
Compare the user's transcript to the original script and return a JSON object with:
- suggestions: array of specific improvement tips (pronunciation, grammar, missing words, etc.)
- corrected: the user's transcript with corrections applied

Respond ONLY with valid JSON. No markdown, no explanation.`,
          },
          {
            role: 'user',
            content: `Original script:\n${original_script}\n\nUser transcript:\n${transcript}`,
          },
        ],
        response_format: { type: 'json_object' },
        temperature: 0.3,
      }),
    })

    if (!openaiRes.ok) {
      const errorText = await openaiRes.text()
      return new Response(
        JSON.stringify({ error: 'OpenAI request failed', detail: errorText }),
        { status: 502, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    const openaiData = await openaiRes.json()
    const feedback = JSON.parse(openaiData.choices[0].message.content)

    // 카운트 증가 (upsert)
    await supabase
      .from('user_daily_stats')
      .upsert(
        { user_id, date: today, ai_feedback_count: currentCount + 1 },
        { onConflict: 'user_id,date' }
      )

    return new Response(
      JSON.stringify({
        suggestions: feedback.suggestions ?? [],
        corrected: feedback.corrected ?? transcript,
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
