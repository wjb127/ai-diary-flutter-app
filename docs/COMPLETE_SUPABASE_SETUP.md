# 🔐 완전한 Supabase 설정 가이드 (모바일 배포용)

## 📱 앱 정보
- **Android Package ID**: `com.aidiary.app`
- **iOS Bundle ID**: `com.aidiary.app`
- **앱 이름**: AI 일기

## 🎯 Supabase 대시보드에서 해야 할 설정

### 1. **프로젝트 기본 정보**
1. **Settings** → **General** → **General settings**
2. **Project name**: AI Diary App
3. **Organization**: 본인 계정

### 2. **이메일 인증 설정**
1. **Authentication** → **Providers** → **Email**
2. ✅ `Enable email confirmations` **ON** 
3. ✅ `Enable email change confirmations` **ON**
4. ✅ `Secure email change` **ON**

### 3. **Site URL 설정**
**Authentication** → **URL Configuration**:
- **Site URL**: `https://your-production-url.com` (배포 후)
- **Redirect URLs** 추가:
  ```
  http://localhost:3000/**
  https://your-production-url.com/**
  com.aidiary.app://login-callback/
  ```

### 4. **구글 로그인 설정**
**Authentication** → **Providers** → **Google**:
1. ✅ **Enable sign in with Google** ON
2. **Authorized Client IDs** 추가:
   ```
   949519878688-h2ag7kbhsj18bhcjf5k2p61e4ggkdgls.apps.googleusercontent.com (웹용)
   949519878688-9n5jvlprvjgbdju2e1qngdph21u9a6g8.apps.googleusercontent.com (iOS용)
   949519878688-ANDROID_CLIENT_ID.apps.googleusercontent.com (안드로이드용 - Firebase에서 생성)
   ```

### 5. **애플 로그인 설정** (iOS 전용)
**Authentication** → **Providers** → **Apple**:
1. ✅ **Enable sign in with Apple** ON
2. **Bundle ID**: `com.aidiary.app`

## 🔧 Firebase Console에서 해야 할 설정

