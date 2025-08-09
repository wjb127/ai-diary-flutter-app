# Supabase 설정 가이드

이 문서는 AI 일기장 앱을 위한 Supabase 백엔드 설정 가이드입니다.

## 1. Supabase 프로젝트 생성

1. [Supabase](https://supabase.com)에 접속하여 계정을 생성합니다.
2. 새 프로젝트를 생성합니다.
3. 프로젝트명: `ai-diary-app`
4. 데이터베이스 비밀번호를 설정합니다.

## 2. 데이터베이스 스키마 설정

아래 SQL을 Supabase SQL Editor에서 실행하세요:

```sql
-- Enable RLS (Row Level Security)
ALTER TABLE auth.users ENABLE ROW LEVEL SECURITY;

-- Create diary_entries table
CREATE TABLE public.diary_entries (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    date DATE NOT NULL,
    title TEXT NOT NULL,
    original_content TEXT NOT NULL,
    generated_content TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable RLS on diary_entries
ALTER TABLE public.diary_entries ENABLE ROW LEVEL SECURITY;

-- Create RLS policies
-- Users can only see their own diary entries
CREATE POLICY "Users can view own diary entries" ON public.diary_entries
    FOR SELECT USING (auth.uid() = user_id);

-- Users can only insert their own diary entries
CREATE POLICY "Users can insert own diary entries" ON public.diary_entries
    FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Users can only update their own diary entries
CREATE POLICY "Users can update own diary entries" ON public.diary_entries
    FOR UPDATE USING (auth.uid() = user_id);

-- Users can only delete their own diary entries
CREATE POLICY "Users can delete own diary entries" ON public.diary_entries
    FOR DELETE USING (auth.uid() = user_id);

-- Create unique index on user_id and date
CREATE UNIQUE INDEX diary_entries_user_date_idx ON public.diary_entries (user_id, date);

-- Create function to update updated_at column
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Create trigger for updated_at
CREATE TRIGGER update_diary_entries_updated_at BEFORE UPDATE
    ON public.diary_entries FOR EACH ROW EXECUTE FUNCTION
    update_updated_at_column();
```

## 3. 인증 설정

### 익명 로그인 활성화
1. Supabase Dashboard → Authentication → Settings
2. "Allow anonymous sign-ins" 옵션을 활성화합니다.

### 이메일 인증 설정 (선택사항)
1. Authentication → Settings → Auth providers
2. Email 설정을 확인합니다.

## 4. Edge Functions 설정

AI 일기 생성을 위한 Edge Function을 생성합니다.

### 4.1 Supabase CLI 설치
```bash
npm install -g supabase
```

### 4.2 프로젝트 초기화
```bash
supabase init
supabase login
supabase link --project-ref YOUR_PROJECT_REF
```

### 4.3 Edge Function 생성
```bash
supabase functions new generate-diary
```

### 4.4 Edge Function 코드
`supabase/functions/generate-diary/index.ts` 파일을 다음과 같이 작성:

```typescript
import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { corsHeaders } from '../_shared/cors.ts'

const ANTHROPIC_API_KEY = Deno.env.get('ANTHROPIC_API_KEY')

serve(async (req) => {
  // CORS 처리
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const { title, content } = await req.json()

    if (!title || !content) {
      throw new Error('제목과 내용이 필요합니다.')
    }

    // Claude API 호출
    const response = await fetch('https://api.anthropic.com/v1/messages', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'x-api-key': ANTHROPIC_API_KEY!,
        'anthropic-version': '2023-06-01'
      },
      body: JSON.stringify({
        model: 'claude-3-sonnet-20240229',
        max_tokens: 1000,
        messages: [{
          role: 'user',
          content: `다음 일기를 따뜻하고 아름다운 문체로 각색해주세요. 원본의 의미와 감정은 유지하면서 더 서정적이고 감동적으로 만들어주세요. 

제목: ${title}

내용: ${content}

각색할 때 다음 사항들을 고려해주세요:
1. 일상의 소소한 순간들을 특별하게 표현
2. 감정을 더 풍부하게 묘사
3. 추억으로 남을 만한 아름다운 문장으로 변환
4. 긍정적이고 희망적인 톤으로 마무리
5. 원본 글의 핵심 내용과 감정은 반드시 유지

각색된 일기만 출력해주세요.`
        }]
      })
    })

    if (!response.ok) {
      throw new Error(`Claude API 오류: ${response.status}`)
    }

    const data = await response.json()
    const generatedContent = data.content[0].text

    return new Response(
      JSON.stringify({ generated_content: generatedContent }),
      {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 200,
      },
    )

  } catch (error) {
    return new Response(
      JSON.stringify({ error: error.message }),
      {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 400,
      },
    )
  }
})
```

### 4.5 CORS 헬퍼 파일
`supabase/functions/_shared/cors.ts` 파일을 생성:

```typescript
export const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}
```

### 4.6 환경 변수 설정
```bash
supabase secrets set ANTHROPIC_API_KEY=your_claude_api_key_here
```

### 4.7 Edge Function 배포
```bash
supabase functions deploy generate-diary
```

## 5. Flutter 앱 설정

### 5.1 환경 변수 설정
`lib/main.dart` 파일에서 Supabase 설정을 업데이트하세요:

```dart
await Supabase.initialize(
  url: 'YOUR_SUPABASE_PROJECT_URL',
  anonKey: 'YOUR_SUPABASE_ANON_KEY',
);
```

### 5.2 API 키 확인 방법
1. Supabase Dashboard → Settings → API
2. Project URL과 anon/public key를 복사하여 사용

## 6. 보안 설정

### 6.1 API 키 보호
- Flutter 앱에는 Supabase anon key만 포함
- Claude API 키는 Edge Function에서만 사용
- 환경 변수로 민감한 정보 관리

### 6.2 RLS 정책 확인
- 모든 테이블에 적절한 RLS 정책 적용
- 사용자는 자신의 데이터만 접근 가능

## 7. 테스트

### 7.1 데이터베이스 연결 테스트
Flutter 앱을 실행하여 다음을 확인:
- 익명 로그인 성공
- 일기 작성 및 저장
- 날짜별 일기 조회

### 7.2 Edge Function 테스트
```bash
supabase functions serve
```

로컬에서 테스트 후 배포된 함수가 정상 작동하는지 확인

## 8. 문제 해결

### 자주 발생하는 문제들:

1. **RLS 정책 오류**: 테이블에 적절한 RLS 정책이 설정되었는지 확인
2. **CORS 오류**: Edge Function에서 CORS 헤더가 올바르게 설정되었는지 확인  
3. **API 키 오류**: Supabase와 Anthropic API 키가 올바르게 설정되었는지 확인
4. **익명 로그인 실패**: Authentication 설정에서 익명 로그인이 활성화되었는지 확인

## 9. 추가 기능

향후 구현할 수 있는 기능들:
- 일기 백업/복원
- 이미지 첨부
- 감정 분석
- 월간/연간 통계
- 소셜 로그인 (Google, Apple)

---

이 설정을 완료하면 AI 일기장 앱이 Supabase와 연동되어 정상적으로 작동합니다.