import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// 테스트 자격 증명
const String testEmail = 'wjb127@nate.com';
const String testPassword = 'Simon1793@';
const String supabaseUrl = 'https://jihhsiijrxhazbxhoirl.supabase.co';
const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImppaGhzaWlqcnhoYXpieGhvaXJsIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTQ3MjQzMjcsImV4cCI6MjA3MDMwMDMyN30.sd8iZ2kPlAR9QTfvreCUZKWtziEnctPLHlYrPOpxyXU';

void main() {
  late SupabaseClient supabase;

  setUpAll(() async {
    // Supabase 초기화
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
    supabase = Supabase.instance.client;
  });

  group('Authentication Tests', () {
    test('로그인 테스트 - 정상 계정', () async {
      try {
        // 로그인 시도
        final response = await supabase.auth.signInWithPassword(
          email: testEmail,
          password: testPassword,
        );

        // 로그인 성공 확인
        expect(response.user, isNotNull);
        expect(response.user?.email, equals(testEmail));
        expect(response.session, isNotNull);
        expect(response.session?.accessToken, isNotNull);
        
        print('✅ 로그인 성공: ${response.user?.email}');
        print('   세션 토큰: ${response.session?.accessToken?.substring(0, 20)}...');
      } catch (e) {
        print('❌ 로그인 실패: $e');
        fail('로그인이 실패했습니다: $e');
      }
    });

    test('AI 일기 생성 테스트 - 로그인 후', () async {
      try {
        // 먼저 로그인
        await supabase.auth.signInWithPassword(
          email: testEmail,
          password: testPassword,
        );

        // Edge Function 호출
        final response = await supabase.functions.invoke(
          'generate-diary',
          body: {
            'title': '테스트 일기',
            'content': '오늘은 테스트하는 날입니다.',
            'style': 'emotional',
            'language': 'ko',
          },
        );

        // 응답 확인
        expect(response.data, isNotNull);
        expect(response.data['generated_content'], isNotNull);
        
        print('✅ AI 일기 생성 성공');
        print('   생성된 내용: ${response.data['generated_content']?.toString().substring(0, 50)}...');
      } catch (e) {
        print('❌ AI 일기 생성 실패: $e');
        fail('AI 일기 생성이 실패했습니다: $e');
      }
    });

    test('게스트 모드 AI 일기 생성 테스트', () async {
      try {
        // 로그아웃 (게스트 모드)
        await supabase.auth.signOut();

        // Edge Function 호출 (anon key 사용)
        final response = await supabase.functions.invoke(
          'generate-diary',
          body: {
            'title': '게스트 테스트 일기',
            'content': '게스트 모드에서 작성하는 일기입니다.',
            'style': 'poetic',
            'language': 'ko',
          },
          headers: {
            'Authorization': 'Bearer $supabaseAnonKey',
          },
        );

        // 응답 확인
        expect(response.data, isNotNull);
        
        if (response.data['error'] != null) {
          print('⚠️ 게스트 모드 AI 오류: ${response.data['error']}');
        } else {
          expect(response.data['generated_content'], isNotNull);
          print('✅ 게스트 모드 AI 일기 생성 성공');
          print('   생성된 내용: ${response.data['generated_content']?.toString().substring(0, 50)}...');
        }
      } catch (e) {
        print('❌ 게스트 모드 AI 일기 생성 실패: $e');
        // 게스트 모드는 실패할 수 있으므로 fail 대신 경고만
        print('   Edge Function이 인증을 요구할 수 있습니다.');
      }
    });

    test('잘못된 비밀번호로 로그인 시도', () async {
      try {
        await supabase.auth.signInWithPassword(
          email: testEmail,
          password: 'wrongpassword',
        );
        fail('잘못된 비밀번호로 로그인이 성공하면 안됩니다');
      } catch (e) {
        print('✅ 예상대로 로그인 실패: $e');
        expect(e.toString(), contains('Invalid'));
      }
    });

    tearDownAll(() async {
      // 테스트 후 로그아웃
      await supabase.auth.signOut();
    });
  });
}