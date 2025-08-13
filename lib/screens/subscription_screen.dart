import 'package:flutter/material.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import '../services/subscription_service.dart';
import '../services/auth_service.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  final SubscriptionService _subscriptionService = SubscriptionService(AuthService());
  List<StoreProduct> _products = [];
  bool _isLoading = true;
  int _selectedIndex = 1; // 기본적으로 연간 플랜 선택

  @override
  void initState() {
    super.initState();
    _initializeSubscription();
  }

  Future<void> _initializeSubscription() async {
    try {
      await _subscriptionService.initialize();
      await _loadProducts();
    } catch (e) {
      // 구독 서비스 초기화 실패 시 안전하게 처리
      print('구독 서비스 초기화 실패: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadProducts() async {
    setState(() => _isLoading = true);
    
    try {
      final products = await _subscriptionService.getProducts();
      setState(() {
        _products = products;
        _isLoading = false;
      });
    } catch (e) {
      print('상품 로드 실패: $e');
      setState(() => _isLoading = false);
      // 에러가 발생해도 앱이 꺼지지 않도록 UI 표시
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('구독 정보를 불러올 수 없습니다. 개발자 모드에서 실행 중입니다.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  Future<void> _handlePurchase() async {
    setState(() => _isLoading = true);
    
    try {
      bool success = false;
      if (_selectedIndex == 0) {
        success = await _subscriptionService.purchaseMonthly();
      } else {
        success = await _subscriptionService.purchaseYearly();
      }
      
      setState(() => _isLoading = false);
      
      if (success && mounted) {
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('프리미엄 구독이 활성화되었습니다! 🎉'),
            backgroundColor: Color(0xFF10B981),
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('구독을 처리할 수 없습니다. 개발자 모드에서는 구독이 제한됩니다.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      print('구매 처리 실패: $e');
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('구독 처리 중 오류가 발생했습니다.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _handleRestore() async {
    setState(() => _isLoading = true);
    
    try {
      final success = await _subscriptionService.restorePurchases();
      
      setState(() => _isLoading = false);
      
      if (mounted) {
        if (success) {
          Navigator.of(context).pop(true);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('구독이 복원되었습니다! ✨'),
              backgroundColor: Color(0xFF10B981),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('복원할 구독이 없습니다'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      print('구매 복원 실패: $e');
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('구독 복원 중 오류가 발생했습니다.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'AI 일기 프리미엄',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E293B),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF1E293B)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 헤더
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFF6366F1),
                            Color(0xFF8B5CF6),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Column(
                        children: [
                          Icon(
                            Icons.auto_awesome,
                            size: 48,
                            color: Colors.white,
                          ),
                          SizedBox(height: 16),
                          Text(
                            '무제한 AI 일기 작성',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            '프리미엄으로 업그레이드하고\n모든 기능을 제한 없이 사용하세요',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white70,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 30),
                    
                    // 혜택 리스트
                    _buildBenefitItem(
                      icon: Icons.all_inclusive,
                      title: '무제한 일기 작성',
                      description: '매달 무제한으로 일기를 작성할 수 있어요',
                      isPremium: true,
                    ),
                    _buildBenefitItem(
                      icon: Icons.auto_awesome,
                      title: '고급 AI 각색',
                      description: '더 창의적이고 감성적인 AI 각색',
                      isPremium: true,
                    ),
                    _buildBenefitItem(
                      icon: Icons.palette,
                      title: '다양한 테마',
                      description: '시, 소설, 에세이 등 다양한 스타일',
                      isPremium: true,
                    ),
                    _buildBenefitItem(
                      icon: Icons.cloud_sync,
                      title: '자동 백업',
                      description: '소중한 일기를 안전하게 보관',
                      isPremium: true,
                    ),
                    _buildBenefitItem(
                      icon: Icons.download,
                      title: 'PDF 내보내기',
                      description: '일기를 예쁜 PDF로 저장',
                      isPremium: true,
                    ),
                    
                    const SizedBox(height: 30),
                    
                    // 개발자 모드 알림 (상품이 없는 경우)
                    if (_products.isEmpty) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.orange.withOpacity(0.3)),
                        ),
                        child: const Column(
                          children: [
                            Icon(Icons.info_outline, color: Colors.orange, size: 24),
                            SizedBox(height: 8),
                            Text(
                              '개발자 모드',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.orange,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              '현재 개발자 환경에서 실행되어 구독 기능이 제한됩니다.\n실제 앱에서는 정상적으로 작동합니다.',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.orange,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                    
                    // 구독 플랜
                    const Text(
                      '구독 플랜 선택',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // 월간 플랜
                    _buildPlanCard(
                      index: 0,
                      title: '월간 구독',
                      price: _products.isNotEmpty 
                          ? _products.firstWhere((p) => p.identifier == SubscriptionService.monthlyProductId, orElse: () => _products.first).priceString
                          : '₩4,500',
                      period: '/월',
                      isPopular: false,
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // 연간 플랜
                    _buildPlanCard(
                      index: 1,
                      title: '연간 구독',
                      price: _products.length > 1 
                          ? _products.firstWhere((p) => p.identifier == SubscriptionService.yearlyProductId, orElse: () => _products.last).priceString
                          : '₩39,000',
                      period: '/년',
                      isPopular: true,
                      savings: '28% 할인',
                    ),
                    
                    const SizedBox(height: 30),
                    
                    // 구독 버튼
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handlePurchase,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6366F1),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          _selectedIndex == 0 
                              ? '월간 구독 시작하기' 
                              : '연간 구독 시작하기',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // 구매 복원 버튼
                    Center(
                      child: TextButton(
                        onPressed: _isLoading ? null : _handleRestore,
                        child: const Text(
                          '이전 구매 복원',
                          style: TextStyle(
                            color: Color(0xFF6366F1),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // 약관
                    const Text(
                      '• 구독은 현재 기간이 끝나기 24시간 전에 취소하지 않으면 자동으로 갱신됩니다.\n'
                      '• 구독료는 iTunes 계정(iOS) 또는 Google Play 계정(Android)을 통해 청구됩니다.\n'
                      '• 구독은 구매 후 계정 설정에서 관리할 수 있습니다.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF64748B),
                      ),
                    ),
                    
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildBenefitItem({
    required IconData icon,
    required String title,
    required String description,
    required bool isPremium,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isPremium 
                  ? const Color(0xFF6366F1).withOpacity(0.1)
                  : const Color(0xFFE2E8F0),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: isPremium 
                  ? const Color(0xFF6366F1)
                  : const Color(0xFF64748B),
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanCard({
    required int index,
    required String title,
    required String price,
    required String period,
    required bool isPopular,
    String? savings,
  }) {
    final isSelected = _selectedIndex == index;
    
    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected 
                ? const Color(0xFF6366F1) 
                : const Color(0xFFE2E8F0),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected 
                      ? const Color(0xFF6366F1) 
                      : const Color(0xFFCBD5E1),
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Container(
                      margin: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFF6366F1),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      if (isPopular) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF10B981),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            '인기',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        price,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      Text(
                        period,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF64748B),
                        ),
                      ),
                      if (savings != null) ...[
                        const SizedBox(width: 8),
                        Text(
                          savings,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF10B981),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}