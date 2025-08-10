import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:ai_diary_app/screens/home_screen.dart';
import 'package:ai_diary_app/services/localization_service.dart';

void main() {
  group('HomeScreen Widget Tests', () {
    late LocalizationService localizationService;

    setUp(() {
      localizationService = LocalizationService();
      localizationService.setLanguage('ko'); // Reset to Korean
    });

    Widget createTestableWidget() {
      return ChangeNotifierProvider<LocalizationService>.value(
        value: localizationService,
        child: MaterialApp.router(
          routerConfig: GoRouter(
            routes: [
              GoRoute(
                path: '/',
                builder: (context, state) => const HomeScreen(),
              ),
              GoRoute(
                path: '/diary',
                builder: (context, state) => const Scaffold(
                  body: Text('Diary Screen'),
                ),
              ),
            ],
          ),
        ),
      );
    }

    testWidgets('should display Korean content initially', (WidgetTester tester) async {
      await tester.pumpWidget(createTestableWidget());
      await tester.pumpAndSettle();

      expect(find.text('안녕하세요! 👋'), findsOneWidget);
      expect(find.text('AI 일기장'), findsOneWidget);
      expect(find.text('어떻게 작동하나요?'), findsOneWidget);
      expect(find.text('일기 작성 시작하기'), findsOneWidget);
    });

    testWidgets('should display language toggle button', (WidgetTester tester) async {
      await tester.pumpWidget(createTestableWidget());
      await tester.pumpAndSettle();

      expect(find.text('🇰🇷'), findsOneWidget);
      expect(find.text('KOR'), findsOneWidget);
      expect(find.byIcon(Icons.language), findsOneWidget);
    });

    testWidgets('should toggle to English when language button is tapped', (WidgetTester tester) async {
      await tester.pumpWidget(createTestableWidget());
      await tester.pumpAndSettle();

      // Initially Korean
      expect(find.text('안녕하세요! 👋'), findsOneWidget);
      expect(find.text('🇰🇷'), findsOneWidget);

      // Tap language toggle button
      await tester.tap(find.byIcon(Icons.language));
      await tester.pumpAndSettle();

      // Should be English now
      expect(find.text('Hello! 👋'), findsOneWidget);
      expect(find.text('🇺🇸'), findsOneWidget);
      expect(find.text('ENG'), findsOneWidget);
      expect(find.text('AI Diary'), findsOneWidget);
    });

    testWidgets('should toggle back to Korean when tapped again', (WidgetTester tester) async {
      await tester.pumpWidget(createTestableWidget());
      await tester.pumpAndSettle();

      // Toggle to English
      await tester.tap(find.byIcon(Icons.language));
      await tester.pumpAndSettle();

      // Verify English
      expect(find.text('Hello! 👋'), findsOneWidget);

      // Toggle back to Korean
      await tester.tap(find.byIcon(Icons.language));
      await tester.pumpAndSettle();

      // Should be Korean again
      expect(find.text('안녕하세요! 👋'), findsOneWidget);
      expect(find.text('🇰🇷'), findsOneWidget);
      expect(find.text('KOR'), findsOneWidget);
    });

    testWidgets('should have start writing button that is tappable', (WidgetTester tester) async {
      await tester.pumpWidget(createTestableWidget());
      await tester.pumpAndSettle();

      // Find the start writing button
      final startButton = find.text('일기 작성 시작하기');
      expect(startButton, findsOneWidget);
      
      // Verify button is tappable
      expect(tester.getCenter(startButton), isNotNull);
    });

    testWidgets('should display all feature cards', (WidgetTester tester) async {
      await tester.pumpWidget(createTestableWidget());
      await tester.pumpAndSettle();

      expect(find.text('자유롭게 작성하세요'), findsOneWidget);
      expect(find.text('AI가 각색해드려요'), findsOneWidget);
      expect(find.text('소중한 추억 보관'), findsOneWidget);
    });

    testWidgets('should display feature icons correctly', (WidgetTester tester) async {
      await tester.pumpWidget(createTestableWidget());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.edit_outlined), findsOneWidget);
      expect(find.byIcon(Icons.auto_awesome), findsOneWidget);
      expect(find.byIcon(Icons.bookmark_outline), findsOneWidget);
      expect(find.byIcon(Icons.auto_stories), findsOneWidget);
    });

    testWidgets('should update feature texts when language changes', (WidgetTester tester) async {
      await tester.pumpWidget(createTestableWidget());
      await tester.pumpAndSettle();

      // Initially Korean
      expect(find.text('자유롭게 작성하세요'), findsOneWidget);

      // Toggle to English
      await tester.tap(find.byIcon(Icons.language));
      await tester.pumpAndSettle();

      // Should show English feature texts
      expect(find.text('Write freely'), findsOneWidget);
      expect(find.text('AI enhances your story'), findsOneWidget);
      expect(find.text('Preserve precious memories'), findsOneWidget);
    });

    testWidgets('should maintain scroll functionality', (WidgetTester tester) async {
      await tester.pumpWidget(createTestableWidget());
      await tester.pumpAndSettle();

      // Find scrollable widget
      final scrollFinder = find.byType(SingleChildScrollView);
      expect(scrollFinder, findsOneWidget);

      // Test scrolling
      await tester.drag(scrollFinder, const Offset(0, -200));
      await tester.pumpAndSettle();

      // Should still be able to find elements
      expect(find.text('일기 작성 시작하기'), findsOneWidget);
    });
  });
}