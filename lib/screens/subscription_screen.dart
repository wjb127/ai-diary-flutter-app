import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:purchases_flutter/purchases_flutter.dart';
import '../services/subscription_service.dart';
import '../services/auth_service.dart';
import '../services/localization_service.dart';

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
    if (kIsWeb) {
      // 웹에서는 구독 기능 비활성화
      setState(() => _isLoading = false);
    } else {
      _initializeSubscription();
    }
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
          const SnackBar(content: Text('구독 상품을 불러올 수 없습니다')),
        );
      }
    }
  }

  Future<void> _purchaseProduct(StoreProduct product) async {
    try {
      final success = await _subscriptionService.purchaseProduct(product);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('구독이 완료되었습니다!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('구독 실패: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizationService = LocalizationService();
    final isKorean = localizationService.isKorean;
    
    // 웹 플랫폼 체크
    if (kIsWeb) {
      return Scaffold(
        appBar: AppBar(
          title: Text(isKorean ? '구독' : 'Subscription'),
          centerTitle: true,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.web,
                  size: 80,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 24),
                Text(
                  isKorean 
                    ? '웹 버전에서는 구독 기능을 지원하지 않습니다' 
                    : 'Subscription is not available on web',
                  style: Theme.of(context).textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  isKorean
                    ? '모바일 앱에서 구독 서비스를 이용해주세요'
                    : 'Please use the mobile app for subscription services',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                OutlinedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back),
                  label: Text(isKorean ? '돌아가기' : 'Go Back'),
                ),
              ],
            ),
          ),
        ),
      );
    }
    
    // 모바일 구독 화면
    return Scaffold(
      appBar: AppBar(
        title: Text(isKorean ? '프리미엄 구독' : 'Premium Subscription'),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildSubscriptionContent(isKorean),
    );
  }

  Widget _buildSubscriptionContent(bool isKorean) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          // 구독 서비스 준비 중 안내
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF3C7),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFFFCD34D),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.construction,
                  color: Color(0xFFF59E0B),
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isKorean ? '구독 서비스 준비 중' : 'Subscription Coming Soon',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF92400E),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isKorean 
                          ? '현재 하루 10회 무료로 이용 가능합니다' 
                          : 'Currently available 10 times per day for free',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF92400E),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          // 헤더
          const CircleAvatar(
            radius: 40,
            backgroundColor: Colors.deepPurple,
            child: Icon(Icons.star, size: 40, color: Colors.white),
          ),
          const SizedBox(height: 16),
          Text(
            isKorean ? 'AI 일기 프리미엄' : 'AI Diary Premium',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isKorean 
              ? '무제한 AI 일기를 작성하세요' 
              : 'Write unlimited AI diaries',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 32),
          
          // 특징 리스트
          _buildFeatureList(isKorean),
          const SizedBox(height: 32),
          
          // 구독 플랜
          if (_products.isNotEmpty) ...[
            Text(
              isKorean ? '구독 플랜 선택' : 'Choose Your Plan',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ..._products.asMap().entries.map((entry) {
              final index = entry.key;
              final product = entry.value;
              return _buildPlanCard(product, index == _selectedIndex, index, isKorean);
            }).toList(),
            const SizedBox(height: 24),
            
            // 구매 버튼 (준비 중이므로 비활성화)
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: null, // 준비 중이므로 비활성화
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  isKorean ? '구독 서비스 준비 중' : 'Coming Soon',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // 복원 버튼
            TextButton(
              onPressed: () async {
                try {
                  await _subscriptionService.restorePurchases();
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          isKorean ? '구독이 복원되었습니다' : 'Subscription restored',
                        ),
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('복원 실패: $e')),
                    );
                  }
                }
              },
              child: Text(
                isKorean ? '이전 구매 복원' : 'Restore Purchases',
                style: const TextStyle(color: Colors.grey),
              ),
            ),
          ] else ...[
            // 상품이 없을 때
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Icon(Icons.info_outline, size: 48, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    isKorean 
                      ? '구독 상품을 불러올 수 없습니다' 
                      : 'Unable to load subscription products',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isKorean
                      ? '나중에 다시 시도해주세요'
                      : 'Please try again later',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ],
          
          const SizedBox(height: 24),
          
          // 약관
          Text(
            isKorean
              ? '구독은 현재 기간이 끝나기 24시간 전에 취소하지 않으면 자동으로 갱신됩니다.'
              : 'Subscription automatically renews unless canceled 24 hours before the current period ends.',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureList(bool isKorean) {
    final features = isKorean
      ? [
          '✨ 무제한 AI 일기 생성',
          '📝 모든 일기 영구 보관',
          '🎨 프리미엄 테마 및 스타일',
          '☁️ 클라우드 동기화',
          '🚫 광고 없음',
        ]
      : [
          '✨ Unlimited AI diary generation',
          '📝 Permanent storage of all diaries',
          '🎨 Premium themes and styles',
          '☁️ Cloud synchronization',
          '🚫 No advertisements',
        ];

    return Column(
      children: features.map((feature) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                feature,
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      )).toList(),
    );
  }

  Widget _buildPlanCard(StoreProduct product, bool isSelected, int index, bool isKorean) {
    final isYearly = product.identifier.contains('yearly');
    final savings = isYearly ? (isKorean ? '58% 할인' : '58% OFF') : null;
    
    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? Colors.deepPurple : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(16),
          color: isSelected ? Colors.deepPurple.withOpacity(0.05) : null,
        ),
        child: Row(
          children: [
            Radio<int>(
              value: index,
              groupValue: _selectedIndex,
              onChanged: (value) => setState(() => _selectedIndex = value!),
              activeColor: Colors.deepPurple,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        isYearly 
                          ? (isKorean ? '연간 구독' : 'Yearly')
                          : (isKorean ? '월간 구독' : 'Monthly'),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (savings != null) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            savings,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product.priceString,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[700],
                    ),
                  ),
                  if (isYearly) ...[
                    const SizedBox(height: 4),
                    Text(
                      isKorean ? '월 ₩3,250 상당' : 'About ₩3,250/month',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}