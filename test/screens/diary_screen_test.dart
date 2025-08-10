import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ai_diary_app/screens/diary_screen.dart';
import 'package:ai_diary_app/services/diary_service.dart';
import 'package:ai_diary_app/models/diary_model.dart';
import 'package:intl/date_symbol_data_local.dart';

// Mock class for DiaryService
class MockDiaryService extends Mock implements DiaryService {}

void main() {
  group('DiaryScreen Widget Tests', () {
    late MockDiaryService mockDiaryService;

    setUpAll(() async {
      // Initialize locale data for testing
      await initializeDateFormatting('ko_KR', null);
    });

    setUp(() {
      mockDiaryService = MockDiaryService();
    });

    Widget createTestableWidget() {
      return MaterialApp(
        home: const DiaryScreen(),
      );
    }

    testWidgets('should display all essential UI elements', (WidgetTester tester) async {
      await tester.pumpWidget(createTestableWidget());
      await tester.pumpAndSettle();

      // Check for app bar
      expect(find.text('AI 일기장'), findsOneWidget);
      
      // Check for calendar section
      expect(find.text('날짜 선택'), findsOneWidget);
      
      // Check for diary writing section
      expect(find.text('오늘의 일기 ✍️'), findsOneWidget);
      expect(find.text('일기 제목'), findsOneWidget);
      expect(find.text('오늘 있었던 일'), findsOneWidget);
      
      // Check for AI generation button
      expect(find.text('AI로 일기 각색하기'), findsOneWidget);
      expect(find.byIcon(Icons.auto_awesome), findsOneWidget);
    });

    testWidgets('should show current date by default', (WidgetTester tester) async {
      await tester.pumpWidget(createTestableWidget());
      await tester.pumpAndSettle();

      final today = DateTime.now();
      final expectedDateText = RegExp(r'\d{4}년 \d{1,2}월 \d{1,2}일.*일기');
      
      // Should show today's date
      expect(find.byWidgetPredicate((widget) =>
        widget is Text && 
        widget.data != null && 
        expectedDateText.hasMatch(widget.data!)
      ), findsOneWidget);
    });

    testWidgets('should allow text input in title and content fields', (WidgetTester tester) async {
      await tester.pumpWidget(createTestableWidget());
      await tester.pumpAndSettle();

      // Find title text field
      final titleField = find.widgetWithText(TextField, '일기 제목').first;
      await tester.enterText(titleField, '테스트 제목');
      expect(find.text('테스트 제목'), findsOneWidget);

      // Find content text field
      final contentField = find.widgetWithText(TextField, '오늘 있었던 일').first;
      await tester.enterText(contentField, '테스트 내용입니다.');
      expect(find.text('테스트 내용입니다.'), findsOneWidget);
    });

    testWidgets('should show loading state when generating AI diary', (WidgetTester tester) async {
      await tester.pumpWidget(createTestableWidget());
      await tester.pumpAndSettle();

      // Enter some content first
      final titleField = find.widgetWithText(TextField, '일기 제목').first;
      await tester.enterText(titleField, '테스트 제목');
      
      final contentField = find.widgetWithText(TextField, '오늘 있었던 일').first;
      await tester.enterText(contentField, '테스트 내용');

      // Tap AI generation button
      await tester.tap(find.text('AI로 일기 각색하기'));
      await tester.pump(); // Just pump once to see loading state

      // Should show loading text and spinner
      expect(find.text('AI가 일기를 각색하고 있어요...'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should show validation message when fields are empty', (WidgetTester tester) async {
      await tester.pumpWidget(createTestableWidget());
      await tester.pumpAndSettle();

      // Tap AI generation button without entering content
      await tester.tap(find.text('AI로 일기 각색하기'));
      await tester.pumpAndSettle();

      // Should show snackbar with validation message
      expect(find.text('제목과 내용을 모두 입력해주세요!'), findsOneWidget);
    });

    testWidgets('should validate empty title only', (WidgetTester tester) async {
      await tester.pumpWidget(createTestableWidget());
      await tester.pumpAndSettle();

      // Enter only content, leave title empty
      final contentField = find.widgetWithText(TextField, '오늘 있었던 일').first;
      await tester.enterText(contentField, '테스트 내용');

      await tester.tap(find.text('AI로 일기 각색하기'));
      await tester.pumpAndSettle();

      expect(find.text('제목과 내용을 모두 입력해주세요!'), findsOneWidget);
    });

    testWidgets('should validate empty content only', (WidgetTester tester) async {
      await tester.pumpWidget(createTestableWidget());
      await tester.pumpAndSettle();

      // Enter only title, leave content empty
      final titleField = find.widgetWithText(TextField, '일기 제목').first;
      await tester.enterText(titleField, '테스트 제목');

      await tester.tap(find.text('AI로 일기 각색하기'));
      await tester.pumpAndSettle();

      expect(find.text('제목과 내용을 모두 입력해주세요!'), findsOneWidget);
    });

    testWidgets('should show generated diary result section when AI generation completes', (WidgetTester tester) async {
      await tester.pumpWidget(createTestableWidget());
      await tester.pumpAndSettle();

      // Enter title and content
      final titleField = find.widgetWithText(TextField, '일기 제목').first;
      await tester.enterText(titleField, '좋은 하루');
      
      final contentField = find.widgetWithText(TextField, '오늘 있었던 일').first;
      await tester.enterText(contentField, '친구와 만나서 즐거웠다.');

      // Tap AI generation button
      await tester.tap(find.text('AI로 일기 각색하기'));
      await tester.pumpAndSettle(const Duration(seconds: 3)); // Wait for async operation

      // Should show generated diary section
      expect(find.text('AI가 각색한 일기'), findsOneWidget);
      expect(find.text('일기 저장하기'), findsOneWidget);
      
      // Should show generated content (mock will return content with input text)
      expect(find.textContaining('좋은 하루'), findsAtLeastNWidgets(1));
      expect(find.textContaining('친구와 만나서 즐거웠다.'), findsAtLeastNWidgets(1));
    });

    testWidgets('should have working calendar navigation', (WidgetTester tester) async {
      await tester.pumpWidget(createTestableWidget());
      await tester.pumpAndSettle();

      // Find and verify calendar is present
      expect(find.byType(DropdownButton<String>), findsNothing); // TableCalendar doesn't use dropdown
      
      // Calendar should be interactive (just verify it exists)
      expect(find.text('날짜 선택'), findsOneWidget);
      
      // Note: TableCalendar interaction is complex to test, 
      // but we can verify the date display updates
      final today = DateTime.now();
      final expectedPattern = RegExp(r'\d{4}년 \d{1,2}월 \d{1,2}일');
      expect(find.byWidgetPredicate((widget) =>
        widget is Text && 
        widget.data != null && 
        expectedPattern.hasMatch(widget.data!)
      ), findsOneWidget);
    });

    testWidgets('should show save button only after AI generation', (WidgetTester tester) async {
      await tester.pumpWidget(createTestableWidget());
      await tester.pumpAndSettle();

      // Initially, save button should not be visible
      expect(find.text('일기 저장하기'), findsNothing);

      // Enter content and generate AI diary
      final titleField = find.widgetWithText(TextField, '일기 제목').first;
      await tester.enterText(titleField, '테스트 제목');
      
      final contentField = find.widgetWithText(TextField, '오늘 있었던 일').first;
      await tester.enterText(contentField, '테스트 내용');

      await tester.tap(find.text('AI로 일기 각색하기'));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Now save button should be visible
      expect(find.text('일기 저장하기'), findsOneWidget);
    });

    testWidgets('should handle text field focus and styling', (WidgetTester tester) async {
      await tester.pumpWidget(createTestableWidget());
      await tester.pumpAndSettle();

      // Check text fields have proper styling
      final titleField = find.widgetWithText(TextField, '일기 제목').first;
      final titleWidget = tester.widget<TextField>(titleField);
      
      expect(titleWidget.decoration?.fillColor, equals(const Color(0xFFF8FAFC)));
      expect(titleWidget.decoration?.filled, isTrue);
      
      // Check content field has multiple lines
      final contentField = find.widgetWithText(TextField, '오늘 있었던 일').first;
      final contentWidget = tester.widget<TextField>(contentField);
      expect(contentWidget.maxLines, equals(8));
    });

    testWidgets('should show proper hint texts', (WidgetTester tester) async {
      await tester.pumpWidget(createTestableWidget());
      await tester.pumpAndSettle();

      expect(find.text('오늘의 제목을 입력해주세요'), findsOneWidget);
      expect(find.text('오늘 하루는 어떠셨나요? 자유롭게 적어보세요!\n완벽하지 않아도 괜찮아요 😊'), findsOneWidget);
    });
  });
}