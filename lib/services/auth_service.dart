import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;
  bool _isGuestMode = true; // 기본적으로 게스트 모드
  
  AuthService() {
    // 인증 상태 변경 감지
    _supabase.auth.onAuthStateChange.listen((data) {
      _log('인증 상태 변경', '${data.event} - ${data.session?.user?.email}');
      notifyListeners();
    });
  }

  void _log(String message, [dynamic data]) {
    // 모든 플랫폼에서 로그 출력 (디버깅용)
    debugPrint('🔐 [AUTH] $message ${data != null ? '| $data' : ''}');
  }

  User? get currentUser {
    final supabaseUser = _supabase.auth.currentUser;
    
    // Supabase에 실제 사용자가 로그인되어 있으면 그 사용자를 반환
    if (supabaseUser != null && !supabaseUser.isAnonymous) {
      _isGuestMode = false; // 실제 사용자가 있으면 게스트 모드 해제
      return supabaseUser;
    }
    
    // 게스트 모드이거나 익명 사용자인 경우
    if (_isGuestMode) {
      return _createGuestUser();
    }
    
    return supabaseUser;
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

  // 게스트 모드인지 확인하는 getter
  bool get isGuestMode => _isGuestMode;

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

  // 구글 로그인
  Future<void> signInWithGoogle() async {
    _log('구글 로그인 시도');
    
    try {
      if (kIsWeb) {
        // 웹에서는 Supabase OAuth 사용
        await _supabase.auth.signInWithOAuth(
          OAuthProvider.google,
          redirectTo: 'https://ai-diary-flutter-app.vercel.app/auth/callback',
        );
      } else {
        // 모바일에서는 Google Sign In 패키지 사용
        // iOS에서는 GoogleService-Info.plist 사용
        // Android에서는 google-services.json 사용
        final GoogleSignIn googleSignIn = GoogleSignIn(
          scopes: ['email', 'profile'],
        );
        
        final googleUser = await googleSignIn.signIn();
        if (googleUser == null) {
          throw Exception('구글 로그인 취소됨');
        }
        
        final googleAuth = await googleUser.authentication;
        final accessToken = googleAuth.accessToken;
        final idToken = googleAuth.idToken;
        
        if (accessToken == null || idToken == null) {
          throw Exception('구글 인증 토큰을 가져올 수 없습니다');
        }
        
        await _supabase.auth.signInWithIdToken(
          provider: OAuthProvider.google,
          idToken: idToken,
          accessToken: accessToken,
        );
      }
      
      _isGuestMode = false;
      _log('구글 로그인 성공');
      notifyListeners();
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
        webAuthenticationOptions: WebAuthenticationOptions(
          clientId: 'com.test.aidiary.service',
          redirectUri: Uri.parse(
            'https://jihhsiijrxhazbxhoirl.supabase.co/auth/v1/callback',
          ),
        ),
      );

      final idToken = credential.identityToken;
      if (idToken == null) {
        throw Exception('애플 ID 토큰을 가져올 수 없습니다');
      }

      await _supabase.auth.signInWithIdToken(
        provider: OAuthProvider.apple,
        idToken: idToken,
      );

      _isGuestMode = false;
      _log('애플 로그인 성공');
      notifyListeners();
    } catch (e) {
      _log('애플 로그인 실패', e.toString());
      throw Exception('애플 로그인 실패: $e');
    }
  }
}