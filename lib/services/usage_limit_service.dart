import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// AI 기능 사용 제한을 관리하는 서비스
/// Google Play Store AI 정책 준수를 위한 일일 사용 제한 구현
/// Supabase를 통해 서버에서 사용 횟수를 관리하여 디바이스 간 동기화
class UsageLimitService extends ChangeNotifier {
  static const int dailyLimit = 10; // 일일 사용 제한 (계정당 10회)
  static const String _usageCountKey = 'daily_usage_count';
  static const String _lastResetDateKey = 'last_reset_date';
  
  int _usageCount = 0;
  DateTime? _lastResetDate;
  final _supabase = Supabase.instance.client;
  
  int get usageCount => _usageCount;
  int get remainingCount => dailyLimit - _usageCount;
  bool get hasReachedLimit => _usageCount >= dailyLimit;
  
  UsageLimitService() {
    _loadUsageData();
  }
  
  /// 사용 데이터 로드
  Future<void> _loadUsageData() async {
    // 로그인 상태 확인
    final user = _supabase.auth.currentUser;
    
    if (user != null && user.id != 'guest-user-id') {
      // 서버에서 사용 횟수 가져오기
      await _loadFromSupabase(user.id);
    } else {
      // 게스트 모드 - 로컬 저장소 사용
      await _loadFromLocal();
    }
  }
  
  /// Supabase에서 사용 횟수 로드
  Future<void> _loadFromSupabase(String userId) async {
    try {
      final today = DateTime.now();
      final todayString = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
      
      // 오늘 날짜의 사용 횟수 조회
      final response = await _supabase
          .from('usage_limits')
          .select('usage_count')
          .eq('user_id', userId)
          .eq('date', todayString)
          .maybeSingle();
      
      if (response != null) {
        _usageCount = response['usage_count'] ?? 0;
      } else {
        _usageCount = 0;
      }
      
      _lastResetDate = DateTime(today.year, today.month, today.day);
      notifyListeners();
    } catch (e) {
      print('📊 Supabase 사용 횟수 로드 실패, 로컬 저장소 사용: $e');
      // 실패 시 로컬 저장소로 폴백
      await _loadFromLocal();
    }
  }
  
  /// 로컬 저장소에서 사용 횟수 로드
  Future<void> _loadFromLocal() async {
    final prefs = await SharedPreferences.getInstance();
    _usageCount = prefs.getInt(_usageCountKey) ?? 0;
    
    final lastResetDateString = prefs.getString(_lastResetDateKey);
    if (lastResetDateString != null) {
      _lastResetDate = DateTime.parse(lastResetDateString);
    }
    
    // 날짜가 바뀌었으면 카운트 리셋
    await _checkAndResetIfNewDay();
    notifyListeners();
  }
  
  /// 새로운 날이 시작되었는지 확인하고 초기화
  Future<void> _checkAndResetIfNewDay() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    if (_lastResetDate == null) {
      // 첫 사용
      await _resetUsageCount();
      return;
    }
    
    final lastResetDay = DateTime(
      _lastResetDate!.year,
      _lastResetDate!.month,
      _lastResetDate!.day,
    );
    
    if (today.isAfter(lastResetDay)) {
      // 새로운 날짜, 카운트 리셋
      await _resetUsageCount();
    }
  }
  
  /// 사용 횟수 초기화
  Future<void> _resetUsageCount() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    
    _usageCount = 0;
    _lastResetDate = now;
    
    await prefs.setInt(_usageCountKey, 0);
    await prefs.setString(_lastResetDateKey, now.toIso8601String());
    
    notifyListeners();
  }
  
  /// 기능 사용 가능 여부 확인
  Future<bool> canUseFeature() async {
    // 사용 전 최신 데이터 로드
    final user = _supabase.auth.currentUser;
    if (user != null && user.id != 'guest-user-id') {
      await _loadFromSupabase(user.id);
    } else {
      await _checkAndResetIfNewDay();
    }
    return !hasReachedLimit;
  }
  
  /// 사용 횟수 증가
  Future<void> incrementUsage() async {
    if (hasReachedLimit) {
      throw Exception('일일 사용 한도를 초과했습니다');
    }
    
    final user = _supabase.auth.currentUser;
    
    if (user != null && user.id != 'guest-user-id') {
      // 서버에서 사용 횟수 증가
      await _incrementInSupabase(user.id);
    } else {
      // 게스트 모드 - 로컬에서만 증가
      await _incrementLocal();
    }
  }
  
  /// Supabase에서 사용 횟수 증가
  Future<void> _incrementInSupabase(String userId) async {
    try {
      final today = DateTime.now();
      final todayString = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
      
      // 현재 사용 횟수 가져오기
      final currentData = await _supabase
          .from('usage_limits')
          .select('usage_count')
          .eq('user_id', userId)
          .eq('date', todayString)
          .maybeSingle();
      
      final currentCount = currentData?['usage_count'] ?? 0;
      
      if (currentCount >= dailyLimit) {
        throw Exception('일일 사용 한도를 초과했습니다');
      }
      
      // upsert로 오늘 날짜의 사용 횟수 증가
      await _supabase
          .from('usage_limits')
          .upsert({
            'user_id': userId,
            'date': todayString,
            'usage_count': currentCount + 1,
            'updated_at': DateTime.now().toIso8601String(),
          }, onConflict: 'user_id,date');
      
      _usageCount = currentCount + 1;
      notifyListeners();
      
      // 로컬에도 동기화
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_usageCountKey, _usageCount);
      
      print('📊 사용 횟수 증가: $_usageCount / $dailyLimit');
    } catch (e) {
      print('📊 Supabase 사용 횟수 증가 실패: $e');
      // 실패 시 로컬에서만 증가
      await _incrementLocal();
    }
  }
  
  /// 로컬에서 사용 횟수 증가
  Future<void> _incrementLocal() async {
    final prefs = await SharedPreferences.getInstance();
    _usageCount++;
    await prefs.setInt(_usageCountKey, _usageCount);
    
    notifyListeners();
    print('📊 로컬 사용 횟수 증가: $_usageCount / $dailyLimit');
  }
  
  /// 남은 사용 횟수 문자열 반환
  String getRemainingUsesText({bool isKorean = true}) {
    if (hasReachedLimit) {
      return isKorean 
        ? '오늘 사용 한도를 초과했습니다' 
        : 'Daily limit reached';
    }
    
    return isKorean
      ? '오늘 남은 횟수: $remainingCount회'
      : 'Remaining today: $remainingCount';
  }
  
  // 디버그용 - 카운트 강제 리셋
  Future<void> forceReset() async {
    await _resetUsageCount();
  }
}