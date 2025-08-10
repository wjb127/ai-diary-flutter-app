import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
}