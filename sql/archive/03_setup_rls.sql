-- Row Level Security (RLS) 설정
-- 이 파일을 Supabase SQL Editor에서 실행하세요 (01, 02 실행 후)

-- RLS 활성화
ALTER TABLE diary_entries ENABLE ROW LEVEL SECURITY;

-- 기존 정책들 삭제 (재실행 시 오류 방지)
DROP POLICY IF EXISTS "Users can read own diary entries" ON diary_entries;
DROP POLICY IF EXISTS "Users can create own diary entries" ON diary_entries;
DROP POLICY IF EXISTS "Users can update own diary entries" ON diary_entries;
DROP POLICY IF EXISTS "Users can delete own diary entries" ON diary_entries;

-- 사용자가 자신의 일기만 읽을 수 있는 정책
CREATE POLICY "Users can read own diary entries"
  ON diary_entries
  FOR SELECT
  USING (auth.uid() = user_id);

-- 사용자가 자신의 일기만 생성할 수 있는 정책
CREATE POLICY "Users can create own diary entries"
  ON diary_entries
  FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- 사용자가 자신의 일기만 수정할 수 있는 정책
CREATE POLICY "Users can update own diary entries"
  ON diary_entries
  FOR UPDATE
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- 사용자가 자신의 일기만 삭제할 수 있는 정책
CREATE POLICY "Users can delete own diary entries"
  ON diary_entries
  FOR DELETE
  USING (auth.uid() = user_id);

-- RLS 정책 확인 쿼리 (선택사항 - 확인용)
-- SELECT schemaname, tablename, policyname, permissive, roles, cmd, qual, with_check 
-- FROM pg_policies 
-- WHERE tablename = 'diary_entries';