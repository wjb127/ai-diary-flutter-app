import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SimpleSubscriptionService extends ChangeNotifier {
  static const String monthlyProductId = 'ai_diary_monthly';
  static const String yearlyProductId = 'ai_diary_yearly';
  
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _subscription;
  
  List<ProductDetails> _products = [];
  bool _isAvailable = false;
  bool _isPremium = false;
  bool _loading = false;
  
  // Getters
  bool get isPremium => _isPremium;
  bool get isAvailable => _isAvailable;
  bool get loading => _loading;
  List<ProductDetails> get products => _products;
  
  // 초기화
  Future<void> initialize() async {
    _log('구독 서비스 초기화 시작');
    
    // 구매 가능 여부 확인
    _isAvailable = await _inAppPurchase.isAvailable();
    if (!_isAvailable) {
      _log('In-App Purchase를 사용할 수 없습니다');
      notifyListeners();
      return;
    }
    
    // 구매 업데이트 리스너 설정
    _subscription = _inAppPurchase.purchaseStream.listen(
      _onPurchaseUpdate,
      onDone: () => _subscription?.cancel(),
      onError: (error) => _log('구매 스트림 에러: $error'),
    );
    
    // 상품 로드
    await loadProducts();
    
    // 이전 구매 복원
    await restorePurchases();
    
    _log('구독 서비스 초기화 완료');
  }
  
  // 상품 로드
  Future<void> loadProducts() async {
    _loading = true;
    notifyListeners();
    
    try {
      final Set<String> productIds = {monthlyProductId, yearlyProductId};
      final ProductDetailsResponse response = 
          await _inAppPurchase.queryProductDetails(productIds);
      
      if (response.error != null) {
        _log('상품 로드 에러: ${response.error}');
        _loading = false;
        notifyListeners();
        return;
      }
      
      _products = response.productDetails;
      _log('상품 로드 완료: ${_products.length}개');
    } catch (e) {
      _log('상품 로드 실패: $e');
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
  
  // 구매 처리
  Future<bool> purchase(String productId) async {
    if (!_isAvailable || _products.isEmpty) {
      _log('구매 불가능: 상품이 없거나 사용 불가');
      return false;
    }
    
    try {
      final ProductDetails? product = _products.firstWhere(
        (p) => p.id == productId,
        orElse: () => throw Exception('상품을 찾을 수 없습니다'),
      );
      
      if (product == null) {
        _log('상품을 찾을 수 없음: $productId');
        return false;
      }
      
      final PurchaseParam purchaseParam = PurchaseParam(
        productDetails: product,
      );
      
      // 구독 상품 구매
      bool result = await _inAppPurchase.buyNonConsumable(
        purchaseParam: purchaseParam,
      );
      
      _log('구매 요청: $productId, 결과: $result');
      return result;
    } catch (e) {
      _log('구매 실패: $e');
      return false;
    }
  }
  
  // 구매 업데이트 처리
  void _onPurchaseUpdate(List<PurchaseDetails> purchaseDetailsList) {
    for (PurchaseDetails purchase in purchaseDetailsList) {
      _log('구매 업데이트: ${purchase.productID}, 상태: ${purchase.status}');
      
      if (purchase.status == PurchaseStatus.pending) {
        // 구매 대기 중
        _log('구매 대기 중: ${purchase.productID}');
      } else if (purchase.status == PurchaseStatus.error) {
        // 구매 에러
        _log('구매 에러: ${purchase.error}');
        _inAppPurchase.completePurchase(purchase);
      } else if (purchase.status == PurchaseStatus.purchased ||
                 purchase.status == PurchaseStatus.restored) {
        // 구매 성공 또는 복원
        _verifyAndDeliverProduct(purchase);
      } else if (purchase.status == PurchaseStatus.canceled) {
        // 구매 취소
        _log('구매 취소됨');
        _inAppPurchase.completePurchase(purchase);
      }
    }
  }
  
  // 구매 검증 및 제공
  Future<void> _verifyAndDeliverProduct(PurchaseDetails purchase) async {
    // 실제 앱에서는 서버 검증 필요
    // 여기서는 간단히 로컬 저장소에 저장
    
    _log('구매 검증 중: ${purchase.productID}');
    
    // 프리미엄 활성화
    await _setPremiumStatus(true);
    
    // 구매 완료 처리
    await _inAppPurchase.completePurchase(purchase);
    
    _log('구매 완료: ${purchase.productID}');
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
  
  // 프리미엄 상태 설정
  Future<void> _setPremiumStatus(bool isPremium) async {
    _isPremium = isPremium;
    
    // 로컬 저장소에 저장
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_premium', isPremium);
    
    notifyListeners();
  }
  
  // 프리미엄 상태 로드
  Future<void> loadPremiumStatus() async {
    final prefs = await SharedPreferences.getInstance();
    _isPremium = prefs.getBool('is_premium') ?? false;
    notifyListeners();
  }
  
  // 월간 구매
  Future<bool> purchaseMonthly() async {
    return purchase(monthlyProductId);
  }
  
  // 연간 구매
  Future<bool> purchaseYearly() async {
    return purchase(yearlyProductId);
  }
  
  // 로깅
  void _log(String message) {
    debugPrint('💳 [SUBSCRIPTION] $message');
  }
  
  // 정리
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}