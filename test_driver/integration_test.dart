import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:provider/provider.dart';
import 'package:ai_diary_app/main.dart' as app;
import 'package:ai_diary_app/services/localization_service.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('App Integration Tests', () {
    testWidgets('should launch app and test language toggle functionality', (WidgetTester tester) async {
      // Launch the app
      app.main();
      await tester.pumpAndSettle();

      // Verify app launches with Korean as default
      expect(find.text('안녕하세요! 👋'), findsOneWidget);
      expect(find.text('AI 일기장'), findsOneWidget);
      expect(find.text('🇰🇷'), findsOneWidget);
      expect(find.text('KOR'), findsOneWidget);

      // Test language toggle
      await tester.tap(find.byIcon(Icons.language));
      await tester.pumpAndSettle();

      // Should switch to English
      expect(find.text('Hello! 👋'), findsOneWidget);
      expect(find.text('AI Diary'), findsOneWidget);
      expect(find.text('🇺🇸'), findsOneWidget);
      expect(find.text('ENG'), findsOneWidget);

      // Toggle back to Korean
      await tester.tap(find.byIcon(Icons.language));
      await tester.pumpAndSettle();

      // Should switch back to Korean
      expect(find.text('안녕하세요! 👋'), findsOneWidget);
      expect(find.text('AI 일기장'), findsOneWidget);
      expect(find.text('🇰🇷'), findsOneWidget);
    });

    testWidgets('should navigate between screens with correct language', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Switch to English first
      await tester.tap(find.byIcon(Icons.language));
      await tester.pumpAndSettle();

      // Navigate to diary screen
      await tester.tap(find.text('Start Writing Diary'));
      await tester.pumpAndSettle();

      // Check if diary screen maintains English language
      expect(find.text('Today\'s Diary ✍️'), findsOneWidget);

      // Navigate back to home
      await tester.tap(find.text('Home'));
      await tester.pumpAndSettle();

      // Should still be in English
      expect(find.text('Hello! 👋'), findsOneWidget);
      expect(find.text('🇺🇸'), findsOneWidget);
    });

    testWidgets('should persist language selection across navigation', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Navigate to Profile screen in Korean
      await tester.tap(find.text('프로필'));
      await tester.pumpAndSettle();

      // Navigate to Subscription screen
      await tester.tap(find.text('구독'));
      await tester.pumpAndSettle();

      // Navigate back to Home
      await tester.tap(find.text('홈'));
      await tester.pumpAndSettle();

      // Should still be in Korean
      expect(find.text('안녕하세요! 👋'), findsOneWidget);
      expect(find.text('🇰🇷'), findsOneWidget);

      // Now switch to English
      await tester.tap(find.byIcon(Icons.language));
      await tester.pumpAndSettle();

      // Navigate through screens in English
      await tester.tap(find.text('AI Diary'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Profile'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Home'));
      await tester.pumpAndSettle();

      // Should maintain English
      expect(find.text('Hello! 👋'), findsOneWidget);
      expect(find.text('🇺🇸'), findsOneWidget);
    });

    testWidgets('should handle rapid language toggles correctly', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Rapid toggle test
      for (int i = 0; i < 5; i++) {
        await tester.tap(find.byIcon(Icons.language));
        await tester.pumpAndSettle();
        
        if (i % 2 == 0) {
          // Should be English
          expect(find.text('Hello! 👋'), findsOneWidget);
        } else {
          // Should be Korean
          expect(find.text('안녕하세요! 👋'), findsOneWidget);
        }
      }
    });

    testWidgets('should maintain responsive design across languages', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Test different screen sizes
      await tester.binding.setSurfaceSize(const Size(400, 800));
      await tester.pumpAndSettle();

      // Verify Korean layout
      expect(find.text('안녕하세요! 👋'), findsOneWidget);

      // Switch to English
      await tester.tap(find.byIcon(Icons.language));
      await tester.pumpAndSettle();

      // Verify English layout adapts correctly
      expect(find.text('Hello! 👋'), findsOneWidget);
      
      // Test wider screen
      await tester.binding.setSurfaceSize(const Size(1200, 800));
      await tester.pumpAndSettle();

      // Should still show correctly with responsive wrapper
      expect(find.text('Hello! 👋'), findsOneWidget);
    });
  });
}