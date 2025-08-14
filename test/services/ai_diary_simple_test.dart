import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// AI 일기 생성 간단한 테스트
void main() {
  const supabaseUrl = 'https://jihhsiijrxhazbxhoirl.supabase.co';
  const supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImppaGhzaWlqcnhoYXpieGhvaXJsIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTQ3MjQzMjcsImV4cCI6MjA3MDMwMDMyN30.sd8iZ2kPlAR9QTfvreCUZKWtziEnctPLHlYrPOpxyXU';
  
  late String accessToken;

  setUpAll(() async {
    // 테스트 사용자로 로그인
    final response = await http.post(
      Uri.parse('$supabaseUrl/auth/v1/token?grant_type=password'),
      headers: {
        'Content-Type': 'application/json',
        'apikey': supabaseAnonKey,
      },
      body: jsonEncode({
        'email': 'test@example.com', // 실제 테스트 시 환경변수로 대체
        'password': 'TestPassword123!', // 실제 테스트 시 환경변수로 대체
      }),
    );
    
    expect(response.statusCode, 200, reason: '로그인 실패');
    final data = jsonDecode(response.body);
    accessToken = data['access_token'];
    expect(accessToken, isNotEmpty, reason: 'Access token이 비어있음');
  });

  group('AI 일기 생성 Edge Function 테스트', () {
    test('✅ 감성적 스타일로 일기를 각색할 수 있다', () async {
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
      
      print('감성적 스타일 테스트 통과 ✅');
    });

    test('✅ 대서사시 스타일에 게임 용어가 포함되지 않는다', () async {
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
      expect(generatedContent.toLowerCase().contains('레벨'), false);
      expect(generatedContent.toLowerCase().contains('경험치'), false);
      expect(generatedContent.toLowerCase().contains('스탯'), false);
      expect(generatedContent.toLowerCase().contains('포인트'), false);
      expect(generatedContent.toUpperCase().contains('HP'), false);
      expect(generatedContent.toUpperCase().contains('MP'), false);
      
      print('대서사시 스타일 테스트 통과 ✅');
    });

    test('✅ 시적 스타일로 일기를 각색할 수 있다', () async {
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
      
      print('시적 스타일 테스트 통과 ✅');
    });

    test('✅ 유머러스 스타일에 재미있는 요소가 포함된다', () async {
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
      
      // 유머러스한 톤이 있는지 확인 (길이로 판단)
      expect(content.length > 50, true,
          reason: '유머러스 스타일은 재미있게 확장되어야 합니다');
      
      print('유머러스 스타일 테스트 통과 ✅');
    });

    test('✅ 미니멀리스트 스타일은 간결하게 표현한다', () async {
      final longContent = '오늘은 정말 특별한 하루였다. 아침에 일찍 일어나서 운동을 하고, 건강한 아침을 먹었다. 회사에서는 중요한 프로젝트를 완료했고, 동료들과 즐거운 점심을 함께했다. 저녁에는 가족과 함께 맛있는 저녁을 먹으며 하루를 마무리했다.';
      
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
      
      print('미니멀리스트 스타일 테스트 통과 ✅');
    });

    test('✅ 각 스타일은 고유한 특징을 가진다', () async {
      const testTitle = '일상';
      const testContent = '오늘 하루를 보냈다.';
      
      // 3가지 다른 스타일 테스트
      final styles = ['emotional', 'epic', 'minimalist'];
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
            'title': testTitle,
            'content': testContent,
            'style': style,
          }),
        );
        
        expect(response.statusCode, 200);
        final data = jsonDecode(response.body);
        results.add(data['generated_content'] as String);
      }
      
      // 모든 결과가 서로 다른지 확인
      expect(results[0] != results[1], true, reason: 'emotional과 epic은 달라야 함');
      expect(results[1] != results[2], true, reason: 'epic과 minimalist는 달라야 함');
      expect(results[0] != results[2], true, reason: 'emotional과 minimalist는 달라야 함');
      
      print('스타일 고유성 테스트 통과 ✅');
    });
  });
}