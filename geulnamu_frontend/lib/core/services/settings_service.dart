import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 설정 관리 서비스
/// SharedPreferences를 사용하여 로컬에 설정값 저장
class SettingsService {
  static final SettingsService _instance = SettingsService._internal();
  factory SettingsService() => _instance;
  SettingsService._internal();

  // 설정 키 상수
  static const String _themeKey = 'theme_mode';
  static const String _notificationKey = 'meeting_notification';

  /// 테마 모드 가져오기
  /// 기본값: system
  Future<ThemeMode> getThemeMode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final themeString = prefs.getString(_themeKey) ?? 'system';
      
      switch (themeString) {
        case 'light':
          return ThemeMode.light;
        case 'dark':
          return ThemeMode.dark;
        case 'system':
        default:
          return ThemeMode.system;
      }
    } catch (e) {
      print('❌ [SettingsService] 테마 모드 로드 실패: $e');
      return ThemeMode.system; // 기본값
    }
  }

  /// 테마 모드 저장하기
  Future<bool> setThemeMode(ThemeMode themeMode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String themeString;
      
      switch (themeMode) {
        case ThemeMode.light:
          themeString = 'light';
          break;
        case ThemeMode.dark:
          themeString = 'dark';
          break;
        case ThemeMode.system:
        default:
          themeString = 'system';
          break;
      }
      
      final success = await prefs.setString(_themeKey, themeString);
      
      if (!success) {
        print('❌ [SettingsService] 테마 모드 저장 실패');
      }
      
      return success;
    } catch (e) {
      print('❌ [SettingsService] 테마 모드 저장 오류: $e');
      return false;
    }
  }

  /// 모임 알림 설정 가져오기
  /// 기본값: true (켜짐)
  Future<bool> getMeetingNotification() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final enabled = prefs.getBool(_notificationKey) ?? true; // 기본값: 켜짐
      
      return enabled;
    } catch (e) {
      print('❌ [SettingsService] 모임 알림 설정 로드 실패: $e');
      return true; // 기본값
    }
  }

  /// 모임 알림 설정 저장하기
  Future<bool> setMeetingNotification(bool enabled) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final success = await prefs.setBool(_notificationKey, enabled);
      
      if (!success) {
        print('❌ [SettingsService] 모임 알림 설정 저장 실패');
      }
      
      return success;
    } catch (e) {
      print('❌ [SettingsService] 모임 알림 설정 저장 오류: $e');
      return false;
    }
  }

  /// 모든 설정 초기화 (디버그/테스트용)
  Future<bool> resetAllSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      final results = await Future.wait([
        prefs.remove(_themeKey),
        prefs.remove(_notificationKey),
      ]);
      
      final success = results.every((result) => result);
      
      return success;
    } catch (e) {
      print('❌ [SettingsService] 설정 초기화 오류: $e');
      return false;
    }
  }

  /// 설정 정보 디버그 출력
  Future<void> debugPrintSettings() async {
    try {
      final themeMode = await getThemeMode();
      final notification = await getMeetingNotification();
      
      print('🔧 [SettingsService] 현재 설정:');
      print('   테마 모드: $themeMode');
      print('   모임 알림: $notification');
    } catch (e) {
      print('❌ [SettingsService] 설정 정보 출력 실패: $e');
    }
  }

  /// 테마 모드를 문자열로 변환 (UI 표시용)
  String getThemeModeDisplayName(ThemeMode themeMode) {
    switch (themeMode) {
      case ThemeMode.light:
        return '라이트';
      case ThemeMode.dark:
        return '다크';
      case ThemeMode.system:
        return '시스템 설정';
    }
  }

  /// 모든 테마 모드 옵션 반환
  List<ThemeMode> getAllThemeModes() {
    return [ThemeMode.light, ThemeMode.dark, ThemeMode.system];
  }
}
