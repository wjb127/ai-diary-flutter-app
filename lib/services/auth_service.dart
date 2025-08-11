import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class AuthService extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;
  bool _isGuestMode = true; // 기본적으로 게스트 모드

  void _log(String message, [dynamic data]) {
    // 모든 플랫폼에서 로그 출력 (디버깅용)
    debugPrint('🔐 [AUTH] $message ${data != null ? '| $data' : ''}');
  }

  User? get currentUser {
    if (_isGuestMode) {
      // 게스트 모드용 더미 User 객체 반환
      return _createGuestUser();
    }
    return _supabase.auth.currentUser;
  }

  User _createGuestUser() {
    // 게스트 모드를 위한 더미 User
    return User(
      id: 'guest-user-id',
      appMetadata: {},
      userMetadata: {},
      aud: 'authenticated',
      createdAt: DateTime.now().toIso8601String(),
      email: 'guest@aidiary.app',
    );
  }
  
  Stream<AuthState> get authStateStream => _supabase.auth.onAuthStateChange;

  Future<void> signInAnonymously() async {
    _log('익명 로그인 시도');
    
    try {
      final response = await _supabase.auth.signInAnonymously();
      _log('익명 로그인 성공', response.user?.id);
    } catch (e) {
      _log('익명 로그인 실패', e.toString());
      throw Exception('익명 로그인 실패: $e');
    }
  }

  Future<void> signInAsGuest() async {
    try {
      _log('게스트 모드 로그인 시도');
      _isGuestMode = true;
      _log('게스트 모드 상태 설정 완료: $_isGuestMode');
      notifyListeners();
      _log('게스트 모드 notifyListeners 완료');
    } catch (e) {
      _log('게스트 모드 로그인 실패', e.toString());
      rethrow;
    }
  }

  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    _log('로그인 시도', 'email: $email');
    
    try {
      await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      _isGuestMode = false; // 실제 로그인 시 게스트 모드 해제
      _log('이메일 로그인 성공');
      notifyListeners();
    } catch (e) {
      _log('이메일 로그인 실패', e.toString());
      throw Exception('이메일 로그인 실패: $e');
    }
  }

  Future<void> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      await _supabase.auth.signUp(
        email: email,
        password: password,
      );
    } catch (e) {
      throw Exception('이메일 회원가입 실패: $e');
    }
  }

  Future<void> signOut() async {
    try {
      if (_isGuestMode) {
        _isGuestMode = false;
        _log('게스트 모드 로그아웃');
        notifyListeners(); // 상태 변경 알림
        return;
      }
      await _supabase.auth.signOut();
      _log('로그아웃 성공');
    } catch (e) {
      _log('로그아웃 실패', e.toString());
      throw Exception('로그아웃 실패: $e');
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      await _supabase.auth.resetPasswordForEmail(email);
    } catch (e) {
      throw Exception('비밀번호 재설정 실패: $e');
    }
  }

  // 구글 로그인 (Supabase OAuth)
  Future<void> signInWithGoogle() async {
    _log('구글 로그인 시도 (Supabase OAuth)');
    
    try {
      await _supabase.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: kIsWeb 
            ? null 
            : 'com.aidiary.app://login-callback/',
        authScreenLaunchMode: LaunchMode.externalApplication,
      );
      
      _log('구글 로그인 성공');
    } catch (e) {
      _log('구글 로그인 실패', e.toString());
      throw Exception('구글 로그인 실패: $e');
    }
  }

  // 애플 로그인
  Future<void> signInWithApple() async {
    _log('애플 로그인 시도');
    
    try {
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final idToken = credential.identityToken;
      if (idToken == null) {
        throw Exception('애플 ID 토큰을 가져올 수 없습니다');
      }

      await _supabase.auth.signInWithIdToken(
        provider: OAuthProvider.apple,
        idToken: idToken,
      );

      _log('애플 로그인 성공');
    } catch (e) {
      _log('애플 로그인 실패', e.toString());
      throw Exception('애플 로그인 실패: $e');
    }
  }
}