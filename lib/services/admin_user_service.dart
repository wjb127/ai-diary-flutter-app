import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';

class AdminUserService {
  final SupabaseClient _supabase = Supabase.instance.client;
  
  /// 모든 사용자 목록 조회
  Future<List<Map<String, dynamic>>> getAllUsers({
    int page = 1,
    int limit = 20,
    String? searchQuery,
    String? sortBy = 'created_at',
    bool ascending = false,
  }) async {
    try {
      var query = _supabase.from('auth.users').select('''
        id,
        email,
        created_at,
        updated_at,
        last_sign_in_at,
        email_confirmed_at,
        phone,
        raw_user_meta_data
      ''');

      // 검색 필터
      if (searchQuery != null && searchQuery.isNotEmpty) {
        query = query.or('email.ilike.%$searchQuery%,phone.ilike.%$searchQuery%');
      }

      // 정렬
      query = query.order(sortBy, ascending: ascending);

      // 페이징
      final from = (page - 1) * limit;
      query = query.range(from, from + limit - 1);

      final response = await query;
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('사용자 목록 조회 실패: $e');
      throw Exception('사용자 목록을 불러올 수 없습니다: $e');
    }
  }

  /// 사용자 상세 정보 조회
  Future<Map<String, dynamic>?> getUserDetails(String userId) async {
    try {
      // 기본 사용자 정보
      final userResponse = await _supabase
          .from('auth.users')
          .select('''
            id,
            email,
            created_at,
            updated_at,
            last_sign_in_at,
            email_confirmed_at,
            phone,
            raw_user_meta_data
          ''')
          .eq('id', userId)
          .single();

      // 일기 통계
      final diaryStats = await _getDiaryStats(userId);
      
      return {
        ...userResponse,
        'diary_stats': diaryStats,
      };
    } catch (e) {
      debugPrint('사용자 상세 정보 조회 실패: $e');
      return null;
    }
  }

  /// 사용자 일기 통계
  Future<Map<String, dynamic>> _getDiaryStats(String userId) async {
    try {
      // 총 일기 수
      final totalCount = await _supabase
          .from('diary_entries')
          .count()
          .eq('user_id', userId);

      // 최근 7일 일기 수
      final recentCount = await _supabase
          .from('diary_entries')
          .count()
          .eq('user_id', userId)
          .gte('created_at', DateTime.now().subtract(const Duration(days: 7)).toIso8601String());

      // 첫 일기 작성일
      final firstDiaryResponse = await _supabase
          .from('diary_entries')
          .select('created_at')
          .eq('user_id', userId)
          .order('created_at', ascending: true)
          .limit(1);

      // 마지막 일기 작성일
      final lastDiaryResponse = await _supabase
          .from('diary_entries')
          .select('created_at')
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .limit(1);

      return {
        'total_entries': totalCount,
        'recent_entries': recentCount,
        'first_entry_date': firstDiaryResponse.isNotEmpty 
            ? firstDiaryResponse.first['created_at'] 
            : null,
        'last_entry_date': lastDiaryResponse.isNotEmpty 
            ? lastDiaryResponse.first['created_at'] 
            : null,
      };
    } catch (e) {
      debugPrint('일기 통계 조회 실패: $e');
      return {
        'total_entries': 0,
        'recent_entries': 0,
        'first_entry_date': null,
        'last_entry_date': null,
      };
    }
  }

  /// 사용자 계정 비활성화
  Future<bool> deactivateUser(String userId) async {
    try {
      // Supabase Admin API를 통해 사용자 비활성화
      // 실제 구현시에는 적절한 권한 검증 필요
      await _supabase.auth.admin.updateUserById(
        userId,
        AdminUserAttributes(
          emailConfirm: false,
          userMetadata: {'is_active': false},
        ),
      );
      
      debugPrint('사용자 계정 비활성화 완료: $userId');
      return true;
    } catch (e) {
      debugPrint('사용자 계정 비활성화 실패: $e');
      return false;
    }
  }

  /// 사용자 계정 활성화
  Future<bool> activateUser(String userId) async {
    try {
      await _supabase.auth.admin.updateUserById(
        userId,
        AdminUserAttributes(
          emailConfirm: true,
          userMetadata: {'is_active': true},
        ),
      );
      
      debugPrint('사용자 계정 활성화 완료: $userId');
      return true;
    } catch (e) {
      debugPrint('사용자 계정 활성화 실패: $e');
      return false;
    }
  }

  /// 사용자 일기 목록 조회 (관리자용)
  Future<List<Map<String, dynamic>>> getUserDiaries(
    String userId, {
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final from = (page - 1) * limit;
      
      final response = await _supabase
          .from('diary_entries')
          .select('id, date, title, created_at, updated_at')
          .eq('user_id', userId)
          .order('date', ascending: false)
          .range(from, from + limit - 1);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('사용자 일기 목록 조회 실패: $e');
      throw Exception('사용자 일기를 불러올 수 없습니다: $e');
    }
  }

  /// 전체 사용자 통계
  Future<Map<String, dynamic>> getUserStats() async {
    try {
      // 전체 사용자 수
      final totalUsers = await _supabase.from('auth.users').count();

      // 이번 달 가입자 수
      final thisMonthUsers = await _supabase
          .from('auth.users')
          .count()
          .gte('created_at', DateTime(DateTime.now().year, DateTime.now().month, 1).toIso8601String());

      // 활성 사용자 (최근 30일 로그인)
      final activeUsers = await _supabase
          .from('auth.users')
          .count()
          .gte('last_sign_in_at', DateTime.now().subtract(const Duration(days: 30)).toIso8601String());

      // 이메일 인증 완료 사용자
      final verifiedUsers = await _supabase
          .from('auth.users')
          .count()
          .not('email_confirmed_at', 'is', null);

      return {
        'total_users': totalUsers,
        'this_month_users': thisMonthUsers,
        'active_users': activeUsers,
        'verified_users': verifiedUsers,
      };
    } catch (e) {
      debugPrint('사용자 통계 조회 실패: $e');
      return {
        'total_users': 0,
        'this_month_users': 0,
        'active_users': 0,
        'verified_users': 0,
      };
    }
  }
}