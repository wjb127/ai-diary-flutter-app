-- 관리자 전용 사용자 관리 기능을 위한 SQL 정책

-- 관리자 역할 생성 (이미 있다면 무시)
DO $$ 
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'admin_user') THEN
    CREATE ROLE admin_user;
  END IF;
END $$;

-- 관리자 사용자 테이블 생성 (관리자 권한 관리용)
CREATE TABLE IF NOT EXISTS public.admin_users (
  id UUID REFERENCES auth.users(id) PRIMARY KEY,
  role TEXT NOT NULL DEFAULT 'admin',
  permissions TEXT[] DEFAULT ARRAY['read_users', 'manage_users'],
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- RLS 활성화
ALTER TABLE public.admin_users ENABLE ROW LEVEL SECURITY;

-- 관리자만 관리자 테이블에 접근 가능
CREATE POLICY "Admin users can view admin table" ON public.admin_users
  FOR ALL USING (
    EXISTS (
      SELECT 1 FROM public.admin_users 
      WHERE id = auth.uid() AND 'read_users' = ANY(permissions)
    )
  );

-- 사용자 통계를 위한 뷰 생성
CREATE OR REPLACE VIEW public.user_stats AS
SELECT 
  COUNT(*) as total_users,
  COUNT(CASE WHEN created_at >= date_trunc('month', CURRENT_DATE) THEN 1 END) as this_month_users,
  COUNT(CASE WHEN last_sign_in_at >= CURRENT_DATE - INTERVAL '30 days' THEN 1 END) as active_users,
  COUNT(CASE WHEN email_confirmed_at IS NOT NULL THEN 1 END) as verified_users
FROM auth.users;

-- 관리자만 사용자 통계 뷰에 접근 가능
CREATE POLICY "Admin can view user stats" ON public.user_stats
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM public.admin_users 
      WHERE id = auth.uid() AND 'read_users' = ANY(permissions)
    )
  );

-- 사용자 일기 통계를 위한 함수 생성
CREATE OR REPLACE FUNCTION public.get_user_diary_stats(target_user_id UUID)
RETURNS JSON AS $$
DECLARE
  result JSON;
BEGIN
  -- 관리자 권한 확인
  IF NOT EXISTS (
    SELECT 1 FROM public.admin_users 
    WHERE id = auth.uid() AND 'read_users' = ANY(permissions)
  ) THEN
    RAISE EXCEPTION 'Access denied: Admin privileges required';
  END IF;

  SELECT json_build_object(
    'total_entries', COUNT(*),
    'recent_entries', COUNT(CASE WHEN created_at >= CURRENT_DATE - INTERVAL '7 days' THEN 1 END),
    'first_entry_date', MIN(created_at),
    'last_entry_date', MAX(created_at)
  ) INTO result
  FROM public.diary_entries
  WHERE user_id = target_user_id;

  RETURN result;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 관리자용 사용자 목록 조회 함수
CREATE OR REPLACE FUNCTION public.get_users_for_admin(
  page_size INTEGER DEFAULT 20,
  page_offset INTEGER DEFAULT 0,
  search_query TEXT DEFAULT NULL,
  sort_by TEXT DEFAULT 'created_at',
  sort_order TEXT DEFAULT 'DESC'
)
RETURNS TABLE (
  id UUID,
  email TEXT,
  created_at TIMESTAMPTZ,
  updated_at TIMESTAMPTZ,
  last_sign_in_at TIMESTAMPTZ,
  email_confirmed_at TIMESTAMPTZ,
  phone TEXT,
  raw_user_meta_data JSONB
) AS $$
BEGIN
  -- 관리자 권한 확인
  IF NOT EXISTS (
    SELECT 1 FROM public.admin_users 
    WHERE admin_users.id = auth.uid() AND 'read_users' = ANY(permissions)
  ) THEN
    RAISE EXCEPTION 'Access denied: Admin privileges required';
  END IF;

  -- 동적 쿼리 실행
  RETURN QUERY EXECUTE format('
    SELECT u.id, u.email, u.created_at, u.updated_at, u.last_sign_in_at, 
           u.email_confirmed_at, u.phone, u.raw_user_meta_data
    FROM auth.users u
    WHERE ($3 IS NULL OR u.email ILIKE $3 OR u.phone ILIKE $3)
    ORDER BY %I %s
    LIMIT $1 OFFSET $2',
    sort_by, 
    CASE WHEN upper(sort_order) = 'ASC' THEN 'ASC' ELSE 'DESC' END
  )
  USING page_size, page_offset, 
        CASE WHEN search_query IS NOT NULL THEN '%' || search_query || '%' ELSE NULL END;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 트리거 함수: updated_at 자동 업데이트
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- admin_users 테이블용 트리거
DROP TRIGGER IF EXISTS update_admin_users_updated_at ON public.admin_users;
CREATE TRIGGER update_admin_users_updated_at 
    BEFORE UPDATE ON public.admin_users 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- 기본 관리자 계정 추가 (실제 운영시에는 실제 관리자 이메일로 변경 필요)
-- 이 부분은 실제 배포시 주석 처리하고 수동으로 관리자 추가
/*
INSERT INTO public.admin_users (id, role, permissions) 
VALUES (
  -- 실제 관리자의 auth.users ID를 여기에 입력
  '00000000-0000-0000-0000-000000000000'::UUID,
  'super_admin',
  ARRAY['read_users', 'manage_users', 'delete_users']
) ON CONFLICT (id) DO NOTHING;
*/

COMMENT ON TABLE public.admin_users IS '관리자 권한 관리 테이블';
COMMENT ON FUNCTION public.get_user_diary_stats(UUID) IS '특정 사용자의 일기 통계 조회 (관리자 전용)';
COMMENT ON FUNCTION public.get_users_for_admin(INTEGER, INTEGER, TEXT, TEXT, TEXT) IS '관리자용 사용자 목록 조회 함수';