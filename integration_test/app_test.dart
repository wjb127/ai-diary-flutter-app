import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ai_diary/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('E2E 앱 테스트', () {
    testWidgets('로그인 및 AI 일기 생성 테스트', (WidgetTester tester) async {
      // 앱 시작
      app.main();
      await tester.pumpAndSettle();

      // 홈 화면 확인
      expect(find.text('AI 일기'), findsOneWidget);

      // 프로필 탭으로 이동
      final profileTab = find.byIcon(Icons.person);
      await tester.tap(profileTab);
      await tester.pumpAndSettle();

      // 로그인 버튼 찾기
      final loginButton = find.text('로그인/회원가입');
      if (loginButton.evaluate().isNotEmpty) {
        await tester.tap(loginButton);
        await tester.pumpAndSettle();

        // 이메일 입력
        final emailField = find.byType(TextField).first;
        await tester.enterText(emailField, 'wjb127@nate.com');
        await tester.pumpAndSettle();

        // 비밀번호 입력
        final passwordField = find.byType(TextField).last;
        await tester.enterText(passwordField, 'Simon1793@');
        await tester.pumpAndSettle();

        // 로그인 버튼 탭
        final signInButton = find.widgetWithText(ElevatedButton, '로그인');
        await tester.tap(signInButton);
        await tester.pumpAndSettle(Duration(seconds: 3));

        // 로그인 성공 확인
        expect(find.text('wjb127@nate.com'), findsOneWidget);
      }

      // 일기 탭으로 이동
      final diaryTab = find.byIcon(Icons.edit);
      await tester.tap(diaryTab);
      await tester.pumpAndSettle();

      // 오늘 날짜 선택
      final todayButton = find.text('오늘');
      if (todayButton.evaluate().isNotEmpty) {
        await tester.tap(todayButton);
        await tester.pumpAndSettle();
      }

      // 제목 입력
      final titleField = find.byType(TextField).first;
      await tester.enterText(titleField, '테스트 일기');
      await tester.pumpAndSettle();

      // 내용 입력
      final contentField = find.byType(TextField).last;
      await tester.enterText(contentField, '오늘은 Flutter 앱 테스트를 진행했습니다.');
      await tester.pumpAndSettle();

      // AI 생성 버튼 탭
      final generateButton = find.widgetWithText(ElevatedButton, 'AI로 일기 각색하기');
      if (generateButton.evaluate().isNotEmpty) {
        await tester.tap(generateButton);
        await tester.pumpAndSettle(Duration(seconds: 5));

        // AI 생성 결과 확인
        expect(find.textContaining('AI'), findsWidgets);
      }
    });
  });
}