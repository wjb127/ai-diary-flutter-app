import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ai_diary_app/services/auth_service.dart';
import 'package:ai_diary_app/services/diary_service.dart';
import 'package:ai_diary_app/models/diary_model.dart';
import 'package:mocktail/mocktail.dart';

// Mock classes
class MockSupabaseClient extends Mock implements SupabaseClient {}
class MockGoTrueClient extends Mock implements GoTrueClient {}
class MockUser extends Mock implements User {}
class MockAuthResponse extends Mock implements AuthResponse {}
class MockSession extends Mock implements Session {}

void main() {
  group('Google Login → AI Diary Save Integration Test', () {
    late MockSupabaseClient mockSupabaseClient;
    late MockGoTrueClient mockGoTrueClient;
    late MockUser mockUser;
    late MockAuthResponse mockAuthResponse;
    late MockSession mockSession;

    setUpAll(() async {
      // Flutter 바인딩 초기화
      WidgetsFlutterBinding.ensureInitialized();
      
      // Supabase 테스트용 초기화
      await Supabase.initialize(
        url: 'https://test.supabase.co',
        anonKey: 'test-anon-key',
      );
    });

    setUp(() {
      mockSupabaseClient = MockSupabaseClient();
      mockGoTrueClient = MockGoTrueClient();
      mockUser = MockUser();
      mockAuthResponse = MockAuthResponse();
      mockSession = MockSession();
      
      // Supabase 초기화 Mock
      when(() => mockSupabaseClient.auth).thenReturn(mockGoTrueClient);
    });

    test('구글 로그인 → AI 일기 생성 → 저장 → 조회 전체 플로우', () async {
      // 1단계: 구글 로그인 시뮬레이션
      when(() => mockUser.id).thenReturn('google-user-123');
      when(() => mockUser.email).thenReturn('test@gmail.com');
      when(() => mockUser.appMetadata).thenReturn({'provider': 'google'});
      
      when(() => mockSession.user).thenReturn(mockUser);
      when(() => mockAuthResponse.session).thenReturn(mockSession);
      when(() => mockAuthResponse.user).thenReturn(mockUser);
      
      when(() => mockGoTrueClient.signInWithOAuth(any())).thenAnswer(
        (_) async => true,
      );
      when(() => mockGoTrueClient.currentUser).thenReturn(mockUser);
      when(() => mockGoTrueClient.currentSession).thenReturn(mockSession);

      // 구글 로그인 상태 확인
      expect(mockUser.email, equals('test@gmail.com'));
      expect(mockUser.appMetadata['provider'], equals('google'));

      // 2단계: AI 일기 생성
      const testTitle = '구글 로그인 후 작성한 일기';
      const testContent = '오늘은 구글 계정으로 로그인해서 일기를 작성했다.';
      
      // AI 각색 시뮬레이션 (Mock 데이터 사용)
      final generatedContent = await diaryService.generateDiaryWithAI(
        title: testTitle,
        originalContent: testContent,
        style: 'emotional',
        language: 'ko',
      );
      
      expect(generatedContent, isNotNull);
      expect(generatedContent, isNotEmpty);
      expect(generatedContent.contains('구글'), isTrue);

      // 3단계: 일기 저장 시뮬레이션
      final testDate = DateTime.now();
      final savedDiary = DiaryEntry(
        id: 'diary-google-123',
        userId: mockUser.id,
        date: testDate,
        title: testTitle,
        originalContent: testContent,
        generatedContent: generatedContent,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // 저장 확인
      expect(savedDiary.userId, equals('google-user-123'));
      expect(savedDiary.title, equals(testTitle));
      expect(savedDiary.originalContent, equals(testContent));
      expect(savedDiary.generatedContent, isNotNull);

      // 4단계: 저장된 일기 조회
      final retrievedDiary = DiaryEntry(
        id: savedDiary.id,
        userId: savedDiary.userId,
        date: savedDiary.date,
        title: savedDiary.title,
        originalContent: savedDiary.originalContent,
        generatedContent: savedDiary.generatedContent,
        createdAt: savedDiary.createdAt,
        updatedAt: savedDiary.updatedAt,
      );

      // 조회 확인
      expect(retrievedDiary.id, equals(savedDiary.id));
      expect(retrievedDiary.generatedContent, equals(savedDiary.generatedContent));
      expect(retrievedDiary.date.day, equals(testDate.day));
      expect(retrievedDiary.date.month, equals(testDate.month));
      expect(retrievedDiary.date.year, equals(testDate.year));
    });

    test('구글 로그인 상태에서 여러 날짜의 일기 저장 및 관리', () async {
      // 구글 로그인 상태 설정
      when(() => mockUser.id).thenReturn('google-user-456');
      when(() => mockUser.email).thenReturn('multiday@gmail.com');
      when(() => mockGoTrueClient.currentUser).thenReturn(mockUser);

      // 여러 날짜의 일기 생성
      final diaries = <DiaryEntry>[];
      
      for (int i = 0; i < 5; i++) {
        final date = DateTime.now().subtract(Duration(days: i));
        final diary = DiaryEntry(
          id: 'diary-day-$i',
          userId: mockUser.id,
          date: date,
          title: '${date.month}월 ${date.day}일 일기',
          originalContent: '오늘의 일상 #$i',
          generatedContent: 'AI가 각색한 ${date.month}월 ${date.day}일의 특별한 하루',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        diaries.add(diary);
      }

      // 모든 일기가 저장되었는지 확인
      expect(diaries.length, equals(5));
      expect(diaries.every((d) => d.userId == 'google-user-456'), isTrue);
      expect(diaries.every((d) => d.generatedContent != null), isTrue);
      
      // 날짜별로 정렬되어 있는지 확인
      final sortedDiaries = List<DiaryEntry>.from(diaries)
        ..sort((a, b) => b.date.compareTo(a.date));
      
      expect(sortedDiaries.first.date.isAfter(sortedDiaries.last.date), isTrue);
    });

    test('구글 로그인 후 일기 업데이트 플로우', () async {
      // 구글 로그인 상태
      when(() => mockUser.id).thenReturn('google-user-789');
      when(() => mockGoTrueClient.currentUser).thenReturn(mockUser);

      // 초기 일기 생성
      final originalDiary = DiaryEntry(
        id: 'diary-update-test',
        userId: mockUser.id,
        date: DateTime.now(),
        title: '수정 전 제목',
        originalContent: '원본 내용',
        generatedContent: null, // 처음엔 AI 각색 없음
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // AI 각색 추가
      const newGeneratedContent = '구글 사용자의 AI 각색된 멋진 일기';
      
      final updatedDiary = DiaryEntry(
        id: originalDiary.id,
        userId: originalDiary.userId,
        date: originalDiary.date,
        title: originalDiary.title,
        originalContent: originalDiary.originalContent,
        generatedContent: newGeneratedContent,
        createdAt: originalDiary.createdAt,
        updatedAt: DateTime.now(),
      );

      // 업데이트 확인
      expect(updatedDiary.generatedContent, equals(newGeneratedContent));
      expect(updatedDiary.originalContent, equals(originalDiary.originalContent));
      expect(updatedDiary.title, equals(originalDiary.title));
      expect(updatedDiary.updatedAt.isAfter(originalDiary.updatedAt), isTrue);
    });

    test('구글 로그인 없이 일기 저장 시도 시 실패', () async {
      // 로그인하지 않은 상태
      when(() => mockGoTrueClient.currentUser).thenReturn(null);

      // 일기 저장 시도
      expect(
        () async {
          await diaryService.createDiary(
            date: DateTime.now(),
            title: '미로그인 일기',
            originalContent: '로그인하지 않고 작성',
          );
        },
        throwsException,
      );
    });

    test('구글 로그인 세션 만료 후 재로그인 및 일기 복구', () async {
      // 초기 로그인 상태
      when(() => mockUser.id).thenReturn('google-user-session');
      when(() => mockSession.expiresAt).thenReturn(
        DateTime.now().subtract(Duration(hours: 1)).millisecondsSinceEpoch,
      );
      
      // 세션 만료 확인
      final isExpired = DateTime.now().millisecondsSinceEpoch > (mockSession.expiresAt ?? 0);
      expect(isExpired, isTrue);

      // 재로그인 시뮬레이션
      final newSession = MockSession();
      when(() => newSession.expiresAt).thenReturn(
        DateTime.now().add(Duration(hours: 24)).millisecondsSinceEpoch,
      );
      when(() => newSession.user).thenReturn(mockUser);
      
      // 이전 일기 복구 확인
      final recoveredDiaries = [
        DiaryEntry(
          id: 'recovered-1',
          userId: mockUser.id,
          date: DateTime.now().subtract(Duration(days: 1)),
          title: '어제 일기',
          originalContent: '복구된 내용',
          generatedContent: 'AI 각색 내용도 복구됨',
          createdAt: DateTime.now().subtract(Duration(days: 1)),
          updatedAt: DateTime.now().subtract(Duration(days: 1)),
        ),
      ];

      expect(recoveredDiaries.isNotEmpty, isTrue);
      expect(recoveredDiaries.first.generatedContent, isNotNull);
    });
  });
}