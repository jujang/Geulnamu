import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart'; // 🎯 SystemChrome import 추가
import '../core/services/settings_service.dart';
import 'dart:js' as js show context;

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
      
      // 🎯 초기 로드 시 시스템 UI 설정
      _updateSystemUI(_themeMode);
    } catch (e) {
      print('❌ [ThemeProvider] 테마 모드 초기화 실패: $e');
      _themeMode = ThemeMode.system; // 실패 시 기본값
      _updateSystemUI(_themeMode);
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
      // 🎯 먼저 시스템 UI 변경 (동기식)
      _updateSystemUI(newThemeMode);
      
      // 그 다음 테마 모드 변경 + 단일 알림
      _themeMode = newThemeMode;

      // 설정 저장 (비동기)
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
      notifyListeners();  // 🎯 단일 알림 - 깜박임 방지
    }
  }
  
  /// 🎯 시스템 UI 통합 업데이트 (웹 theme-color + 네이티브 SystemChrome)
  void _updateSystemUI(ThemeMode mode) {
    // 🎯 웹/네이티브 완전 분리 - PWA 깜박임 방지
    if (kIsWeb) {
      // 웹 환경: theme-color만 업데이트
      _updateWebThemeColor(mode);
    } else {
      // 네이티브 환경: SystemChrome만 업데이트
      _updateNativeSystemUI(mode);
    }
  }
  
  /// 🎯 네이티브 앱의 시스템 UI 업데이트 (상단바 + 하단 내비게이션 바)
  void _updateNativeSystemUI(ThemeMode mode) {
    try {
      bool isDark;
      Color statusBarColor;
      Color navigationBarColor;
      Brightness statusBarIconBrightness;
      Brightness navigationBarIconBrightness;
      
      switch (mode) {
        case ThemeMode.light:
          isDark = false;
          statusBarColor = const Color(0xFF7DD3C0); // 라이트 모드: 민트색 AppBar
          navigationBarColor = const Color(0xFFFAFAFA); // 라이트 모드: 배경색과 동일 (#FAFAFA)
          statusBarIconBrightness = Brightness.light; // 아이콘 밝은색
          navigationBarIconBrightness = Brightness.dark; // 아이콘 어두운색
          break;
        case ThemeMode.dark:
          isDark = true;
          statusBarColor = const Color(0xFF1E1E1E); // 다크 모드: 어두운 AppBar
          navigationBarColor = const Color(0xFF0F0F0F); // 다크 모드: 배경색과 동일 (#0F0F0F)
          statusBarIconBrightness = Brightness.light; // 아이콘 밝은색
          navigationBarIconBrightness = Brightness.light; // 아이콘 밝은색
          break;
        case ThemeMode.system:
          // 🎯 시스템 설정에 따라 자동 결정
          // 현재 시스템 다크모드 여부를 정확히 알 수 없으므로
          // 기본값으로 라이트 모드 설정 (화면이 빌드될 때 자동 업데이트됨)
          isDark = false;
          statusBarColor = const Color(0xFF7DD3C0);
          navigationBarColor = const Color(0xFFFAFAFA);
          statusBarIconBrightness = Brightness.light;
          navigationBarIconBrightness = Brightness.dark;
          break;
      }
      
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        statusBarColor: statusBarColor,
        statusBarIconBrightness: statusBarIconBrightness,
        statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
        
        // 🎯 핵심: 하단 내비게이션 바 색상 변경
        systemNavigationBarColor: navigationBarColor,
        systemNavigationBarIconBrightness: navigationBarIconBrightness,
        systemNavigationBarDividerColor: isDark 
            ? const Color(0xFF424242) 
            : const Color(0xFFE0E0E0),
      ));
      
      print('✅ [ThemeProvider] 네이티브 시스템 UI 업데이트 완료: ${isDark ? "다크" : "라이트"}');
      print('   - 상단바: $statusBarColor');
      print('   - 하단바: $navigationBarColor');
    } catch (e) {
      print('❌ [ThemeProvider] 네이티브 시스템 UI 업데이트 실패: $e');
    }
  }
  
  /// 🎯 웹 환경에서 theme-color 동적 변경
  void _updateWebThemeColor(ThemeMode mode) {
    if (!kIsWeb) {
      print('📱 [ThemeProvider] 네이티브 앱 - theme-color 변경 불필요');
      return;
    }
    
    try {
      String color;
      bool isDark;
      
      switch (mode) {
        case ThemeMode.light:
          color = '#FAFAFA'; // 🎯 라이트 모드: 오프화이트 배경색
          isDark = false;
          break;
        case ThemeMode.dark:
          color = '#0F0F0F'; // 🎯 다크 모드: 거의 검정 배경색
          isDark = true;
          break;
        case ThemeMode.system:
          // 🎯 시스템 설정 감지 (JavaScript 통해)
          try {
            final prefersDark = js.context.callMethod(
              'eval',
              ['window.matchMedia("(prefers-color-scheme: dark)").matches']
            );
            isDark = prefersDark == true;
            color = isDark ? '#0F0F0F' : '#FAFAFA'; // 🎯 시스템 테마에 맞는 배경색
            print('🌓 [ThemeProvider] 시스템 테마 감지: ${isDark ? "다크" : "라이트"}');
          } catch (e) {
            print('⚠️ [ThemeProvider] 시스템 테마 감지 실패: $e - 기본값(라이트) 사용');
            color = '#FAFAFA';
            isDark = false;
          }
          break;
      }
      
      print('🎨 [ThemeProvider] 웹 theme-color 변경 시도: $color (다크: $isDark)');
      
      // JavaScript 함수 호출
      js.context.callMethod('updateThemeColor', [color, isDark]);
      
      print('✅ [ThemeProvider] 웹 theme-color 변경 완료');
    } catch (e) {
      print('❌ [ThemeProvider] 웹 theme-color 변경 실패: $e');
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
