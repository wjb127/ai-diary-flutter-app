import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ai_diary_app/services/diary_service.dart';
import 'package:ai_diary_app/models/diary_model.dart';

// Mock classes
class MockSupabaseClient extends Mock implements SupabaseClient {}
class MockGoTrueClient extends Mock implements GoTrueClient {}
class MockUser extends Mock implements User {}
class MockQueryBuilder extends Mock implements SupabaseQueryBuilder {}
class MockFilterBuilder extends Mock implements PostgrestFilterBuilder<PostgrestList> {}
class MockFunctionsClient extends Mock implements FunctionsClient {}
class MockFunctionResponse extends Mock implements FunctionResponse {}

void main() {
  group('DiaryService Tests', () {
    late DiaryService diaryService;
    late MockSupabaseClient mockSupabaseClient;
    late MockGoTrueClient mockGoTrueClient;
    late MockUser mockUser;
    late MockQueryBuilder mockQueryBuilder;
    late MockFilterBuilder mockFilterBuilder;
    late MockFunctionsClient mockFunctionsClient;
    late MockFunctionResponse mockFunctionResponse;

    setUpAll(() {
      registerFallbackValue(<String, dynamic>{});
      registerFallbackValue(DateTime.now());
    });

    setUp(() {
      mockSupabaseClient = MockSupabaseClient();
      mockGoTrueClient = MockGoTrueClient();
      mockUser = MockUser();
      mockQueryBuilder = MockQueryBuilder();
      mockFilterBuilder = MockFilterBuilder();
      mockFunctionsClient = MockFunctionsClient();
      mockFunctionResponse = MockFunctionResponse();
      
      // Setup Supabase singleton mock
      when(() => mockSupabaseClient.auth).thenReturn(mockGoTrueClient);
      when(() => mockSupabaseClient.from(any())).thenReturn(mockQueryBuilder);
      when(() => mockSupabaseClient.functions).thenReturn(mockFunctionsClient);
      when(() => mockGoTrueClient.currentUser).thenReturn(mockUser);
      when(() => mockUser.id).thenReturn('test-user-id');

      diaryService = DiaryService();
    });

    group('generateDiaryWithAI', () {
      test('should generate mock diary when Edge Function fails', () async {
        // Arrange
        when(() => mockFunctionsClient.invoke(
          'generate-diary',
          body: any(named: 'body'),
        )).thenThrow(Exception('Network error'));

        // Act
        final result = await diaryService.generateDiaryWithAI(
          title: 'Test Title',
          originalContent: 'Test content',
        );

        // Assert
        expect(result, contains('오늘은 정말 특별한 하루였다. Test Title'));
        expect(result, contains('Test content'));
        expect(result, contains('AI가 당신의 일상을 아름답게 각색했습니다'));
        expect(result.length, greaterThan(100)); // Should be a substantial diary entry
      });

      test('should return generated content from Edge Function when successful', () async {
        // Arrange
        final mockResponse = {'generated_content': 'AI generated diary content'};
        when(() => mockFunctionResponse.data).thenReturn(mockResponse);
        when(() => mockFunctionsClient.invoke(
          'generate-diary',
          body: any(named: 'body'),
        )).thenAnswer((_) async => mockFunctionResponse);

        // Act
        final result = await diaryService.generateDiaryWithAI(
          title: 'Test Title',
          originalContent: 'Test content',
        );

        // Assert
        expect(result, equals('AI generated diary content'));
      });

      test('should throw exception when Edge Function returns invalid response', () async {
        // Arrange
        final mockResponse = {'error': 'Invalid request'};
        when(() => mockFunctionResponse.data).thenReturn(mockResponse);
        when(() => mockFunctionsClient.invoke(
          'generate-diary',
          body: any(named: 'body'),
        )).thenAnswer((_) async => mockFunctionResponse);

        // Act & Assert
        expect(
          () => diaryService.generateDiaryWithAI(
            title: 'Test Title',
            originalContent: 'Test content',
          ),
          throwsException,
        );
      });
    });

    group('Mock diary generation', () {
      test('should generate realistic diary content with user input', () {
        // Act
        final result = diaryService.generateDiaryWithAI(
          title: '친구와 카페에서 만남',
          originalContent: '오늘 친구랑 카페가서 커피마시고 수다떨었다.',
        );

        // Assert - Wait for the result since it's async with delay
        result.then((generatedDiary) {
          expect(generatedDiary, contains('친구와 카페에서 만남'));
          expect(generatedDiary, contains('오늘 친구랑 카페가서 커피마시고 수다떨었다.'));
          expect(generatedDiary, contains('오늘은 정말 특별한 하루였다'));
          expect(generatedDiary, contains('소소한 일상들이 모여'));
          expect(generatedDiary, contains('AI가 당신의 일상을 아름답게 각색했습니다'));
        });
      });

      test('should handle empty content gracefully', () {
        // Act
        final result = diaryService.generateDiaryWithAI(
          title: '',
          originalContent: '',
        );

        // Assert
        result.then((generatedDiary) {
          expect(generatedDiary, isA<String>());
          expect(generatedDiary.length, greaterThan(0));
          expect(generatedDiary, contains('오늘은 정말 특별한 하루였다'));
        });
      });

      test('should include inspirational content', () {
        // Act
        final result = diaryService.generateDiaryWithAI(
          title: '평범한 하루',
          originalContent: '별일없었다',
        );

        // Assert
        result.then((generatedDiary) {
          expect(generatedDiary, contains('소중한 이야기'));
          expect(generatedDiary, contains('성장시키는'));
          expect(generatedDiary, contains('기대된다'));
          expect(generatedDiary, contains('✨'));
        });
      });
    });
  });

  group('DiaryEntry Model Tests', () {
    test('should create DiaryEntry from JSON correctly', () {
      // Arrange
      final json = {
        'id': 'test-id',
        'user_id': 'user-123',
        'date': '2024-01-15',
        'title': 'Test Diary',
        'original_content': 'Original content',
        'generated_content': 'Generated content',
        'created_at': '2024-01-15T10:30:00Z',
        'updated_at': '2024-01-15T11:30:00Z',
      };

      // Act
      final diary = DiaryEntry.fromJson(json);

      // Assert
      expect(diary.id, equals('test-id'));
      expect(diary.userId, equals('user-123'));
      expect(diary.date, equals(DateTime.parse('2024-01-15')));
      expect(diary.title, equals('Test Diary'));
      expect(diary.originalContent, equals('Original content'));
      expect(diary.generatedContent, equals('Generated content'));
    });

    test('should convert DiaryEntry to JSON correctly', () {
      // Arrange
      final diary = DiaryEntry(
        id: 'test-id',
        userId: 'user-123',
        date: DateTime.parse('2024-01-15'),
        title: 'Test Diary',
        originalContent: 'Original content',
        generatedContent: 'Generated content',
        createdAt: DateTime.parse('2024-01-15T10:30:00Z'),
        updatedAt: DateTime.parse('2024-01-15T11:30:00Z'),
      );

      // Act
      final json = diary.toJson();

      // Assert
      expect(json['id'], equals('test-id'));
      expect(json['user_id'], equals('user-123'));
      expect(json['date'], equals('2024-01-15'));
      expect(json['title'], equals('Test Diary'));
      expect(json['original_content'], equals('Original content'));
      expect(json['generated_content'], equals('Generated content'));
    });

    test('should handle null generated content', () {
      // Arrange
      final json = {
        'id': 'test-id',
        'user_id': 'user-123',
        'date': '2024-01-15',
        'title': 'Test Diary',
        'original_content': 'Original content',
        'generated_content': null,
        'created_at': '2024-01-15T10:30:00Z',
        'updated_at': '2024-01-15T11:30:00Z',
      };

      // Act
      final diary = DiaryEntry.fromJson(json);

      // Assert
      expect(diary.generatedContent, isNull);
    });

    test('should create copy with updated fields', () {
      // Arrange
      final original = DiaryEntry(
        id: 'test-id',
        userId: 'user-123',
        date: DateTime.parse('2024-01-15'),
        title: 'Original Title',
        originalContent: 'Original content',
        generatedContent: null,
        createdAt: DateTime.parse('2024-01-15T10:30:00Z'),
        updatedAt: DateTime.parse('2024-01-15T11:30:00Z'),
      );

      // Act
      final updated = original.copyWith(
        title: 'Updated Title',
        generatedContent: 'New generated content',
      );

      // Assert
      expect(updated.title, equals('Updated Title'));
      expect(updated.generatedContent, equals('New generated content'));
      expect(updated.id, equals(original.id)); // Unchanged fields remain the same
      expect(updated.originalContent, equals(original.originalContent));
    });

    test('should handle various date formats', () {
      // Test different date string formats
      final testCases = [
        '2024-01-15',
        '2024-12-31',
        '2023-02-28',
      ];

      for (final dateString in testCases) {
        final json = {
          'id': 'test-id',
          'user_id': 'user-123',
          'date': dateString,
          'title': 'Test',
          'original_content': 'Content',
          'generated_content': null,
          'created_at': '${dateString}T10:30:00Z',
          'updated_at': '${dateString}T11:30:00Z',
        };

        final diary = DiaryEntry.fromJson(json);
        expect(diary.date, equals(DateTime.parse(dateString)));
      }
    });
  });
}