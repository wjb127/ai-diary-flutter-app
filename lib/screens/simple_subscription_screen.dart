import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/local_subscription_service.dart';
import '../services/localization_service.dart';

class SimpleSubscriptionScreen extends StatefulWidget {
  const SimpleSubscriptionScreen({super.key});

  @override
  State<SimpleSubscriptionScreen> createState() => _SimpleSubscriptionScreenState();
}

class _SimpleSubscriptionScreenState extends State<SimpleSubscriptionScreen> {
  int _selectedPlan = 1; // 0: 월간, 1: 연간

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LocalSubscriptionService>().initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<LocalSubscriptionService, LocalizationService>(
      builder: (context, subscriptionService, localizationService, child) {
        final localizations = AppLocalizations(localizationService.currentLanguage);
        
        return Scaffold(
          backgroundColor: const Color(0xFFF8FAFC),
          appBar: AppBar(
            title: Text(
              localizations.premiumPlan,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Color(0xFF1E293B)),
              onPressed: () => Navigator.of(context).pop(),
            ),
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
                            localizationService.isKorean ? 'EN' : '한',
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
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // 헤더 섹션
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.star,
                        size: 48,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        localizations.premiumPlan,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        localizationService.isKorean 
                          ? 'AI가 당신의 일상을 더욱 특별하게'
                          : 'Let AI make your daily life extraordinary',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white70,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // 현재 상태 표시
                if (subscriptionService.isPremium)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.green[200]!),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle, color: Colors.green),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            localizationService.isKorean 
                              ? '✨ 프리미엄 활성화됨!'
                              : '✨ Premium Active!',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.green,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                else if (subscriptionService.canUseFreeFeatures)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue[200]!),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.access_time, color: Colors.blue),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            localizationService.isKorean 
                              ? '🎁 무료 체험 ${subscriptionService.remainingFreeDays}일 남음'
                              : '🎁 Free trial: ${subscriptionService.remainingFreeDays} days left',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.blue,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                
                const SizedBox(height: 20),
                
                // 프리미엄 기능들
                _buildFeaturesList(localizations),
                
                const SizedBox(height: 20),
                
                // 가격 플랜 (프리미엄이 아닐 때만 표시)
                if (!subscriptionService.isPremium) ...[
                  Text(
                    localizationService.isKorean 
                      ? '요금제 선택'
                      : 'Choose Your Plan',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // 월간/연간 선택
                  _buildPricingPlans(localizations),
                  
                  const SizedBox(height: 24),
                  
                  // 구독 버튼들
                  _buildSubscriptionButtons(context, subscriptionService, localizations),
                ],
                
                const SizedBox(height: 20),
                
                // 개발/테스트용 버튼들 (디버그 모드에서만)
                if (subscriptionService.canUseFreeFeatures && !subscriptionService.isPremium)
                  _buildDebugButtons(context, subscriptionService, localizations),
                
                const SizedBox(height: 40),
              ],
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildFeaturesList(AppLocalizations localizations) {
    final features = [
      {
        'icon': Icons.auto_fix_high,
        'title': localizations.isKorean ? 'AI 문체 변환' : 'AI Style Transformation',
        'desc': localizations.isKorean ? '10가지 문체로 일기 각색' : 'Transform your diary in 10 different styles',
      },
      {
        'icon': Icons.cloud_sync,
        'title': localizations.isKorean ? '클라우드 동기화' : 'Cloud Sync',
        'desc': localizations.isKorean ? '모든 기기에서 일기 동기화' : 'Sync diaries across all devices',
      },
      {
        'icon': Icons.lock,
        'title': localizations.isKorean ? '프라이버시 보호' : 'Privacy Protection',
        'desc': localizations.isKorean ? '고급 암호화로 일기 보안' : 'Advanced encryption for diary security',
      },
      {
        'icon': Icons.trending_up,
        'title': localizations.isKorean ? '감정 분석' : 'Emotion Analysis',
        'desc': localizations.isKorean ? '일기 감정 패턴 분석' : 'Analyze emotional patterns in your diary',
      },
    ];
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              localizations.isKorean ? '프리미엄 기능' : 'Premium Features',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
          ),
          ...features.map((feature) => Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6366F1).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    feature['icon'] as IconData,
                    color: const Color(0xFF6366F1),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        feature['title'] as String,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        feature['desc'] as String,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )).toList(),
          const SizedBox(height: 4),
        ],
      ),
    );
  }
  
  Widget _buildPricingPlans(AppLocalizations localizations) {
    return Row(
      children: [
        // 월간 플랜
        Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _selectedPlan = 0),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _selectedPlan == 0 ? const Color(0xFF6366F1).withOpacity(0.1) : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _selectedPlan == 0 ? const Color(0xFF6366F1) : const Color(0xFFE2E8F0),
                  width: 2,
                ),
              ),
              child: Column(
                children: [
                  Text(
                    localizations.isKorean ? '월간' : 'Monthly',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    localizations.isKorean ? '₩4,900' : '\$3.99',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF6366F1),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    localizations.isKorean ? '/월' : '/month',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        // 연간 플랜 (인기)
        Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _selectedPlan = 1),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _selectedPlan == 1 ? const Color(0xFF6366F1).withOpacity(0.1) : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _selectedPlan == 1 ? const Color(0xFF6366F1) : const Color(0xFFE2E8F0),
                  width: 2,
                ),
              ),
              child: Stack(
                children: [
                  // 인기 뱃지
                  if (_selectedPlan == 1)
                    Positioned(
                      top: -8,
                      right: -8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.orange,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          localizations.isKorean ? '인기' : 'Popular',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  Column(
                    children: [
                      Text(
                        localizations.isKorean ? '연간' : 'Yearly',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        localizations.isKorean ? '₩39,000' : '\$29.99',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF6366F1),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        localizations.isKorean ? '/년 (33% 할인)' : '/year (33% off)',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.green,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildSubscriptionButtons(BuildContext context, LocalSubscriptionService service, AppLocalizations localizations) {
    return Column(
      children: [
        // 구독하기 버튼
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: service.isLoading ? null : () => _handleSubscription(context, service),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6366F1),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: service.isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Text(
                  localizations.isKorean ? '프리미엄 시작하기' : 'Start Premium',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
          ),
        ),
        
        const SizedBox(height: 12),
        
        // 무료 체험 버튼 (체험하지 않은 경우)
        if (!service.canUseFreeFeatures)
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () => _startFreeTrial(context, service),
              child: Text(
                localizations.isKorean ? '7일 무료 체험 시작' : 'Start 7-Day Free Trial',
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF6366F1),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        
        const SizedBox(height: 8),
        
        // 구매 복원 버튼
        TextButton(
          onPressed: () => _restorePurchases(context, service),
          child: Text(
            localizations.isKorean ? '구매 복원' : 'Restore Purchases',
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF64748B),
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildDebugButtons(BuildContext context, LocalSubscriptionService service, AppLocalizations localizations) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            localizations.isKorean ? '개발자 옵션' : 'Developer Options',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => service.enablePremiumForTesting(),
                  child: Text(
                    localizations.isKorean ? '테스트용 프리미엄' : 'Enable Premium',
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ),
              Expanded(
                child: TextButton(
                  onPressed: () => service.resetForTesting(),
                  child: Text(
                    localizations.isKorean ? '초기화' : 'Reset',
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Future<void> _handleSubscription(BuildContext context, LocalSubscriptionService service) async {
    final productId = _selectedPlan == 0 
      ? LocalSubscriptionService.monthlyProductId 
      : LocalSubscriptionService.yearlyProductId;
    
    final success = await service.purchaseSubscription(productId);
    
    if (context.mounted) {
      if (success) {
        _showMessage(context, '구독이 시작되었습니다!', isSuccess: true);
      } else {
        _showMessage(context, '구독 처리 중 오류가 발생했습니다.');
      }
    }
  }
  
  Future<void> _startFreeTrial(BuildContext context, LocalSubscriptionService service) async {
    await service.startFreeTrial();
    if (context.mounted) {
      _showMessage(context, '7일 무료 체험이 시작되었습니다!', isSuccess: true);
    }
  }
  
  Future<void> _restorePurchases(BuildContext context, LocalSubscriptionService service) async {
    final success = await service.restorePurchases();
    if (context.mounted) {
      if (success) {
        _showMessage(context, '구매가 복원되었습니다!', isSuccess: true);
      } else {
        _showMessage(context, '복원할 구매 내역이 없습니다.');
      }
    }
  }
  
  void _showMessage(BuildContext context, String message, {bool isSuccess = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isSuccess ? Colors.green : Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}

// 임시 LocalizationService 클래스 (실제로는 별도 파일에 있음)
class AppLocalizations {
  final String currentLanguage;
  
  AppLocalizations(this.currentLanguage);
  
  bool get isKorean => currentLanguage == 'ko';
  
  String get premiumPlan => isKorean ? 'AI 일기 프리미엄' : 'AI Diary Premium';
}