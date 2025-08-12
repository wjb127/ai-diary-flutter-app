import { serve } from "https://deno.land/std@0.224.0/http/server.ts"
import { corsHeaders } from "../_shared/cors.ts"

// Verify user with supabase-js v2 using forwarded Authorization header
import { createClient } from "https://esm.sh/@supabase/supabase-js@2"

// These two are provided by the Supabase Edge Functions runtime by default
const SUPABASE_URL = Deno.env.get('SUPABASE_URL')
const SUPABASE_ANON_KEY = Deno.env.get('SUPABASE_ANON_KEY')

// Custom secret you set in Edge Functions → Secrets
const ANTHROPIC_API_KEY = Deno.env.get('ANTHROPIC_API_KEY')

// 문체별 프롬프트 정의
const stylePrompts: Record<string, string> = {
  emotional: '따뜻하고 감성적인 문체로 각색해주세요. 감정을 풍부하게 표현하고 서정적으로 만들어주세요.',
  epic: '크루세이더 킹즈 3 스타일의 대서사시 문체로 각색해주세요. 중세 연대기처럼 거창하고 장엄하게, 가문의 위신과 영광, 운명 등을 언급하며 작성해주세요. 마지막에는 게임 스타일로 "[연대기 기록 완료. 가문의 위신 +값, 스트레스 -값]" 같은 문구를 추가해주세요.',
  poetic: '시적이고 은유적인 문체로 각색해주세요. 운율과 리듬감을 살리고, 자연과 감정을 아름답게 묘사해주세요.',
  humorous: '유머러스하고 재미있는 문체로 각색해주세요. 웃음을 주는 표현과 농담을 섞어서 즐겁게 읽을 수 있도록 해주세요. ㅋㅋㅋ나 이모티콘도 적절히 사용해주세요.',
  philosophical: '철학적이고 사색적인 문체로 각색해주세요. 일상에서 깊은 의미를 찾고, 존재와 삶에 대한 성찰을 담아주세요.',
  minimalist: '간결하고 미니멀한 문체로 각색해주세요. 핵심만 짧고 명료하게, 불필요한 수식어 없이 표현해주세요.',
  detective: '탐정 소설 스타일로 각색해주세요. 관찰자 시점에서 세밀하게 묘사하고, 추리소설처럼 긴장감 있게 서술해주세요.',
  fairytale: '동화 스타일로 각색해주세요. "옛날 옛적에" 같은 동화적 표현을 사용하고, 마법같은 순간들을 강조해주세요.',
  scifi: 'SF 소설 스타일로 각색해주세요. 미래적이고 기술적인 용어를 사용하며, 일상을 우주적 관점에서 서술해주세요.',
  historical: '역사 기록 스타일로 각색해주세요. 객관적이고 연대기적으로 서술하며, 역사적 사건처럼 기록해주세요.'
}

serve(async (req) => {
  // CORS preflight
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const authHeader = req.headers.get('Authorization') ?? ''

    if (!SUPABASE_URL || !SUPABASE_ANON_KEY) {
      return new Response(JSON.stringify({ error: 'Supabase runtime env is missing.' }), {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 500,
      })
    }

    // RLS-aware client using anon key + forwarded JWT
    const supabase = createClient(SUPABASE_URL, SUPABASE_ANON_KEY, {
      global: { headers: { Authorization: authHeader } },
    })

    const { data: { user }, error } = await supabase.auth.getUser()
    if (error || !user) {
      return new Response(JSON.stringify({ error: 'Unauthorized' }), {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 401,
      })
    }

    const { title, content, style = 'emotional' } = await req.json()
    if (!title || !content) {
      return new Response(JSON.stringify({ error: '제목과 내용이 필요합니다.' }), {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 400,
      })
    }

    // 선택된 문체에 맞는 프롬프트 가져오기
    const selectedPrompt = stylePrompts[style] || stylePrompts.emotional

    // If no Anthropic key is configured, return a graceful mock
    if (!ANTHROPIC_API_KEY) {
      const mock = generateMockDiary(title, content, style)
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
        model: 'claude-3-5-sonnet-20241022',
        max_tokens: 1000,
        messages: [{
          role: 'user',
          content: `다음 일기를 ${selectedPrompt}

제목: ${title}

내용: ${content}

각색할 때 다음 사항을 고려해주세요:
1) 원본의 의미와 감정은 유지하되 선택된 문체로 재창조
2) 일상의 소소한 순간들을 문체에 맞게 특별하게 표현
3) 읽는 사람이 몰입할 수 있도록 생생하게 묘사
4) 각 문체의 특징을 명확하게 살려서 작성

각색된 일기만 출력해주세요.`,
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

function generateMockDiary(title: string, original: string, style: string): string {
  // 문체별 Mock 응답
  switch (style) {
    case 'epic':
      const date = new Date()
      return `[서기 ${date.getFullYear()}년 제${date.getMonth() + 1}월 제${date.getDate()}일의 연대기]

오늘, 평범한 필멸자인 나는 "${title}"라는 대업을 완수하였노라.

${original}

이날의 업적은 후세에 길이 전해질 것이며, 나의 후손들은 이 영광스러운 순간을 영원히 기억하리라. 
비록 지금은 하찮아 보일지라도, 이 모든 것이 거대한 운명의 톱니바퀴를 돌리는 중요한 사건임을 누가 알겠는가?

신들이여, 내일도 나에게 힘을 주소서!

[연대기 기록 완료. 가문의 위신 +10, 스트레스 -5]`

    case 'poetic':
      return `${title}

${original}

바람이 속삭이듯 하루가 지나가고
작은 숨결들이 모여 하나의 시가 되었네
평범함 속에 숨겨진 아름다움을 발견하며
오늘도 나는 조용히 성장하고 있어

내일은 또 어떤 시를 쓰게 될까
기대와 설렘으로 펜을 내려놓는다`

    case 'humorous':
      return `제목: ${title} (웃겨서 배꼽 빠질 뻔한 하루)

${original}

ㅋㅋㅋㅋㅋ 진짜 오늘 내가 이런 일을 겪었다니! 
나중에 이 일기 다시 읽으면 또 빵 터질 듯.
인생은 시트콤이고, 나는 주인공이야! 
내일은 또 무슨 개그 에피소드가 펼쳐질까? 🤣

PS. 미래의 나야, 이거 읽고 웃지 마라. 아 참고로 복근 생겼니?`

    default:
      return `오늘은 유난히 마음이 오래 머무는 하루였다. ${title}

${original}

사소한 순간들이 반짝이며 하루를 채웠다. 작은 기쁨들을 조심스레 모아 간직해 본다. 
내일의 나는 오늘을 떠올리며 미소 지을 수 있기를.`
  }
}