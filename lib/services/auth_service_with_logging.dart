import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // 로깅 헬퍼 메서드
  void _log(String message, [dynamic data]) {
    final timestamp = DateTime.now().toIso8601String();
    if (kDebugMode) {
      print('🔐 [$timestamp] AuthService: $message');
      if (data != null) {
        print('📊 Data: $data');
      }
    }
    // 웹에서도 콘솔에 출력
    if (kIsWeb) {
      // ignore: avoid_print
      print('🌐 [WEB AUTH LOG] $message ${data != null ? '| Data: $data' : ''}');
    }
  }

  void _logError(String message, dynamic error) {
    final timestamp = DateTime.now().toIso8601String();
    if (kDebugMode) {
      print('❌ [$timestamp] AuthService ERROR: $message');
      print('🔴 Error: $error');
    }
    // 웹에서도 콘솔에 출력
    if (kIsWeb) {
      // ignore: avoid_print
      print('🚨 [WEB AUTH ERROR] $message | Error: $error');
    }
  }

  User? get currentUser {
    final user = _supabase.auth.currentUser;
    _log('currentUser 조회', {
      'userId': user?.id,
      'email': user?.email,
      'isAnonymous': user?.appMetadata['provider'] == 'anonymous',
      'createdAt': user?.createdAt,
    });
    return user;
  }
  
  Stream<AuthState> get authStateStream {
    _log('authStateStream 구독 시작');
    return _supabase.auth.onAuthStateChange.map((state) {
      _log('Auth State 변경', {
        'event': state.event.toString(),
        'userId': state.session?.user.id,
        'isAnonymous': state.session?.user.appMetadata['provider'] == 'anonymous',
      });
      return state;
    });
  }

  Future<void> signInAnonymously() async {
    _log('익명 로그인 시도');
    
    try {
      // Supabase URL과 Key 확인
      _log('Supabase 설정', {
        'url': _supabase.supabaseUrl,
        'hasAnonKey': _supabase.supabaseKey.isNotEmpty,
      });

      final response = await _supabase.auth.signInAnonymously();
      
      _log('익명 로그인 성공!', {
        'userId': response.user?.id,
        'session': response.session != null,
        'expiresAt': response.session?.expiresAt,
      });
    } catch (e) {
      _logError('익명 로그인 실패', e);
      throw Exception('익명 로그인 실패: $e');
    }
  }

  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    _log('이메일 로그인 시도', {'email': email});
    
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      
      _log('이메일 로그인 성공!', {
        'userId': response.user?.id,
        'email': response.user?.email,
      });
    } catch (e) {
      _logError('이메일 로그인 실패', e);
      throw Exception('이메일 로그인 실패: $e');
    }
  }

  Future<void> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    _log('이메일 회원가입 시도', {'email': email});
    
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
      );
      
      _log('이메일 회원가입 성공!', {
        'userId': response.user?.id,
        'email': response.user?.email,
      });
    } catch (e) {
      _logError('이메일 회원가입 실패', e);
      throw Exception('이메일 회원가입 실패: $e');
    }
  }

  Future<void> signOut() async {
    _log('로그아웃 시도');
    
    try {
      await _supabase.auth.signOut();
      _log('로그아웃 성공!');
    } catch (e) {
      _logError('로그아웃 실패', e);
      throw Exception('로그아웃 실패: $e');
    }
  }

  Future<void> resetPassword(String email) async {
    _log('비밀번호 재설정 시도', {'email': email});
    
    try {
      await _supabase.auth.resetPasswordForEmail(email);
      _log('비밀번호 재설정 이메일 전송 성공!');
    } catch (e) {
      _logError('비밀번호 재설정 실패', e);
      throw Exception('비밀번호 재설정 실패: $e');
    }
  }
}