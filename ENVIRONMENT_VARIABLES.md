# 환경변수 설정 가이드

> ⚠️ **보안 경고**: 이 문서의 키 값들을 공개 저장소에 커밋하지 마세요!

## Vercel 환경변수 설정

### 1. Vercel 대시보드 접속
1. https://vercel.com 로그인
2. `ai-diary-flutter-app` 프로젝트 선택
3. **Settings** 탭 클릭
4. **Environment Variables** 섹션으로 이동

### 2. 환경변수 추가
다음 변수들을 하나씩 추가하세요:

#### SUPABASE_URL
```
https://jihhsiijrxhazbxhoirl.supabase.co
```

#### SUPABASE_ANON_KEY
```
eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImppaGhzaWlqcnhoYXpieGhvaXJsIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTQ3MjQzMjcsImV4cCI6MjA3MDMwMDMyN30.sd8iZ2kPlAR9QTfvreCUZKWtziEnctPLHlYrPOpxyXU
```

### 3. 재배포
1. 환경변수 저장 후
2. **Deployments** 탭으로 이동
3. 최신 배포 옆 `...` 메뉴 클릭
4. **Redeploy** 선택

## Supabase Service Role Key (서버사이드 전용)

> ⚠️ **경고**: 이 키는 Edge Functions에서만 사용하세요. 클라이언트 코드에 절대 노출하지 마세요!

```
eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImppaGhzaWlqcnhoYXpieGhvaXJsIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1NDcyNDMyNywiZXhwIjoyMDcwMzAwMzI3fQ.gHQxZM40nwxgYFjYkWbkb5G-QPH5nvECtEO1FpCqJ8Q
```

## 로컬 개발 환경

`.env.local` 파일이 프로젝트 루트에 생성되어 있습니다.

### Flutter 실행
```bash
flutter run --dart-define-from-file=.env.local
```

### 웹 빌드 테스트
```bash
flutter build web --dart-define=SUPABASE_URL=https://jihhsiijrxhazbxhoirl.supabase.co --dart-define=SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImppaGhzaWlqcnhoYXpieGhvaXJsIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTQ3MjQzMjcsImV4cCI6MjA3MDMwMDMyN30.sd8iZ2kPlAR9QTfvreCUZKWtziEnctPLHlYrPOpxyXU
```

## 보안 체크리스트
- [ ] `.env.local` 파일이 `.gitignore`에 포함되어 있는지 확인
- [ ] Service Role Key를 클라이언트 코드에 사용하지 않았는지 확인
- [ ] 환경변수가 하드코딩되지 않았는지 확인
- [ ] 프로덕션 배포 전 모든 환경변수가 설정되었는지 확인