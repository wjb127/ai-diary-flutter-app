# 🚀 Play Store 출시 최종 체크리스트

**앱 정보**
- 앱 이름: AI 감성 일기
- 패키지명: `com.aigamsung.diary`
- 버전: 1.0.0 (빌드 2)

## ✅ 완료된 작업

### 1. 기술적 준비
- [x] 패키지명 변경 완료
- [x] Keystore 생성 (유효기간 27년)
- [x] ProGuard 설정 (코드 난독화)
- [x] APK/AAB 빌드 완료 (26MB)

### 2. Firebase 설정
- [x] 새 Android 앱 추가
- [x] google-services.json 업데이트
- [x] SHA-1 인증서 추가 (Firebase Console)

### 3. 스토어 자료
- [x] 스크린샷 5개 준비 (1080x2340)
- [x] 앱 설명 작성 (한국어/영어)
- [x] 개인정보처리방침 URL 준비

## 🔴 즉시 해야 할 작업 (수동)

### 1. Google Cloud Console OAuth 설정
1. [Google Cloud Console](https://console.cloud.google.com/apis/credentials?project=ai-diary-469013) 접속
2. **OAuth 2.0 클라이언트 ID** → **+ 클라이언트 ID 만들기**
3. 유형: **Android** 선택
4. 입력 정보:
   - 이름: `AI 감성 일기 Android`
   - 패키지명: `com.aigamsung.diary`
   - SHA-1: `6595A95EFB632C02D5B56923709304C4D9C74DFA`
5. **만들기** 클릭

### 2. Supabase 설정 확인
1. [Supabase Dashboard](https://app.supabase.com) 접속
2. 프로젝트: `jihhsiijrxhazbxhoirl` 선택
3. **Authentication** → **Providers** → **Google**
4. 확인 사항:
   - Enabled: ON
   - Client ID 입력됨
   - Authorized Client IDs에 추가:
     ```
     985326625841-ohbunfq2ushk1autqdso1rf43qpmn7sa.apps.googleusercontent.com
     ```

### 3. 앱 테스트
```bash
# 폰 연결 후
adb devices

# 앱 실행
adb shell am start -n com.aigamsung.diary/.MainActivity

# 테스트 항목
- [ ] Google 로그인 성공
- [ ] 게스트 모드 작동
- [ ] 일기 작성 가능
- [ ] AI 각색 기능 작동
```

## 🟡 Play Console 등록 (1/16)

### 1. 개발자 계정
- [Play Console](https://play.google.com/console) 가입
- 등록비: $25 (일회성)
- 승인 대기: 최대 48시간

### 2. 앱 생성
- 앱 이름: **AI 감성 일기**
- 패키지명: `com.aigamsung.diary`
- 기본 언어: 한국어

### 3. 스토어 등록정보
- [ ] 앱 아이콘 업로드 (512x512)
- [ ] 피처 그래픽 업로드 (1024x500)
- [ ] 스크린샷 업로드 (최소 2개)
- [ ] 짧은 설명 입력
- [ ] 긴 설명 입력

### 4. 앱 콘텐츠
- [ ] 개인정보처리방침 URL
- [ ] 콘텐츠 등급 설문
- [ ] 타겟 연령: 13세 이상
- [ ] 데이터 보안 설문

### 5. 가격 및 배포
- [ ] 무료 앱 설정
- [ ] 국가: 대한민국 선택
- [ ] 인앱 구매 설정 (RevenueCat)

## 🟢 출시 (1/20-22)

### 1. 테스트 트랙
- [ ] 내부 테스트 생성
- [ ] AAB 업로드: `build/app/outputs/bundle/release/app-release.aab`
- [ ] 테스터 초대 (최소 20명)

### 2. 프로덕션 출시
- [ ] 출시 노트 작성
- [ ] 단계적 출시 설정
- [ ] 심사 제출

## 📱 파일 위치

### 빌드 파일
```bash
# APK (테스트용)
build/app/outputs/flutter-apk/app-release.apk

# AAB (Play Store 업로드용)
build/app/outputs/bundle/release/app-release.aab
```

### Keystore
```bash
# 원본 (절대 삭제 금지!)
/Users/seungbeenwi/aidiary-release.keystore

# 백업
~/Documents/AI-Diary-Backups/
```

### 스크린샷
```bash
screenshots/play_store/
├── screenshot_01_auth.png
├── screenshot_02_home.png
├── screenshot_03_diary.png
├── screenshot_04_profile.png
└── screenshot_05_subscription.png
```

## 📊 체크리스트 요약

### 기술 준비 ✅
- [x] 빌드 완료
- [x] Firebase 설정
- [x] 패키지명 변경

### 수동 작업 필요 🔴
- [ ] Google Cloud OAuth
- [ ] Supabase 확인
- [ ] 앱 테스트

### Play Console 🟡
- [ ] 개발자 등록
- [ ] 앱 생성
- [ ] 스토어 정보
- [ ] 심사 제출

## 🎯 목표 일정

| 날짜 | 작업 | 상태 |
|------|------|------|
| 1/15 (오늘) | OAuth 설정, 테스트 | 🔴 진행 필요 |
| 1/16 (목) | Play Console 가입 | ⏳ |
| 1/17 (금) | 스토어 정보 입력 | ⏳ |
| 1/18-19 (주말) | 테스트 | ⏳ |
| 1/20 (월) | 심사 제출 | ⏳ |
| 1/22 (수) | 출시 예정 | ⏳ |

## 💡 중요 팁

1. **Keystore 백업**: 최소 3곳 이상
2. **스크린샷**: 실제 사용 화면 권장
3. **설명**: SEO 키워드 포함
4. **심사**: 보통 2-24시간, 최대 7일
5. **정책**: AI 사용 명시 필수

## 📞 지원 링크

- [Play Console](https://play.google.com/console)
- [Firebase Console](https://console.firebase.google.com/project/ai-diary-469013)
- [Supabase Dashboard](https://app.supabase.com)
- [Google Cloud Console](https://console.cloud.google.com)

---

**마지막 업데이트**: 2025년 1월 15일  
**작성자**: Claude AI Assistant