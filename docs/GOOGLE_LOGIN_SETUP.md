# Google 로그인 완전 구현 가이드

## 1. Google Cloud Console 설정

### 1.1 프로젝트 생성
1. [Google Cloud Console](https://console.cloud.google.com) 접속
2. 새 프로젝트 생성 또는 기존 프로젝트 선택
3. 프로젝트 이름: "AI Diary App" (예시)

### 1.2 OAuth 동의 화면 설정
1. **API 및 서비스 > OAuth 동의 화면**
2. User Type: External 선택
3. 앱 정보 입력:
   - 앱 이름: AI 일기장
   - 사용자 지원 이메일: your-email@gmail.com
   - 앱 도메인: https://ai-diary-flutter-app.vercel.app
   - 개발자 연락처 정보: your-email@gmail.com
4. 범위 추가:
   - email
   - profile
   - openid

### 1.3 OAuth 2.0 클라이언트 ID 생성

#### iOS 클라이언트
1. **사용자 인증 정보 > 사용자 인증 정보 만들기 > OAuth 클라이언트 ID**
2. 애플리케이션 유형: **iOS**
3. 번들 ID: `com.test.aidiary` (또는 실제 번들 ID)
4. 생성된 클라이언트 ID 저장

#### Android 클라이언트
1. 애플리케이션 유형: **Android**
2. 패키지 이름: `com.aidiary.app`
3. SHA-1 인증서 지문:
   ```bash
   # Debug SHA-1
   keytool -list -v \
     -keystore ~/.android/debug.keystore \
     -alias androiddebugkey \
     -storepass android \
     -keypass android
   
   # Release SHA-1
   keytool -list -v \
     -keystore [your-keystore-path] \
     -alias [your-alias]
   ```

#### 웹 클라이언트
1. 애플리케이션 유형: **웹 애플리케이션**
2. 이름: "AI Diary Web"
3. 승인된 JavaScript 원본:
   - `http://localhost:3000`
   - `https://ai-diary-flutter-app.vercel.app`
4. 승인된 리디렉션 URI:
   - `https://jihhsiijrxhazbxhoirl.supabase.co/auth/v1/callback`

## 2. iOS 설정

### 2.1 GoogleService-Info.plist 다운로드
1. Google Cloud Console에서 iOS 클라이언트 선택
2. plist 파일 다운로드
3. `ios/Runner/` 폴더에 추가
4. Xcode에서 프로젝트에 추가 (Add Files to "Runner")

### 2.2 Info.plist 수정
`ios/Runner/Info.plist`에 추가:
```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleURLSchemes</key>
        <array>
            <!-- REVERSED_CLIENT_ID from GoogleService-Info.plist -->
            <string>com.googleusercontent.apps.YOUR_REVERSED_CLIENT_ID</string>
        </array>
    </dict>
</array>
```

### 2.3 iOS 최소 버전 설정
`ios/Podfile`:
```ruby
platform :ios, '12.0'
```

## 3. Android 설정

### 3.1 google-services.json 다운로드
1. Google Cloud Console에서 Android 클라이언트 선택
2. JSON 파일 다운로드
3. `android/app/` 폴더에 추가

### 3.2 Gradle 설정
`android/build.gradle`:
```gradle
buildscript {
    dependencies {
        classpath 'com.google.gms:google-services:4.4.0'
    }
}
```

`android/app/build.gradle`:
```gradle
apply plugin: 'com.google.gms.google-services'

android {
    defaultConfig {
        minSdkVersion 21
    }
}
```

## 4. Flutter 코드 수정

### 4.1 auth_service.dart
```dart
Future<void> signInWithGoogle() async {
  try {
    if (kIsWeb) {
      // 웹에서는 Supabase OAuth 사용
      await _supabase.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: kIsWeb 
          ? 'https://ai-diary-flutter-app.vercel.app/auth/callback'
          : null,
      );
    } else {
      // 모바일에서는 Google Sign-In SDK 사용
      const webClientId = 'YOUR_WEB_CLIENT_ID.apps.googleusercontent.com';
      
      final GoogleSignIn googleSignIn = GoogleSignIn(
        scopes: ['email', 'profile'],
        serverClientId: webClientId, // 중요: 웹 클라이언트 ID 사용
      );
      
      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        throw Exception('구글 로그인 취소됨');
      }
      
      final googleAuth = await googleUser.authentication;
      final idToken = googleAuth.idToken;
      final accessToken = googleAuth.accessToken;
      
      if (idToken == null) {
        throw Exception('구글 인증 토큰을 가져올 수 없습니다');
      }
      
      // Supabase에 토큰으로 로그인
      await _supabase.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );
    }
    
    _isGuestMode = false;
    notifyListeners();
  } catch (e) {
    print('구글 로그인 오류: $e');
    rethrow;
  }
}
```

## 5. Supabase 설정

### 5.1 Google Provider 활성화
1. [Supabase Dashboard](https://app.supabase.com) 접속
2. Authentication > Providers > Google
3. Enable Google 체크
4. 입력 필드:
   - **Client ID**: 웹 클라이언트 ID
   - **Client Secret**: 웹 클라이언트 Secret
5. Callback URL 복사 (Google Console에 추가 필요)

### 5.2 Authorized Domains 설정
Authentication > URL Configuration:
- Site URL: `https://ai-diary-flutter-app.vercel.app`
- Redirect URLs:
  - `https://ai-diary-flutter-app.vercel.app/**`
  - `com.test.aidiary://login-callback`

## 6. 테스트 체크리스트

### iOS 테스트
- [ ] GoogleService-Info.plist 파일 존재 확인
- [ ] Info.plist에 URL Scheme 추가 확인
- [ ] 실제 기기에서 테스트 (시뮬레이터도 가능)
- [ ] 로그인 후 Supabase에 사용자 생성 확인

### Android 테스트
- [ ] google-services.json 파일 존재 확인
- [ ] SHA-1 지문 등록 확인
- [ ] Google Play Services가 있는 에뮬레이터/기기에서 테스트
- [ ] 로그인 후 Supabase에 사용자 생성 확인

### 웹 테스트
- [ ] 승인된 JavaScript 원본 확인
- [ ] 리디렉션 URI 확인
- [ ] 로컬호스트와 프로덕션 URL 모두 테스트

## 7. 일반적인 오류 해결

### "Invalid API Key" 오류
- Client ID와 Bundle ID/Package Name 매칭 확인
- SHA-1 지문 정확성 확인

### "Developer Error" (Android)
- SHA-1 지문 재확인
- google-services.json 파일 최신 버전 확인
- Package Name 일치 확인

### "Redirect URI Mismatch" 오류
- Google Console과 Supabase의 리디렉션 URI 일치 확인
- 웹의 경우 정확한 도메인 사용

### iOS에서 로그인 창이 안 뜨는 경우
- URL Scheme 설정 확인
- GoogleService-Info.plist의 REVERSED_CLIENT_ID 확인

## 8. 필요한 정보 체크리스트

Google Cloud Console에서 필요한 정보:
- [ ] iOS Client ID
- [ ] Android Client ID  
- [ ] Web Client ID (중요: 모바일 앱에서도 이것을 사용)
- [ ] Web Client Secret (Supabase용)

프로젝트 정보:
- [ ] iOS Bundle ID: `com.test.aidiary`
- [ ] Android Package Name: `com.aidiary.app`
- [ ] Web URL: `https://ai-diary-flutter-app.vercel.app`

## 9. 구현 순서

1. Google Cloud Console에서 OAuth 클라이언트 생성
2. iOS/Android 설정 파일 다운로드 및 추가
3. Supabase에 Google Provider 설정
4. Flutter 코드 수정
5. 각 플랫폼에서 테스트
6. 프로덕션 배포 전 SHA-1 업데이트 (Android)