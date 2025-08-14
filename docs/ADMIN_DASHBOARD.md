# 관리자 대시보드 사용 가이드

## 접속 방법

1. **웹 브라우저에서 접속**
   - URL: https://ai-diary-flutter-53lee85wo-seungbeen-wis-projects.vercel.app
   - 프로필 화면 → 관리자 메뉴 → 관리자 대시보드 클릭

2. **직접 URL 접속**
   - https://ai-diary-flutter-53lee85wo-seungbeen-wis-projects.vercel.app/#/admin

3. **관리자 비밀번호**
   - 비밀번호: `admin1234`
   - 보안을 위해 프로덕션 환경에서는 변경 필요

## 주요 기능

### 1. 대시보드 개요
- **전체 사용자**: 총 사용자 수 표시
- **오늘 가입**: 오늘 새로 가입한 사용자 수
- **전체 일기**: 작성된 모든 일기 수
- **오늘 일기**: 오늘 작성된 일기 수
- **최근 활동**: 최근 일기 작성 내역

### 2. 퍼널 분석 (개발 예정)
- 사용자 온보딩 퍼널 분석
- 일기 작성 프로세스 분석
- 구독 전환 퍼널 분석

### 3. 사용자 관리 (개발 예정)
- 사용자 목록 조회
- 사용자별 활동 내역
- 사용자 통계 분석

## 사용자 행동 추적 시스템

### 데이터베이스 테이블

1. **user_events**: 모든 사용자 이벤트 기록
2. **user_sessions**: 사용자 세션 정보
3. **funnel_steps**: 퍼널 단계 정의

### 추적되는 이벤트 유형

#### 앱 이벤트
- `app_open`: 앱 시작
- `app_close`: 앱 종료

#### 화면 이벤트
- `screen_view`: 화면 조회

#### 일기 이벤트
- `diary_start`: 일기 작성 시작
- `diary_content_entered`: 내용 입력
- `ai_generation_request`: AI 생성 요청
- `ai_generation_complete`: AI 생성 완료
- `diary_save`: 일기 저장

#### 구독 이벤트
- `subscription_screen_view`: 구독 화면 조회
- `product_selected`: 상품 선택
- `payment_start`: 결제 시작
- `payment_complete`: 결제 완료

#### 인증 이벤트
- `signup_start`: 회원가입 시작
- `signup_complete`: 회원가입 완료
- `login`: 로그인
- `logout`: 로그아웃

### Supabase 설정

SQL 마이그레이션 실행:
```sql
-- /supabase/migrations/002_user_analytics.sql 파일 내용을 
-- Supabase SQL Editor에서 실행
```

### Flutter 앱에서 사용법

```dart
import 'services/analytics_service.dart';

final analytics = AnalyticsService();

// 화면 조회 이벤트
await analytics.logScreenView('home');

// 일기 이벤트
await analytics.logDiaryEvent('diary_start', data: {
  'date': selectedDate.toIso8601String(),
});

// 구독 이벤트
await analytics.logSubscriptionEvent('product_selected', data: {
  'product_id': 'monthly',
  'price': 4500,
});

// 커스텀 이벤트
await analytics.logEvent('custom', 'button_click', 
  eventData: {'button_name': 'share'},
  pageUrl: '/diary'
);
```

## 보안 고려사항

1. **관리자 비밀번호 변경**
   - `/lib/screens/admin_screen.dart`의 `_adminPassword` 변경
   - 환경변수로 관리 권장

2. **관리자 이메일 제한**
   - 특정 이메일 도메인만 허용하도록 수정 가능

3. **RLS (Row Level Security)**
   - Supabase 테이블에 RLS 정책 적용됨
   - 관리자만 모든 데이터 조회 가능

## 향후 개발 계획

1. **퍼널 분석 시각화**
   - 차트 라이브러리 통합
   - 실시간 퍼널 분석 대시보드

2. **사용자 관리 기능**
   - 사용자 검색/필터
   - 사용자별 상세 정보
   - 사용자 차단/해제

3. **보고서 기능**
   - 일간/주간/월간 리포트
   - CSV 내보내기
   - 이메일 알림

4. **A/B 테스트**
   - 실험 설정 및 관리
   - 결과 분석 대시보드