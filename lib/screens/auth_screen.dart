import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import '../services/auth_service.dart';
import '../screens/home_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final AuthService _authService = AuthService();
  
  // Form controllers
  final _loginEmailController = TextEditingController();
  final _loginPasswordController = TextEditingController();
  final _signupEmailController = TextEditingController();
  final _signupPasswordController = TextEditingController();
  final _signupPasswordConfirmController = TextEditingController();
  
  // Form keys
  final _loginFormKey = GlobalKey<FormState>();
  final _signupFormKey = GlobalKey<FormState>();
  
  bool _isLoading = false;
  bool _obscureLoginPassword = true;
  bool _obscureSignupPassword = true;
  bool _obscureSignupPasswordConfirm = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _loginEmailController.dispose();
    _loginPasswordController.dispose();
    _signupEmailController.dispose();
    _signupPasswordController.dispose();
    _signupPasswordConfirmController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_loginFormKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await _authService.signInWithEmail(
        email: _loginEmailController.text.trim(),
        password: _loginPasswordController.text,
      );
      
      if (mounted) {
        // 로그인 성공 메시지 표시
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('로그인 성공! 홈 화면으로 이동합니다.'),
            backgroundColor: Color(0xFF10B981),
            duration: Duration(seconds: 2),
          ),
        );
        
        // 짧은 딜레이 후 홈 화면으로 이동
        await Future.delayed(const Duration(milliseconds: 500));
        
        // AuthScreen을 닫고 메인 화면의 홈 탭으로 이동
        Navigator.of(context).pop(); // AuthScreen 닫기
        
        // 홈 탭으로 이동하기 위해 GoRouter 사용
        if (mounted) {
          context.go('/'); // 홈 화면으로 이동
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('로그인 실패: ${e.toString().replaceAll('Exception: ', '')}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleGuestLogin() async {
    debugPrint('🟢 [AUTH_SCREEN] 게스트 로그인 시작');
    
    setState(() => _isLoading = true);

    try {
      debugPrint('🟢 [AUTH_SCREEN] AuthService.signInAsGuest 호출');
      await _authService.signInAsGuest();
      
      debugPrint('🟢 [AUTH_SCREEN] 게스트 로그인 성공, HomeScreen으로 이동');
      if (mounted) {
        Navigator.of(context).pop(); // 프로필 화면으로 돌아가기
        debugPrint('🟢 [AUTH_SCREEN] 프로필 화면으로 돌아가기 완료');
      }
    } catch (e) {
      debugPrint('🔴 [AUTH_SCREEN] 게스트 로그인 실패: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('게스트 로그인 실패: ${e.toString().replaceAll('Exception: ', '')}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleSignup() async {
    if (!_signupFormKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await _authService.signUpWithEmail(
        email: _signupEmailController.text.trim(),
        password: _signupPasswordController.text,
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('회원가입 성공! 이메일을 확인해주세요.'),
            backgroundColor: Color(0xFF10B981),
          ),
        );
        
        // 로그인 탭으로 전환
        _tabController.animateTo(0);
        _loginEmailController.text = _signupEmailController.text;
        _signupEmailController.clear();
        _signupPasswordController.clear();
        _signupPasswordConfirmController.clear();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('회원가입 실패: ${e.toString().replaceAll('Exception: ', '')}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() => _isLoading = true);

    try {
      await _authService.signInWithGoogle();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('구글 로그인 성공! 홈 화면으로 이동합니다.'),
            backgroundColor: Color(0xFF10B981),
            duration: Duration(seconds: 2),
          ),
        );
        
        await Future.delayed(const Duration(milliseconds: 500));
        Navigator.of(context).pop();
        
        if (mounted) {
          context.go('/');
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('구글 로그인 실패: ${e.toString().replaceAll('Exception: ', '')}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleAppleSignIn() async {
    setState(() => _isLoading = true);

    try {
      await _authService.signInWithApple();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('애플 로그인 성공! 홈 화면으로 이동합니다.'),
            backgroundColor: Color(0xFF10B981),
            duration: Duration(seconds: 2),
          ),
        );
        
        await Future.delayed(const Duration(milliseconds: 500));
        Navigator.of(context).pop();
        
        if (mounted) {
          context.go('/');
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('애플 로그인 실패: ${e.toString().replaceAll('Exception: ', '')}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1E293B)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'AI 감성 일기',
          style: TextStyle(
            color: Color(0xFF1E293B),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 간단한 설명 문구만
                  const SizedBox(height: 20),
                  const Text(
                    '당신의 일상을 아름답게 기록하세요',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(height: 20),
                
                // Tab Bar
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    indicator: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    labelColor: const Color(0xFF6366F1),
                    unselectedLabelColor: const Color(0xFF64748B),
                    labelStyle: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                    tabs: const [
                      Tab(text: '로그인'),
                      Tab(text: '회원가입'),
                    ],
                  ),
                ),
                  const SizedBox(height: 32),
                
                  // Tab Views - 고정 높이로 설정
                  SizedBox(
                    height: 600, // 충분한 고정 높이
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        // Login Form
                        _buildLoginForm(),
                        // Signup Form
                        _buildSignupForm(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginForm() {
    return Form(
      key: _loginFormKey,
      child: SingleChildScrollView(
        child: Column(
          children: [
          TextFormField(
            controller: _loginEmailController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: '이메일',
              hintText: 'your@email.com',
              prefixIcon: const Icon(Icons.email_outlined),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF6366F1), width: 2),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return '이메일을 입력해주세요';
              }
              if (!value.contains('@')) {
                return '올바른 이메일 형식이 아닙니다';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _loginPasswordController,
            obscureText: _obscureLoginPassword,
            decoration: InputDecoration(
              labelText: '비밀번호',
              hintText: '••••••••',
              prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureLoginPassword ? Icons.visibility_off : Icons.visibility,
                  color: const Color(0xFF64748B),
                ),
                onPressed: () {
                  setState(() {
                    _obscureLoginPassword = !_obscureLoginPassword;
                  });
                },
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF6366F1), width: 2),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return '비밀번호를 입력해주세요';
              }
              return null;
            },
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _handleLogin,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6366F1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      '로그인',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // 구분선
          Row(
            children: [
              Expanded(child: Divider(color: Colors.grey.shade300)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  '또는',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                  ),
                ),
              ),
              Expanded(child: Divider(color: Colors.grey.shade300)),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // 구글 로그인
          SizedBox(
            width: double.infinity,
            height: 52,
            child: OutlinedButton(
              onPressed: _isLoading ? null : _handleGoogleSignIn,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFFE2E8F0)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                backgroundColor: Colors.white,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/google_logo.png',
                    height: 20,
                    width: 20,
                    errorBuilder: (context, error, stackTrace) => 
                        const Icon(Icons.g_mobiledata, size: 20),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Google로 계속하기',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 12),
          
          // 애플 로그인
          SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton(
                onPressed: _isLoading ? null : _handleAppleSignIn,
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFFE2E8F0)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  backgroundColor: Colors.black,
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.apple, color: Colors.white, size: 20),
                    SizedBox(width: 12),
                    Text(
                      'Apple로 계속하기',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          
          if (!kIsWeb && defaultTargetPlatform == TargetPlatform.iOS)
            const SizedBox(height: 24),
          
          if (kIsWeb || defaultTargetPlatform != TargetPlatform.iOS)
            const SizedBox(height: 24),
          
          TextButton(
            onPressed: () {
              // TODO: 비밀번호 재설정 기능
            },
            child: const Text(
              '비밀번호를 잊으셨나요?',
              style: TextStyle(
                color: Color(0xFF6366F1),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // 게스트 모드 버튼
          SizedBox(
            width: double.infinity,
            height: 52,
            child: OutlinedButton(
              onPressed: _isLoading ? null : _handleGuestLogin,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFF10B981)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                backgroundColor: Colors.white,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.person_outline, color: Color(0xFF10B981)),
                  const SizedBox(width: 8),
                  Text(
                    _isLoading ? '로그인 중...' : '게스트로 시작하기',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF10B981),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
        ),
      ),
    );
  }

  Widget _buildSignupForm() {
    return Form(
      key: _signupFormKey,
      child: SingleChildScrollView(
        child: Column(
          children: [
            TextFormField(
              controller: _signupEmailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: '이메일',
                hintText: 'your@email.com',
                prefixIcon: const Icon(Icons.email_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF6366F1), width: 2),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '이메일을 입력해주세요';
                }
                if (!value.contains('@')) {
                  return '올바른 이메일 형식이 아닙니다';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _signupPasswordController,
              obscureText: _obscureSignupPassword,
              decoration: InputDecoration(
                labelText: '비밀번호',
                hintText: '최소 6자 이상',
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureSignupPassword ? Icons.visibility_off : Icons.visibility,
                    color: const Color(0xFF64748B),
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureSignupPassword = !_obscureSignupPassword;
                    });
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF6366F1), width: 2),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '비밀번호를 입력해주세요';
                }
                if (value.length < 6) {
                  return '비밀번호는 최소 6자 이상이어야 합니다';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _signupPasswordConfirmController,
              obscureText: _obscureSignupPasswordConfirm,
              decoration: InputDecoration(
                labelText: '비밀번호 확인',
                hintText: '비밀번호를 다시 입력해주세요',
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureSignupPasswordConfirm ? Icons.visibility_off : Icons.visibility,
                    color: const Color(0xFF64748B),
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureSignupPasswordConfirm = !_obscureSignupPasswordConfirm;
                    });
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF6366F1), width: 2),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '비밀번호 확인을 입력해주세요';
                }
                if (value != _signupPasswordController.text) {
                  return '비밀번호가 일치하지 않습니다';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleSignup,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6366F1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        '회원가입',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '회원가입 시 서비스 이용약관에 동의하는 것으로 간주됩니다',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}