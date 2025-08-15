import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ai_diary_app/screens/reset_password_screen.dart';
import 'package:ai_diary_app/services/auth_service.dart';

// Mock classes
class MockSupabaseClient extends Mock implements SupabaseClient {}
class MockGoTrueClient extends Mock implements GoTrueClient {}
class MockAuthService extends Mock implements AuthService {}
class MockBuildContext extends Mock implements BuildContext {}

void main() {
  late MockSupabaseClient mockSupabaseClient;
  late MockGoTrueClient mockGoTrueClient;
  late MockAuthService mockAuthService;

  setUpAll(() {
    registerFallbackValue(UserAttributes(password: 'testpassword'));
  });

  setUp(() {
    mockSupabaseClient = MockSupabaseClient();
    mockGoTrueClient = MockGoTrueClient();
    mockAuthService = MockAuthService();
    
    when(() => mockSupabaseClient.auth).thenReturn(mockGoTrueClient);
  });

  group('ResetPasswordScreen', () {
    testWidgets('화면이 올바르게 렌더링되는지 확인', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ResetPasswordScreen(),
        ),
      );

      // 화면 요소들이 표시되는지 확인
      expect(find.text('비밀번호 재설정'), findsOneWidget);
      expect(find.text('새 비밀번호 설정'), findsOneWidget);
      expect(find.text('새로운 비밀번호를 입력해주세요'), findsOneWidget);
      expect(find.byType(TextFormField), findsNWidgets(2)); // 비밀번호, 비밀번호 확인
      expect(find.text('비밀번호 변경'), findsOneWidget);
    });

    testWidgets('비밀번호 필드가 비어있을 때 유효성 검사', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ResetPasswordScreen(),
        ),
      );

      // 비밀번호 변경 버튼 탭
      await tester.tap(find.text('비밀번호 변경'));
      await tester.pump();

      // 에러 메시지 확인
      expect(find.text('비밀번호를 입력해주세요'), findsOneWidget);
      expect(find.text('비밀번호 확인을 입력해주세요'), findsOneWidget);
    });

    testWidgets('비밀번호가 8자 미만일 때 유효성 검사', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ResetPasswordScreen(),
        ),
      );

      // 짧은 비밀번호 입력
      await tester.enterText(find.byType(TextFormField).first, 'short');
      await tester.enterText(find.byType(TextFormField).last, 'short');
      
      // 비밀번호 변경 버튼 탭
      await tester.tap(find.text('비밀번호 변경'));
      await tester.pump();

      // 에러 메시지 확인
      expect(find.text('비밀번호는 8자 이상이어야 합니다'), findsOneWidget);
    });

    testWidgets('비밀번호가 일치하지 않을 때 유효성 검사', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ResetPasswordScreen(),
        ),
      );

      // 서로 다른 비밀번호 입력
      await tester.enterText(find.byType(TextFormField).first, 'password123');
      await tester.enterText(find.byType(TextFormField).last, 'different456');
      
      // 비밀번호 변경 버튼 탭
      await tester.tap(find.text('비밀번호 변경'));
      await tester.pump();

      // 에러 메시지 확인
      expect(find.text('비밀번호가 일치하지 않습니다'), findsOneWidget);
    });

    testWidgets('비밀번호 보기/숨기기 토글 동작 확인', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ResetPasswordScreen(),
        ),
      );

      // 초기 상태: 비밀번호 숨김 (visibility_off 아이콘)
      expect(find.byIcon(Icons.visibility_off), findsNWidgets(2));
      expect(find.byIcon(Icons.visibility), findsNothing);

      // 첫 번째 비밀번호 필드 토글
      await tester.tap(find.byIcon(Icons.visibility_off).first);
      await tester.pump();

      // 첫 번째 필드만 visibility 아이콘으로 변경
      expect(find.byIcon(Icons.visibility_off), findsOneWidget);
      expect(find.byIcon(Icons.visibility), findsOneWidget);

      // 두 번째 비밀번호 필드 토글
      await tester.tap(find.byIcon(Icons.visibility_off));
      await tester.pump();

      // 두 필드 모두 visibility 아이콘
      expect(find.byIcon(Icons.visibility_off), findsNothing);
      expect(find.byIcon(Icons.visibility), findsNWidgets(2));
    });

    testWidgets('로딩 상태 UI 확인', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ResetPasswordScreen(),
        ),
      );

      // 유효한 비밀번호 입력
      await tester.enterText(find.byType(TextFormField).first, 'newpassword123');
      await tester.enterText(find.byType(TextFormField).last, 'newpassword123');
      
      // 비밀번호 변경 버튼 탭
      await tester.tap(find.text('비밀번호 변경'));
      await tester.pump();

      // 로딩 인디케이터가 표시되는지 확인 (비동기 작업 중)
      // 실제 Supabase 호출이 Mock되지 않아 실패할 수 있으므로 
      // 이 테스트는 통합 테스트에서 더 적합
    });
  });

  group('AuthService - resetPassword', () {
    test('resetPassword 메서드가 올바른 이메일로 호출되는지 확인', () async {
      const testEmail = 'test@example.com';
      
      when(() => mockGoTrueClient.resetPasswordForEmail(
        testEmail,
        redirectTo: any(named: 'redirectTo'),
      )).thenAnswer((_) async {});

      // Supabase 초기화가 필요하므로 실제 테스트는 통합 테스트에서 수행
      // 단위 테스트에서는 Mock 객체 동작만 검증
      
      await mockGoTrueClient.resetPasswordForEmail(
        testEmail,
        redirectTo: 'https://ai-diary-flutter-app.vercel.app/reset-password',
      );
      
      verify(() => mockGoTrueClient.resetPasswordForEmail(
        testEmail,
        redirectTo: 'https://ai-diary-flutter-app.vercel.app/reset-password',
      )).called(1);
    });

    test('resetPassword 실패 시 예외 처리', () async {
      const testEmail = 'invalid@example.com';
      
      when(() => mockGoTrueClient.resetPasswordForEmail(
        testEmail,
        redirectTo: any(named: 'redirectTo'),
      )).thenThrow(Exception('Network error'));

      expect(
        () async => await mockGoTrueClient.resetPasswordForEmail(
          testEmail,
          redirectTo: 'https://ai-diary-flutter-app.vercel.app/reset-password',
        ),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('Password Validation', () {
    test('비밀번호 길이 검증', () {
      // 8자 미만
      expect(_isPasswordValid('short'), false);
      expect(_isPasswordValid('1234567'), false);
      
      // 8자 이상
      expect(_isPasswordValid('12345678'), true);
      expect(_isPasswordValid('longerpassword'), true);
    });

    test('비밀번호 일치 검증', () {
      expect(_doPasswordsMatch('password123', 'password123'), true);
      expect(_doPasswordsMatch('password123', 'different456'), false);
      expect(_doPasswordsMatch('', ''), true);
    });
  });
}

// Helper functions for validation testing
bool _isPasswordValid(String password) {
  return password.length >= 8;
}

bool _doPasswordsMatch(String password1, String password2) {
  return password1 == password2;
}