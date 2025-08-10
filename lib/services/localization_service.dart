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