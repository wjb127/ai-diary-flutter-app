# 🔥 Firebase SHA 인증서 추가 가이드

## ✅ 완료된 작업
1. Firebase에 새 Android 앱 추가됨
   - App ID: `1:985326625841:android:443d5c6c366e5923082110`
   - Package name: `com.aigamsung.diary`
2. 새 google-services.json 파일 저장됨

## 🔴 남은 필수 작업: SHA 인증서 추가

### Firebase Console에서 SHA 추가하기

1. **Firebase Console 접속**
   - URL: https://console.firebase.google.com/project/ai-diary-469013/settings/general

2. **Android 앱 선택**
   - 패키지명: `com.aigamsung.diary` 찾기
   - "SHA 인증서 지문" 섹션 찾기

3. **SHA-1 추가** (복사해서 붙여넣기)
   ```
   Release SHA-1: 6595A95EFB632C02D5B56923709304C4D9C74DFA
   Debug SHA-1: EB7EF5853E92A125993C1A57FFC5F3F51D0415C
   ```

4. **저장 클릭**

### Google Cloud Console OAuth 설정

1. **Google Cloud Console 접속**
   - URL: https://console.cloud.google.com/apis/credentials?project=ai-diary-469013

2. **OAuth 2.0 클라이언트 ID**
   - "Android 클라이언트" 추가 또는 수정

3. **정보 입력**
   - 패키지명: `com.aigamsung.diary`
   - SHA-1: `6595A95EFB632C02D5B56923709304C4D9C74DFA`

4. **저장**

## 📱 테스트 방법

SHA 추가 후 앱 재설치:
```bash
# 앱 재설치
adb uninstall com.aigamsung.diary
adb install build/app/outputs/flutter-apk/app-release.apk

# 또는 디버그 빌드로 테스트
flutter run
```

## ⚠️ 중요 사항

- SHA 인증서는 대소문자 구분 없음
- 콜론(:) 없이 입력해도 됨
- 변경사항 적용에 몇 분 소요될 수 있음
- Release와 Debug SHA 모두 추가 권장

## 🎯 확인 사항

- [ ] Firebase Console에 SHA-1 추가
- [ ] Google Cloud Console에 OAuth 클라이언트 설정
- [ ] Google 로그인 테스트
- [ ] 게스트 모드 테스트

---

**마지막 업데이트**: 2025년 1월 15일
**Firebase App ID**: 1:985326625841:android:443d5c6c366e5923082110