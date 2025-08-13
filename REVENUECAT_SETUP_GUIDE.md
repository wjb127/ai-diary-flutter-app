# 📱 RevenueCat 설정 가이드 - AI 일기 앱

## 🎯 현실적인 출시 전략

### 🔴 현재 상황 (앱스토어 출시 전)
- ✅ RevenueCat SDK 통합 완료
- ✅ 구독 UI/UX 구현 완료
- ❌ App Store Connect 설정 불가 (앱 출시 필요)
- ❌ P8 Key 발급 불가 (앱 출시 필요)
- ❌ 실제 구독 테스트 불가

## 📋 단계별 실행 계획

### 1️⃣ Phase 1: 무료 앱으로 첫 출시 (1-2주)

#### A. 앱스토어 준비
```
1. Apple Developer Program 가입 ($99/년)
2. App Store Connect에서 앱 생성
   - Bundle ID: com.aidiary.app
   - 앱 이름: AI 일기
3. 앱 스크린샷 및 설명 준비
4. 개인정보 처리방침 URL 제공
```

#### B. 코드 수정 (구독 기능 임시 비활성화)
```dart
// lib/services/subscription_service.dart
static const bool isProduction = false; // 첫 출시 시 false
```

#### C. 심사 제출
- 구독 기능 숨김 처리
- 기본 일기 기능만 활성화
- 심사 기간: 약 2-7일

### 2️⃣ Phase 2: RevenueCat 설정 (앱 승인 후 즉시)

#### A. App Store Connect 설정
```
1. 구독 상품 생성
   - 월간: ai_diary_monthly (₩4,900)
   - 연간: ai_diary_yearly (₩49,000)
   
2. Shared Secret 생성
   - App Store Connect → 앱 → 구독 관리 → Shared Secret
   
3. P8 Key 발급
   - Users and Access → Keys → In-App Purchase
```

#### B. RevenueCat Dashboard 설정
```
1. 프로젝트 생성
2. iOS 앱 추가
   - Bundle ID: com.aidiary.app
   - Shared Secret 입력
   - P8 Key 업로드
   
3. Products 설정
   - ai_diary_monthly
   - ai_diary_yearly
   
4. Offerings 설정
   - Default Offering
   - Packages 구성
   
5. API Keys 발급
   - Public API Key 복사
```

#### C. 환경 변수 설정
```bash
# .env 파일
REVENUECAT_API_KEY=appl_xxxxxxxxxxxxx
```

### 3️⃣ Phase 3: 구독 기능 활성화 업데이트 (1.1.0)

#### A. 코드 활성화
```dart
// lib/services/subscription_service.dart
static const bool isProduction = true; // 활성화
static const String _revenueCatApiKey = 'appl_xxxxxxxxxxxxx';
```

#### B. 테스트
```
1. Sandbox 테스터 계정 생성
2. TestFlight 배포
3. 구독 플로우 테스트
```

#### C. 업데이트 출시
- 버전 1.1.0으로 업데이트
- What's New: "프리미엄 구독 기능 추가"

## 🚀 즉시 실행 가능한 작업

### 오늘 할 수 있는 것:
1. ✅ Apple Developer Program 가입
2. ✅ RevenueCat 계정 생성
3. ✅ 앱 스크린샷 준비
4. ✅ 앱 설명 작성

### 앱 출시 후 할 것:
1. ⏳ App Store Connect 구독 설정
2. ⏳ RevenueCat 연동
3. ⏳ P8 Key 설정
4. ⏳ 구독 테스트

## 💡 Pro Tips

### 첫 출시 시 주의사항:
- 구독 버튼은 "Coming Soon"으로 표시
- 무료로 모든 기능 제공 (일시적)
- 사용자 피드백 수집 집중

### RevenueCat 테스트 모드:
```dart
// 개발 중 테스트
if (kDebugMode) {
  // 구독 없이 프리미엄 기능 사용
  return true;
}
```

## 📊 예상 타임라인

```
Week 1: Apple Developer 가입 + 앱 제출
Week 2: 앱 심사 + 승인
Week 3: RevenueCat 설정 + 구독 상품 생성
Week 4: 업데이트 버전 출시 (구독 활성화)
```

## 🔗 필요한 링크들

- [Apple Developer Program](https://developer.apple.com/programs/)
- [App Store Connect](https://appstoreconnect.apple.com/)
- [RevenueCat Dashboard](https://app.revenuecat.com/)
- [RevenueCat Flutter 문서](https://docs.revenuecat.com/docs/flutter)

## ✅ 체크리스트

### 앱 출시 전:
- [ ] Apple Developer Program 가입
- [ ] Bundle ID 확정 (com.aidiary.app)
- [ ] 앱 아이콘 준비 (1024x1024)
- [ ] 스크린샷 준비 (iPhone, iPad)
- [ ] 앱 설명 작성
- [ ] 개인정보 처리방침 페이지
- [ ] 지원 URL

### 앱 출시 후:
- [ ] 구독 상품 생성
- [ ] P8 Key 발급
- [ ] RevenueCat 프로젝트 설정
- [ ] API Key 연동
- [ ] Sandbox 테스트
- [ ] 업데이트 배포

---

💬 **참고**: 첫 출시는 무료 앱으로 빠르게 진행하고, 사용자 피드백을 받으면서 구독 모델을 준비하는 것이 현실적입니다.