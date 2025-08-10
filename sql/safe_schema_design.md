# 🛡️ 안전한 데이터베이스 설계 가이드

## ⚠️ ENUM 타입 문제와 해결책

### 왜 ENUM이 문제가 되는가?
1. **수정이 매우 어려움**: 값 추가는 가능하지만 삭제/수정은 거의 불가능
2. **마이그레이션 지옥**: enum 값 변경 시 모든 데이터 마이그레이션 필요
3. **Flutter/Dart 호환성**: Supabase 클라이언트에서 enum 처리가 복잡함
4. **테스트 어려움**: enum 값 변경 시 모든 테스트 수정 필요

### ✅ 권장 해결책: TEXT + CHECK 제약

```sql
-- ❌ 나쁜 예시 (ENUM 사용)
CREATE TYPE diary_status AS ENUM ('draft', 'published', 'archived');
ALTER TABLE diary_entries ADD COLUMN status diary_status;

-- ✅ 좋은 예시 (TEXT + CHECK 사용)
ALTER TABLE diary_entries 
ADD COLUMN status TEXT DEFAULT 'draft'
CHECK (status IN ('draft', 'published', 'archived'));
```

### 장점:
- 값 추가/삭제가 CHECK 제약 수정만으로 가능
- Flutter에서 일반 String으로 처리
- 테스트와 마이그레이션이 쉬움

## 🗑️ 불필요한 테이블 예방

### 현재 앱에 필요한 테이블 (최소한의 구조)
```
public.diary_entries  -- 일기 데이터 (현재 이것만 필요!)
```

### 향후 추가 가능한 테이블 (필요시에만)
```
public.user_profiles     -- 사용자 프로필 (구독 기능 추가 시)
public.ai_prompts        -- AI 프롬프트 템플릿 (고급 기능)
public.diary_tags        -- 태그 기능 (검색 기능 추가 시)
```

### 테이블 생성 전 체크리스트
- [ ] 이 테이블이 정말 필요한가?
- [ ] 기존 테이블에 컬럼 추가로 해결 가능한가?
- [ ] ENUM 대신 TEXT + CHECK를 사용했는가?
- [ ] 외래키 관계가 명확한가?
- [ ] RLS 정책을 설정했는가?

## 🔍 정기적인 데이터베이스 청소

### 월 1회 실행 권장 쿼리
```sql
-- 1. 사용하지 않는 테이블 확인
SELECT tablename, n_live_tup as rows
FROM pg_stat_user_tables
WHERE schemaname = 'public' 
  AND n_live_tup = 0;

-- 2. 사용하지 않는 인덱스 확인
SELECT indexname, idx_scan as scans
FROM pg_stat_user_indexes
WHERE idx_scan = 0;

-- 3. 사용하지 않는 enum 확인
SELECT typname FROM pg_type 
WHERE typtype = 'e' 
  AND typnamespace = 'public'::regnamespace;
```

## 💡 Best Practices

### 1. 상태 관리
```sql
-- 미래 확장성을 고려한 설계
ALTER TABLE diary_entries 
ADD COLUMN visibility TEXT DEFAULT 'private'
CHECK (visibility IN ('private', 'public', 'shared'));

-- 나중에 값 추가가 쉬움
ALTER TABLE diary_entries 
DROP CONSTRAINT diary_entries_visibility_check;
ALTER TABLE diary_entries 
ADD CONSTRAINT diary_entries_visibility_check 
CHECK (visibility IN ('private', 'public', 'shared', 'friends_only'));
```

### 2. 소프트 삭제 패턴
```sql
-- 데이터를 실제로 삭제하지 않고 표시만
ALTER TABLE diary_entries 
ADD COLUMN deleted_at TIMESTAMPTZ DEFAULT NULL;

-- 삭제된 항목 제외하는 뷰
CREATE VIEW active_diary_entries AS
SELECT * FROM diary_entries 
WHERE deleted_at IS NULL;
```

### 3. 메타데이터 저장 (JSON)
```sql
-- 유연한 메타데이터 저장 (enum 대신)
ALTER TABLE diary_entries 
ADD COLUMN metadata JSONB DEFAULT '{}';

-- 예시: 기분, 날씨, 태그 등
UPDATE diary_entries 
SET metadata = jsonb_build_object(
  'mood', 'happy',
  'weather', 'sunny',
  'tags', ARRAY['travel', 'family']
);
```

## 🚨 절대 하지 말아야 할 것들

1. **ENUM 타입 생성** - 대신 TEXT + CHECK 사용
2. **CASCADE DELETE 없는 외래키** - 고아 데이터 방지
3. **RLS 없는 테이블** - 보안 취약점
4. **인덱스 없는 외래키** - 성능 저하
5. **용도 불명확한 테이블 생성** - 관리 부담 증가

## 📊 현재 스키마 상태 (안전함)

```
diary_entries 테이블:
- ✅ ENUM 사용 안 함
- ✅ 명확한 용도
- ✅ RLS 설정됨
- ✅ 적절한 인덱스
- ✅ CASCADE DELETE 설정
```

이 구조를 유지하면서 필요한 기능만 추가하시면 됩니다!