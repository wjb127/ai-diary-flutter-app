# Google과 Apple 로그인 구현 가이드

## Google 로그인 설정

### 1. Google Cloud Console 설정
1. [Google Cloud Console](https://console.cloud.google.com) 접속
2. 새 프로젝트 생성 또는 기존 프로젝트 선택
3. "API 및 서비스" > "사용 설정된 API 및 서비스" 이동
4. Google Sign-In API 활성화

### 2. OAuth 2.0 클라이언트 ID 생성

#### iOS용 클라이언트 ID
1. "사용자 인증 정보" > "사용자 인증 정보 만들기" > "OAuth 클라이언트 ID"
2. 애플리케이션 유형: iOS
3. 번들 ID: `com.aidiary.app` (또는 프로젝트의 번들 ID)
4. 생성된 클라이언트 ID 저장

#### Android용 클라이언트 ID
1. 애플리케이션 유형: Android
2. 패키지 이름: `com.aidiary.app`
3. SHA-1 인증서 지문 입력:
   ```bash
   # Debug 키스토어의 SHA-1 얻기
   keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
   
   # Release 키스토어의 SHA-1 얻기
   keytool -list -v -keystore [키스토어 경로] -alias [별칭]
   ```

#### 웹용 클라이언트 ID
1. 애플리케이션 유형: 웹 애플리케이션
2. 승인된 JavaScript 원본: 
   - `http://localhost:3000` (개발용)
   - `https://your-domain.com` (프로덕션용)
3. 승인된 리디렉션 URI:
   - `https://your-project.supabase.co/auth/v1/callback`

### 3. Flutter 프로젝트 설정

#### iOS 설정
1. `ios/Runner/Info.plist`에 URL Scheme 추가:
   ```xml
   <key>CFBundleURLTypes</key>
   <array>
     <dict>
       <key>CFBundleURLSchemes</key>
       <array>
         <string>com.googleusercontent.apps.[REVERSED_CLIENT_ID]</string>
       </array>
     </dict>
   </array>
   ```

2. GoogleService-Info.plist 다운로드하여 `ios/Runner/` 폴더에 추가

#### Android 설정
1. `android/app/google-services.json` 파일 다운로드하여 추가
2. `android/build.gradle`:
   ```gradle
   dependencies {
     classpath 'com.google.gms:google-services:4.4.0'
   }
   ```
3. `android/app/build.gradle`:
   ```gradle
   apply plugin: 'com.google.gms.google-services'
   ```

#### 웹 설정
1. `web/index.html`에 메타 태그 추가:
   ```html
   <meta name="google-signin-client_id" content="YOUR_WEB_CLIENT_ID.apps.googleusercontent.com">
   ```

### 4. Supabase 설정
1. Supabase 대시보드 > Authentication > Providers
2. Google 활성화
3. Client ID와 Client Secret 입력

## Apple 로그인 설정

### 1. Apple Developer 설정
1. [Apple Developer](https://developer.apple.com) 접속
2. Certificates, Identifiers & Profiles 이동
3. Identifiers에서 앱 ID 선택
4. "Sign In with Apple" 기능 활성화

### 2. Service ID 생성 (웹용)
1. Identifiers > 새로 만들기 > Services IDs
2. 설명과 Identifier 입력
3. "Sign In with Apple" 활성화
4. Configure 클릭:
   - 도메인: `your-project.supabase.co`
   - Return URLs: `https://your-project.supabase.co/auth/v1/callback`

### 3. Key 생성
1. Keys > 새로 만들기
2. "Sign In with Apple" 선택
3. Configure에서 Service ID 연결
4. `.p8` 파일 다운로드 (한 번만 다운로드 가능!)

### 4. Flutter 프로젝트 설정

#### iOS 설정
1. Xcode에서 프로젝트 열기
2. Signing & Capabilities 탭
3. "+ Capability" 클릭하여 "Sign In with Apple" 추가
4. `ios/Runner/Runner.entitlements` 파일 생성:
   ```xml
   <?xml version="1.0" encoding="UTF-8"?>
   <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
   <plist version="1.0">
   <dict>
     <key>com.apple.developer.applesignin</key>
     <array>
       <string>Default</string>
     </array>
   </dict>
   </plist>
   ```

#### Android 설정
Android는 Apple 로그인을 웹뷰로 처리하므로 특별한 설정 불필요

### 5. Supabase 설정
1. Supabase 대시보드 > Authentication > Providers
2. Apple 활성화
3. Service ID, Team ID, Key ID, Private Key 입력

## 코드 구현

### 필요한 패키지 설치
```yaml
dependencies:
  google_sign_in: ^6.2.2
  sign_in_with_apple: ^6.1.3
  supabase_flutter: ^2.8.0
```

### AuthService 구현
```dart
// Google 로그인
Future<void> signInWithGoogle() async {
  if (kIsWeb) {
    // 웹에서는 Supabase OAuth 사용
    await _supabase.auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: 'https://your-app.com/auth/callback',
    );
  } else {
    // 모바일에서는 Google Sign In SDK 사용
    final GoogleSignIn googleSignIn = GoogleSignIn(
      serverClientId: WEB_CLIENT_ID,
    );
    
    final googleUser = await googleSignIn.signIn();
    final googleAuth = await googleUser!.authentication;
    
    await _supabase.auth.signInWithIdToken(
      provider: OAuthProvider.google,
      idToken: googleAuth.idToken!,
      accessToken: googleAuth.accessToken,
    );
  }
}

// Apple 로그인
Future<void> signInWithApple() async {
  final credential = await SignInWithApple.getAppleIDCredential(
    scopes: [
      AppleIDAuthorizationScopes.email,
      AppleIDAuthorizationScopes.fullName,
    ],
  );
  
  await _supabase.auth.signInWithIdToken(
    provider: OAuthProvider.apple,
    idToken: credential.identityToken!,
  );
}
```

## 테스트

### Google 로그인 테스트
1. iOS: 실제 기기 또는 시뮬레이터에서 테스트
2. Android: 에뮬레이터는 Google Play Services 필요
3. Web: localhost에서 테스트 가능

### Apple 로그인 테스트
1. iOS: 실제 기기 필요 (시뮬레이터도 가능)
2. Android: 웹뷰로 처리되므로 실제 기기 권장
3. Web: HTTPS 환경 필요

## 주의사항

1. **API 키 보안**: 
   - 클라이언트 ID는 공개되어도 괜찮음
   - Secret Key는 절대 클라이언트 코드에 포함하지 말 것

2. **Bundle ID/Package Name**:
   - Google과 Apple에 등록한 ID가 실제 앱과 일치해야 함

3. **리디렉션 URL**:
   - Supabase 프로젝트 URL이 정확해야 함
   - 웹 배포 시 실제 도메인으로 변경 필요

4. **테스트 계정**:
   - Apple: Sandbox 계정 사용 가능
   - Google: 테스트 사용자 등록 권장

## 문제 해결

### Google 로그인 실패
- SHA-1 인증서 지문 확인
- Bundle ID/Package Name 확인
- OAuth 동의 화면 설정 확인

### Apple 로그인 실패
- Provisioning Profile에 Sign In with Apple 권한 확인
- Service ID와 Bundle ID 매칭 확인
- Entitlements 파일 존재 여부 확인

### Supabase 연동 실패
- Redirect URL 정확성 확인
- Supabase 프로젝트 설정 확인
- 네트워크 연결 상태 확인