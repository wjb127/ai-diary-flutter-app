# Play Store 출시 TODO List

## 📅 목표 출시일: 2025년 1월 22일 (다음주)
**작성일**: 2025년 1월 15일

---

## 🔴 긴급 (D-1~2)

### 1. 앱 서명 키 생성 ⚠️ **최우선**
```bash
keytool -genkey -v -keystore ~/aidiary-release.keystore -alias aidiary -keyalg RSA -keysize 2048 -validity 10000
```
- [x] keystore 파일 생성 ✅
- [x] 비밀번호 안전한 곳에 저장 ✅ 
- [x] `android/key.properties` 파일 생성 ✅
- [x] `.gitignore`에 key.properties 추가 ✅
- [ ] ⚠️ **keystore 파일 백업 필수** (Google Drive, USB 등)

**⚠️ 주의: 이 키를 잃어버리면 앱 업데이트 불가능**

### 2. 패키지명 변경 ⚠️ **변경 불가**
~~현재: `com.test.aidiary`~~
**변경됨**: `com.aigamsung.diary` ✅

변경 파일:
- [x] `android/app/build.gradle` ✅
- [x] `android/app/google-services.json` ✅
- [x] `android/app/src/main/AndroidManifest.xml` ✅
- [ ] iOS Bundle Identifier (iOS 출시 시)

---

## 🟡 중요 (D-3~4)

### 3. 버전 설정
`pubspec.yaml`:
```yaml
version: 1.0.0+1  # 이전
version: 1.0.0+2  # 현재 설정됨 ✅
```
- [x] 버전 번호 결정 ✅
- [x] 빌드 번호 증가 ✅

### 4. ProGuard 설정
`android/app/proguard-rules.pro`:
- [x] Supabase 관련 규칙 추가 ✅
- [x] Google Sign-In 규칙 추가 ✅
- [x] Play Core 라이브러리 규칙 추가 ✅
- [x] 난독화 예외 설정 ✅

### 5. 앱 번들 빌드
```bash
flutter build appbundle --release
```
- [x] .aab 파일 생성 ✅ (26.2MB)
- [x] 파일 크기 확인 ✅ (150MB 제한 내)

---

## 🟢 스토어 등록 정보 (D-5~6)

### 6. 앱 정보
- [x] **앱 이름**: AI 감성 일기 ✅ (AndroidManifest.xml 설정됨)
- [x] **짧은 설명** (80자): ✅ (store_description_ko.txt 준비됨)
  ```
  AI가 당신의 일상을 아름답게 각색해주는 감성 일기장 - Claude AI 기반
  ```
- [x] **긴 설명** (4000자): ✅ (store_description_ko.txt 준비됨)

### 7. 스크린샷 준비
최소 2개, 권장 8개 (각 320~3840px)
- [ ] 홈 화면
- [ ] 일기 작성 화면
- [ ] AI 각색 결과 화면
- [ ] 프로필 화면
- [ ] 달력 화면
- [ ] 로그인 화면
- [ ] 테마 (다크/라이트) 화면
- [ ] 멘탈 헬스 리소스 화면

### 8. 그래픽 자산
- [ ] **앱 아이콘**: 512x512 PNG ✅ (이미 있음)
- [ ] **피처 그래픽**: 1024x500 PNG
- [ ] **프로모션 그래픽**: 180x120 PNG (선택)

### 9. 스토어 등록 정보

#### 카테고리
- [ ] 주 카테고리: **라이프스타일**
- [ ] 보조 카테고리: **도구**

#### 연령 등급
- [ ] 콘텐츠 등급 설문 작성
- [ ] 13세 이상 설정 (AI 콘텐츠)

#### 연락처 정보
- [ ] 개발자 이메일
- [ ] 개발자 웹사이트 (선택)
- [ ] 전화번호 (선택)

---

## 📝 앱 설명 템플릿

### 짧은 설명 (80자)
```
AI가 당신의 일상을 아름답게 각색해주는 감성 일기장 - Claude AI 기반
```

