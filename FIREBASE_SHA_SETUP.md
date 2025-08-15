# Firebase Google Sign-In 설정 가이드

## 🔴 현재 문제
Google 로그인 시 `PlatformException(sign_in_failed)` 오류 발생

## 원인
패키지명 변경 (`com.test.aidiary` → `com.aigamsung.diary`) 후 Firebase에 새로운 SHA 인증서 미등록

## 해결 방법

### 1. SHA 인증서 확인
현재 프로젝트의 SHA 인증서:
```
Release SHA-1: 65:95:A9:5E:FB:63:2C:02:D5:B5:69:23:70:93:04:C4:D9:C7:4D:FA
Debug SHA-1: EB:7E:F5:85:E3:92:A1:25:99:31:C1:A5:7F:FC:5F:3F:51:D0:41:5C
```

### 2. Firebase Console 설정

1. [Firebase Console](https://console.firebase.google.com) 접속
2. `ai-diary-469013` 프로젝트 선택
3. 프로젝트 설정 → 일반 탭
4. Android 앱 섹션에서 `com.aigamsung.diary` 앱 찾기
   - 없으면 "앱 추가" 클릭하여 새로 추가
5. SHA 인증서 지문 추가:
   - **Release SHA-1**: `6595A95EFB632C02D5B56923709304C4D9C74DFA`
   - **Debug SHA-1**: `EB7EF5853E92A125993C1A57FFC5F3F51D0415C`

### 3. google-services.json 다운로드
1. Firebase Console에서 업데이트된 `google-services.json` 다운로드
2. `android/app/` 디렉토리에 복사 (기존 파일 덮어쓰기)

### 4. 앱 재빌드
```bash
flutter clean
flutter pub get
flutter build apk --release
```

### 5. 재설치
```bash
adb uninstall com.aigamsung.diary
adb install build/app/outputs/flutter-apk/app-release.apk
```

## 추가 확인 사항

### Google Cloud Console OAuth 2.0 설정
1. [Google Cloud Console](https://console.cloud.google.com) 접속
2. `ai-diary-469013` 프로젝트 선택
3. API 및 서비스 → 사용자 인증 정보
4. OAuth 2.0 클라이언트 ID에서 Android 클라이언트 확인
5. 패키지명이 `com.aigamsung.diary`인지 확인
6. SHA-1 지문이 올바른지 확인

## 임시 해결책 (테스트용)
Debug 빌드 사용:
```bash
flutter build apk --debug
adb install build/app/outputs/flutter-apk/app-debug.apk
```

## 주의사항
- SHA 인증서는 대소문자 구분 없음
- Firebase와 Google Cloud Console 모두 업데이트 필요
- 변경사항 적용에 몇 분 소요될 수 있음