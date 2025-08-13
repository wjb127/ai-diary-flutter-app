import 'package:flutter/foundation.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'auth_service.dart';

class SubscriptionService {
  static const String _revenueCatApiKey = String.fromEnvironment('REVENUECAT_API_KEY');
  static const String _entitlementId = 'premium';
  
  // Subscription products
  static const String monthlyProductId = 'ai_diary_monthly';
  static const String yearlyProductId = 'ai_diary_yearly';
  
  CustomerInfo? _customerInfo;
  bool _isInitialized = false;
  final AuthService _authService;
  
  SubscriptionService(this._authService);
  
  bool get isPremium => _customerInfo?.entitlements.all[_entitlementId]?.isActive ?? false;
  
  void _log(String message, [dynamic data]) {
    // 모든 플랫폼에서 로그 출력 (디버깅용)
    debugPrint('💳 [SUBSCRIPTION] $message ${data != null ? '| $data' : ''}');
  }
  
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      _log('RevenueCat 초기화 시작');
      
      // 웹 플랫폼은 구독을 지원하지 않음
      if (kIsWeb) {
        _log('웹 플랫폼은 구독을 지원하지 않습니다');
        _isInitialized = true;
        return;
      }
      
      // API 키가 없으면 초기화를 건너뜀 (개발/테스트 환경)
      if (_revenueCatApiKey.isEmpty) {
        _log('RevenueCat API 키가 없습니다. 구독 기능이 비활성화됩니다.');
        _isInitialized = true;
        return;
      }
      
      // RevenueCat 설정
      await Purchases.setLogLevel(LogLevel.debug);
      
      PurchasesConfiguration configuration;
      if (defaultTargetPlatform == TargetPlatform.iOS) {
        configuration = PurchasesConfiguration(_revenueCatApiKey);
      } else if (defaultTargetPlatform == TargetPlatform.android) {
        configuration = PurchasesConfiguration(_revenueCatApiKey);
      } else {
        _log('지원하지 않는 플랫폼입니다');
        _isInitialized = true;
        return;
      }
      
      await Purchases.configure(configuration);
      
      // 사용자 ID 설정 (AuthService를 통해 현재 사용자 정보 가져오기)
      final user = _authService.currentUser;
      if (user != null) {
        await Purchases.logIn(user.id);
        _log('사용자 로그인', '${user.id} (${user.email})');
      } else {
        _log('익명 사용자로 초기화');
      }
      
      // 구독 정보 가져오기
      await refreshCustomerInfo();
      
      _isInitialized = true;
      _log('RevenueCat 초기화 완료');
    } catch (e) {
      _log('RevenueCat 초기화 실패', e.toString());
      _isInitialized = true; // 실패해도 초기화를 완료로 표시
    }
  }
  
  Future<void> refreshCustomerInfo() async {
    try {
      _customerInfo = await Purchases.getCustomerInfo();
      _log('구독 정보 갱신', isPremium ? '프리미엄' : '무료');
    } catch (e) {
      _log('구독 정보 갱신 실패', e.toString());
    }
  }
  
  Future<List<StoreProduct>> getProducts() async {
    // 웹이나 API 키가 없는 경우 빈 리스트 반환
    if (kIsWeb || _revenueCatApiKey.isEmpty || !_isInitialized) {
      _log('구독 서비스가 초기화되지 않음');
      return [];
    }
    
    try {
      final products = await Purchases.getProducts(
        [monthlyProductId, yearlyProductId],
      );
      _log('상품 목록 조회', products.length);
      return products;
    } catch (e) {
      _log('상품 목록 조회 실패', e.toString());
      return [];
    }
  }
  
  Future<bool> purchaseMonthly() async {
    return _purchase(monthlyProductId);
  }
  
  Future<bool> purchaseYearly() async {
    return _purchase(yearlyProductId);
  }
  
  Future<bool> _purchase(String productId) async {
    // 웹이나 API 키가 없는 경우 실패 반환
    if (kIsWeb || _revenueCatApiKey.isEmpty || !_isInitialized) {
      _log('구매 불가 - 구독 서비스가 초기화되지 않음');
      return false;
    }
    
    try {
      _log('구매 시도', productId);
      
      final products = await getProducts();
      if (products.isEmpty) {
        _log('구매 불가 - 상품이 없음');
        return false;
      }
      
      final product = products.firstWhere(
        (p) => p.identifier == productId,
        orElse: () => products.first,
      );
      
      final purchaseResult = await Purchases.purchaseStoreProduct(product);
      
      _customerInfo = purchaseResult;
      
      final success = _customerInfo?.entitlements.all[_entitlementId]?.isActive ?? false;
      _log('구매 결과', success ? '성공' : '실패');
      
      return success;
    } catch (e) {
      _log('구매 실패', e.toString());
      return false;
    }
  }
  
  Future<bool> restorePurchases() async {
    // 웹이나 API 키가 없는 경우 실패 반환
    if (kIsWeb || _revenueCatApiKey.isEmpty || !_isInitialized) {
      _log('복원 불가 - 구독 서비스가 초기화되지 않음');
      return false;
    }
    
    try {
      _log('구매 복원 시도');
      _customerInfo = await Purchases.restorePurchases();
      
      final success = isPremium;
      _log('구매 복원 결과', success ? '프리미엄 복원됨' : '복원할 구매 없음');
      
      return success;
    } catch (e) {
      _log('구매 복원 실패', e.toString());
      return false;
    }
  }
  
  // 무료 사용자 제한
  static const int freeMonthlyDiaryLimit = 10;
  static const int premiumMonthlyDiaryLimit = -1; // 무제한
  
  Future<int> getRemainingDiaries() async {
    if (isPremium) return premiumMonthlyDiaryLimit;
    
    try {
      final now = DateTime.now();
      final startOfMonth = DateTime(now.year, now.month, 1);
      final endOfMonth = DateTime(now.year, now.month + 1, 0);
      
      final response = await Supabase.instance.client
          .from('diary_entries')
          .select('id')
          .gte('created_at', startOfMonth.toIso8601String())
          .lte('created_at', endOfMonth.toIso8601String())
          .count();
      
      final usedCount = response.count ?? 0;
      return freeMonthlyDiaryLimit - usedCount;
    } catch (e) {
      _log('일기 카운트 조회 실패', e.toString());
      return 0;
    }
  }
  
  Future<bool> canCreateDiary() async {
    // 디버그 모드에서는 생성 제한 없음
    if (kDebugMode) return true;
    if (isPremium) return true;
    
    final remaining = await getRemainingDiaries();
    return remaining > 0;
  }
}