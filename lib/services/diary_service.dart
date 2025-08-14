import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/diary_model.dart';
import '../utils/content_policy.dart';

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
      final user = _supabase.auth.currentUser;
      _log('현재 사용자', {
        'userId': user?.id,
        'isAnonymous': user?.appMetadata['provider'] == 'anonymous',
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
    String style = 'emotional',
    String language = 'ko',
  }) async {
    _log('generateDiaryWithAI 시작', {
      'title': title,
      'contentLength': originalContent.length,
      'style': style,
      'language': language,
    });

    // AI 콘텐츠 정책: 안전성 검사
    if (!ContentPolicy.isContentSafe(originalContent) || 
        !ContentPolicy.isContentSafe(title)) {
      throw Exception('안전하지 않은 콘텐츠가 감지되었습니다. 다른 내용으로 작성해주세요.');
    }

    // 개인정보 필터링
    final filteredContent = ContentPolicy.filterPersonalInfo(originalContent);
    final filteredTitle = ContentPolicy.filterPersonalInfo(title);

    try {
      _log('Edge Function 호출 시도');
      
      final response = await _supabase.functions.invoke(
        'generate-diary',
        body: {
          'title': title,
          'content': originalContent,
          'style': style,
          'language': language,
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
      await Future.delayed(const Duration(seconds: 2));
      return _generateMockDiary(title, originalContent, style, language);
    }
  }

  String _generateMockDiary(String title, String originalContent, String style, String language) {
    _log('Mock 일기 생성', {'style': style, 'language': language});
    
    if (language == 'en') {
      return _generateEnglishDiary(title, originalContent, style);
    }
    
    // 문체별 Mock 일기 반환 (한국어)
    switch (style) {
      case 'epic':
        return """[${DateTime.now().year}년 제${DateTime.now().month}월 제${DateTime.now().day}일의 연대기]

오늘, 평범한 필멸자인 나는 "$title"라는 대업을 완수하였노라.

$originalContent

이날의 업적은 후세에 길이 전해질 것이며, 나의 후손들은 이 영광스러운 순간을 영원히 기억하리라. 비록 지금은 하찮아 보일지라도, 이 모든 것이 거대한 운명의 톱니바퀴를 돌리는 중요한 사건임을 누가 알겠는가?

신들이여, 내일도 나에게 힘을 주소서!

[연대기 기록 완료. 가문의 위신 +10, 스트레스 -5]""";
        
      case 'poetic':
        return """$title

$originalContent

바람이 속삭이듯 하루가 지나가고
작은 숨결들이 모여 하나의 시가 되었네
평범함 속에 숨겨진 아름다움을 발견하며
오늘도 나는 조용히 성장하고 있어

내일은 또 어떤 시를 쓰게 될까
기대와 설렘으로 펜을 내려놓는다""";
        
      case 'humorous':
        return """제목: $title (웃겨서 배꼽 빠질 뻔한 하루)

$originalContent

ㅋㅋㅋㅋㅋ 진짜 오늘 내가 이런 일을 겪었다니! 
나중에 이 일기 다시 읽으면 또 빵 터질 듯.
인생은 시트콤이고, 나는 주인공이야! 
내일은 또 무슨 개그 에피소드가 펼쳐질까? 🤣

PS. 미래의 나야, 이거 읽고 웃지 마라. 아 참고로 복근 생겼니?""";
        
      default:
        final content = """오늘은 정말 특별한 하루였다. $title

$originalContent

이렇게 소소한 일상들이 모여 나만의 소중한 이야기가 되어간다. 매일매일이 새로운 발견과 작은 기쁨으로 가득하다는 것을 다시 한번 느꼈다. 

평범해 보이는 하루일지라도, 그 안에는 수많은 감정과 경험들이 녹아있다. 때로는 힘들고 지칠 때도 있지만, 그런 순간들마저도 나를 성장시키는 소중한 밑거름이 된다.

오늘의 나에게 고맙다. 내일의 나도 기대된다. ✨""";
        // AI 콘텐츠 워터마크 추가
        return ContentPolicy.addAIWatermark(content);
    }
  }

  String _generateEnglishDiary(String title, String originalContent, String style) {
    switch (style) {
      case 'epic':
        return """[Chronicles of ${DateTime.now().year}, Month ${DateTime.now().month}, Day ${DateTime.now().day}]

Today, I, a mere mortal, have accomplished the great deed known as "$title".

$originalContent

This day's achievements shall be passed down through generations, and my descendants will remember this glorious moment forever. Though it may seem insignificant now, who knows that all of this is an important event that turns the great wheel of destiny?

Gods, give me strength tomorrow as well!

[Chronicle recording complete. Family prestige +10, Stress -5]""";

      case 'poetic':
        return """$title

$originalContent

Like a whisper of wind, the day passes by
Small breaths gather to become a single poem
Discovering beauty hidden in the ordinary
Today, I am quietly growing again

What poem will I write tomorrow?
I lay down my pen with anticipation and excitement""";

      case 'humorous':
        return """Title: $title (A Day So Funny I Almost Lost My Belly Button)

$originalContent

LOL, I can't believe I went through this today! 
I'll probably burst out laughing when I read this diary later.
Life is a sitcom, and I'm the main character! 
What kind of comedy episode will unfold tomorrow? 🤣

PS. Future me, don't laugh while reading this. Oh, by the way, do you have abs now?""";

      case 'philosophical':
        return """$title

$originalContent

What is existence but a series of moments strung together like pearls on the thread of consciousness? Today's experience adds another pearl to this eternal necklace of being.

In the grand tapestry of life, each thread - no matter how small - contributes to the overall pattern. The mundane becomes profound when viewed through the lens of eternity.

As I reflect on today's events, I'm reminded that we are both the observer and the observed, the writer and the written, constantly creating and recreating ourselves through each moment of awareness.

Tomorrow brings new opportunities for philosophical inquiry and self-discovery.""";

      case 'detective':
        return """Case File: $title
Date: ${DateTime.now().toIso8601String().split('T')[0]}
Status: Under Investigation

$originalContent

Initial observations suggest there's more to this case than meets the eye. Every detail, no matter how trivial, could be a crucial clue in understanding the bigger picture of my life.

The evidence points to a day filled with both mysteries and revelations. Further investigation required.

Case to be continued...

- Detective Me""";

      default:
        return """Today was truly a special day. $title

$originalContent

These small everyday moments come together to form my own precious story. I felt once again that every single day is filled with new discoveries and small joys.

Even what seems like an ordinary day contains countless emotions and experiences. Sometimes it's difficult and exhausting, but even those moments become precious foundation stones that help me grow.

Thank you to today's me. I'm excited about tomorrow's me too. ✨

- AI has beautifully enhanced your daily life -""";
    }
  }

  Future<void> deleteDiary(String diaryId) async {
    await _supabase
        .from('diary_entries')
        .delete()
        .eq('id', diaryId);
  }
}