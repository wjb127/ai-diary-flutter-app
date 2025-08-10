-- Triggers and Functions
-- 이 파일을 Supabase SQL Editor에서 실행하세요 (01_create_tables.sql 실행 후)

-- updated_at 자동 업데이트 함수 생성
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = timezone('utc'::text, now());
  RETURN NEW;
END;
$$ language 'plpgsql';

-- updated_at 자동 업데이트 트리거 생성
DROP TRIGGER IF EXISTS update_diary_entries_updated_at ON diary_entries;
CREATE TRIGGER update_diary_entries_updated_at
  BEFORE UPDATE ON diary_entries
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- 함수 설명
COMMENT ON FUNCTION update_updated_at_column() IS 'updated_at 컬럼을 자동으로 현재 시간으로 업데이트하는 함수';