import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ai_diary_app/services/localization_service.dart';

void main() {
  group('LocalizationService Tests', () {
    late LocalizationService localizationService;

    setUp(() {
      localizationService = LocalizationService();
    });

    test('should initialize with Korean as default language', () {
      expect(localizationService.currentLanguage, equals('ko'));
      expect(localizationService.isKorean, isTrue);
      expect(localizationService.isEnglish, isFalse);
    });

    test('should set language correctly', () {
      localizationService.setLanguage('en');
      
      expect(localizationService.currentLanguage, equals('en'));
      expect(localizationService.isKorean, isFalse);
      expect(localizationService.isEnglish, isTrue);
    });

    test('should toggle language from Korean to English', () {
      localizationService.setLanguage('ko');
      localizationService.toggleLanguage();
      
      expect(localizationService.currentLanguage, equals('en'));
      expect(localizationService.isEnglish, isTrue);
    });

    test('should toggle language from English to Korean', () {
      localizationService.setLanguage('en');
      localizationService.toggleLanguage();
      
      expect(localizationService.currentLanguage, equals('ko'));
      expect(localizationService.isKorean, isTrue);
    });

    test('should not notify listeners when setting same language', () {
      bool notified = false;
      localizationService.addListener(() {
        notified = true;
      });

      localizationService.setLanguage('ko'); // Same as default
      expect(notified, isFalse);
    });

    test('should notify listeners when changing language', () {
      bool notified = false;
      localizationService.addListener(() {
        notified = true;
      });

      localizationService.setLanguage('en');
      expect(notified, isTrue);
    });

    test('should maintain singleton pattern', () {
      final service1 = LocalizationService();
      final service2 = LocalizationService();
      
      expect(identical(service1, service2), isTrue);
    });
  });

  group('AppLocalizations Tests', () {
    test('should return Korean translations for Korean locale', () {
      final localizations = AppLocalizations('ko');
      
      expect(localizations.greeting, equals('안녕하세요! 👋'));
      expect(localizations.appTitle, equals('AI 일기장'));
      expect(localizations.navHome, equals('홈'));
      expect(localizations.navDiary, equals('AI일기장'));
    });

    test('should return English translations for English locale', () {
      final localizations = AppLocalizations('en');
      
      expect(localizations.greeting, equals('Hello! 👋'));
      expect(localizations.appTitle, equals('AI Diary'));
      expect(localizations.navHome, equals('Home'));
      expect(localizations.navDiary, equals('AI Diary'));
    });

    test('should format Korean dates correctly', () {
      final localizations = AppLocalizations('ko');
      final date = DateTime(2024, 1, 15);
      
      expect(localizations.diaryDateFormat(date), equals('2024년 1월 15일 일기'));
    });

    test('should format English dates correctly', () {
      final localizations = AppLocalizations('en');
      final date = DateTime(2024, 1, 15);
      
      expect(localizations.diaryDateFormat(date), equals('Jan 15, 2024 Diary'));
    });

    test('should handle all month abbreviations in English', () {
      final localizations = AppLocalizations('en');
      
      expect(localizations.diaryDateFormat(DateTime(2024, 1, 1)), contains('Jan'));
      expect(localizations.diaryDateFormat(DateTime(2024, 2, 1)), contains('Feb'));
      expect(localizations.diaryDateFormat(DateTime(2024, 12, 1)), contains('Dec'));
    });
  });

  group('AppLocalizationsDelegate Tests', () {
    const delegate = AppLocalizationsDelegate();

    test('should support Korean and English locales', () {
      expect(delegate.isSupported(const Locale('ko', '')), isTrue);
      expect(delegate.isSupported(const Locale('en', '')), isTrue);
      expect(delegate.isSupported(const Locale('ja', '')), isFalse);
      expect(delegate.isSupported(const Locale('fr', '')), isFalse);
    });

    test('should load AppLocalizations correctly', () async {
      final koreanLocalizations = await delegate.load(const Locale('ko', ''));
      final englishLocalizations = await delegate.load(const Locale('en', ''));
      
      expect(koreanLocalizations.languageCode, equals('ko'));
      expect(englishLocalizations.languageCode, equals('en'));
    });

    test('should not reload delegate', () {
      expect(delegate.shouldReload(delegate), isFalse);
    });
  });
}