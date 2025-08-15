import 'package:flutter_test/flutter_test.dart';
import 'package:ai_diary_app/services/auth_service.dart';

void main() {
  group('AuthService 상태 테스트', () {
    late AuthService authService;

    setUp(() {
      authService = AuthService();
    });

    test('AuthService 초기화 및 게스트 모드 확인', () async {
      print('🔍 AuthService 초기화 테스트');
      
      // 게스트 모드 시작
      await authService.signInAsGuest();
      
      print('✅ 게스트 모드: ${authService.isGuestMode}');
      print('✅ 현재 사용자: ${authService.currentUser?.email}');
      
      expect(authService.isGuestMode, isTrue);
      expect(authService.currentUser, isNotNull);
    });

    test('isGuestMode 로직 상세 분석', () async {
      print('🔍 isGuestMode 로직 테스트');
      
      // 게스트 모드 설정
      await authService.signInAsGuest();
      
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
  });
}