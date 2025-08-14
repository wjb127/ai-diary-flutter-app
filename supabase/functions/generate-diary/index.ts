import { serve } from "https://deno.land/std@0.224.0/http/server.ts"
import { corsHeaders } from "../_shared/cors.ts"

// These are provided by the Supabase Edge Functions runtime by default
const SUPABASE_URL = Deno.env.get('SUPABASE_URL')
const SUPABASE_ANON_KEY = Deno.env.get('SUPABASE_ANON_KEY')

// Custom secret you set in Edge Functions → Secrets
const ANTHROPIC_API_KEY = Deno.env.get('ANTHROPIC_API_KEY')

// 문체별 프롬프트 정의
const stylePrompts: Record<string, string> = {
  emotional: '따뜻하고 감성적인 문체로 각색해주세요. 감정을 풍부하게 표현하고 서정적으로 만들어주세요.',
  epic: '중세 연대기나 크루세이더 왕조사 같은 역사 서사시 문체로 완전히 재창조해주세요. 일상의 평범한 사건들을 역사에 남을 대사건처럼 거창하게 각색하고, 인물들은 역사적 인물처럼 묘사해주세요. "서기 XXXX년", "이날 역사적인 사건이", "후세에 전해지기를" 같은 연대기적 표현을 사용하세요. 원본 내용을 그대로 반복하지 말고, 완전히 새로운 역사 서사시로 재탄생시켜주세요. 게임 용어나 수치는 절대 사용하지 마세요.',
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
    // 비로그인 사용자도 AI 기능 사용 가능
    // const authHeader = req.headers.get('Authorization') ?? ''

    if (!SUPABASE_URL || !SUPABASE_ANON_KEY) {
      return new Response(JSON.stringify({ error: 'Supabase runtime env is missing.' }), {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 500,
      })
    }

    // 인증 체크 제거 - 모든 사용자가 AI 기능 사용 가능
    // 게스트 모드 사용자도 AI 일기 생성 가능

    const { title, content, style = 'emotional' } = await req.json()
    if (!title || !content) {
      return new Response(JSON.stringify({ error: '제목과 내용이 필요합니다.' }), {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 400,
      })
    }

    // 선택된 문체에 맞는 프롬프트 가져오기
    const selectedPrompt = stylePrompts[style] || stylePrompts.emotional

    // If no Anthropic key is configured, return error
    if (!ANTHROPIC_API_KEY) {
      return new Response(JSON.stringify({ 
        error: 'AI 서비스가 현재 작동하지 않습니다. 관리자에게 문의해주세요.',
        details: 'Anthropic API key not configured'
      }), {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 503,
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
        model: 'claude-sonnet-4-20250514',
        max_tokens: 1000,
        messages: [{
          role: 'user',
          content: `다음 일기를 ${selectedPrompt}

원본 제목: ${title}
원본 내용: ${content}

중요 지침:
- 원본 내용을 그대로 반복하거나 인용하지 마세요
- 완전히 새로운 문체로 재창조하여 각색해주세요  
- 원본의 핵심 의미는 유지하되, 표현은 180도 다르게 바꿔주세요
- 선택된 문체의 특징을 극대화하여 작성하세요
- 원본과 완전히 다른 느낌의 텍스트를 생성하세요

각색된 일기만 출력해주세요. 원본을 절대 그대로 쓰지 마세요.`,
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
      return `서기 ${date.getFullYear()}년 ${date.getMonth() + 1}월 ${date.getDate()}일의 기록

이 날, "${title}"에 관한 중대한 사건이 있었노라.

${original}

이는 비록 작은 일상의 한 조각이나, 인생이라는 거대한 서사시에서 빼놓을 수 없는 장면이었다. 
후에 되돌아볼 때, 오늘의 모든 순간들이 얼마나 소중했는지를 깨닫게 되리라.

시간의 강물은 멈추지 않고 흘러가지만, 이 하루만큼은 영원히 기억될 것이다.
오늘이라는 날이 내게 선사한 모든 경험에 감사하며 펜을 놓는다.`

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