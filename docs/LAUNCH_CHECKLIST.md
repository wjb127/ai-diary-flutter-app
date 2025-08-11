# 🚀 AI 일기 앱 출시 체크리스트

## 📅 Phase 1: 기술 설정 (Week 1-2)

### 1️⃣ RevenueCat 설정
- [ ] RevenueCat 계정 생성 (https://app.revenuecat.com)
- [ ] 새 프로젝트 생성: "AI Diary App"
- [ ] Android 앱 추가
  - [ ] Package Name: `com.aidiary.app` 입력
  - [ ] Google Play Service Account JSON 키 업로드
- [ ] iOS 앱 추가
  - [ ] Bundle ID: `com.aidiary.app` 입력
  - [ ] App Store Connect API Key 생성 및 업로드
- [ ] Products 생성
  - [ ] `ai_diary_monthly` - ₩4,500/월
  - [ ] `ai_diary_yearly` - ₩39,000/년
- [ ] Entitlements 생성
  - [ ] Identifier: `premium`
  - [ ] 두 상품 모두 연결
- [ ] API Keys 복사
  - [ ] Android API Key 복사
  - [ ] iOS API Key 복사

### 2️⃣ Supabase 설정
- [ ] Supabase 계정 생성 (https://supabase.com)
- [ ] 새 프로젝트 생성
  - [ ] 프로젝트 이름: AI Diary
  - [ ] 데이터베이스 비밀번호 설정
  - [ ] Region: Seoul (또는 가까운 지역)
- [ ] Database 설정
  - [ ] SQL Editor에서 테이블 생성 스크립트 실행
  - [ ] RLS (Row Level Security) 정책 설정
- [ ] Authentication 설정
  - [ ] Email 설정
    - [ ] Enable email confirmations: ON
    - [ ] Enable email change confirmations: ON
    - [ ] Secure email change: ON
  - [ ] Google OAuth 설정
    - [ ] Enable sign in with Google: ON
    - [ ] Client ID 입력
    - [ ] Client Secret 입력
  - [ ] Apple OAuth 설정 (iOS)
    - [ ] Enable sign in with Apple: ON
    - [ ] Service ID 입력
    - [ ] Team ID 입력
    - [ ] Key ID 입력
    - [ ] Private Key 붙여넣기
- [ ] URL Configuration
  - [ ] Site URL: 프로덕션 URL 입력
  - [ ] Redirect URLs 추가
    - [ ] `http://localhost:3000/**`
    - [ ] `com.aidiary.app://login-callback/`
    - [ ] 프로덕션 URL 추가
- [ ] Edge Functions 배포
  - [ ] AI 일기 생성 함수 작성
  - [ ] 배포 및 테스트
- [ ] API Keys 복사
  - [ ] Project URL 복사
  - [ ] Anon Key 복사

### 3️⃣ Apple Developer 설정 (iOS)
- [ ] Apple Developer Program 가입 ($99/년)
  - [ ] 개인 또는 법인 선택
  - [ ] 결제 정보 입력
  - [ ] 승인 대기 (24-48시간)
- [ ] Certificates, Identifiers & Profiles 접속
- [ ] App ID 등록
  - [ ] Platform: iOS
  - [ ] Bundle ID: `com.aidiary.app`
  - [ ] Description: AI Diary App
  - [ ] Capabilities 활성화
    - [ ] Sign in with Apple
    - [ ] In-App Purchase
- [ ] Service ID 생성 (OAuth용)
  - [ ] Description: AI Diary OAuth
  - [ ] Identifier: `com.aidiary.app.oauth`
  - [ ] Sign in with Apple 활성화
  - [ ] Configure 클릭
    - [ ] Primary App ID: com.aidiary.app
    - [ ] Domains: Supabase 도메인
    - [ ] Return URLs: Supabase callback URL
- [ ] Key 생성 (Sign in with Apple)
  - [ ] Key Name: AI Diary Apple OAuth
  - [ ] Sign in with Apple 체크
  - [ ] Configure → Primary App ID 선택
  - [ ] .p8 파일 다운로드 (한 번만 가능!)
  - [ ] Key ID 기록

### 4️⃣ Google Play Console 설정 (Android)
- [ ] Google Play Console 계정 생성 ($25 일회성)
  - [ ] 개발자 계정 등록
  - [ ] 결제 정보 입력
  - [ ] 신원 확인
- [ ] 새 앱 만들기
  - [ ] 앱 이름: AI 일기
  - [ ] 기본 언어: 한국어
  - [ ] 앱 또는 게임: 앱
  - [ ] 무료 또는 유료: 무료
- [ ] 앱 설정
  - [ ] 패키지 이름: `com.aidiary.app`
  - [ ] 앱 카테고리: 라이프스타일
  - [ ] 태그 추가
- [ ] Google OAuth 설정
  - [ ] Google Cloud Console 접속
  - [ ] OAuth 2.0 클라이언트 ID 생성
  - [ ] SHA-1 인증서 지문 추가
- [ ] 인앱 상품 생성
  - [ ] 월간 구독 상품 생성
  - [ ] 연간 구독 상품 생성
  - [ ] RevenueCat과 연동

## 📅 Phase 2: 앱 스토어 준비 (Week 3-4)

### 5️⃣ 앱 메타데이터 작성
- [ ] 앱 이름 결정
  - [ ] 주 이름: AI 일기
  - [ ] 부제: AI가 써주는 감성 일기장
- [ ] 앱 설명 작성
  - [ ] 짧은 설명 (80자)
  - [ ] 전체 설명 (4000자)
  - [ ] 키워드 선정 (100자)
- [ ] 카테고리 선택
  - [ ] 주 카테고리: 라이프스타일
  - [ ] 보조 카테고리: 생산성
- [ ] 연령 등급 설정
  - [ ] 콘텐츠 등급 설문 완료
  - [ ] 4+ 또는 12+ 결정

### 6️⃣ 미디어 자료 제작
- [ ] 앱 아이콘 제작
  - [ ] 1024x1024 마스터 버전
  - [ ] iOS 각 사이즈 Export
  - [ ] Android 각 사이즈 Export
- [ ] 스크린샷 제작
  - [ ] iPhone 6.7" (1290 x 2796)
  - [ ] iPhone 6.5" (1284 x 2778)
  - [ ] iPhone 5.5" (1242 x 2208)
  - [ ] iPad 12.9" (2048 x 2732)
  - [ ] Android Phone (다양한 해상도)
  - [ ] Android Tablet (다양한 해상도)
- [ ] 각 스크린샷 내용
  - [ ] 홈 화면
  - [ ] 일기 작성 화면
  - [ ] AI 각색 결과
  - [ ] 달력 뷰
  - [ ] 구독 화면
- [ ] 홍보 자료
  - [ ] Feature Graphic (Google Play)
  - [ ] 프리뷰 영상 (선택사항)

### 7️⃣ 법적 문서 준비
- [ ] 개인정보처리방침 작성
  - [ ] 수집하는 정보 명시
    - [ ] 이메일 주소
    - [ ] 일기 내용
    - [ ] 사용 통계
  - [ ] 정보 사용 목적
  - [ ] 보관 기간
  - [ ] 제3자 제공 여부
  - [ ] 사용자 권리
- [ ] 서비스 이용약관 작성
  - [ ] 서비스 정의
  - [ ] 사용자 의무
  - [ ] 결제 및 환불 정책
  - [ ] 지적재산권
  - [ ] 면책조항
- [ ] 문서 호스팅
  - [ ] GitHub Pages 설정 또는
  - [ ] 개인 웹사이트 업로드
  - [ ] URL 확인

### 8️⃣ 베타 테스트
- [ ] TestFlight 설정 (iOS)
  - [ ] 빌드 업로드
  - [ ] 테스터 그룹 생성
  - [ ] 초대 링크 생성
- [ ] Google Play Internal Testing
  - [ ] 테스트 트랙 생성
  - [ ] APK/AAB 업로드
  - [ ] 테스터 이메일 추가
- [ ] 테스터 모집 (10-20명)
  - [ ] 가족/친구 초대
  - [ ] 베타 테스트 커뮤니티 활용
- [ ] 테스트 시나리오 문서 작성
  - [ ] 회원가입/로그인
  - [ ] 일기 작성
  - [ ] AI 각색
  - [ ] 구독 결제
  - [ ] 구독 복원
- [ ] 피드백 수집
  - [ ] 구글 폼 생성
  - [ ] 주요 이슈 정리
- [ ] 버그 수정
  - [ ] 크리티컬 이슈 우선 해결
  - [ ] UI/UX 개선사항 반영

## 📅 Phase 3: 출시 및 심사 (Week 5-6)

### 9️⃣ 최종 빌드 준비
- [ ] 버전 번호 설정
  - [ ] Version: 1.0.0
  - [ ] Build Number: 1
- [ ] 환경변수 확인
  - [ ] SUPABASE_URL
  - [ ] SUPABASE_ANON_KEY
  - [ ] REVENUECAT_API_KEY
- [ ] 릴리즈 빌드 생성
  - [ ] Android: `flutter build appbundle --release`
  - [ ] iOS: `flutter build ipa --release`
- [ ] 빌드 테스트
  - [ ] 설치 확인
  - [ ] 주요 기능 작동 확인

### 🔟 App Store 제출 (iOS)
- [ ] App Store Connect 접속
- [ ] 새 앱 생성
  - [ ] 플랫폼: iOS
  - [ ] 이름: AI 일기
  - [ ] 기본 언어: 한국어
  - [ ] Bundle ID: com.aidiary.app
  - [ ] SKU: ai-diary-app
- [ ] 앱 정보 입력
  - [ ] 카테고리 선택
  - [ ] 콘텐츠 등급 설정
  - [ ] 가격 및 판매 지역
- [ ] 버전 정보 입력
  - [ ] 스크린샷 업로드
  - [ ] 설명 입력
  - [ ] 키워드 입력
  - [ ] 지원 URL
  - [ ] 마케팅 URL
- [ ] 빌드 업로드
  - [ ] Xcode 또는 Transporter 사용
  - [ ] 빌드 선택
- [ ] 인앱 구매 설정
  - [ ] 구독 상품 연결
  - [ ] 심사 노트 작성
- [ ] 제출 전 체크리스트
  - [ ] 개인정보처리방침 URL
  - [ ] 데모 계정 (필요시)
  - [ ] 심사 노트
- [ ] 심사 제출
  - [ ] 예상 대기 시간: 24-48시간

### 1️⃣1️⃣ Google Play 제출 (Android)
- [ ] Google Play Console 접속
- [ ] 앱 콘텐츠 설정
  - [ ] 앱 액세스 권한
  - [ ] 광고 포함 여부
  - [ ] 콘텐츠 등급
  - [ ] 타겟 연령층
  - [ ] 뉴스 앱 여부
  - [ ] 코로나19 접촉자 추적 앱 여부
- [ ] 스토어 등록정보
  - [ ] 앱 이름
  - [ ] 간단한 설명
  - [ ] 자세한 설명
  - [ ] 그래픽 자산 업로드
- [ ] 앱 릴리즈
  - [ ] 프로덕션 트랙 선택
  - [ ] AAB 파일 업로드
  - [ ] 릴리즈 이름
  - [ ] 릴리즈 노트
- [ ] 가격 및 배포
  - [ ] 국가/지역 선택
  - [ ] 무료 앱 설정
- [ ] 검토 및 출시
  - [ ] 모든 섹션 완료 확인
  - [ ] 출시 검토 시작
  - [ ] 예상 대기 시간: 2-3시간

## 📅 Phase 4: 마케팅 및 론칭 (Week 7-8)

### 1️⃣2️⃣ 론칭 준비
- [ ] 출시일 결정
  - [ ] 요일: 화/수/목 추천
  - [ ] 시간: 오전 10-11시
- [ ] 론칭 이벤트 기획
  - [ ] 첫 달 무료 체험
  - [ ] 얼리버드 할인 (연간 50% 할인)
  - [ ] 리뷰 이벤트
- [ ] 보도자료 작성
  - [ ] 앱 소개
  - [ ] 주요 기능
  - [ ] 창업 스토리
  - [ ] 연락처

### 1️⃣3️⃣ 소셜 미디어 마케팅
- [ ] 인스타그램
  - [ ] 계정 생성
  - [ ] 프로필 작성
  - [ ] 첫 게시물 준비 (9개)
  - [ ] 해시태그 리서치
    - [ ] #일기 #다이어리 #AI일기
    - [ ] #일기앱 #감성일기
  - [ ] 스토리 콘텐츠 준비
- [ ] 페이스북
  - [ ] 페이지 생성
  - [ ] 커버 이미지 제작
  - [ ] 첫 게시물 작성
- [ ] 트위터/X
  - [ ] 계정 생성
  - [ ] 프로필 설정
  - [ ] 론칭 트윗 준비
- [ ] 유튜브
  - [ ] 채널 생성
  - [ ] 앱 소개 영상 제작
  - [ ] 사용법 튜토리얼

### 1️⃣4️⃣ 커뮤니티 마케팅
- [ ] 네이버
  - [ ] 블로그 포스팅
  - [ ] 카페 홍보 (관련 카페 5개)
  - [ ] 지식iN 답변
- [ ] 커뮤니티 사이트
  - [ ] 클리앙
  - [ ] 뽐뿌
  - [ ] 디시인사이드
- [ ] 관련 커뮤니티
  - [ ] 일기/다이어리 카페
  - [ ] 자기계발 커뮤니티
  - [ ] 앱 추천 커뮤니티

### 1️⃣5️⃣ PR 및 미디어
- [ ] 언론사 연락
  - [ ] 테크 미디어 리스트 작성
  - [ ] 보도자료 발송
  - [ ] 팔로우업
- [ ] 블로거 컨택
  - [ ] 앱 리뷰 블로거 리스트
  - [ ] 제품 소개 이메일
  - [ ] 프로모션 코드 제공
- [ ] 인플루언서 협업
  - [ ] 마이크로 인플루언서 선정
  - [ ] 협업 제안서 작성
  - [ ] 계약 및 진행

## 📅 Phase 5: 출시 후 운영 (Month 2-3)

### 1️⃣6️⃣ 분석 도구 설정
- [ ] Firebase Analytics 연동
  - [ ] SDK 설치
  - [ ] 이벤트 설정
  - [ ] 전환 추적
- [ ] Firebase Crashlytics 설정
  - [ ] 크래시 리포팅 활성화
  - [ ] 알림 설정
- [ ] RevenueCat 대시보드 활용
  - [ ] 구독 지표 확인
  - [ ] 코호트 분석
- [ ] 커스텀 이벤트 추적
  - [ ] 앱 설치
  - [ ] 회원가입 완료
  - [ ] 첫 일기 작성
  - [ ] AI 각색 사용
  - [ ] 구독 시작
  - [ ] 구독 취소

### 1️⃣7️⃣ 사용자 피드백 수집
- [ ] 인앱 피드백 기능
  - [ ] 피드백 버튼 추가
  - [ ] 설문 폼 연동
- [ ] 앱스토어 리뷰 모니터링
  - [ ] 일일 리뷰 체크
  - [ ] 리뷰 답변
  - [ ] 부정적 리뷰 대응
- [ ] 사용자 인터뷰
  - [ ] 주요 사용자 선정
  - [ ] 인터뷰 진행
  - [ ] 인사이트 정리

### 1️⃣8️⃣ 업데이트 계획
- [ ] 버그 수정 (v1.0.1)
  - [ ] 크리티컬 이슈
  - [ ] 사용자 리포트 버그
- [ ] 기능 개선 (v1.1.0)
  - [ ] UI/UX 개선
  - [ ] 성능 최적화
- [ ] 새 기능 추가 (v1.2.0)
  - [ ] PDF 내보내기
  - [ ] 테마 선택
  - [ ] 일기 통계

### 1️⃣9️⃣ 수익화 최적화
- [ ] 가격 A/B 테스트
  - [ ] 월간 가격 조정
  - [ ] 연간 할인율 조정
- [ ] 프리미엄 기능 조정
  - [ ] 무료 제한 조정 (10개 → 5개?)
  - [ ] 새 프리미엄 기능 추가
- [ ] 프로모션 실행
  - [ ] 시즌 이벤트
  - [ ] 특별 할인
  - [ ] 번들 상품

## 📊 핵심 지표 모니터링

### 2️⃣0️⃣ 일일 체크 항목
- [ ] DAU (일일 활성 사용자)
- [ ] 신규 가입자 수
- [ ] 구독 전환 수
- [ ] 크래시 발생률
- [ ] 앱스토어 리뷰

### 2️⃣1️⃣ 주간 체크 항목
- [ ] WAU (주간 활성 사용자)
- [ ] 리텐션율 (1일, 7일)
- [ ] 평균 세션 시간
- [ ] ARPU (사용자당 평균 매출)
- [ ] 구독 취소율

### 2️⃣2️⃣ 월간 체크 항목
- [ ] MAU (월간 활성 사용자)
- [ ] MRR (월간 반복 매출)
- [ ] LTV (고객 생애 가치)
- [ ] CAC (고객 획득 비용)
- [ ] 30일 리텐션

## 💰 예산 관리

### 2️⃣3️⃣ 초기 비용 (필수)
- [ ] Apple Developer Program: $99/년
- [ ] Google Play Console: $25 (일회성)
- [ ] 도메인: ~$15/년
- [ ] 법무 검토: ~$200
- [ ] **총 필수 비용: ~$340**

### 2️⃣4️⃣ 월간 운영비
- [ ] Supabase Pro: $25/월
- [ ] RevenueCat: 무료 (월 $10K 이하)
- [ ] 마케팅: $100-500/월 (선택)
- [ ] **총 월간 비용: $25-525**

### 2️⃣5️⃣ 수익 목표
- [ ] 1개월차: 50명 구독자 (₩200,000)
- [ ] 3개월차: 150명 구독자 (₩600,000)
- [ ] 6개월차: 300명 구독자 (₩1,200,000)
- [ ] 12개월차: 500명 구독자 (₩2,000,000)

## 🎯 성공 지표

### 2️⃣6️⃣ 단기 목표 (3개월)
- [ ] MAU 1,000명 달성
- [ ] 구독자 100명 확보
- [ ] 앱스토어 평점 4.5 이상
- [ ] 월 매출 ₩400,000 달성

### 2️⃣7️⃣ 중기 목표 (6개월)
- [ ] MAU 5,000명 달성
- [ ] 구독자 300명 확보
- [ ] 월 매출 ₩1,200,000 달성
- [ ] 손익분기점 달성

### 2️⃣8️⃣ 장기 목표 (12개월)
- [ ] MAU 10,000명 달성
- [ ] 구독자 500명 확보
- [ ] 월 매출 ₩2,000,000 달성
- [ ] 해외 시장 진출

## 📝 메모 및 특이사항

```
[날짜] - [내용]
예: 2024-01-15 - App Store 심사 통과
```

---

**마지막 업데이트**: 2024년 월 일

**진행 상황**: ▯▯▯▯▯▯▯▯▯▯ 0/28 완료

---

## 🚨 중요 연락처 및 링크

- RevenueCat Support: support@revenuecat.com
- Supabase Support: support@supabase.io
- Apple Developer Support: https://developer.apple.com/contact/
- Google Play Console Support: https://support.google.com/googleplay/android-developer

**이 체크리스트를 매일 확인하며 하나씩 체크해 나가세요!** ✅