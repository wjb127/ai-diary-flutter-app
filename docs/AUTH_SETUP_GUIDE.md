# 🔐 로그인/회원가입 설정 가이드

## 📋 완료된 작업
- ✅ 로그인/회원가입 화면 구현
- ✅ 인증 상태 기반 라우팅 보호
- ✅ 개선된 달력 UI (접고 펼치기)
- ✅ 로그아웃 기능
- ✅ 로깅 시스템

## 🎯 이제 해야 할 Supabase 설정

### 1. **Supabase 이메일 인증 활성화**

#### Supabase 대시보드에서:
1. **Authentication** → **Providers** 메뉴
2. **Email** 섹션에서:
   - `Enable email confirmations` **ON** (이메일 확인)
   - `Enable email change confirmations` **ON**
   - `Secure email change` **ON** 

3. **Site URL 설정**:
   - Development: `http://localhost:3000`
   - Production: 실제 배포된 URL

4. **Email Templates 설정** (선택사항):
   - Confirmation 이메일 커스텀화
   - 회사 로고, 색상 변경 가능

### 2. **익명 인증 비활성화** (선택사항)
1. **Authentication** → **Providers**
2. **Anonymous** 토글을 **OFF**로 변경
3. **Save** 클릭

### 3. **환경변수 설정**

#### API Keys 복사:
1. **Settings** → **API** 메뉴
2. 복사할 값들:
   ```
   Project URL: https://your-project-id.supabase.co
   anon key: eyJhbGci...
   ```

#### 앱 실행:
```bash
flutter run \
  --dart-define=SUPABASE_URL=https://your-project-id.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=eyJhbGci...your-key-here
```

## 🚀 테스트 시나리오

### 1. **회원가입 테스트**
1. 앱 실행 → 회원가입 탭
2. 실제 이메일 주소 입력
3. 비밀번호 입력 (최소 6자)
4. 회원가입 클릭
5. **이메일 확인 링크 클릭** ← 중요!

### 2. **로그인 테스트**  
1. 이메일 확인 후 로그인 탭
2. 가입한 이메일/비밀번호 입력
3. 로그인 성공 → 홈 화면으로 이동

### 3. **일기 저장 테스트**
1. "일기 작성 시작하기" 클릭
2. 날짜 클릭 → 달력 펼쳐짐
3. 제목과 내용 입력
4. AI 각색 → 저장
5. **성공 메시지 확인**

### 4. **로그아웃 테스트**
1. 프로필 → 로그아웃
2. 로그인 화면으로 이동

## 🔍 문제 해결

### 로그가 보이지 않는 경우:
```bash
flutter run --web-port 3000 --dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...
```
브라우저 개발자 도구 → Console 탭에서 로그 확인

### 일반적인 오류들:

#### "Invalid login credentials"
- 이메일 확인 링크를 클릭했는지 확인
- 비밀번호가 정확한지 확인

#### "Email not confirmed"
- Supabase에서 `Enable email confirmations`가 ON인 경우
- 이메일 확인 링크 클릭 필요

#### "User not found"  
- 회원가입이 완료되지 않음
- Supabase 대시보드 → Authentication → Users에서 확인

#### 저장 실패:
- 로그인이 안 되어 있음
- RLS 정책 문제 (이미 해결됨)

## 📊 Supabase 대시보드에서 확인

### Authentication → Users
- 가입한 사용자 목록 확인
- 이메일 확인 상태 체크

### Table Editor → diary_entries  
- 저장된 일기 확인
- user_id와 실제 사용자 매칭 확인

### Logs
- 실시간 로그 확인
- API 호출 내역 추적

## 🎯 완료 후 예상 동작

1. **첫 실행**: 로그인 화면
2. **회원가입**: 이메일 확인 → 자동 로그인 유도
3. **로그인 후**: 홈 화면 → 일기 작성 가능
4. **일기 저장**: 성공 메시지 + DB에 저장 확인
5. **로그아웃**: 다시 로그인 화면으로

모든 설정이 완료되면 완전한 회원제 일기 서비스가 됩니다! 🎉