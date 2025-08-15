#!/bin/bash

# Play Store 스크린샷 준비 스크립트

echo "🎨 Play Store 스크린샷 준비 중..."

# 디렉토리 생성
mkdir -p play_store/final

# 스크린샷 이름 변경 및 복사
echo "📱 스크린샷 정리 중..."

cp play_store/screenshot_01_auth.png play_store/final/01_login_ko.png
cp play_store/screenshot_02_home.png play_store/final/02_home_ko.png  
cp play_store/screenshot_03_diary.png play_store/final/03_diary_ko.png
cp play_store/screenshot_04_profile.png play_store/final/04_profile_ko.png
cp play_store/screenshot_05_subscription.png play_store/final/05_subscription_ko.png

echo "✅ 스크린샷 준비 완료!"
echo ""
echo "📊 스크린샷 정보:"
echo "- 해상도: 1080x2340"
echo "- 개수: 5개"
echo "- 위치: screenshots/play_store/final/"
echo ""
echo "📝 Play Store 업로드 체크리스트:"
echo "1. ✅ 로그인 화면"
echo "2. ✅ 홈 화면"
echo "3. ✅ 일기 작성 화면"
echo "4. ✅ 프로필 화면"
echo "5. ✅ 구독 화면"
echo ""
echo "추가로 필요한 스크린샷:"
echo "- [ ] AI 각색 결과 화면"
echo "- [ ] 달력 뷰"
echo "- [ ] 정신 건강 리소스 화면"