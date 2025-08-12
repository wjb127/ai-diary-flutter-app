import 'package:flutter/material.dart';

class LocalizationService extends ChangeNotifier {
  static final LocalizationService _instance = LocalizationService._internal();
  factory LocalizationService() => _instance;
  LocalizationService._internal();

  String _currentLanguage = 'ko';
  
  String get currentLanguage => _currentLanguage;
  bool get isKorean => _currentLanguage == 'ko';
  bool get isEnglish => _currentLanguage == 'en';

  void setLanguage(String languageCode) {
    if (_currentLanguage != languageCode) {
      _currentLanguage = languageCode;
      notifyListeners();
    }
  }

  void toggleLanguage() {
    setLanguage(_currentLanguage == 'ko' ? 'en' : 'ko');
  }
}

class AppLocalizations {
  final String languageCode;
  
  AppLocalizations(this.languageCode);
  
  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  // 홈 화면 번역
  String get greeting => languageCode == 'ko' ? '안녕하세요! 👋' : 'Hello! 👋';
  String get subtitle => languageCode == 'ko' 
      ? 'AI가 당신의 일상을 특별한 추억으로 만들어드려요' 
      : 'AI transforms your daily life into special memories';
  
  String get appTitle => languageCode == 'ko' ? 'AI 일기장' : 'AI Diary';
  String get appSubtitle => languageCode == 'ko' 
      ? '당신의 일상을 아름다운 추억으로' 
      : 'Transform your daily life into beautiful memories';
  
  String get howItWorksTitle => languageCode == 'ko' ? '어떻게 작동하나요?' : 'How does it work?';
  
  // 기능 소개
  String get feature1Title => languageCode == 'ko' ? '자유롭게 작성하세요' : 'Write freely';
  String get feature1Description => languageCode == 'ko' 
      ? '오늘 있었던 일을 자유롭게 작성해보세요.\n완벽하지 않아도 괜찮아요!' 
      : 'Write about your day freely.\nIt doesn\'t have to be perfect!';
  
  String get feature2Title => languageCode == 'ko' ? 'AI가 각색해드려요' : 'AI enhances your story';
  String get feature2Description => languageCode == 'ko' 
      ? '인공지능이 당신의 일상을 따뜻하고\n아름다운 추억으로 변환해줍니다.' 
      : 'AI transforms your daily moments into\nwarm and beautiful memories.';
  
  String get feature3Title => languageCode == 'ko' ? '소중한 추억 보관' : 'Preserve precious memories';
  String get feature3Description => languageCode == 'ko' 
      ? '각색된 일기들은 안전하게 보관되어\n언제든 다시 읽어볼 수 있어요.' 
      : 'Enhanced diaries are safely stored\nfor you to revisit anytime.';
  
  String get startWritingButton => languageCode == 'ko' ? '일기 작성 시작하기' : 'Start Writing Diary';
  
  // 네비게이션
  String get navHome => languageCode == 'ko' ? '홈' : 'Home';
  String get navDiary => languageCode == 'ko' ? 'AI일기장' : 'AI Diary';
  String get navProfile => languageCode == 'ko' ? '프로필' : 'Profile';
  String get navSubscription => languageCode == 'ko' ? '구독' : 'Subscription';
  
  // 일기 화면
  String get selectDate => languageCode == 'ko' ? '날짜 선택' : 'Select Date';
  String get diaryTitle => languageCode == 'ko' ? '오늘의 일기 ✍️' : 'Today\'s Diary ✍️';
  String get titleLabel => languageCode == 'ko' ? '일기 제목' : 'Diary Title';
  String get titleHint => languageCode == 'ko' ? '오늘의 제목을 입력해주세요' : 'Enter today\'s title';
  String get contentLabel => languageCode == 'ko' ? '오늘 있었던 일' : 'What happened today';
  String get contentHint => languageCode == 'ko' 
      ? '오늘 하루는 어떠셨나요? 자유롭게 적어보세요!\n완벽하지 않아도 괜찮아요 😊' 
      : 'How was your day? Write freely!\nIt doesn\'t have to be perfect 😊';
  
