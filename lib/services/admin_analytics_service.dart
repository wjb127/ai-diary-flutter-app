import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:math';

class AdminAnalyticsService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // 대시보드 전체 데이터 조회
  Future<Map<String, dynamic>> getDashboardData() async {
    try {
      // 실제 데이터가 없는 경우 모의 데이터 생성
      return _generateMockData();
    } catch (e) {
      print('Analytics data fetch error: $e');
      return _generateMockData();
    }
  }

  // 사용자 퍼널 데이터 조회
  Future<Map<String, dynamic>> getFunnelData() async {
    try {
      // 실제 구현 시에는 Supabase에서 데이터를 가져옴
      return {
        'visitorsToSignup': 0.15, // 방문자 → 회원가입 15%
        'signupToFirstDiary': 0.65, // 회원가입 → 첫 일기 작성 65%
        'firstDiaryToActive': 0.45, // 첫 일기 → 활성 사용자 45%
        'activeToPremium': 0.08, // 활성 사용자 → 프리미엄 8%
      };
    } catch (e) {
      print('Funnel data fetch error: $e');
      return {
        'visitorsToSignup': 0.15,
        'signupToFirstDiary': 0.65,
        'firstDiaryToActive': 0.45,
        'activeToPremium': 0.08,
      };
    }
  }

  // 리텐션 데이터 조회
  Future<List<Map<String, dynamic>>> getRetentionData() async {
    try {
      // 실제 구현 시에는 Supabase에서 데이터를 가져옴
      return List.generate(30, (index) {
        return {
          'day': index + 1,
          'retention': (100 - (index * 2.5) + Random().nextDouble() * 10).clamp(0, 100),
        };
      });
    } catch (e) {
      print('Retention data fetch error: $e');
      return [];
    }
  }

  // 전환율 데이터 조회
  Future<List<Map<String, dynamic>>> getConversionData() async {
    try {
      final now = DateTime.now();
      return List.generate(12, (index) {
        final date = DateTime(now.year, now.month - index, 1);
        return {
          'month': '${date.month}월',
          'conversion': (5 + Random().nextDouble() * 15).toStringAsFixed(2),
        };
      }).reversed.toList();
    } catch (e) {
      print('Conversion data fetch error: $e');
      return [];
    }
  }

  // 북극성 지표 데이터 조회
  Future<Map<String, dynamic>> getNorthStarMetrics() async {
    try {
      return {
        'weeklyActiveDiaries': 2847, // 주간 활성 일기 수 (북극성 지표)
        'averageSessionTime': '8분 32초',
        'userEngagementScore': 87.5,
        'contentQualityScore': 92.3,
        'retentionDay7': 42.8,
        'retentionDay30': 18.5,
      };
    } catch (e) {
      print('North star metrics fetch error: $e');
      return {};
    }
  }

  // 모의 데이터 생성 (실제 데이터가 없을 때)
  Map<String, dynamic> _generateMockData() {
    final random = Random();
    
    return {
      // 기본 통계
      'totalUsers': 15420 + random.nextInt(1000),
      'dailyActiveUsers': 3247 + random.nextInt(500),
      'premiumUsers': 1832 + random.nextInt(200),
      'totalDiaries': 45678 + random.nextInt(2000),
      
      // 성장률 (%)
      'userGrowthRate': (8.5 + random.nextDouble() * 5).toStringAsFixed(1),
      'dauGrowthRate': (12.3 + random.nextDouble() * 8).toStringAsFixed(1),
      'premiumGrowthRate': (15.7 + random.nextDouble() * 10).toStringAsFixed(1),
      'diaryGrowthRate': (22.1 + random.nextDouble() * 12).toStringAsFixed(1),
      
      // 퍼널 데이터
      'funnelVisitors': 10000,
      'funnelSignups': 1500,
      'funnelFirstDiary': 975,
      'funnelActiveUsers': 439,
      'funnelPremium': 35,
      
      // 북극성 지표
      'northStar': {
        'weeklyActiveDiaries': 2847 + random.nextInt(500),
        'averageSessionTime': '${7 + random.nextInt(4)}분 ${20 + random.nextInt(40)}초',
        'userEngagementScore': (85 + random.nextDouble() * 10).toStringAsFixed(1),
        'contentQualityScore': (90 + random.nextDouble() * 8).toStringAsFixed(1),
        'retentionDay7': (40 + random.nextDouble() * 10).toStringAsFixed(1),
        'retentionDay30': (15 + random.nextDouble() * 8).toStringAsFixed(1),
      },
      
      // 리텐션 데이터
      'retentionData': List.generate(30, (index) {
        return {
          'day': index + 1,
          'retention': (100 - (index * 2.5) + random.nextDouble() * 10).clamp(0, 100).toStringAsFixed(1),
        };
      }),
      
      // 전환율 데이터
      'conversionData': List.generate(12, (index) {
        final now = DateTime.now();
        final date = DateTime(now.year, now.month - index, 1);
        return {
          'month': '${date.month}월',
          'conversion': (5 + random.nextDouble() * 15).toStringAsFixed(2),
        };
      }).reversed.toList(),
    };
  }

  // 실시간 통계 업데이트 (웹소켓 또는 주기적 폴링)
  Stream<Map<String, dynamic>> getRealTimeStats() async* {
    while (true) {
      await Future.delayed(const Duration(seconds: 30));
      yield await getDashboardData();
    }
  }

  // 특정 기간의 상세 분석 데이터
  Future<Map<String, dynamic>> getDetailedAnalytics(DateTime startDate, DateTime endDate) async {
    try {
      // 실제 구현 시에는 날짜 범위에 따른 쿼리 실행
      return _generateMockData();
    } catch (e) {
      print('Detailed analytics fetch error: $e');
      return {};
    }
  }

  // A/B 테스트 결과 데이터
  Future<List<Map<String, dynamic>>> getABTestResults() async {
    try {
      return [
        {
          'testName': '회원가입 플로우 A/B 테스트',
          'variantA': {'name': '기존 플로우', 'conversion': 12.5, 'users': 5000},
          'variantB': {'name': '간소화 플로우', 'conversion': 18.3, 'users': 5000},
          'status': 'active',
          'significance': 95.8,
        },
        {
          'testName': '일기 작성 UI 테스트',
          'variantA': {'name': '기본 에디터', 'engagement': 65.2, 'users': 3000},
          'variantB': {'name': '개선 에디터', 'engagement': 78.9, 'users': 3000},
          'status': 'completed',
          'significance': 99.2,
        },
      ];
    } catch (e) {
      print('A/B test data fetch error: $e');
      return [];
    }
  }
}