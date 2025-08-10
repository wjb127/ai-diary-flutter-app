# SQL 스크립트 실행 가이드

이 디렉토리에는 Supabase 데이터베이스 설정에 필요한 SQL 스크립트들이 포함되어 있습니다.

## 📋 실행 순서

**반드시 아래 순서대로 실행하세요:**

### 1. `01_create_tables.sql`
- 기본 테이블 생성
- diary_entries 테이블과 인덱스 생성
- 컬럼 설명 추가

### 2. `02_create_triggers.sql`  
- updated_at 자동 업데이트 함수 생성
- 트리거 설정

### 3. `03_setup_rls.sql`
- Row Level Security 활성화
- 사용자 권한 정책 설정
- 데이터 보안 정책 적용

### 4. `04_test_queries.sql` (선택사항)
- 설정 확인용 쿼리
- 테이블 구조, 인덱스, 정책 확인
- 데이터 확인용 쿼리

## 🚀 실행 방법

### Supabase 대시보드에서 실행:
1. [Supabase Dashboard](https://app.supabase.com) 로그인
2. 프로젝트 선택
3. **SQL Editor** 메뉴 클릭
4. **New query** 버튼 클릭
5. 각 파일의 내용을 복사해서 붙여넣기
6. **RUN** 버튼 클릭

### 실행 결과 확인:
- 성공 시: "Success. No rows returned" 또는 결과 테이블 표시
- 실패 시: 오류 메시지 확인 후 문제 해결

## ⚠️ 주의사항

- **순서대로 실행**: 의존성이 있으므로 순서를 지켜주세요
- **재실행 안전**: 모든 스크립트는 재실행해도 안전하도록 작성됨
- **오류 발생 시**: 각 단계별로 오류를 확인하고 해결 후 다음 단계 진행

## 🔍 문제 해결

### 일반적인 오류:
- `relation "diary_entries" does not exist` → 01번 스크립트 먼저 실행
- `function update_updated_at_column() does not exist` → 02번 스크립트 실행
- `policy "..." already exists` → 무시해도 됨 (재실행 시 정상)

### 데이터 확인:
```sql
-- 테이블이 생성되었는지 확인
SELECT table_name FROM information_schema.tables 
WHERE table_schema = 'public' AND table_name = 'diary_entries';

-- RLS가 활성화되었는지 확인  
SELECT relname, relrowsecurity FROM pg_class 
WHERE relname = 'diary_entries';
```