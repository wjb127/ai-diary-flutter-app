-- 🧹 데이터베이스 정리 및 검증 스크립트
-- 이 스크립트로 불필요한 테이블과 enum 타입을 확인하고 정리할 수 있습니다

-- ============================================
-- 1. 현재 데이터베이스 상태 확인
-- ============================================

-- 1.1) 모든 테이블 목록 확인
SELECT 
    schemaname,
    tablename,
    tableowner
FROM pg_tables 
WHERE schemaname NOT IN ('pg_catalog', 'information_schema')
ORDER BY schemaname, tablename;

-- 1.2) 모든 ENUM 타입 확인 (⚠️ 주의: enum은 삭제가 까다로움)
SELECT 
    n.nspname as schema,
    t.typname as enum_name,
    array_agg(e.enumlabel ORDER BY e.enumsortorder) as enum_values
FROM pg_type t 
JOIN pg_enum e ON t.oid = e.enumtypid  
JOIN pg_catalog.pg_namespace n ON n.oid = t.typnamespace
WHERE n.nspname NOT IN ('pg_catalog', 'information_schema')
GROUP BY n.nspname, t.typname;

-- 1.3) diary_entries 테이블의 정확한 구조 확인
SELECT 
    column_name,
    data_type,
    udt_name,  -- enum 타입이면 여기에 표시됨
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_name = 'diary_entries'
ORDER BY ordinal_position;

-- ============================================
-- 2. 사용하지 않는 테이블 찾기
-- ============================================

-- 2.1) 빈 테이블 찾기 (데이터가 없는 테이블)
SELECT 
    schemaname,
    tablename,
    n_live_tup as row_count
FROM pg_stat_user_tables
WHERE schemaname = 'public'
    AND n_live_tup = 0
    AND tablename != 'diary_entries'  -- 우리가 사용할 테이블 제외
ORDER BY tablename;

-- 2.2) 외래키 의존성 확인 (삭제 전 확인 필수!)
SELECT
    tc.table_name AS referencing_table,
    kcu.column_name AS referencing_column,
    ccu.table_name AS referenced_table,
    ccu.column_name AS referenced_column
FROM information_schema.table_constraints AS tc
JOIN information_schema.key_column_usage AS kcu
    ON tc.constraint_name = kcu.constraint_name
JOIN information_schema.constraint_column_usage AS ccu
    ON ccu.constraint_name = tc.constraint_name
WHERE tc.constraint_type = 'FOREIGN KEY'
    AND tc.table_schema = 'public';

-- ============================================
-- 3. ENUM 타입 문제 확인
-- ============================================

-- 3.1) diary_entries가 enum을 사용하는지 확인
SELECT 
    a.attname as column_name,
    t.typname as type_name,
    CASE 
        WHEN t.typtype = 'e' THEN 'ENUM TYPE - 주의필요!'
        ELSE 'Safe'
    END as type_check
FROM pg_attribute a
JOIN pg_type t ON a.atttypid = t.oid
WHERE a.attrelid = 'diary_entries'::regclass
    AND a.attnum > 0
    AND NOT a.attisdropped;

-- 3.2) 사용되지 않는 enum 타입 찾기
WITH used_enums AS (
    SELECT DISTINCT 
        a.atttypid
    FROM pg_attribute a
    JOIN pg_class c ON a.attrelid = c.oid
    WHERE a.atttypid IN (
        SELECT oid FROM pg_type WHERE typtype = 'e'
    )
)
SELECT 
    t.typname as unused_enum,
    n.nspname as schema
FROM pg_type t
JOIN pg_namespace n ON t.typnamespace = n.oid
WHERE t.typtype = 'e'
    AND t.oid NOT IN (SELECT atttypid FROM used_enums)
    AND n.nspname = 'public';

-- ============================================
-- 4. 정리 스크립트 (주석 해제하여 실행)
-- ============================================

-- ⚠️ 주의: 아래 명령들은 매우 신중하게 실행하세요!
-- 실행 전 반드시 백업을 하시기 바랍니다.

-- 4.1) 불필요한 테이블 삭제 예시
-- DROP TABLE IF EXISTS old_table_name CASCADE;

-- 4.2) 사용하지 않는 enum 타입 삭제
-- 먼저 enum을 사용하는 모든 컬럼을 text로 변경 후 삭제
-- ALTER TABLE table_name ALTER COLUMN column_name TYPE text;
-- DROP TYPE IF EXISTS enum_type_name;

-- 4.3) 안전한 enum 대체 방법 (CHECK 제약 사용)
-- 예시: status enum 대신 text + check constraint 사용
-- ALTER TABLE diary_entries 
-- ADD COLUMN status text DEFAULT 'draft'
-- CHECK (status IN ('draft', 'published', 'archived'));

-- ============================================
-- 5. 최종 검증
-- ============================================

-- 5.1) diary_entries 테이블만 있는지 확인
SELECT 
    COUNT(*) as table_count,
    string_agg(tablename, ', ') as table_list
FROM pg_tables 
WHERE schemaname = 'public'
    AND tablename NOT LIKE 'pg_%'
    AND tablename NOT LIKE 'sql_%';

-- 5.2) enum 타입이 없는지 확인
SELECT 
    COUNT(*) as enum_count,
    string_agg(typname, ', ') as enum_list
FROM pg_type 
WHERE typtype = 'e' 
    AND typnamespace = (SELECT oid FROM pg_namespace WHERE nspname = 'public');

-- 5.3) diary_entries 테이블 최종 상태
SELECT 
    'diary_entries' as table_name,
    COUNT(*) as column_count,
    string_agg(column_name || '(' || data_type || ')', ', ' ORDER BY ordinal_position) as columns
FROM information_schema.columns 
WHERE table_name = 'diary_entries';