-- 🔍 현재 상태 확인 (이것만 실행해서 상태 체크!)
-- 실행 결과를 보고 문제가 있는지 확인

SELECT 
    'diary_entries 테이블' as item,
    CASE WHEN EXISTS (SELECT 1 FROM pg_tables WHERE tablename = 'diary_entries') 
         THEN '✅ 생성됨' ELSE '❌ 없음' END as status
UNION ALL
SELECT 
    'RLS 활성화' as item,
    CASE WHEN relrowsecurity 
         THEN '✅ 활성화' ELSE '❌ 비활성화' END as status
FROM pg_class WHERE relname = 'diary_entries'
UNION ALL
SELECT 
    'RLS 정책 개수' as item,
    COUNT(*)::text || '개' as status
FROM pg_policies WHERE tablename = 'diary_entries'
UNION ALL
SELECT 
    '익명 인증 테스트' as item,
    CASE WHEN auth.uid() IS NOT NULL 
         THEN '✅ 작동중' ELSE '⚠️ 익명인증 설정필요' END as status;