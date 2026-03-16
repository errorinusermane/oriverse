// supabase/functions/pronunciation-score/index.ts
// Flow: lesson_scripts에서 원문 조회 → 토큰 비교로 점수 산출 → user_lesson_progress 저장

import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const PASS_THRESHOLD = Number(Deno.env.get('PASS_THRESHOLD') ?? '60')

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

function tokenize(text: string): string[] {
  return text
    .toLowerCase()
    .replace(/[^\p{L}\s]/gu, '')
    .split(/\s+/)
    .filter(Boolean)
}

function levenshtein(a: string, b: string): number {
  const m = a.length
  const n = b.length
  const dp: number[][] = Array.from({ length: m + 1 }, (_, i) =>
    Array.from({ length: n + 1 }, (_, j) => (i === 0 ? j : j === 0 ? i : 0))
  )
  for (let i = 1; i <= m; i++) {
    for (let j = 1; j <= n; j++) {
      dp[i][j] =
        a[i - 1] === b[j - 1]
          ? dp[i - 1][j - 1]
          : 1 + Math.min(dp[i - 1][j], dp[i][j - 1], dp[i - 1][j - 1])
    }
  }
  return dp[m][n]
}

// 각 예상 토큰을 실제 토큰과 비교 (레벤슈타인 거리 1 이내면 일치로 처리)
function scoreTokens(
  expected: string[],
  actual: string[]
): { score: number; mismatched: string[] } {
  if (expected.length === 0) return { score: 100, mismatched: [] }

  const mismatched: string[] = []
  let matched = 0

  for (const token of expected) {
    const found = actual.some((t) => {
      const dist = levenshtein(token, t)
      return dist === 0 || (token.length >= 4 && dist <= 1)
    })
    if (found) {
      matched++
    } else {
      mismatched.push(token)
    }
  }

  const score = Math.round((matched / expected.length) * 100)
  return { score, mismatched }
}

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    // JWT 검증
    const authHeader = req.headers.get('Authorization')
    if (!authHeader?.startsWith('Bearer ')) {
      return new Response(
        JSON.stringify({ error: 'Unauthorized' }),
        { status: 401, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }
    const { data: { user }, error: authError } = await createClient(
      Deno.env.get('SUPABASE_URL')!,
      Deno.env.get('SUPABASE_ANON_KEY')!,
      { global: { headers: { Authorization: authHeader } } }
    ).auth.getUser()
    if (authError || !user) {
      return new Response(
        JSON.stringify({ error: 'Unauthorized' }),
        { status: 401, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    const { lesson_id, script_id, transcript } = await req.json()

    if (!script_id || transcript === undefined) {
      return new Response(
        JSON.stringify({ error: 'script_id, transcript are required' }),
        { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    const supabase = createClient(
      Deno.env.get('SUPABASE_URL')!,
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
    )

    // 원문 조회
    const { data: scriptRow, error: scriptError } = await supabase
      .from('lesson_scripts')
      .select('script_text, lesson_id')
      .eq('id', script_id)
      .single()

    if (scriptError || !scriptRow) {
      return new Response(
        JSON.stringify({ error: 'Script not found', detail: scriptError?.message }),
        { status: 404, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    const expectedTokens = tokenize(scriptRow.script_text)
    const actualTokens = tokenize(transcript)
    const { score, mismatched } = scoreTokens(expectedTokens, actualTokens)
    const passed = score >= PASS_THRESHOLD

    // user_lesson_progress 저장
    const resolvedLessonId = lesson_id ?? scriptRow.lesson_id
    const upsertData: Record<string, unknown> = {
      user_id: user.id,
      lesson_id: resolvedLessonId,
      script_id,
      status: passed ? 'completed' : 'attempted',
      transcription: transcript,
      confidence_score: score / 100,
      attempted_at: new Date().toISOString(),
    }
    if (passed) {
      upsertData.completed_at = new Date().toISOString()
    }

    const { error: upsertError } = await supabase
      .from('user_lesson_progress')
      .upsert(upsertData, { onConflict: 'user_id,script_id' })

    if (upsertError) {
      console.error('[pronunciation-score] upsert failed:', upsertError)
    }

    return new Response(
      JSON.stringify({ score, passed, feedback_tokens: mismatched }),
      { status: 200, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )
  } catch (err) {
    return new Response(
      JSON.stringify({ error: 'Internal server error', detail: String(err) }),
      { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )
  }
})
