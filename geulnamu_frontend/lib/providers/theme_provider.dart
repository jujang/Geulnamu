import 'package:flutter/material.dart';
import '../core/services/settings_service.dart';

/// 테마 상태 관리 Provider
/// SettingsService와 연동하여 테마 모드 관리
class ThemeProvider extends ChangeNotifier {
  final SettingsService _settingsService = SettingsService();
  
  ThemeMode _themeMode = ThemeMode.system; // 기본값: 시스템 설정
  bool _isLoading = false;

  /// 현재 테마 모드
  ThemeMode get themeMode => _themeMode;
  
  /// 로딩 상태
  bool get isLoading => _isLoading;

  /// 현재 테마 모드의 표시명
  String get currentThemeDisplayName => _settingsService.getThemeModeDisplayName(_themeMode);

  /// 초기화 - 저장된 테마 모드 로드
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      _themeMode = await _settingsService.getThemeMode();
      print('✅ [ThemeProvider] 테마 모드 초기화 완료: $_themeMode');
    } catch (e) {
      print('❌ [ThemeProvider] 테마 모드 초기화 실패: $e');
      _themeMode = ThemeMode.system; // 실패 시 기본값
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 테마 모드 변경
  Future<void> setThemeMode(ThemeMode newThemeMode) async {
    if (_themeMode == newThemeMode) {
      print('🔄 [ThemeProvider] 동일한 테마 모드 - 변경 없음: $newThemeMode');
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      // 먼저 UI 업데이트
      _themeMode = newThemeMode;
      notifyListeners();

      // 설정 저장
      final success = await _settingsService.setThemeMode(newThemeMode);
      
      if (success) {
        print('✅ [ThemeProvider] 테마 모드 변경 성공: $newThemeMode');
      } else {
        print('❌ [ThemeProvider] 테마 모드 저장 실패 - UI는 이미 변경됨');
      }
    } catch (e) {
      print('❌ [ThemeProvider] 테마 모드 변경 오류: $e');
      // 에러 발생 시 이전 상태로 복원하지 않음 (UI 우선)
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 다음 테마 모드로 순환 (라이트 → 다크 → 시스템 → 라이트...)
  Future<void> toggleThemeMode() async {
    ThemeMode nextTheme;
    
    switch (_themeMode) {
      case ThemeMode.light:
        nextTheme = ThemeMode.dark;
        break;
      case ThemeMode.dark:
        nextTheme = ThemeMode.system;
        break;
      case ThemeMode.system:
        nextTheme = ThemeMode.light;
        break;
    }
    
    await setThemeMode(nextTheme);
  }

  /// 다크 모드 여부 확인 (시스템 테마 모드 고려)
  bool isDarkMode(BuildContext context) {
    switch (_themeMode) {
      case ThemeMode.light:
        return false;
      case ThemeMode.dark:
        return true;
      case ThemeMode.system:
        return MediaQuery.of(context).platformBrightness == Brightness.dark;
    }
  }

  /// 모든 테마 모드 옵션 반환
  List<ThemeMode> get allThemeModes => _settingsService.getAllThemeModes();

  /// 테마 모드 표시명 반환
  String getThemeModeDisplayName(ThemeMode mode) => _settingsService.getThemeModeDisplayName(mode);
}
