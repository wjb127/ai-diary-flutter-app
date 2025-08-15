import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ai_diary_app/services/auth_service.dart';
import 'package:ai_diary_app/services/diary_service.dart';
import 'package:ai_diary_app/models/diary_model.dart';

void main() {
  group('전체 API 통합 테스트', () {
    late AuthService authService;
    late DiaryService diaryService;

    setUpAll(() async {
      // Supabase 초기화
      await Supabase.initialize(
        url: 'https://jihhsiijrxhazbxhoirl.supabase.co',
        anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImppaGhzaWlqcnhoYXpieGhvaXJsIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTQ3MjQzMjcsImV4cCI6MjA3MDMwMDMyN30.sd8iZ2kPlAR9QTfvreCUZKWtziEnctPLHlYrPOpxyXU',
      );
      
      authService = AuthService();
      diaryService = DiaryService();
    });

    test('1. AuthService 초기화 및 게스트 모드 확인', () async {
      print('🔍 AuthService 초기화 테스트');
      
      // 게스트 모드 시작
      await authService.signInAsGuest();
      
      print('✅ 게스트 모드: ${authService.isGuestMode}');
      print('✅ 현재 사용자: ${authService.currentUser?.email}');
      
      expect(authService.isGuestMode, isTrue);
      expect(authService.currentUser, isNotNull);
    });

    test('2. AI 일기 생성 API 테스트', () async {
      print('🔍 AI 일기 생성 테스트');
      
      const testTitle = 'API 테스트 일기';
      const testContent = '오늘은 전체 API를 테스트해보는 날이다. 모든 기능이 잘 작동하길 바란다.';
      
      final generatedContent = await diaryService.generateDiaryWithAI(
        title: testTitle,
        originalContent: testContent,
        style: 'emotional',
        language: 'ko',
      );
      
      print('✅ 원본 내용: $testContent');
      print('✅ AI 생성 내용: $generatedContent');
      
      expect(generatedContent, isNotNull);
      expect(generatedContent, isNotEmpty);
      expect(generatedContent.length, greaterThan(10));
    });

    test('3. 게스트 모드에서 일기 생성 시도 (실패 예상)', () async {
      print('🔍 게스트 모드 일기 생성 테스트');
      
      const testTitle = '게스트 모드 테스트';
      const testContent = '게스트 모드에서는 저장이 안 되어야 한다.';
      
      try {
        await diaryService.createDiary(
          date: DateTime.now(),
          title: testTitle,
          originalContent: testContent,
        );
        fail('게스트 모드에서 일기 생성이 성공하면 안 됨');
      } catch (e) {
        print('✅ 예상된 오류: $e');
        expect(e.toString(), contains('게스트'));
      }
    });

    test('4. isGuestMode 로직 테스트', () async {
      print('🔍 isGuestMode 로직 테스트');
      
      // 게스트 모드 확인
      expect(authService.isGuestMode, isTrue);
      print('✅ 게스트 모드 상태: ${authService.isGuestMode}');
      
      // 실제 사용자 정보 확인
      final user = authService.currentUser;
      print('✅ 사용자 정보: ${user?.email}');
      print('✅ 사용자 ID: ${user?.id}');
      
      // 게스트 사용자인지 확인
      if (user?.email == 'guest@aidiary.app') {
        print('✅ 게스트 사용자 확인됨');
      } else {
        print('⚠️ 실제 로그인된 사용자: ${user?.email}');
      }
    });

    test('5. DiaryService 메서드 존재 확인', () async {
      print('🔍 DiaryService 메서드 확인');
      
      // 필요한 메서드들이 존재하는지 확인
      expect(diaryService.createDiary, isNotNull);
      expect(diaryService.updateDiaryWithGenerated, isNotNull);
      expect(diaryService.generateDiaryWithAI, isNotNull);
      expect(diaryService.getDiaryByDate, isNotNull);
      
      print('✅ 모든 DiaryService 메서드 존재 확인');
    });

    test('6. AuthService 상태 변화 테스트', () async {
      print('🔍 AuthService 상태 변화 테스트');
      
      // 초기 상태
      print('초기 게스트 모드: ${authService.isGuestMode}');
      
      // Supabase 인증 상태 확인
      final supabaseUser = authService.currentUser;
      print('Supabase 사용자: ${supabaseUser?.email}');
      
      // isGuestMode 로직 분석
      if (supabaseUser != null && supabaseUser.email != null && supabaseUser.email != 'guest@aidiary.app') {
        print('⚠️ 실제 로그인된 사용자가 있지만 게스트 모드로 인식됨');
        print('사용자 이메일: ${supabaseUser.email}');
        print('익명 사용자 여부: ${supabaseUser.isAnonymous}');
      }
      
      expect(authService.currentUser, isNotNull);
    });

    test('7. 전체 플로우 시뮬레이션', () async {
      print('🔍 전체 플로우 시뮬레이션');
      
      // 1. 일기 작성
      const title = '완전한 플로우 테스트';
      const content = '이것은 전체 플로우를 테스트하는 일기입니다.';
      
      // 2. AI 생성
      final aiContent = await diaryService.generateDiaryWithAI(
        title: title,
        originalContent: content,
        style: 'emotional',
        language: 'ko',
      );
      
      print('AI 생성 완료: ${aiContent.substring(0, 50)}...');
      
      // 3. 저장 시도 (게스트 모드에서는 실패해야 함)
      print('현재 인증 상태: isGuestMode=${authService.isGuestMode}');
      
      if (authService.isGuestMode) {
        print('✅ 게스트 모드이므로 저장 불가 (정상)');
      } else {
        print('⚠️ 로그인 상태이므로 저장 가능');
        
        try {
          final diary = await diaryService.createDiary(
            date: DateTime.now(),
            title: title,
            originalContent: content,
          );
          
          // AI 내용 업데이트
          await diaryService.updateDiaryWithGenerated(
            diaryId: diary.id,
            generatedContent: aiContent,
          );
          
          print('✅ 일기 저장 성공: ${diary.id}');
        } catch (e) {
          print('❌ 일기 저장 실패: $e');
        }
      }
    });
  });
}