# Google 로그인 빠른 설정 가이드

## 🚨 현재 필요한 작업

### 1. Google Cloud Console에서 해야 할 일

1. [Google Cloud Console](https://console.cloud.google.com) 접속
2. 새 프로젝트 생성 또는 기존 프로젝트 선택
3. **API 및 서비스 > 사용자 인증 정보** 이동

### 2. OAuth 클라이언트 ID 생성

#### iOS 클라이언트 생성
1. **사용자 인증 정보 만들기 > OAuth 클라이언트 ID**
2. 애플리케이션 유형: **iOS**
3. 번들 ID: `com.test.aidiary`
4. **만들기** 클릭
5. **plist 파일 다운로드** 클릭

#### 다운로드한 파일 설치
1. 다운로드한 `GoogleService-Info.plist` 파일을 복사
2. `/Users/seungbeenwi/Project/ai-diary-flutter-app/ios/Runner/` 폴더에 붙여넣기 (기존 파일 덮어쓰기)

### 3. Info.plist 수정

`ios/Runner/Info.plist`의 CFBundleURLSchemes를 수정:
1. GoogleService-Info.plist 파일 열기
2. `REVERSED_CLIENT_ID` 값 복사
3. Info.plist의 32번째 줄 수정:
```xml
<string>com.googleusercontent.apps.[YOUR_REVERSED_CLIENT_ID]</string>
```

### 4. Supabase 설정

1. [Supabase Dashboard](https://app.supabase.com/project/jihhsiijrxhazbxhoirl) 접속
2. **Authentication > Providers > Google** 이동
3. **Enable Google** 체크
4. 입력할 정보:
   - **Client ID (for OAuth)**: Google Console의 웹 애플리케이션 Client ID
   - **Client Secret**: Google Console의 웹 애플리케이션 Client Secret

### 5. 웹 애플리케이션 OAuth 생성 (Supabase용)

1. Google Cloud Console로 돌아가기
2. **사용자 인증 정보 만들기 > OAuth 클라이언트 ID**
3. 애플리케이션 유형: **웹 애플리케이션**
4. 이름: "AI Diary Web (Supabase)"
5. 승인된 JavaScript 원본 추가:
   - `https://jihhsiijrxhazbxhoirl.supabase.co`
6. 승인된 리디렉션 URI 추가:
   - `https://jihhsiijrxhazbxhoirl.supabase.co/auth/v1/callback`
7. **만들기** 클릭
8. 표시되는 **Client ID**와 **Client Secret** 복사

## ✅ 체크리스트

- [ ] iOS용 OAuth 클라이언트 생성
- [ ] GoogleService-Info.plist 다운로드 및 설치
- [ ] Info.plist의 REVERSED_CLIENT_ID 수정
- [ ] 웹 애플리케이션 OAuth 클라이언트 생성
- [ ] Supabase에 Client ID와 Secret 입력
- [ ] 앱 재빌드 및 테스트

## 🔧 빌드 및 테스트

```bash
# iOS 빌드
flutter build ios --release

# 아이폰에 설치
flutter install --device-id 00008140-001A395E26C1801C
```

## ⚠️ 주의사항

1. **Bundle ID 일치**: Google Console과 Xcode의 Bundle ID가 `com.test.aidiary`로 일치해야 함
2. **REVERSED_CLIENT_ID**: Info.plist에 정확히 입력해야 함
3. **웹 클라이언트**: Supabase는 웹 애플리케이션 타입의 OAuth 클라이언트가 필요함

## 🐛 문제 해결

### "Developer Error" 발생 시
- GoogleService-Info.plist 파일이 올바른 위치에 있는지 확인
- Bundle ID가 일치하는지 확인

### 로그인 창이 안 뜨는 경우
- Info.plist의 URL Scheme 확인
- GoogleService-Info.plist의 REVERSED_CLIENT_ID 확인

### "Invalid API Key" 오류
- Google Cloud Console에서 프로젝트가 활성화되어 있는지 확인
- OAuth 동의 화면이 구성되어 있는지 확인

## 📞 도움이 필요하면

1. Google Cloud Console 프로젝트 ID 알려주기
2. 오류 메시지 스크린샷 제공
3. Xcode 콘솔 로그 확인

---
*이 가이드를 따라 설정하면 Google 로그인이 작동합니다!*