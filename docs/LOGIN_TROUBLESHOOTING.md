# 아이폰 로그인 실패 해결 가이드

## 문제: "로그인 실패(이메일)" 오류

### 1. 환경변수 설정 확인

현재 앱이 기본 플레이스홀더 값을 사용하고 있어 Supabase 연결이 실패합니다.

#### 해결 방법 1: 빌드 시 환경변수 설정
```bash
flutter build ios --release \
  --dart-define=SUPABASE_URL=https://your-project.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=your-anon-key
```

#### 해결 방법 2: 하드코딩 (개발용)
`lib/main.dart` 파일 수정:
```dart
const String kSupabaseUrl = 'https://your-actual-project.supabase.co';
const String kSupabaseAnonKey = 'your-actual-anon-key';
```

### 2. Supabase 프로젝트 설정 확인

1. [Supabase Dashboard](https://app.supabase.com) 접속
2. 프로젝트 선택
3. Settings > API 메뉴에서:
   - Project URL 복사
   - anon public key 복사

### 3. 이메일 인증 설정 확인

1. Supabase Dashboard > Authentication > Providers
2. Email 활성화 확인
3. Settings > Authentication에서:
   - "Enable email confirmations" 설정 확인
   - 개발 중이라면 비활성화 권장

### 4. 네트워크 연결 확인

- Wi-Fi 또는 셀룰러 데이터 연결 확인
- VPN 사용 시 비활성화 후 시도

### 5. 테스트 계정 생성

1. Supabase Dashboard > Authentication > Users
2. "Add user" > "Create new user"
3. 이메일과 비밀번호 입력
4. "Auto Confirm User" 체크

### 6. 로그 확인

Xcode Console에서 다음 로그 확인:
- `🔐 [AUTH]` 로 시작하는 인증 관련 로그
- Supabase 초기화 실패 메시지

### 7. 임시 해결책: 게스트 모드 사용

로그인 문제가 해결될 때까지:
1. "게스트로 시작하기" 버튼 사용
2. 로컬에서만 데이터 저장 (클라우드 동기화 없음)

## 빠른 설정 스크립트

```bash
#!/bin/bash
# setup.sh

# Supabase 프로젝트 정보 입력
read -p "Supabase URL을 입력하세요: " SUPABASE_URL
read -p "Supabase Anon Key를 입력하세요: " SUPABASE_ANON_KEY

# iOS 빌드 및 설치
flutter build ios --release \
  --dart-define=SUPABASE_URL=$SUPABASE_URL \
  --dart-define=SUPABASE_ANON_KEY=$SUPABASE_ANON_KEY

# 디바이스에 설치
flutter install
```

## 자주 발생하는 오류 메시지

### "Invalid login credentials"
- 이메일 또는 비밀번호가 잘못됨
- 계정이 존재하지 않음
- 이메일 인증이 완료되지 않음

### "Connection error"
- 네트워크 연결 문제
- Supabase URL이 잘못됨
- 방화벽 또는 프록시 차단

### "Rate limit exceeded"
- 너무 많은 로그인 시도
- 5분 후 다시 시도

## 추가 도움말

문제가 지속되면:
1. Supabase 프로젝트 새로 생성
2. 최소한의 설정으로 테스트
3. GitHub Issues에 문제 보고: https://github.com/wjb127/ai-diary-flutter-app/issues