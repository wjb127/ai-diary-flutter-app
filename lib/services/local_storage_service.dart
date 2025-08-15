import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/diary_model.dart';

class LocalStorageService {
  static const String _diaryKeyPrefix = 'local_diary_';
  static const String _pendingDiariesKey = 'pending_diaries';
  static const String _tempDiaryKey = 'temp_diary_content';
  
  final SharedPreferences _prefs;
  
  LocalStorageService._(this._prefs);
  
  static Future<LocalStorageService> getInstance() async {
    final prefs = await SharedPreferences.getInstance();
    return LocalStorageService._(prefs);
  }
  
  // AI 생성 일기 임시 저장 (로그인 전)
  Future<void> saveTempDiary({
    required DateTime date,
    required String title,
    required String originalContent,
    required String generatedContent,
  }) async {
    try {
      final tempDiary = {
        'date': date.toIso8601String(),
        'title': title,
        'originalContent': originalContent,
        'generatedContent': generatedContent,
        'createdAt': DateTime.now().toIso8601String(),
      };
      
      final jsonString = jsonEncode(tempDiary);
      await _prefs.setString(_tempDiaryKey, jsonString);
      
      if (kDebugMode) {
        print('💾 임시 일기 저장 완료: $title');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ 임시 일기 저장 실패: $e');
      }
    }
  }
  
  // 임시 저장된 일기 불러오기
  Future<Map<String, dynamic>?> getTempDiary() async {
    try {
      final jsonString = _prefs.getString(_tempDiaryKey);
      if (jsonString != null) {
        return jsonDecode(jsonString) as Map<String, dynamic>;
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ 임시 일기 불러오기 실패: $e');
      }
    }
    return null;
  }
  
  // 임시 일기 삭제
  Future<void> clearTempDiary() async {
    await _prefs.remove(_tempDiaryKey);
  }
  
  // 로컬에 일기 저장 (오프라인/게스트 모드용)
  Future<void> saveLocalDiary(DiaryEntry diary) async {
    try {
      final key = '$_diaryKeyPrefix${diary.date.toIso8601String().split('T')[0]}';
      final jsonString = jsonEncode(diary.toJson());
      await _prefs.setString(key, jsonString);
      
      // 동기화 대기 목록에 추가
      await _addToPendingSync(diary.date);
      
      if (kDebugMode) {
        print('💾 로컬 일기 저장: ${diary.title}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ 로컬 일기 저장 실패: $e');
      }
    }
  }
  
  // 특정 날짜의 로컬 일기 불러오기
  Future<DiaryEntry?> getLocalDiary(DateTime date) async {
    try {
      final key = '$_diaryKeyPrefix${date.toIso8601String().split('T')[0]}';
      final jsonString = _prefs.getString(key);
      
      if (jsonString != null) {
        final json = jsonDecode(jsonString) as Map<String, dynamic>;
        return DiaryEntry.fromJson(json);
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ 로컬 일기 불러오기 실패: $e');
      }
    }
    return null;
  }
  
  // 모든 로컬 일기 불러오기
  Future<List<DiaryEntry>> getAllLocalDiaries() async {
    final diaries = <DiaryEntry>[];
    
    try {
      final keys = _prefs.getKeys().where((key) => key.startsWith(_diaryKeyPrefix));
      
      for (final key in keys) {
        final jsonString = _prefs.getString(key);
        if (jsonString != null) {
          final json = jsonDecode(jsonString) as Map<String, dynamic>;
          diaries.add(DiaryEntry.fromJson(json));
        }
      }
      
      // 날짜순 정렬 (최신순)
      diaries.sort((a, b) => b.date.compareTo(a.date));
    } catch (e) {
      if (kDebugMode) {
        print('❌ 전체 로컬 일기 불러오기 실패: $e');
      }
    }
    
    return diaries;
  }
  
  // 동기화 대기 목록에 추가
  Future<void> _addToPendingSync(DateTime date) async {
    final pendingList = _prefs.getStringList(_pendingDiariesKey) ?? [];
    final dateString = date.toIso8601String().split('T')[0];
    
    if (!pendingList.contains(dateString)) {
      pendingList.add(dateString);
      await _prefs.setStringList(_pendingDiariesKey, pendingList);
    }
  }
  
  // 동기화 대기 중인 일기 목록 가져오기
  Future<List<String>> getPendingSyncDates() async {
    return _prefs.getStringList(_pendingDiariesKey) ?? [];
  }
  
  // 동기화 완료 후 대기 목록에서 제거
  Future<void> removePendingSync(DateTime date) async {
    final pendingList = _prefs.getStringList(_pendingDiariesKey) ?? [];
    final dateString = date.toIso8601String().split('T')[0];
    
    pendingList.remove(dateString);
    await _prefs.setStringList(_pendingDiariesKey, pendingList);
  }
  
  // 로컬 일기 삭제
  Future<void> deleteLocalDiary(DateTime date) async {
    final key = '$_diaryKeyPrefix${date.toIso8601String().split('T')[0]}';
    await _prefs.remove(key);
    await removePendingSync(date);
  }
  
  // 모든 로컬 데이터 삭제
  Future<void> clearAllLocalData() async {
    final keys = _prefs.getKeys().where((key) => 
      key.startsWith(_diaryKeyPrefix) || 
      key == _pendingDiariesKey ||
      key == _tempDiaryKey
    );
    
    for (final key in keys) {
      await _prefs.remove(key);
    }
  }
  
  // 로그인 후 로컬 데이터를 서버와 동기화
  Future<List<DiaryEntry>> syncWithServer() async {
    final pendingDates = await getPendingSyncDates();
    final syncedDiaries = <DiaryEntry>[];
    
    for (final dateString in pendingDates) {
      final date = DateTime.parse(dateString);
      final localDiary = await getLocalDiary(date);
      
      if (localDiary != null) {
        syncedDiaries.add(localDiary);
        // 서버에 저장 후 로컬에서 제거하는 로직은 diary_service에서 처리
      }
    }
    
    return syncedDiaries;
  }
}