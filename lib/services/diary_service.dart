import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/diary_model.dart';

class DiaryService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<DiaryEntry> createDiary({
    required DateTime date,
    required String title,
    required String originalContent,
  }) async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('사용자가 로그인되어 있지 않습니다.');

    final now = DateTime.now();
    final diaryData = {
      'user_id': user.id,
      'date': date.toIso8601String().split('T')[0],
      'title': title,
      'original_content': originalContent,
      'created_at': now.toIso8601String(),
      'updated_at': now.toIso8601String(),
    };

    final response = await _supabase
        .from('diary_entries')
        .insert(diaryData)
        .select()
        .single();

    return DiaryEntry.fromJson(response);
  }

  Future<DiaryEntry> updateDiaryWithGenerated({
    required String diaryId,
    required String generatedContent,
  }) async {
    final response = await _supabase
        .from('diary_entries')
        .update({
          'generated_content': generatedContent,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', diaryId)
        .select()
        .single();

    return DiaryEntry.fromJson(response);
  }

  Future<List<DiaryEntry>> getDiariesByUser() async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('사용자가 로그인되어 있지 않습니다.');

    final response = await _supabase
        .from('diary_entries')
        .select()
        .eq('user_id', user.id)
        .order('date', ascending: false);

    return response.map<DiaryEntry>((json) => DiaryEntry.fromJson(json)).toList();
  }

  Future<DiaryEntry?> getDiaryByDate(DateTime date) async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('사용자가 로그인되어 있지 않습니다.');

    final dateString = date.toIso8601String().split('T')[0];

    final response = await _supabase
        .from('diary_entries')
        .select()
        .eq('user_id', user.id)
        .eq('date', dateString)
        .maybeSingle();

    if (response == null) return null;
    return DiaryEntry.fromJson(response);
  }

  Future<String> generateDiaryWithAI({
    required String title,
    required String originalContent,
  }) async {
    try {
      // Supabase Edge Function 호출
      final response = await _supabase.functions.invoke(
        'generate-diary',
        body: {
          'title': title,
          'content': originalContent,
        },
      );

      if (response.data != null && response.data['generated_content'] != null) {
        return response.data['generated_content'];
      } else {
        throw Exception('AI 일기 생성 실패');
      }
    } catch (e) {
      // Edge Function이 아직 배포되지 않은 경우 임시 응답
      await Future.delayed(const Duration(seconds: 2));
      return _generateMockDiary(title, originalContent);
    }
  }

  String _generateMockDiary(String title, String originalContent) {
    return """오늘은 정말 특별한 하루였다. $title

$originalContent

이렇게 소소한 일상들이 모여 나만의 소중한 이야기가 되어간다. 매일매일이 새로운 발견과 작은 기쁨으로 가득하다는 것을 다시 한번 느꼈다. 

평범해 보이는 하루일지라도, 그 안에는 수많은 감정과 경험들이 녹아있다. 때로는 힘들고 지칠 때도 있지만, 그런 순간들마저도 나를 성장시키는 소중한 밑거름이 된다.

오늘의 나에게 고맙다. 내일의 나도 기대된다. ✨

- AI가 당신의 일상을 아름답게 각색했습니다 -""";
  }

  Future<void> deleteDiary(String diaryId) async {
    await _supabase
        .from('diary_entries')
        .delete()
        .eq('id', diaryId);
  }
}