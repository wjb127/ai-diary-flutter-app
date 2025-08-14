# Android 출시 가이드

## 1. Firebase 설정

### Firebase Console에서 프로젝트 생성
1. [Firebase Console](https://console.firebase.google.com) 접속
2. "프로젝트 만들기" 클릭
3. 프로젝트 이름: "AI Diary App" 입력
4. Google Analytics 설정 (선택사항)

### Android 앱 추가
1. Firebase 프로젝트 대시보드에서 Android 아이콘 클릭
2. Android 패키지 이름: `com.aidiary.app`
3. 앱 닉네임: "AI Diary"
4. 디버그 서명 인증서 SHA-1 (선택사항, Google 로그인에 필요)
   ```bash
   keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
   ```
5. "앱 등록" 클릭

### google-services.json 다운로드
1. google-services.json 파일 다운로드
2. `android/app/` 디렉토리에 복사

## 2. Google Sign-In 설정

### Firebase Authentication 활성화
1. Firebase Console → Authentication → Sign-in method
2. Google 제공업체 활성화
3. 프로젝트 공개용 이름 설정
4. 지원 이메일 선택
5. 저장

### OAuth 2.0 클라이언트 설정
1. [Google Cloud Console](https://console.cloud.google.com) 접속
2. Firebase 프로젝트와 연결된 프로젝트 선택
3. APIs & Services → Credentials
4. OAuth 2.0 클라이언트 ID 생성
   - 애플리케이션 유형: Android
   - 패키지 이름: `com.aidiary.app`
   - SHA-1 인증서 지문 입력

## 3. Android 서명 키 생성

### Release 키스토어 생성
```bash
keytool -genkey -v -keystore ~/key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

### key.properties 파일 생성
`android/key.properties` 파일 생성:
```properties
storePassword=<password>
keyPassword=<password>
keyAlias=upload
storeFile=/Users/<username>/key.jks
```

## 4. Gradle 설정 업데이트

### android/app/build.gradle 수정
```gradle
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}

android {
    ...
    signingConfigs {
        release {
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
            storePassword keystoreProperties['storePassword']
        }
    }
    buildTypes {
        release {
            signingConfig signingConfigs.release
        }
    }
}
```

## 5. 앱 정보 설정

### AndroidManifest.xml 수정
- 앱 이름 변경
- 권한 설정 확인
- 인터넷 권한: `<uses-permission android:name="android.permission.INTERNET"/>`

### 앱 아이콘 설정
- `android/app/src/main/res/mipmap-*/` 디렉토리에 아이콘 추가

## 6. 빌드 및 테스트

### APK 빌드
```bash
flutter build apk --release
```

### App Bundle 빌드 (Google Play 권장)
```bash
flutter build appbundle --release
```

## 7. Google Play Console 출시

### 앱 등록
1. [Google Play Console](https://play.google.com/console) 접속
2. "앱 만들기" 클릭
3. 앱 정보 입력

### 스토어 등록정보
- 앱 이름, 설명
- 스크린샷 (최소 2개)
- 아이콘 (512x512)
- 기능 그래픽 (1024x500)

### 출시 관리
1. 프로덕션 → 새 버전 만들기
2. App Bundle (.aab) 업로드
3. 출시 노트 작성
4. 검토 및 출시

## 8. Supabase 설정

### Google OAuth Redirect URL
Supabase Dashboard → Authentication → Providers → Google:
- Authorized Client IDs에 OAuth 2.0 클라이언트 ID 추가
- Redirect URL 확인

## 체크리스트

- [ ] Firebase 프로젝트 생성
- [ ] google-services.json 다운로드 및 추가
- [ ] Google Sign-In 활성화
- [ ] Release 키스토어 생성
- [ ] key.properties 파일 생성
- [ ] build.gradle 서명 설정
- [ ] 앱 아이콘 및 정보 설정
- [ ] APK/AAB 빌드 테스트
- [ ] Google Play Console 앱 등록
- [ ] Supabase OAuth 설정