  String get enhanceWithAI => languageCode == 'ko' ? 'AI로 일기 각색하기' : 'Enhance with AI';
  String get aiEnhancing => languageCode == 'ko' ? 'AI가 일기를 각색하고 있어요...' : 'AI is enhancing your diary...';
  String get aiEnhancedTitle => languageCode == 'ko' ? 'AI가 각색한 일기' : 'AI Enhanced Diary';
  String get saveDiary => languageCode == 'ko' ? '일기 저장하기' : 'Save Diary';
  
  // 메시지
  String get fillAllFields => languageCode == 'ko' ? '제목과 내용을 모두 입력해주세요!' : 'Please fill in both title and content!';
  String get diaryGenerationFailed => languageCode == 'ko' ? 'AI 일기 생성 실패' : 'AI diary generation failed';
  String get diarySaved => languageCode == 'ko' ? '일기가 성공적으로 저장되었습니다! 🎉' : 'Diary saved successfully! 🎉';
  String get diarySaveFailed => languageCode == 'ko' ? '일기 저장 실패' : 'Failed to save diary';
  
  // 프로필 화면
  String get profile => languageCode == 'ko' ? '프로필' : 'Profile';
  String get guestUser => languageCode == 'ko' ? '게스트 사용자' : 'Guest User';
  String get user => languageCode == 'ko' ? '사용자' : 'User';
  String get premiumMember => languageCode == 'ko' ? '프리미엄 회원' : 'Premium Member';
  String get freeMember => languageCode == 'ko' ? '무료 회원' : 'Free Member';
  String get loginForSync => languageCode == 'ko' ? '로그인하여 데이터 동기화' : 'Login to sync data';
  String get loginSyncDesc => languageCode == 'ko' 
      ? '계정을 만들면 모든 기기에서 일기를 동기화할 수 있습니다.' 
      : 'Create an account to sync your diary across all devices.';
  String get loginSignup => languageCode == 'ko' ? '로그인 / 회원가입' : 'Login / Sign Up';
  String get subscriptionManagement => languageCode == 'ko' ? '구독 관리' : 'Subscription Management';
  String get premiumSubscription => languageCode == 'ko' ? '프리미엄 구독' : 'Premium Subscription';
  String get subscribing => languageCode == 'ko' ? '구독 중' : 'Subscribed';
  String get unlimitedDiary => languageCode == 'ko' ? '무제한 일기 작성' : 'Unlimited diary writing';
  String get restorePurchases => languageCode == 'ko' ? '구매 복원' : 'Restore Purchases';
  String get restorePurchasesDesc => languageCode == 'ko' ? '이전 구매 내역 복원' : 'Restore previous purchases';
  String get accountInfo => languageCode == 'ko' ? '계정 정보' : 'Account Info';
  String get appInfo => languageCode == 'ko' ? '앱 정보' : 'App Info';
  String get privacyPolicy => languageCode == 'ko' ? '개인정보처리방침' : 'Privacy Policy';
  String get privacyPolicyDesc => languageCode == 'ko' ? '개인정보 보호 정책' : 'Privacy protection policy';
  String get termsOfService => languageCode == 'ko' ? '이용약관' : 'Terms of Service';
  String get termsOfServiceDesc => languageCode == 'ko' ? '서비스 이용약관' : 'Service terms of use';
  String get logout => languageCode == 'ko' ? '로그아웃' : 'Logout';
  String get logoutDesc => languageCode == 'ko' ? '로그아웃되었습니다. 게스트 모드로 전환됩니다.' : 'Logged out. Switching to guest mode.';
  String get logoutError => languageCode == 'ko' ? '로그아웃 중 오류가 발생했습니다.' : 'An error occurred during logout.';
  
