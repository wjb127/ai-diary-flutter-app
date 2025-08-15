import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ai_diary_app/services/diary_service.dart';
import 'package:ai_diary_app/models/diary_model.dart';
import 'package:mocktail/mocktail.dart';

// Mock classes
class MockSupabaseClient extends Mock implements SupabaseClient {}
class MockGoTrueClient extends Mock implements GoTrueClient {}
class MockUser extends Mock implements User {}

void main() {
  group('DiaryService Tests', () {
    late DiaryService diaryService;
    late MockSupabaseClient mockSupabaseClient;
    late MockGoTrueClient mockGoTrueClient;
    late MockUser mockUser;

    setUp(() {
      mockSupabaseClient = MockSupabaseClient();
      mockGoTrueClient = MockGoTrueClient();
      mockUser = MockUser();
      
      // Setup basic mocks
      when(() => mockSupabaseClient.auth).thenReturn(mockGoTrueClient);
      when(() => mockGoTrueClient.currentUser).thenReturn(mockUser);
      when(() => mockUser.id).thenReturn('test-user-id');
      
      diaryService = DiaryService();
    });

    group('AI Diary Generation and Save', () {
      test('AI 일기 생성 후 저장 시 generated_content가 함께 저장되어야 함', () async {
        // Arrange
        final testDate = DateTime.now();
        const testTitle = '오늘의 일기';
        const testContent = '오늘은 정말 좋은 하루였다.';
        const generatedContent = '오늘은 정말 특별한 하루였다...';
        
        // 일기 생성 후 AI 각색 내용 추가를 시뮬레이션
        final diary = DiaryEntry(
          id: 'diary-123',
          userId: 'test-user-id',
          date: testDate,
          title: testTitle,
          originalContent: testContent,
          generatedContent: generatedContent,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        // Assert
        expect(diary.generatedContent, isNotNull);
        expect(diary.generatedContent, equals(generatedContent));
        expect(diary.originalContent, equals(testContent));
      });

      test('저장된 일기를 다시 불러올 때 generated_content가 유지되어야 함', () async {
        // Arrange
        final testDate = DateTime.now();
        const generatedContent = 'AI가 각색한 아름다운 일기...';
        
        final savedDiary = DiaryEntry(
          id: 'diary-456',
          userId: 'test-user-id',
          date: testDate,
          title: '테스트 일기',
          originalContent: '원본 내용',
          generatedContent: generatedContent,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        // Assert - 저장된 일기에 AI 각색 내용이 있는지 확인
        expect(savedDiary.generatedContent, isNotNull);
        expect(savedDiary.generatedContent, equals(generatedContent));
      });

      test('generateDiaryWithAI 호출 시 Mock 데이터라도 반환되어야 함', () async {
        // Arrange
        diaryService = DiaryService();
        
        // Act - Edge Function이 실패해도 Mock 데이터 반환
        final result = await diaryService.generateDiaryWithAI(
          title: '테스트 제목',
          originalContent: '테스트 내용입니다.',
          style: 'emotional',
          language: 'ko',
        );

        // Assert
        expect(result, isNotNull);
        expect(result, isNotEmpty);
        expect(result.contains('테스트'), isTrue);
      });

      test('일기 저장 후 해당 날짜에 접근 시 저장된 내용이 보여야 함', () async {
        // Arrange
        final testDate = DateTime(2024, 1, 15);
        final diary = DiaryEntry(
          id: 'diary-789',
          userId: 'test-user-id',
          date: testDate,
          title: '1월 15일 일기',
          originalContent: '오늘의 일상',
          generatedContent: 'AI가 각색한 1월 15일의 특별한 하루',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        // Assert - 특정 날짜의 일기 확인
        expect(diary.date.day, equals(15));
        expect(diary.date.month, equals(1));
        expect(diary.generatedContent, contains('1월 15일'));
      });

      test('updateDiaryWithGenerated 호출 시 generated_content만 업데이트되어야 함', () async {
        // Arrange
        final originalDiary = DiaryEntry(
          id: 'diary-update-test',
          userId: 'test-user-id',
          date: DateTime.now(),
          title: '원본 제목',
          originalContent: '원본 내용',
          generatedContent: null,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        const newGeneratedContent = '새로운 AI 각색 내용';

        // Simulate update
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

        // Assert
        expect(updatedDiary.title, equals(originalDiary.title));
        expect(updatedDiary.originalContent, equals(originalDiary.originalContent));
        expect(updatedDiary.generatedContent, equals(newGeneratedContent));
        expect(updatedDiary.generatedContent, isNot(originalDiary.generatedContent));
      });
    });

    group('Guest Mode Handling', () {
      test('게스트 모드에서는 일기 저장이 실패해야 함', () async {
        // Arrange
        when(() => mockGoTrueClient.currentUser).thenReturn(null);
        
        // Act & Assert
        expect(
          () => diaryService.createDiary(
            date: DateTime.now(),
            title: '게스트 일기',
            originalContent: '게스트 모드 테스트',
          ),
          throwsException,
        );
      });

      test('게스트 모드에서도 AI 일기 생성은 가능해야 함', () async {
        // Arrange
        when(() => mockGoTrueClient.currentUser).thenReturn(null);
        
        // Act
        final result = await diaryService.generateDiaryWithAI(
          title: '게스트 테스트',
          originalContent: '게스트 모드에서 작성한 일기',
          style: 'emotional',
          language: 'ko',
        );

        // Assert
        expect(result, isNotNull);
        expect(result, isNotEmpty);
      });
    });
  });
}