### 긴 설명 (4000자)
```markdown
✨ AI 일기장 - 당신의 이야기를 특별하게 ✨

평범한 일상도 AI가 아름답게 각색해드립니다.
Claude AI가 당신의 감정을 이해하고, 문학적으로 재구성합니다.

🎯 주요 기능

【 AI 일기 각색 】
• 간단한 메모도 감성적인 에세이로 변환
• Claude AI의 섬세한 감정 이해
• 한국어/영어 지원

【 안전한 데이터 관리 】
• Supabase 클라우드 자동 백업
• 구글 로그인으로 안전한 동기화
• 언제든 완전 삭제 가능

【 무료 이용 】
• 하루 10회 무료 AI 각색
• 무제한 일기 저장
• 광고 없는 깔끔한 환경

【 정신 건강 지원 】
• 자동 콘텐츠 필터링
• 도움 리소스 제공 (109, 129, 1388)
• AI 응답 신고 기능

【 주요 특징 】
✓ 오프라인 모드 지원
✓ 다크 모드
✓ 달력 뷰
✓ 일기 공유 기능
✓ 개인정보 보호

⚠️ 중요 안내
• 이 앱은 의료 목적이 아닙니다
• AI 생성 콘텐츠는 창작물입니다
• 13세 이상 사용 권장

📱 이용 방법
1. 오늘의 일기 작성
2. AI 각색 버튼 클릭
3. 아름답게 변환된 일기 저장

💬 문의 및 피드백
GitHub: https://github.com/wjb127/ai-diary-flutter-app

개인정보처리방침:
https://raw.githubusercontent.com/wjb127/ai-diary-flutter-app/main/docs/privacy_policy.txt

#AI일기 #일기앱 #감성일기 #ClaudeAI #일기장
```

---

## 🔗 필수 URL

### 10. 정책 문서
- [x] **개인정보처리방침**: 
  ```
  https://raw.githubusercontent.com/wjb127/ai-diary-flutter-app/main/docs/privacy_policy.txt
  ```
- [x] **이용약관**:
  ```
  https://raw.githubusercontent.com/wjb127/ai-diary-flutter-app/main/docs/terms_of_service.txt
  ```

---

## 📋 체크리스트 (출시 전 최종 확인)

### 기술적 확인
- [ ] Release 빌드 테스트 완료
- [ ] 구글 로그인 정상 작동
- [ ] AI 각색 기능 정상 작동
- [ ] 데이터 저장/불러오기 정상
- [ ] 오류 없이 실행되는지 확인

### 정책 준수
- [x] AI 사용 명시 ✅
- [x] 의료 목적 아님 고지 ✅
- [x] 데이터 삭제 기능 ✅
- [x] 콘텐츠 필터링 ✅
- [x] 13세 이상 연령 제한 ✅

### Play Console 설정
- [ ] 앱 생성
- [ ] 스토어 등록정보 입력
- [ ] 콘텐츠 등급 설문
- [ ] 가격 및 배포 설정 (무료)
- [ ] 앱 콘텐츠 선언
- [ ] 데이터 보안 설문

---

## 📅 일정표

| 날짜 | 작업 | 담당 | 상태 |
|------|------|------|------|
| 1/16 (목) | Keystore 생성, 패키지명 변경 | 개발자 | ⏳ |
| 1/17 (금) | 스크린샷 촬영, 스토어 자료 준비 | 개발자 | ⏳ |
| 1/18 (토) | Play Console 등록, 설문 작성 | 개발자 | ⏳ |
| 1/19 (일) | 내부 테스트 | 테스터 | ⏳ |
| 1/20 (월) | 피드백 반영, 최종 빌드 | 개발자 | ⏳ |
| 1/21 (화) | 프로덕션 출시 제출 | 개발자 | ⏳ |
| 1/22 (수) | 출시 승인 대기 | Google | ⏳ |

---

## 🚀 출시 명령어 모음

```bash
# 1. Keystore 생성
keytool -genkey -v -keystore ~/aidiary-release.keystore -alias aidiary -keyalg RSA -keysize 2048 -validity 10000

# 2. key.properties 생성
cat > android/key.properties << EOF
storePassword=YOUR_STORE_PASSWORD
keyPassword=YOUR_KEY_PASSWORD
keyAlias=aidiary
storeFile=/Users/$(whoami)/aidiary-release.keystore
EOF

# 3. 앱 번들 빌드
flutter clean
flutter pub get
flutter build appbundle --release

# 4. APK 빌드 (테스트용)
flutter build apk --release

# 5. 빌드 확인
ls -la build/app/outputs/bundle/release/
ls -la build/app/outputs/flutter-apk/
```

---

## 💡 팁

1. **Keystore 백업**: 최소 3곳에 백업 (클라우드, USB, 외장하드)
2. **비밀번호 관리**: 1Password, Bitwarden 등 사용
3. **테스트**: 출시 전 최소 3명 이상 테스트
4. **스크린샷**: 실제 사용 화면으로 신뢰도 상승
5. **설명**: SEO 키워드 포함 (#AI일기, #일기장 등)

---

## 📞 지원 연락처

- Play Console 지원: https://support.google.com/googleplay/android-developer
- Flutter 문서: https://docs.flutter.dev/deployment/android
- RevenueCat (구독): https://www.revenuecat.com/

---

## ✅ 완료 시 체크

- [ ] 모든 TODO 완료
- [ ] Play Store 제출 완료
- [ ] 출시 승인 대기
- [ ] 출시 완료 🎉

---

**마지막 업데이트**: 2025년 1월 15일
**목표 출시일**: 2025년 1월 22일
**현재 상태**: 준비 중 🚧