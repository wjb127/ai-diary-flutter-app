import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  void _log(String message, [dynamic data]) {
    if (kIsWeb) {
      // ignore: avoid_print
      print('🔐 [AUTH] $message ${data != null ? '| $data' : ''}');
    }
  }

  User? get currentUser => _supabase.auth.currentUser;
  
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

  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
    } catch (e) {
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
      await _supabase.auth.signOut();
    } catch (e) {
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

  // 구글 로그인
  Future<void> signInWithGoogle() async {
    _log('구글 로그인 시도');
    
    try {
      const webClientId = '949519878688-h2ag7kbhsj18bhcjf5k2p61e4ggkdgls.apps.googleusercontent.com';
      const iosClientId = '949519878688-9n5jvlprvjgbdju2e1qngdph21u9a6g8.apps.googleusercontent.com';

      final GoogleSignIn googleSignIn = GoogleSignIn(
        clientId: iosClientId,
        serverClientId: webClientId,
      );

      final googleUser = await googleSignIn.signIn();
      final googleAuth = await googleUser!.authentication;
      final accessToken = googleAuth.accessToken;
      final idToken = googleAuth.idToken;

      if (accessToken == null) {
        throw Exception('구글 액세스 토큰을 가져올 수 없습니다');
      }
      if (idToken == null) {
        throw Exception('구글 ID 토큰을 가져올 수 없습니다');
      }

      await _supabase.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
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