### 1. **프로젝트 생성**
1. [Firebase Console](https://console.firebase.google.com/) 접속
2. **프로젝트 추가** → 프로젝트 이름: `ai-diary-app-project`
3. Google Analytics는 **사용 안 함** (선택사항)

### 2. **Android 앱 추가**
1. **프로젝트 개요** → **Android 아이콘** 클릭
2. **Android 패키지 이름**: `com.aidiary.app`
3. **앱 닉네임**: AI Diary Android
4. **SHA-1 인증서** 지문 추가 (선택사항)

### 3. **iOS 앱 추가**
1. **프로젝트 개요** → **iOS 아이콘** 클릭  
2. **iOS 번들 ID**: `com.aidiary.app`
3. **앱 닉네임**: AI Diary iOS

### 4. **구글 로그인 활성화**
1. **Authentication** → **Sign-in method**
2. **Google** 클릭 → **사용 설정** ON
3. **프로젝트 지원 이메일** 선택
4. **저장**

### 5. **OAuth 동의 화면 설정**
**Google Cloud Console**에서:
1. **API 및 서비스** → **OAuth 동의 화면**
2. **외부** 선택 → **만들기**
3. 필수 정보 입력:
   - **앱 이름**: AI 일기
   - **사용자 지원 이메일**: 본인 이메일
   - **개발자 연락처 정보**: 본인 이메일

## 📁 파일 다운로드 및 설정

### 1. **Android 설정 파일**
1. Firebase Console → **프로젝트 설정** → **일반** 탭
2. **Android 앱** 섹션에서 `google-services.json` 다운로드
3. 파일을 `android/app/` 폴더에 복사

### 2. **iOS 설정 파일**
1. Firebase Console → **프로젝트 설정** → **일반** 탭  
2. **iOS 앱** 섹션에서 `GoogleService-Info.plist` 다운로드
3. Xcode에서 `Runner` 프로젝트에 추가 (Copy items if needed 체크)

## 🍎 Apple Developer 설정 (iOS 배포용)

### 1. **App ID 등록**
1. [Apple Developer Console](https://developer.apple.com/) 접속
2. **Certificates, Identifiers & Profiles** → **Identifiers**
3. **App IDs** → **+** 클릭
4. **Bundle ID**: `com.aidiary.app`
5. **Sign in with Apple** 체크박스 **ON**

### 2. **Service ID 생성**
1. **Services IDs** → **+** 클릭
2. **Description**: AI Diary Web Auth
3. **Identifier**: `com.aidiary.app.web`
4. **Sign in with Apple** 체크박스 **ON**
5. **Configure** 클릭:
   - **Primary App ID**: `com.aidiary.app`
   - **Domains and Subdomains**: `your-supabase-project.supabase.co`
   - **Return URLs**: `https://your-supabase-project.supabase.co/auth/v1/callback`

## 🔑 환경변수 설정

### 개발용 실행 명령:
```bash
flutter run --dart-define=SUPABASE_URL=https://your-project-id.supabase.co --dart-define=SUPABASE_ANON_KEY=your-anon-key-here
```

### 배포용 빌드:
```bash
# Android
flutter build appbundle --dart-define=SUPABASE_URL=https://your-project-id.supabase.co --dart-define=SUPABASE_ANON_KEY=your-anon-key-here

# iOS  
flutter build ipa --dart-define=SUPABASE_URL=https://your-project-id.supabase.co --dart-define=SUPABASE_ANON_KEY=your-anon-key-here
```

## 📋 체크리스트

### ✅ Supabase 설정
- [ ] 이메일 인증 활성화
- [ ] 구글 로그인 Provider 활성화
- [ ] 애플 로그인 Provider 활성화 (iOS용)
- [ ] Site URL 및 Redirect URL 설정
- [ ] RLS 정책 확인

### ✅ Firebase 설정
- [ ] Android/iOS 앱 추가
- [ ] 구글 로그인 활성화
- [ ] google-services.json 다운로드 및 배치
- [ ] GoogleService-Info.plist 다운로드 및 배치

### ✅ Apple Developer 설정 (iOS용)
- [ ] App ID 등록 (Sign in with Apple 포함)
- [ ] Service ID 생성 및 구성

### ✅ 앱 설정
- [ ] Package ID 변경 완료 (`com.aidiary.app`)
- [ ] 앱 이름 변경 완료 (AI 일기)
- [ ] URL Scheme 추가 완료 (iOS)

## 🧪 테스트 시나리오

### 1. **이메일 로그인 테스트**
1. 회원가입 → 이메일 확인 → 로그인

### 2. **구글 로그인 테스트**  
1. "Google로 계속하기" 버튼 클릭
2. 구글 계정 선택 → 권한 동의 → 자동 로그인

### 3. **애플 로그인 테스트** (iOS만)
1. "Apple로 계속하기" 버튼 클릭
2. Face ID/Touch ID → 자동 로그인

### 4. **일기 기능 테스트**
1. 로그인 후 일기 작성
2. AI 각색 → 저장 → 다시 불러오기

## 🚀 배포 준비

### Android (Google Play)
```bash
flutter build appbundle --release
```
- 생성 위치: `build/app/outputs/bundle/release/app-release.aab`

### iOS (App Store)
```bash  
flutter build ipa --release
```
- 생성 위치: `build/ios/ipa/ai_diary_app.ipa`

## 📞 문제 해결

### 구글 로그인 실패
- Firebase 설정 파일 확인
- Client ID가 Supabase에 등록되었는지 확인
- SHA-1 인증서 지문 등록 (Android)

### 애플 로그인 실패  
- Service ID 구성 확인
- Return URL이 정확한지 확인
- App ID에 Sign in with Apple 활성화 확인

모든 설정이 완료되면 완전한 소셜 로그인 지원 AI 일기 앱이 됩니다! 🎉