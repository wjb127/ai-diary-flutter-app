# AI 일기장 📝✨

Flutter와 Supabase, Claude AI를 활용한 스마트 일기 앱입니다. 사용자가 작성한 일상의 이야기를 AI가 아름답고 감동적으로 각색해드립니다.

## 🌟 주요 기능

- **📅 날짜별 일기 작성**: 직관적인 달력 인터페이스로 원하는 날짜의 일기를 작성
- **🤖 AI 각색**: Claude AI가 사용자의 일상을 따뜻하고 아름다운 문체로 재구성
- **💾 자동 저장**: Supabase 클라우드 데이터베이스에 안전하게 저장
- **📱 아름다운 UI**: 모던하고 직관적인 사용자 인터페이스
- **🔐 보안**: Row Level Security(RLS)로 개인 정보 보호

## 🛠 기술 스택

- **Frontend**: Flutter (Dart)
- **Backend**: Supabase
  - 데이터베이스: PostgreSQL
  - 인증: Supabase Auth
  - Edge Functions: Deno + TypeScript
- **AI**: Claude 3 Sonnet (Anthropic)
- **상태 관리**: Provider
- **내비게이션**: GoRouter

## 🚀 시작하기

### 1. 사전 요구사항

- Flutter SDK (3.27.1 이상)
- Android Studio / VS Code
- Supabase 계정
- Anthropic API 키 (Claude)

### 2. 설치

```bash
# 저장소 클론
git clone https://github.com/wjb127/ai-diary-flutter-app.git
cd ai-diary-flutter-app

# 의존성 설치
flutter pub get
```

### 3. Supabase 설정

1. [Supabase](https://supabase.com)에서 새 프로젝트 생성
2. `SUPABASE_SETUP.md` 파일의 가이드를 따라 데이터베이스와 Edge Functions 설정
3. 환경 변수 설정:

```bash
flutter run --dart-define=SUPABASE_URL=your_supabase_url \
           --dart-define=SUPABASE_ANON_KEY=your_anon_key
```

### 4. 실행

```bash
# 디버그 모드로 실행
flutter run

# 릴리즈 모드로 빌드
flutter build apk --release
```

## 📁 프로젝트 구조

```
lib/
├── main.dart              # 앱 진입점
├── models/                # 데이터 모델
│   └── diary_model.dart
├── screens/               # 화면 컴포넌트
│   ├── main_screen.dart   # 메인 네비게이션
│   ├── home_screen.dart   # 홈(랜딩) 페이지
│   ├── diary_screen.dart  # AI 일기장
│   ├── profile_screen.dart
│   └── subscription_screen.dart
└── services/              # 비즈니스 로직
    ├── auth_service.dart
    └── diary_service.dart
```

## 🔒 보안 고려사항

- Supabase Row Level Security(RLS) 적용
- API 키는 환경 변수로 관리
- Edge Functions에서 서버사이드 API 호출
- 사용자별 데이터 격리

## 🤝 기여하기

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 라이선스

이 프로젝트는 MIT 라이선스 하에 배포됩니다.

---

Made with ❤️ by Claude Code & Flutter
