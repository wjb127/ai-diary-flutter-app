import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

class LocalSubscriptionService extends ChangeNotifier {
  static const String _premiumKey = 'is_premium_user';
  static const String _subscriptionDateKey = 'subscription_date';
  static const String _freeTrialKey = 'free_trial_used';
  
  // 구독 상품 ID
  static const String monthlyProductId = 'ai_diary_monthly';
  static const String yearlyProductId = 'ai_diary_yearly';
  
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _subscription;
  
  bool _isPremium = false;
  bool _isLoading = false;
  List<ProductDetails> _products = [];
  DateTime? _subscriptionDate;
  bool _freeTrialUsed = false;
  
  // Getters
  bool get isPremium => _isPremium;
  bool get isLoading => _isLoading;
  List<ProductDetails> get products => _products;
  bool get canUseFreeFeatures => !_freeTrialUsed || _isPremium;
  int get remainingFreeDays => _freeTrialUsed ? 0 : 7;
  
  // 초기화
  Future<void> initialize() async {
    _log('구독 서비스 초기화 시작');
    
    await _loadLocalData();
    
    // In-App Purchase 설정
    final bool available = await _inAppPurchase.isAvailable();
    if (!available) {
      _log('In-App Purchase 사용 불가');
      notifyListeners();
      return;
    }
    
    // 구매 스트림 리스너 설정
    _subscription = _inAppPurchase.purchaseStream.listen(
      _handlePurchaseUpdate,
      onDone: () => _subscription?.cancel(),
      onError: (error) => _log('구매 스트림 에러: $error'),
    );
    
    await _loadProducts();
    _log('구독 서비스 초기화 완료');
  }
  
  // 로컬 데이터 로드
  Future<void> _loadLocalData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isPremium = prefs.getBool(_premiumKey) ?? false;
      _freeTrialUsed = prefs.getBool(_freeTrialKey) ?? false;
      
      final dateString = prefs.getString(_subscriptionDateKey);
      if (dateString != null) {
        _subscriptionDate = DateTime.parse(dateString);
        
        // 구독 만료 확인 (테스트를 위해 30일로 설정)
        if (_subscriptionDate != null && 
            DateTime.now().difference(_subscriptionDate!).inDays > 30) {
          _isPremium = false;
          await _savePremiumStatus(false);
        }
      }
      
      _log('로컬 데이터 로드: isPremium=$_isPremium, freeTrialUsed=$_freeTrialUsed');
    } catch (e) {
      _log('로컬 데이터 로드 실패: $e');
    }
  }
  
  // 상품 정보 로드
  Future<void> _loadProducts() async {
    try {
      _isLoading = true;
      notifyListeners();
      
      final Set<String> productIds = {monthlyProductId, yearlyProductId};
      final ProductDetailsResponse response = await _inAppPurchase.queryProductDetails(productIds);
      
      if (response.error != null) {
        _log('상품 로드 에러: ${response.error}');
        return;
      }
      
      _products = response.productDetails;
      _log('상품 로드 완료: ${_products.length}개');
    } catch (e) {
      _log('상품 로드 실패: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // 무료 체험 시작
  Future<void> startFreeTrial() async {
    if (_freeTrialUsed) return;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_freeTrialKey, true);
      _freeTrialUsed = true;
      
      _log('무료 체험 시작');
      notifyListeners();
    } catch (e) {
      _log('무료 체험 시작 실패: $e');
    }
  }
  
  // 구독 구매
  Future<bool> purchaseSubscription(String productId) async {
    try {
      _log('구독 구매 시작: $productId');
      
      final ProductDetails? product = _products.firstWhere(
        (p) => p.id == productId,
        orElse: () => throw Exception('상품을 찾을 수 없습니다'),
      );
      
      if (product == null) {
        _log('상품을 찾을 수 없음: $productId');
        return false;
      }
      
      final PurchaseParam purchaseParam = PurchaseParam(productDetails: product);
      
      // 구독 상품 구매
      final bool result = await _inAppPurchase.buyAutoRenewingSubscription(
        purchaseParam: purchaseParam,
      );
      
      _log('구매 요청 결과: $result');
      return result;
    } catch (e) {
      _log('구매 실패: $e');
      return false;
    }
  }
  
  // 구매 업데이트 처리
  void _handlePurchaseUpdate(List<PurchaseDetails> purchaseDetailsList) {
    for (final purchase in purchaseDetailsList) {
      _log('구매 업데이트: ${purchase.productID}, 상태: ${purchase.status}');
      
      if (purchase.status == PurchaseStatus.pending) {
        // 구매 대기 중
        _log('구매 대기 중');
      } else if (purchase.status == PurchaseStatus.error) {
        // 구매 에러
        _log('구매 에러: ${purchase.error}');
        _inAppPurchase.completePurchase(purchase);
      } else if (purchase.status == PurchaseStatus.purchased ||
                 purchase.status == PurchaseStatus.restored) {
        // 구매 성공 또는 복원
        _processPurchase(purchase);
      } else if (purchase.status == PurchaseStatus.canceled) {
        // 구매 취소
        _log('구매 취소');
        _inAppPurchase.completePurchase(purchase);
      }
    }
  }
  
  // 구매 처리
  Future<void> _processPurchase(PurchaseDetails purchase) async {
    try {
      _log('구매 처리 중: ${purchase.productID}');
      
      // 프리미엄 활성화
      await _activatePremium();
      
      // 구매 완료 처리
      await _inAppPurchase.completePurchase(purchase);
      
      _log('구매 완료: ${purchase.productID}');
    } catch (e) {
      _log('구매 처리 실패: $e');
    }
  }
  
  // 프리미엄 활성화
  Future<void> _activatePremium() async {
    await _savePremiumStatus(true);
    
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    await prefs.setString(_subscriptionDateKey, now.toIso8601String());
    
    _subscriptionDate = now;
    _log('프리미엄 활성화됨');
  }
  
  // 프리미엄 상태 저장
  Future<void> _savePremiumStatus(bool isPremium) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_premiumKey, isPremium);
      _isPremium = isPremium;
      notifyListeners();
    } catch (e) {
      _log('프리미엄 상태 저장 실패: $e');
    }
  }
  
  // 구매 복원
  Future<bool> restorePurchases() async {
    try {
      _log('구매 복원 시작');
      await _inAppPurchase.restorePurchases();
      return true;
    } catch (e) {
      _log('구매 복원 실패: $e');
      return false;
    }
  }
  
  // 테스트용: 프리미엄 활성화 (개발/테스트 전용)
  Future<void> enablePremiumForTesting() async {
    if (kDebugMode) {
      await _activatePremium();
      _log('테스트용 프리미엄 활성화');
    }
  }
  
  // 테스트용: 모든 데이터 초기화
  Future<void> resetForTesting() async {
    if (kDebugMode) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_premiumKey);
      await prefs.remove(_subscriptionDateKey);
      await prefs.remove(_freeTrialKey);
      
      _isPremium = false;
      _freeTrialUsed = false;
      _subscriptionDate = null;
      
      _log('테스트용 데이터 초기화');
      notifyListeners();
    }
  }
  
  // 로그 출력
  void _log(String message) {
    debugPrint('💳 [LOCAL_SUBSCRIPTION] $message');
  }
  
  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}