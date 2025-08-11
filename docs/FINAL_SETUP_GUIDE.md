# 🚀 AI 일기 앱 최종 설정 가이드 (RevenueCat + Supabase)

## 📱 앱 정보
- **Android Package ID**: `com.aidiary.app`
- **iOS Bundle ID**: `com.aidiary.app`  
- **앱 이름**: "AI 일기"

## 🎯 1. Supabase 설정

### 1-1. 프로젝트 설정
1. [Supabase Dashboard](https://supabase.com/dashboard) 접속
2. **New project** 생성

### 1-2. Authentication 설정
**Authentication** → **Providers**:

#### 📧 Email 설정:
- ✅ `Enable email confirmations` **ON**
- ✅ `Enable email change confirmations` **ON**  
- ✅ `Secure email change` **ON**

#### 🔍 Google OAuth 설정:
1. ✅ `Enable sign in with Google` **ON**
2. **Client ID** (선택사항): 웹용만 있으면 충분
3. **Client Secret**: Google Cloud Console에서 생성

#### 🍎 Apple OAuth 설정 (iOS):
1. ✅ `Enable sign in with Apple` **ON**  
2. **Service ID**: Apple Developer Console에서 생성
3. **Team ID**: Apple Developer 팀 ID
4. **Key ID**: Apple Developer Console에서 생성  
5. **Private Key**: .p8 파일 내용

### 1-3. URL Configuration
**Authentication** → **URL Configuration**:
```
Site URL: https://your-production-url.com
Redirect URLs:
  - http://localhost:3000/**
  - https://your-production-url.com/**
  - com.aidiary.app://login-callback/
```

## 💳 2. RevenueCat 설정

### 2-1. 프로젝트 생성
1. [RevenueCat Dashboard](https://app.revenuecat.com/) 접속
2. **New Project** 생성: "AI Diary App"

### 2-2. 앱 추가
#### Android 앱:
- **Package Name**: `com.aidiary.app`
- **Google Play Service Account**: JSON 키 업로드

#### iOS 앱:  
- **Bundle ID**: `com.aidiary.app`
- **App Store Connect API Key**: 생성 및 업로드

### 2-3. 상품 생성
**Products** 섹션에서:
1. **월간 구독**:
   - Product ID: `ai_diary_monthly`
   - Price: ₩4,500/월
   
2. **연간 구독**:
   - Product ID: `ai_diary_yearly` 
   - Price: ₩39,000/년

### 2-4. Entitlement 설정
**Entitlements** 섹션에서:
- Entitlement ID: `premium`
- 위 두 상품 모두 연결

## 🔐 3. Apple Developer 설정 (iOS만)

### 3-1. App ID 등록
1. [Apple Developer Console](https://developer.apple.com/) 접속
2. **Certificates, Identifiers & Profiles** → **Identifiers**
3. **App IDs** → **+** 클릭
4. **Bundle ID**: `com.aidiary.app`
5. **Capabilities** 체크:
   - ✅ Sign in with Apple
   - ✅ In-App Purchase

### 3-2. Service ID (Apple OAuth)
1. **Services IDs** → **+** 클릭  
2. **Description**: AI Diary OAuth
3. **Identifier**: `com.aidiary.app.oauth`
4. **Configure** 클릭:
   - **Domains**: `your-supabase-project.supabase.co`
   - **Return URLs**: `https://your-supabase-project.supabase.co/auth/v1/callback`

### 3-3. Key 생성 (Apple OAuth)
1. **Keys** → **+** 클릭
2. **Key Name**: AI Diary Apple OAuth
3. ✅ **Sign in with Apple** 체크
4. **Configure** → Primary App ID 선택
5. **Continue** → **Register**
6. **.p8 파일 다운로드** (한 번만 가능!)

## 🔑 4. 환경변수 설정

### 개발용 실행:
```bash
flutter run \
  --dart-define=SUPABASE_URL=https://your-project-id.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9... \
  --dart-define=REVENUECAT_API_KEY=appl_YOUR_API_KEY
```

### 배포용 빌드:
```bash
# Android
flutter build appbundle \
  --dart-define=SUPABASE_URL=https://your-project-id.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=your-anon-key \
  --dart-define=REVENUECAT_API_KEY=goog_YOUR_API_KEY

# iOS  
flutter build ipa \
  --dart-define=SUPABASE_URL=https://your-project-id.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=your-anon-key \
  --dart-define=REVENUECAT_API_KEY=appl_YOUR_API_KEY
```

## 📋 5. 체크리스트

### ✅ Supabase 설정:
- [ ] 프로젝트 생성
- [ ] 이메일 인증 활성화  
- [ ] 구글 OAuth Provider 활성화
- [ ] 애플 OAuth Provider 활성화 (iOS)
- [ ] Redirect URLs 설정

### ✅ RevenueCat 설정:
- [ ] 프로젝트 및 앱 생성
- [ ] 월간/연간 구독 상품 생성
- [ ] Premium Entitlement 생성
- [ ] Store 연동 (Google Play/App Store)

### ✅ Apple Developer 설정 (iOS):
- [ ] App ID 등록 (Sign in with Apple + In-App Purchase)
- [ ] Service ID 생성 및 구성
- [ ] OAuth Key 생성 및 다운로드

### ✅ 앱 설정:
- [ ] Package/Bundle ID 변경 완료
- [ ] 환경변수 설정 완료

## 🧪 6. 테스트 시나리오

### 인증 테스트:
1. ✅ 이메일 회원가입 → 확인 → 로그인
2. ✅ 구글 로그인 (Supabase OAuth)  
3. ✅ 애플 로그인 (iOS만)

### 구독 테스트:
1. ✅ 무료 사용자 일기 제한 (월 10개)
2. ✅ 구독 화면 표시
3. ✅ 샌드박스 구매 테스트
4. ✅ 구매 복원 테스트  

### 일기 기능 테스트:
1. ✅ 일기 작성 → AI 각색 → 저장
2. ✅ 날짜별 일기 불러오기
3. ✅ 프리미엄 무제한 기능

## 🚀 7. 배포

### Google Play Store:
```bash
flutter build appbundle --release --dart-define=...
```
- 생성 위치: `build/app/outputs/bundle/release/app-release.aab`

### Apple App Store:
```bash
flutter build ipa --release --dart-define=...
```  
- 생성 위치: `build/ios/ipa/ai_diary_app.ipa`

## 🔥 주요 특징

### ✨ 구현된 기능들:
- 📧 **완전한 인증 시스템**: 이메일, 구글, 애플 로그인  
- 💳 **프리미엄 구독**: RevenueCat 연동, 월간/연간 플랜
- 🤖 **AI 일기 각색**: Supabase Edge Functions
- 📅 **날짜별 일기 관리**: 접고 펼치는 달력 UI
- 🔒 **프리미엄 제한**: 무료 사용자 월 10개 제한
- 🎨 **현대적 UI/UX**: Material Design 3 스타일

### 🔧 기술 스택:
- **Backend**: Supabase (Database, Auth, Edge Functions)
- **구독 관리**: RevenueCat
- **인증**: Supabase OAuth (Firebase 미사용)  
- **상태 관리**: Provider + GoRouter
- **테스트**: TDD with Mocktail

## 📞 지원

문제 발생 시 각 서비스별 문서를 참고해주세요:
- [Supabase Docs](https://supabase.com/docs)
- [RevenueCat Docs](https://docs.revenuecat.com/)
- [Apple Developer Guide](https://developer.apple.com/documentation/)

**Firebase를 사용하지 않아도 완벽하게 작동하는 구조입니다!** 🎉