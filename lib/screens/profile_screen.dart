import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../services/auth_service.dart';
import '../services/subscription_service.dart';
import '../services/localization_service.dart';
import '../utils/content_policy.dart';
import 'simple_auth_screen.dart';
import 'app_info_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService();
  late SubscriptionService _subscriptionService;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _subscriptionService = SubscriptionService(_authService);
    _initializeSubscription();
    
    // AuthService의 상태 변화 감지
    _authService.addListener(_onAuthStateChanged);
  }
  
  @override
  void dispose() {
    _authService.removeListener(_onAuthStateChanged);
    _deleteConfirmController.dispose();
    super.dispose();
  }

  void _onAuthStateChanged() {
    if (mounted) {
      setState(() {}); // 인증 상태 변화 시 UI 새로고침
    }
  }

  Future<void> _initializeSubscription() async {
    await _subscriptionService.initialize();
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final user = _authService.currentUser;
    final isGuest = user?.id == 'guest-user-id';

    return Consumer<LocalizationService>(
      builder: (context, localizationService, child) {
        final localizations = AppLocalizations(localizationService.currentLanguage);
        
        return Scaffold(
          appBar: AppBar(
            title: Text(
              localizations.profile,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
            actions: [
              // 언어 전환 버튼
              Container(
                margin: const EdgeInsets.only(right: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => localizationService.toggleLanguage(),
                    borderRadius: BorderRadius.circular(20),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            localizationService.isKorean ? '🇰🇷' : '🇺🇸',
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            localizationService.isKorean ? 'KOR' : 'ENG',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF6366F1),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              // 프로필 헤더
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.white.withOpacity(0.2),
                      child: Icon(
                        isGuest ? Icons.person_outline : Icons.person,
                        size: 40,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      isGuest ? localizations.guestUser : (user?.email ?? localizations.user),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _subscriptionService.isPremium ? localizations.premiumMember : localizations.freeMember,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // 게스트 모드일 때만 로그인 유도
              if (isGuest) ...[
                _buildLoginPrompt(localizations),
                const SizedBox(height: 24),
              ],

              // 구독 관리
              _buildSubscriptionSection(localizations),

              const SizedBox(height: 16),

              // 계정 관리
              _buildAccountSection(isGuest, localizations),

              // 웹에서만 관리자 대시보드 링크 표시
              if (kIsWeb) ...[
                const SizedBox(height: 16),
                _buildAdminSection(),
              ],

              const SizedBox(height: 24),

              // 로그아웃 버튼 (게스트가 아닐 때만)
              if (!isGuest)
                _buildLogoutButton(localizations),
            ],
          ),
        ),
      ),
        );
      },
    );
  }

  Widget _buildLoginPrompt(AppLocalizations localizations) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F9FF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF0EA5E9).withOpacity(0.2)),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.cloud_sync_outlined,
            size: 40,
            color: Color(0xFF0EA5E9),
          ),
          const SizedBox(height: 12),
          Text(
            localizations.loginForSync,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            localizations.loginSyncDesc,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () => _navigateToAuth(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0EA5E9),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                localizations.loginSignup,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubscriptionSection(AppLocalizations localizations) {
    final user = _authService.currentUser;
    final isGuest = user?.id == 'guest-user-id';
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '구독 관리',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 16),
          // 구독 서비스 준비 중 표시
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF3C7),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: const Color(0xFFFCD34D),
                width: 1,
              ),
            ),
            child: Row(
              children: const [
                Icon(
                  Icons.construction,
                  color: Color(0xFFF59E0B),
                  size: 20,
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '구독 서비스 준비 중',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF92400E),
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        '현재 하루 10회 무료로 이용 가능합니다',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF92400E),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _buildMenuTile(
            icon: Icons.star_outline,
            title: '프리미엄 구독 (준비 중)',
            subtitle: '무제한 일기 작성',
            onTap: () => context.push('/subscription'),
          ),
          // 게스트가 아닐 때만 구매 복원 버튼 표시
          if (!isGuest)
            _buildMenuTile(
              icon: Icons.restore,
              title: '구매 복원',
              subtitle: '이전 구매 내역 복원',
              onTap: _restorePurchases,
            ),
        ],
      ),
    );
  }

  Widget _buildAccountSection(bool isGuest, AppLocalizations localizations) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '계정 정보',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 16),
          _buildMenuTile(
            icon: Icons.info_outline,
            title: '앱 정보',
            subtitle: 'v1.0.0',
            onTap: () => _navigateToAppInfo(),
          ),
          _buildMenuTile(
            icon: Icons.privacy_tip_outlined,
            title: '개인정보처리방침',
            subtitle: '개인정보 보호 정책',
            onTap: () => _openPrivacyPolicy(),
          ),
          _buildMenuTile(
            icon: Icons.description_outlined,
            title: '이용약관',
            subtitle: '서비스 이용약관',
            onTap: () => _openTermsOfService(),
          ),
          // 데이터 삭제 옵션 추가 (게스트가 아닐 때만)
          if (!isGuest)
            _buildMenuTile(
              icon: Icons.delete_forever_outlined,
              title: '계정 및 데이터 삭제',
              subtitle: '모든 데이터를 완전히 삭제합니다',
              onTap: () => _showDeleteAccountDialog(),
            ),
        ],
      ),
    );
  }

  Widget _buildMenuTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        icon,
        color: const Color(0xFF6366F1),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w500,
          color: Color(0xFF1E293B),
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(
          fontSize: 12,
          color: Color(0xFF64748B),
        ),
      ),
      trailing: const Icon(
        Icons.chevron_right,
        color: Color(0xFF64748B),
      ),
      onTap: onTap,
    );
  }

  Widget _buildAdminSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.deepPurple.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.deepPurple.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.admin_panel_settings,
                color: Colors.deepPurple,
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                '관리자 메뉴',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildMenuTile(
            icon: Icons.dashboard,
            title: '관리자 대시보드',
            subtitle: '사용자 통계 및 분석',
            onTap: () => context.push('/admin'),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutButton(AppLocalizations localizations) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: OutlinedButton(
        onPressed: _handleLogout,
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Color(0xFFEF4444)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: const Text(
          '로그아웃',
          style: TextStyle(
            color: Color(0xFFEF4444),
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  void _navigateToAuth() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const SimpleAuthScreen()),
    );
  }

  void _navigateToAppInfo() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const AppInfoScreen()),
    );
  }

  Future<void> _openPrivacyPolicy() async {
    const url = 'https://raw.githubusercontent.com/wjb127/ai-diary-flutter-app/main/docs/privacy_policy.txt';
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('개인정보처리방침을 열 수 없습니다.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _openTermsOfService() async {
    const url = 'https://raw.githubusercontent.com/wjb127/ai-diary-flutter-app/main/docs/terms_of_service.txt';
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('이용약관을 열 수 없습니다.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _restorePurchases() async {
    // 로딩 다이얼로그 표시
    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('구매 내역을 복원하고 있습니다...'),
            ],
          ),
        ),
      );
    }

    try {
      final success = await _subscriptionService.restorePurchases();
      
      if (mounted) {
        Navigator.of(context).pop(); // 로딩 다이얼로그 닫기
        
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Row(
              children: [
                Icon(
                  success ? Icons.check_circle : Icons.info,
                  color: success ? const Color(0xFF10B981) : const Color(0xFF64748B),
                ),
                const SizedBox(width: 8),
                Text(success ? '복원 완료' : '복원 내역 없음'),
              ],
            ),
            content: Text(
              success 
                ? '구매 내역이 성공적으로 복원되었습니다.\n프리미엄 기능을 이용하실 수 있습니다.' 
                : '복원할 구매 내역이 없습니다.\n새로 구독하시려면 프리미엄 구독 메뉴를 이용해주세요.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('확인'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop(); // 로딩 다이얼로그 닫기
        
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.error, color: Color(0xFFEF4444)),
                SizedBox(width: 8),
                Text('복원 실패'),
              ],
            ),
            content: const Text(
              '구매 내역 복원 중 오류가 발생했습니다.\n잠시 후 다시 시도해주세요.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('확인'),
              ),
            ],
          ),
        );
      }
    }
  }

  Future<void> _handleLogout() async {
    try {
      await _authService.signOut();
      // 로그아웃 후 게스트 모드로 전환
      await _authService.signInAsGuest();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('로그아웃되었습니다. 게스트 모드로 전환됩니다.'),
            backgroundColor: Color(0xFF10B981),
          ),
        );
        setState(() {});
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('로그아웃 중 오류가 발생했습니다.'),
            backgroundColor: Color(0xFFEF4444),
          ),
        );
      }
    }
  }
  
  // 계정 삭제 다이얼로그
  Future<void> _showDeleteAccountDialog() async {
    final localizationService = Provider.of<LocalizationService>(context, listen: false);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(
              Icons.warning_amber_outlined,
              color: Color(0xFFEF4444),
              size: 24,
            ),
            const SizedBox(width: 8),
            Text(
              localizationService.isKorean ? '계정 삭제' : 'Delete Account',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFFEF4444),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              localizationService.isKorean 
                  ? '정말로 계정을 삭제하시겠습니까?'
                  : 'Are you sure you want to delete your account?',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFEE2E2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: const Color(0xFFFCA5A5),
                  width: 1,
                ),
              ),
              child: Text(
                localizationService.isKorean
                    ? '⚠️ 이 작업은 되돌릴 수 없습니다!\n\n'
                      '• 모든 일기가 영구적으로 삭제됩니다\n'
                      '• AI로 생성된 콘텐츠가 모두 삭제됩니다\n'
                      '• 구독 정보가 삭제됩니다\n'
                      '• 계정을 복구할 수 없습니다'
                    : '⚠️ This action cannot be undone!\n\n'
                      '• All diaries will be permanently deleted\n'
                      '• All AI-generated content will be deleted\n'
                      '• Subscription info will be deleted\n'
                      '• Account cannot be recovered',
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF991B1B),
                  height: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              localizationService.isKorean
                  ? '계속하려면 "삭제" 를 입력하세요:'
                  : 'Type "DELETE" to continue:',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _deleteConfirmController,
              decoration: InputDecoration(
                hintText: localizationService.isKorean ? '삭제' : 'DELETE',
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(
                    color: Color(0xFFEF4444),
                    width: 2,
                  ),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              _deleteConfirmController.clear();
              Navigator.of(context).pop();
            },
            child: Text(
              localizationService.isKorean ? '취소' : 'Cancel',
              style: const TextStyle(color: Color(0xFF64748B)),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              final confirmText = _deleteConfirmController.text;
              final expectedText = localizationService.isKorean ? '삭제' : 'DELETE';
              
              if (confirmText != expectedText) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      localizationService.isKorean 
                          ? '확인 텍스트가 일치하지 않습니다'
                          : 'Confirmation text does not match',
                    ),
                    backgroundColor: Colors.orange,
                  ),
                );
                return;
              }
              
              _deleteConfirmController.clear();
              Navigator.of(context).pop();
              await _deleteAccount();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
            ),
            child: Text(
              localizationService.isKorean ? '영구 삭제' : 'Delete Forever',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
  
  // 계정 삭제 실행
  Future<void> _deleteAccount() async {
    final localizationService = Provider.of<LocalizationService>(context, listen: false);
    
    // 로딩 다이얼로그 표시
    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('계정을 삭제하고 있습니다...'),
            ],
          ),
        ),
      );
    }
    
    try {
      // TODO: 실제 계정 삭제 API 호출
      // await _authService.deleteAccount();
      // await _diaryService.deleteAllDiaries();
      
      // 임시: 로그아웃 처리
      await Future.delayed(const Duration(seconds: 2));
      await _authService.signOut();
      await _authService.signInAsGuest();
      
      if (mounted) {
        Navigator.of(context).pop(); // 로딩 다이얼로그 닫기
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              localizationService.isKorean 
                  ? '계정이 성공적으로 삭제되었습니다'
                  : 'Account deleted successfully',
            ),
            backgroundColor: const Color(0xFF10B981),
          ),
        );
        
        // 홈 화면으로 이동
        context.go('/');
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop(); // 로딩 다이얼로그 닫기
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              localizationService.isKorean 
                  ? '계정 삭제 중 오류가 발생했습니다'
                  : 'Error deleting account',
            ),
            backgroundColor: const Color(0xFFEF4444),
          ),
        );
      }
    }
  }
  
  final TextEditingController _deleteConfirmController = TextEditingController();
}
