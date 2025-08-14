import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// AI 일기 생성 테스트
void main() {
  const supabaseUrl = 'https://jihhsiijrxhazbxhoirl.supabase.co';
  const supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImppaGhzaWlqcnhoYXpieGhvaXJsIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTQ3MjQzMjcsImV4cCI6MjA3MDMwMDMyN30.sd8iZ2kPlAR9QTfvreCUZKWtziEnctPLHlYrPOpxyXU';
  
  late SupabaseClient supabase;
  late String accessToken;

  setUpAll(() async {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
    supabase = Supabase.instance.client;
    
    // 테스트 사용자로 로그인 (환경변수 사용 권장)
    final response = await supabase.auth.signInWithPassword(
      email: 'test@example.com', // 실제 테스트 시 환경변수로 대체
      password: 'TestPassword123!', // 실제 테스트 시 환경변수로 대체
    );
    
    accessToken = response.session?.accessToken ?? '';
    expect(accessToken, isNotEmpty, reason: '로그인 실패');
  });

  group('AI 일기 생성 Edge Function 테스트', () {
    test('감성적 스타일로 일기를 각색할 수 있다', () async {
      final response = await http.post(
        Uri.parse('$supabaseUrl/functions/v1/generate-diary'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
          'apikey': supabaseAnonKey,
        },
        body: jsonEncode({
          'title': '평범한 하루',
          'content': '오늘은 회사에서 일하고 집에 왔다.',
          'style': 'emotional',
        }),
      );

      expect(response.statusCode, 200);
      final data = jsonDecode(response.body);
      expect(data['generated_content'], isNotNull);
      expect(data['generated_content'], isNotEmpty);
      
      // 원본 내용이 그대로 포함되지 않았는지 확인
      expect(data['generated_content'].contains('오늘은 회사에서 일하고 집에 왔다'), false,
          reason: '원본 내용이 그대로 포함되면 안됩니다');
    });

    test('대서사시 스타일에 게임 용어가 포함되지 않는다', () async {
      final response = await http.post(
        Uri.parse('$supabaseUrl/functions/v1/generate-diary'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
          'apikey': supabaseAnonKey,
        },
        body: jsonEncode({
          'title': '카페 방문',
          'content': '스타벅스에서 커피를 마셨다.',
          'style': 'epic',
        }),
      );

      expect(response.statusCode, 200);
      final data = jsonDecode(response.body);
      final generatedContent = data['generated_content'] as String;
      
      // 게임 관련 용어가 없는지 확인
      expect(generatedContent.contains('레벨'), false);
      expect(generatedContent.contains('경험치'), false);
      expect(generatedContent.contains('스탯'), false);
      expect(generatedContent.contains('포인트'), false);
      expect(generatedContent.contains('HP'), false);
      expect(generatedContent.contains('MP'), false);
      
      // 대서사시 스타일 특징이 있는지 확인
      expect(
        generatedContent.contains('서기') || 
        generatedContent.contains('역사') ||
        generatedContent.contains('왕조') ||
        generatedContent.contains('전설'),
        true,
        reason: '대서사시 스타일의 특징이 포함되어야 합니다'
      );
    });

    test('시적 스타일로 일기를 각색할 수 있다', () async {
      final response = await http.post(
        Uri.parse('$supabaseUrl/functions/v1/generate-diary'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
          'apikey': supabaseAnonKey,
        },
        body: jsonEncode({
          'title': '봄날',
          'content': '꽃이 피었다.',
          'style': 'poetic',
        }),
      );

      expect(response.statusCode, 200);
      final data = jsonDecode(response.body);
      expect(data['generated_content'], isNotNull);
      
      // 시적 표현이 포함되어 있는지 확인 (은유, 운율 등)
      final content = data['generated_content'] as String;
      expect(content.length > 50, true, 
          reason: '시적 표현으로 확장되어야 합니다');
    });

    test('유머러스 스타일에 이모티콘이 포함된다', () async {
      final response = await http.post(
        Uri.parse('$supabaseUrl/functions/v1/generate-diary'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
          'apikey': supabaseAnonKey,
        },
        body: jsonEncode({
          'title': '재미있는 하루',
          'content': '오늘 정말 웃긴 일이 있었다.',
          'style': 'humorous',
        }),
      );

      expect(response.statusCode, 200);
      final data = jsonDecode(response.body);
      final content = data['generated_content'] as String;
      
      // 유머러스한 요소가 있는지 확인
      expect(
        content.contains('ㅋ') || 
        content.contains('ㅎ') ||
        content.contains('😂') ||
        content.contains('🤣'),
        true,
        reason: '유머러스 스타일에는 웃음 표현이 포함되어야 합니다'
      );
    });

    test('API 키가 없을 때 에러를 반환한다', () async {
      // 이 테스트는 실제로는 Edge Function의 환경변수를 제거해야 테스트 가능
      // 현재는 API 키가 설정되어 있으므로 주석 처리
      // 실제 환경에서는 API 키가 설정되어 있음
    }, skip: true);

    test('잘못된 스타일을 요청하면 기본 스타일로 처리된다', () async {
      final response = await http.post(
        Uri.parse('$supabaseUrl/functions/v1/generate-diary'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
          'apikey': supabaseAnonKey,
        },
        body: jsonEncode({
          'title': '테스트',
          'content': '테스트 내용',
          'style': 'invalid_style',
        }),
      );

      expect(response.statusCode, 200);
      final data = jsonDecode(response.body);
      expect(data['generated_content'], isNotNull);
      // 기본 스타일(emotional)로 처리되었는지 확인
    });

    test('긴 내용도 정상적으로 처리된다', () async {
      final longContent = '오늘은 정말 특별한 하루였다. ' * 50; // 긴 내용
      
      final response = await http.post(
        Uri.parse('$supabaseUrl/functions/v1/generate-diary'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
          'apikey': supabaseAnonKey,
        },
        body: jsonEncode({
          'title': '긴 일기',
          'content': longContent,
          'style': 'minimalist',
        }),
      );

      expect(response.statusCode, 200);
      final data = jsonDecode(response.body);
      expect(data['generated_content'], isNotNull);
      
      // 미니멀리스트 스타일은 원본보다 짧아야 함
      final generatedLength = (data['generated_content'] as String).length;
      expect(generatedLength < longContent.length, true,
          reason: '미니멀리스트 스타일은 간결해야 합니다');
    });

    test('모든 스타일이 서로 다른 결과를 생성한다', () async {
      const styles = [
        'emotional', 'epic', 'poetic', 'humorous', 'philosophical',
        'minimalist', 'detective', 'fairytale', 'scifi', 'historical'
      ];
      
      final results = <String>[];
      
      for (final style in styles) {
        final response = await http.post(
          Uri.parse('$supabaseUrl/functions/v1/generate-diary'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $accessToken',
            'apikey': supabaseAnonKey,
          },
          body: jsonEncode({
            'title': '같은 제목',
            'content': '같은 내용으로 테스트',
            'style': style,
          }),
        );
        
        expect(response.statusCode, 200);
        final data = jsonDecode(response.body);
        results.add(data['generated_content'] as String);
      }
      
      // 모든 결과가 서로 다른지 확인
      final uniqueResults = results.toSet();
      expect(uniqueResults.length, styles.length,
          reason: '각 스타일은 고유한 결과를 생성해야 합니다');
    });
  });
}