  // 인증 화면
  String get welcomeBack => languageCode == 'ko' ? '다시 오신 것을 환영해요! 👋' : 'Welcome back! 👋';
  String get authSubtitle => languageCode == 'ko' 
      ? 'AI 일기장에서 당신만의 특별한 추억을 만들어보세요' 
      : 'Create your special memories with AI Diary';
  String get emailLogin => languageCode == 'ko' ? '이메일로 로그인' : 'Login with Email';
  String get email => languageCode == 'ko' ? '이메일' : 'Email';
  String get emailHint => languageCode == 'ko' ? '이메일을 입력해주세요' : 'Enter your email';
  String get password => languageCode == 'ko' ? '비밀번호' : 'Password';
  String get passwordHint => languageCode == 'ko' ? '비밀번호를 입력해주세요' : 'Enter your password';
  String get login => languageCode == 'ko' ? '로그인' : 'Login';
  String get signup => languageCode == 'ko' ? '회원가입' : 'Sign Up';
  String get signupPrompt => languageCode == 'ko' ? '계정이 없으신가요?' : 'Don\'t have an account?';
  String get loginPrompt => languageCode == 'ko' ? '이미 계정이 있으신가요?' : 'Already have an account?';
  String get orContinueWith => languageCode == 'ko' ? '또는 다음으로 계속하기' : 'Or continue with';
  String get continueWithGoogle => languageCode == 'ko' ? 'Google로 계속하기' : 'Continue with Google';
  String get continueWithApple => languageCode == 'ko' ? 'Apple로 계속하기' : 'Continue with Apple';
  String get skipForNow => languageCode == 'ko' ? '지금은 건너뛰기' : 'Skip for now';
  String get skipDesc => languageCode == 'ko' ? '게스트 모드로 계속 이용하기' : 'Continue in guest mode';
  
  // 에러 메시지
  String get emailRequired => languageCode == 'ko' ? '이메일을 입력해주세요' : 'Please enter email';
  String get passwordRequired => languageCode == 'ko' ? '비밀번호를 입력해주세요' : 'Please enter password';
  String get passwordLength => languageCode == 'ko' ? '비밀번호는 6자 이상이어야 합니다' : 'Password must be at least 6 characters';
  String get authError => languageCode == 'ko' ? '인증 오류' : 'Authentication Error';
  String get loginSuccess => languageCode == 'ko' ? '로그인되었습니다! 🎉' : 'Logged in successfully! 🎉';
  String get signupSuccess => languageCode == 'ko' ? '회원가입이 완료되었습니다! 🎉' : 'Sign up completed! 🎉';
  
  // AI 관련
  String get styleOptions => languageCode == 'ko' ? '문체 선택' : 'Writing Style';
  String get emotionalStyle => languageCode == 'ko' ? '🌸 감성적 문체' : '🌸 Emotional Style';
  String get epicStyle => languageCode == 'ko' ? '⚔️ 대서사시 문체' : '⚔️ Epic Style';
  String get poeticStyle => languageCode == 'ko' ? '📜 시적 문체' : '📜 Poetic Style';
  String get humorousStyle => languageCode == 'ko' ? '😄 유머러스한 문체' : '😄 Humorous Style';
  String get philosophicalStyle => languageCode == 'ko' ? '🤔 철학적 문체' : '🤔 Philosophical Style';
  String get minimalistStyle => languageCode == 'ko' ? '⬜ 미니멀리스트' : '⬜ Minimalist';
  String get detectiveStyle => languageCode == 'ko' ? '🔍 탐정 소설 스타일' : '🔍 Detective Style';
  String get fairytaleStyle => languageCode == 'ko' ? '🧚 동화 스타일' : '🧚 Fairy Tale Style';
  String get scifiStyle => languageCode == 'ko' ? '🚀 SF 소설 스타일' : '🚀 Sci-Fi Style';
  String get historicalStyle => languageCode == 'ko' ? '📚 역사 기록 스타일' : '📚 Historical Style';

  // 날짜 형식
  String diaryDateFormat(DateTime date) {
    if (languageCode == 'ko') {
      return '${date.year}년 ${date.month}월 ${date.day}일 일기';
    } else {
      final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                     'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      return '${months[date.month - 1]} ${date.day}, ${date.year} Diary';
    }
  }
  
  String formatSelectedDate(DateTime date) {
    if (languageCode == 'ko') {
      return '${date.year}년 ${date.month.toString().padLeft(2, '0')}월 ${date.day.toString().padLeft(2, '0')}일';
    } else {
      final months = ['January', 'February', 'March', 'April', 'May', 'June',
                     'July', 'August', 'September', 'October', 'November', 'December'];
      return '${months[date.month - 1]} ${date.day}, ${date.year}';
    }
  }
}

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'ko'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale.languageCode);
  }

  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
}