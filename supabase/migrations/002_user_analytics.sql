-- 사용자 행동 추적 테이블
CREATE TABLE IF NOT EXISTS user_events (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  session_id UUID NOT NULL,
  event_type VARCHAR(50) NOT NULL,
  event_name VARCHAR(100) NOT NULL,
  event_data JSONB,
  page_url TEXT,
  platform VARCHAR(20), -- 'ios', 'android', 'web'
  device_info JSONB,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 인덱스 생성
CREATE INDEX idx_user_events_user_id ON user_events(user_id);
CREATE INDEX idx_user_events_session_id ON user_events(session_id);
CREATE INDEX idx_user_events_event_type ON user_events(event_type);
CREATE INDEX idx_user_events_created_at ON user_events(created_at DESC);

-- 사용자 세션 테이블
CREATE TABLE IF NOT EXISTS user_sessions (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  session_start TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  session_end TIMESTAMP WITH TIME ZONE,
  platform VARCHAR(20),
  device_info JSONB,
  ip_address INET,
  user_agent TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 인덱스 생성
CREATE INDEX idx_user_sessions_user_id ON user_sessions(user_id);
CREATE INDEX idx_user_sessions_created_at ON user_sessions(created_at DESC);

-- 퍼널 단계 정의 테이블
CREATE TABLE IF NOT EXISTS funnel_steps (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  funnel_name VARCHAR(100) NOT NULL,
  step_order INT NOT NULL,
  step_name VARCHAR(100) NOT NULL,
  event_type VARCHAR(50) NOT NULL,
  event_name VARCHAR(100) NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(funnel_name, step_order)
);

-- 기본 퍼널 설정 삽입
INSERT INTO funnel_steps (funnel_name, step_order, step_name, event_type, event_name) VALUES
('user_onboarding', 1, '앱 실행', 'app', 'app_open'),
('user_onboarding', 2, '회원가입 시작', 'auth', 'signup_start'),
('user_onboarding', 3, '회원가입 완료', 'auth', 'signup_complete'),
('user_onboarding', 4, '첫 일기 작성', 'diary', 'diary_create_first'),
('user_onboarding', 5, 'AI 생성 완료', 'diary', 'ai_generation_complete');

INSERT INTO funnel_steps (funnel_name, step_order, step_name, event_type, event_name) VALUES
('diary_creation', 1, '일기 작성 시작', 'diary', 'diary_start'),
('diary_creation', 2, '내용 입력', 'diary', 'diary_content_entered'),
('diary_creation', 3, 'AI 생성 요청', 'diary', 'ai_generation_request'),
('diary_creation', 4, 'AI 생성 완료', 'diary', 'ai_generation_complete'),
('diary_creation', 5, '일기 저장', 'diary', 'diary_save');

INSERT INTO funnel_steps (funnel_name, step_order, step_name, event_type, event_name) VALUES
('subscription_flow', 1, '구독 화면 진입', 'subscription', 'subscription_screen_view'),
('subscription_flow', 2, '구독 상품 선택', 'subscription', 'product_selected'),
('subscription_flow', 3, '결제 시작', 'subscription', 'payment_start'),
('subscription_flow', 4, '결제 완료', 'subscription', 'payment_complete');

-- Row Level Security (RLS) 정책
ALTER TABLE user_events ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE funnel_steps ENABLE ROW LEVEL SECURITY;

-- 관리자는 모든 이벤트 조회 가능
CREATE POLICY "Admin can view all events" ON user_events
  FOR SELECT
  USING (auth.jwt() ->> 'email' LIKE '%@admin.com');

-- 사용자는 자신의 이벤트만 조회 가능
CREATE POLICY "Users can view own events" ON user_events
  FOR SELECT
  USING (auth.uid() = user_id);

-- 사용자는 자신의 이벤트 생성 가능
CREATE POLICY "Users can create own events" ON user_events
  FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- 관리자는 모든 세션 조회 가능
CREATE POLICY "Admin can view all sessions" ON user_sessions
  FOR SELECT
  USING (auth.jwt() ->> 'email' LIKE '%@admin.com');

-- 사용자는 자신의 세션만 조회 가능
CREATE POLICY "Users can view own sessions" ON user_sessions
  FOR SELECT
  USING (auth.uid() = user_id);

-- 사용자는 자신의 세션 생성/수정 가능
CREATE POLICY "Users can create own sessions" ON user_sessions
  FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own sessions" ON user_sessions
  FOR UPDATE
  USING (auth.uid() = user_id);

-- 모든 사용자가 퍼널 단계 조회 가능
CREATE POLICY "Anyone can view funnel steps" ON funnel_steps
  FOR SELECT
  USING (true);

-- 함수: 이벤트 기록
CREATE OR REPLACE FUNCTION log_user_event(
  p_user_id UUID,
  p_session_id UUID,
  p_event_type VARCHAR,
  p_event_name VARCHAR,
  p_event_data JSONB DEFAULT NULL,
  p_page_url TEXT DEFAULT NULL,
  p_platform VARCHAR DEFAULT NULL,
  p_device_info JSONB DEFAULT NULL
)
RETURNS UUID AS $$
DECLARE
  v_event_id UUID;
BEGIN
  INSERT INTO user_events (
    user_id,
    session_id,
    event_type,
    event_name,
    event_data,
    page_url,
    platform,
    device_info
  ) VALUES (
    p_user_id,
    p_session_id,
    p_event_type,
    p_event_name,
    p_event_data,
    p_page_url,
    p_platform,
    p_device_info
  ) RETURNING id INTO v_event_id;
  
  RETURN v_event_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 함수: 퍼널 분석
CREATE OR REPLACE FUNCTION analyze_funnel(
  p_funnel_name VARCHAR,
  p_start_date TIMESTAMP WITH TIME ZONE DEFAULT NOW() - INTERVAL '30 days',
  p_end_date TIMESTAMP WITH TIME ZONE DEFAULT NOW()
)
RETURNS TABLE (
  step_order INT,
  step_name VARCHAR,
  user_count BIGINT,
  conversion_rate NUMERIC
) AS $$
WITH funnel_data AS (
  SELECT
    fs.step_order,
    fs.step_name,
    COUNT(DISTINCT ue.user_id) as users
  FROM funnel_steps fs
  LEFT JOIN user_events ue ON 
    ue.event_type = fs.event_type AND
    ue.event_name = fs.event_name AND
    ue.created_at BETWEEN p_start_date AND p_end_date
  WHERE fs.funnel_name = p_funnel_name
  GROUP BY fs.step_order, fs.step_name
),
first_step AS (
  SELECT users FROM funnel_data WHERE step_order = 1
)
SELECT
  fd.step_order,
  fd.step_name,
  fd.users as user_count,
  CASE 
    WHEN fs.users > 0 THEN ROUND(fd.users::NUMERIC / fs.users * 100, 2)
    ELSE 0
  END as conversion_rate
FROM funnel_data fd
CROSS JOIN first_step fs
ORDER BY fd.step_order;
$$ LANGUAGE plpgsql SECURITY DEFINER;