-- 테스트 및 확인용 쿼리들
-- 설정 완료 후 데이터베이스 상태 확인용

-- 1. 테이블 구조 확인
SELECT 
  column_name, 
  data_type, 
  is_nullable, 
  column_default,
  character_maximum_length
FROM information_schema.columns 
WHERE table_name = 'diary_entries' 
ORDER BY ordinal_position;

-- 2. 인덱스 확인
SELECT 
  i.relname as index_name,
  a.attname as column_name
FROM 
  pg_class t,
  pg_class i,
  pg_index ix,
  pg_attribute a
WHERE 
  t.oid = ix.indrelid
  and i.oid = ix.indexrelid
  and a.attrelid = t.oid
  and a.attnum = ANY(ix.indkey)
  and t.relkind = 'r'
  and t.relname = 'diary_entries'
ORDER BY i.relname, a.attnum;

-- 3. RLS 정책 확인
SELECT 
  schemaname, 
  tablename, 
  policyname, 
  permissive, 
  roles, 
  cmd, 
  qual, 
  with_check 
FROM pg_policies 
WHERE tablename = 'diary_entries';

-- 4. 트리거 확인
SELECT 
  trigger_name,
  event_manipulation,
  action_timing,
  action_statement
FROM information_schema.triggers 
WHERE event_object_table = 'diary_entries';

-- 5. 샘플 데이터 조회 (데이터가 있는 경우)
-- SELECT 
--   id,
--   date,
--   title,
--   LENGTH(original_content) as original_length,
--   LENGTH(generated_content) as generated_length,
--   created_at,
--   updated_at
-- FROM diary_entries 
-- ORDER BY created_at DESC 
-- LIMIT 5;

-- 6. 사용자별 일기 개수 확인 (데이터가 있는 경우)
-- SELECT 
--   user_id,
--   COUNT(*) as diary_count,
--   MIN(date) as first_diary,
--   MAX(date) as last_diary
-- FROM diary_entries 
-- GROUP BY user_id;

-- 7. 최근 7일간 생성된 일기 수 (데이터가 있는 경우)
-- SELECT 
--   DATE(created_at) as date,
--   COUNT(*) as daily_count
-- FROM diary_entries 
-- WHERE created_at >= NOW() - INTERVAL '7 days'
-- GROUP BY DATE(created_at)
-- ORDER BY date DESC;