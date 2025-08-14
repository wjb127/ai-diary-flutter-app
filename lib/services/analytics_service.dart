import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io' show Platform;
import 'package:uuid/uuid.dart';

class AnalyticsService {
  static final AnalyticsService _instance = AnalyticsService._internal();
  factory AnalyticsService() => _instance;
  AnalyticsService._internal();

  final _supabase = Supabase.instance.client;
  final _uuid = const Uuid();
  
  String? _sessionId;
  DateTime? _sessionStart;
  
  // 세션 시작
  Future<void> startSession() async {
    try {
      _sessionId = _uuid.v4();
      _sessionStart = DateTime.now();
      
      final user = _supabase.auth.currentUser;
      if (user == null) return;
      
      await _supabase.from('user_sessions').insert({
        'id': _sessionId,
        'user_id': user.id,
        'session_start': _sessionStart?.toIso8601String(),
        'platform': _getPlatform(),
        'device_info': _getDeviceInfo(),
      });
      
      // 앱 오픈 이벤트 기록
      await logEvent('app', 'app_open');
    } catch (e) {
      debugPrint('세션 시작 실패: $e');
    }
  }
  
  // 세션 종료
  Future<void> endSession() async {
    if (_sessionId == null) return;
    
    try {
      await _supabase.from('user_sessions')
          .update({'session_end': DateTime.now().toIso8601String()})
          .eq('id', _sessionId!);
      
      // 앱 종료 이벤트 기록
      await logEvent('app', 'app_close');
    } catch (e) {
      debugPrint('세션 종료 실패: $e');
    } finally {
      _sessionId = null;
      _sessionStart = null;
    }
  }
  
  // 이벤트 로깅
  Future<void> logEvent(
    String eventType,
    String eventName, {
    Map<String, dynamic>? eventData,
    String? pageUrl,
  }) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return;
      
      // 세션이 없으면 새로 시작
      if (_sessionId == null) {
        await startSession();
      }
      
      await _supabase.rpc('log_user_event', params: {
        'p_user_id': user.id,
        'p_session_id': _sessionId,
        'p_event_type': eventType,
        'p_event_name': eventName,
        'p_event_data': eventData,
        'p_page_url': pageUrl,
        'p_platform': _getPlatform(),
        'p_device_info': _getDeviceInfo(),
      });
      
      debugPrint('📊 이벤트 기록: $eventType/$eventName');
    } catch (e) {
      debugPrint('이벤트 로깅 실패: $e');
    }
  }
  
  // 화면 조회 이벤트
  Future<void> logScreenView(String screenName) async {
    await logEvent('screen', 'screen_view', 
      eventData: {'screen_name': screenName},
      pageUrl: '/$screenName'
    );
  }
  
  // 일기 관련 이벤트
  Future<void> logDiaryEvent(String action, {Map<String, dynamic>? data}) async {
    await logEvent('diary', action, eventData: data);
  }
  
  // 구독 관련 이벤트
  Future<void> logSubscriptionEvent(String action, {Map<String, dynamic>? data}) async {
    await logEvent('subscription', action, eventData: data);
  }
  
  // 인증 관련 이벤트
  Future<void> logAuthEvent(String action, {Map<String, dynamic>? data}) async {
    await logEvent('auth', action, eventData: data);
  }
  
  // 플랫폼 정보 가져오기
  String _getPlatform() {
    if (kIsWeb) return 'web';
    if (!kIsWeb && Platform.isIOS) return 'ios';
    if (!kIsWeb && Platform.isAndroid) return 'android';
    return 'unknown';
  }
  
  // 디바이스 정보 가져오기
  Map<String, dynamic> _getDeviceInfo() {
    final info = <String, dynamic>{
      'platform': _getPlatform(),
      'is_debug': kDebugMode,
    };
    
    if (!kIsWeb) {
      try {
        info['os'] = Platform.operatingSystem;
        info['os_version'] = Platform.operatingSystemVersion;
      } catch (e) {
        // Platform 정보를 가져올 수 없는 경우
      }
    }
    
    return info;
  }
  
  // 퍼널 분석 데이터 가져오기
  Future<List<Map<String, dynamic>>> getFunnelAnalysis(
    String funnelName, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final result = await _supabase.rpc('analyze_funnel', params: {
        'p_funnel_name': funnelName,
        'p_start_date': (startDate ?? DateTime.now().subtract(const Duration(days: 30))).toIso8601String(),
        'p_end_date': (endDate ?? DateTime.now()).toIso8601String(),
      });
      
      return List<Map<String, dynamic>>.from(result);
    } catch (e) {
      debugPrint('퍼널 분석 실패: $e');
      return [];
    }
  }
  
  // 최근 이벤트 가져오기
  Future<List<Map<String, dynamic>>> getRecentEvents({int limit = 100}) async {
    try {
      final result = await _supabase
          .from('user_events')
          .select()
          .order('created_at', ascending: false)
          .limit(limit);
      
      return List<Map<String, dynamic>>.from(result);
    } catch (e) {
      debugPrint('이벤트 조회 실패: $e');
      return [];
    }
  }
  
  // 사용자별 이벤트 통계
  Future<Map<String, dynamic>> getUserEventStats(String userId) async {
    try {
      final events = await _supabase
          .from('user_events')
          .select('event_type, event_name')
          .eq('user_id', userId);
      
      final stats = <String, dynamic>{
        'total_events': events.length,
        'event_types': {},
      };
      
      for (final event in events) {
        final type = event['event_type'] as String;
        stats['event_types'][type] = (stats['event_types'][type] ?? 0) + 1;
      }
      
      return stats;
    } catch (e) {
      debugPrint('사용자 통계 조회 실패: $e');
      return {};
    }
  }
}