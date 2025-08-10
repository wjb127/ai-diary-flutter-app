import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/diary_model.dart';

class DiaryService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // 로깅 헬퍼 메서드
  void _log(String message, [dynamic data]) {
    final timestamp = DateTime.now().toIso8601String();
    if (kDebugMode) {
      print('🔍 [$timestamp] DiaryService: $message');
      if (data != null) {
        print('📊 Data: $data');
      }
    }
    // 웹에서도 콘솔에 출력
    if (kIsWeb) {
      // ignore: avoid_print
      print('🌐 [WEB LOG] $message ${data != null ? '| Data: $data' : ''}');
    }
  }

  void _logError(String message, dynamic error, [StackTrace? stackTrace]) {
    final timestamp = DateTime.now().toIso8601String();
    if (kDebugMode) {
      print('❌ [$timestamp] DiaryService ERROR: $message');
      print('🔴 Error: $error');
      if (stackTrace != null) {
        print('📍 StackTrace: $stackTrace');
      }
    }
    // 웹에서도 콘솔에 출력
    if (kIsWeb) {
      // ignore: avoid_print
      print('🚨 [WEB ERROR] $message | Error: $error');
    }
  }

  Future<DiaryEntry> createDiary({
    required DateTime date,
    required String title,
    required String originalContent,
  }) async {
    _log('createDiary 시작', {
      'date': date.toIso8601String(),
      'title': title,
      'contentLength': originalContent.length,
    });

    try {
      // 현재 사용자 확인
      final user = _supabase.auth.currentUser;
      _log('현재 사용자', {
        'userId': user?.id,
        'isAnonymous': user?.appMetadata['provider'] == 'anonymous',
        'email': user?.email,
      });

      if (user == null) {
        _logError('사용자 없음', '로그인되지 않은 상태');
        throw Exception('사용자가 로그인되어 있지 않습니다.');
      }

      final now = DateTime.now();
      final diaryData = {
        'user_id': user.id,
        'date': date.toIso8601String().split('T')[0],
        'title': title,
        'original_content': originalContent,
        'created_at': now.toIso8601String(),
        'updated_at': now.toIso8601String(),
      };

      _log('데이터베이스에 저장 시도', diaryData);

      final response = await _supabase
          .from('diary_entries')
          .insert(diaryData)
          .select()
          .single();

      _log('저장 성공!', response);
      return DiaryEntry.fromJson(response);
    } catch (e, stackTrace) {
      _logError('createDiary 실패', e, stackTrace);
      rethrow;
    }
  }

  Future<DiaryEntry> updateDiaryWithGenerated({
    required String diaryId,
    required String generatedContent,
  }) async {
    _log('updateDiaryWithGenerated 시작', {
      'diaryId': diaryId,
      'generatedContentLength': generatedContent.length,
    });

    try {
      final response = await _supabase
          .from('diary_entries')
          .update({
            'generated_content': generatedContent,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', diaryId)
          .select()
          .single();

      _log('업데이트 성공!', response);
      return DiaryEntry.fromJson(response);
    } catch (e, stackTrace) {
      _logError('updateDiaryWithGenerated 실패', e, stackTrace);
      rethrow;
    }
  }

  Future<List<DiaryEntry>> getDiariesByUser() async {
    _log('getDiariesByUser 시작');

    try {
      final user = _supabase.auth.currentUser;
      _log('현재 사용자 ID', user?.id);

      if (user == null) {
        _logError('사용자 없음', '로그인되지 않은 상태');
        throw Exception('사용자가 로그인되어 있지 않습니다.');
      }

      final response = await _supabase
          .from('diary_entries')
          .select()
          .eq('user_id', user.id)
          .order('date', ascending: false);

      _log('조회된 일기 개수', response.length);
      return response.map<DiaryEntry>((json) => DiaryEntry.fromJson(json)).toList();
    } catch (e, stackTrace) {
      _logError('getDiariesByUser 실패', e, stackTrace);
      rethrow;
    }
  }

  Future<DiaryEntry?> getDiaryByDate(DateTime date) async {
    _log('getDiaryByDate 시작', date.toIso8601String());

    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        _logError('사용자 없음', '로그인되지 않은 상태');
        throw Exception('사용자가 로그인되어 있지 않습니다.');
      }

      final dateString = date.toIso8601String().split('T')[0];
      _log('날짜로 조회', {'userId': user.id, 'date': dateString});

      final response = await _supabase
          .from('diary_entries')
          .select()
          .eq('user_id', user.id)
          .eq('date', dateString)
          .maybeSingle();

      if (response == null) {
        _log('해당 날짜 일기 없음');
        return null;
      }

      _log('일기 조회 성공', response);
      return DiaryEntry.fromJson(response);
    } catch (e, stackTrace) {
      _logError('getDiaryByDate 실패', e, stackTrace);
      rethrow;
    }
  }

  Future<String> generateDiaryWithAI({
    required String title,
    required String originalContent,
  }) async {
    _log('generateDiaryWithAI 시작', {
      'title': title,
      'contentLength': originalContent.length,
    });

    try {
      // Supabase Edge Function 호출
      _log('Edge Function 호출 시도');
      
      final response = await _supabase.functions.invoke(
        'generate-diary',
        body: {
          'title': title,
          'content': originalContent,
        },
      );

      _log('Edge Function 응답', response.data);

      if (response.data != null && response.data['generated_content'] != null) {
        _log('AI 생성 성공');
        return response.data['generated_content'];
      } else {
        throw Exception('AI 일기 생성 실패');
      }
    } catch (e) {
      _log('Edge Function 실패, Mock 데이터 사용', e.toString());
      // Edge Function이 아직 배포되지 않은 경우 임시 응답
      await Future.delayed(const Duration(seconds: 2));
      return _generateMockDiary(title, originalContent);
    }
  }

  String _generateMockDiary(String title, String originalContent) {
    _log('Mock 일기 생성');
    return """오늘은 정말 특별한 하루였다. $title

$originalContent

이렇게 소소한 일상들이 모여 나만의 소중한 이야기가 되어간다. 매일매일이 새로운 발견과 작은 기쁨으로 가득하다는 것을 다시 한번 느꼈다. 

평범해 보이는 하루일지라도, 그 안에는 수많은 감정과 경험들이 녹아있다. 때로는 힘들고 지칠 때도 있지만, 그런 순간들마저도 나를 성장시키는 소중한 밑거름이 된다.

오늘의 나에게 고맙다. 내일의 나도 기대된다. ✨

- AI가 당신의 일상을 아름답게 각색했습니다 -""";
  }

  Future<void> deleteDiary(String diaryId) async {
    _log('deleteDiary 시작', diaryId);

    try {
      await _supabase
          .from('diary_entries')
          .delete()
          .eq('id', diaryId);
      
      _log('삭제 성공');
    } catch (e, stackTrace) {
      _logError('deleteDiary 실패', e, stackTrace);
      rethrow;
    }
  }
}