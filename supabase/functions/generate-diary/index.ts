import { serve } from "https://deno.land/std@0.224.0/http/server.ts"
import { corsHeaders } from "../_shared/cors.ts"

// Optional: verify user with supabase-js v2 using the forwarded Authorization header
import { createClient } from "https://esm.sh/@supabase/supabase-js@2"

const SUPABASE_URL = Deno.env.get('SUPABASE_URL')
const SERVICE_ROLE_KEY = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')
const ANTHROPIC_API_KEY = Deno.env.get('ANTHROPIC_API_KEY')

serve(async (req) => {
  // CORS preflight
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const authHeader = req.headers.get('Authorization') ?? ''

    // Create a supabase client that forwards the user's JWT for RLS-aware calls if needed
    const supabase = (SUPABASE_URL && SERVICE_ROLE_KEY)
      ? createClient(SUPABASE_URL, SERVICE_ROLE_KEY, {
          global: { headers: { Authorization: authHeader } },
        })
      : null

    if (supabase) {
      const { data: { user }, error } = await supabase.auth.getUser()
      if (error || !user) {
        return new Response(JSON.stringify({ error: 'Unauthorized' }), {
          headers: { ...corsHeaders, 'Content-Type': 'application/json' },
          status: 401,
        })
      }
    }

    const { title, content } = await req.json()
    if (!title || !content) {
      return new Response(JSON.stringify({ error: '제목과 내용이 필요합니다.' }), {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 400,
      })
    }

    // If no Anthropic key is configured, return a graceful mock
    if (!ANTHROPIC_API_KEY) {
      const mock = generateMockDiary(title, content)
      return new Response(JSON.stringify({ generated_content: mock }), {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 200,
      })
    }

    // Call Anthropic Messages API
    const response = await fetch('https://api.anthropic.com/v1/messages', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'x-api-key': ANTHROPIC_API_KEY,
        'anthropic-version': '2023-06-01',
      },
      body: JSON.stringify({
        model: 'claude-3-sonnet-20240229',
        max_tokens: 1000,
        messages: [{
          role: 'user',
          content: `다음 일기를 따뜻하고 아름다운 문체로 각색해주세요. 원본의 의미와 감정은 유지하면서 더 서정적이고 감동적으로 만들어주세요.\n\n제목: ${title}\n\n내용: ${content}\n\n각색할 때 다음 사항을 고려해주세요:\n1) 소소한 순간을 특별하게 표현\n2) 감정을 풍부하게 묘사\n3) 추억으로 남을 문장\n4) 긍정적이고 희망적인 톤\n5) 원문의 핵심 내용과 감정 유지\n\n각색된 일기만 출력해주세요.`,
        }],
      }),
    })

    if (!response.ok) {
      const text = await response.text()
      return new Response(JSON.stringify({ error: `Claude API 오류: ${response.status} ${text}` }), {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 500,
      })
    }

    const data = await response.json()
    const generatedContent = data?.content?.[0]?.text ?? ''

    return new Response(JSON.stringify({ generated_content: generatedContent }), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      status: 200,
    })
  } catch (error) {
    return new Response(JSON.stringify({ error: String(error) }), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      status: 400,
    })
  }
})

function generateMockDiary(title: string, original: string): string {
  return `오늘은 유난히 마음이 오래 머무는 하루였다. ${title}\n\n${original}\n\n사소한 순간들이 반짝이며 하루를 채웠다. 작은 기쁨들을 조심스레 모아 간직해 본다. \n내일의 나는 오늘을 떠올리며 미소 지을 수 있기를.`
}


