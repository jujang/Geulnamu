import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'colors.dart';

/// 글나무 앱의 Material Theme 정의
/// 완전 중앙집중화된 색상 관리 + 명확한 카드/배경 대비 + 다크모드 지원
class GeulnamuTheme {
  
  /// 🎯 라이트 테마 - FAFAFA 배경 + 흰색 카드로 명확한 대비
  static ThemeData get lightTheme {
    final ColorScheme colorScheme = ColorScheme.light(
      // 메인 색상
      primary: GeulnamuColors.primaryLight,
      onPrimary: GeulnamuColors.onPrimaryLight,
      primaryContainer: GeulnamuColors.primaryVariantLight,
      onPrimaryContainer: GeulnamuColors.onPrimaryLight,
      
      // 보조 색상  
      secondary: GeulnamuColors.secondaryLight,
      onSecondary: GeulnamuColors.onBackgroundLight,
      
      // 🎯 표면 색상 - 명확한 대비 보장
      surface: GeulnamuColors.surfaceLight,              // 카드: 완전한 흰색
      onSurface: GeulnamuColors.onSurfaceLight,
      surfaceVariant: GeulnamuColors.surfaceVariantLight,
      onSurfaceVariant: GeulnamuColors.onSurfaceVariantLight,
      
      // 🎯 배경 색상 - 오프화이트
      background: GeulnamuColors.backgroundLight,        // 배경: FAFAFA
      onBackground: GeulnamuColors.onBackgroundLight,
      
      // 에러 색상
      error: GeulnamuColors.error,
      onError: Colors.white,
      
      // 기타
      outline: GeulnamuColors.dividerLight,
      shadow: GeulnamuColors.shadowLight,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      
      // 🎯 가장 중요: 모든 Scaffold의 배경색 자동 설정
      scaffoldBackgroundColor: colorScheme.background,
      
      // 🎯 폰트 테마 - 색상 자동 연동
      textTheme: GoogleFonts.notoSansTextTheme().copyWith(
        headlineLarge: GoogleFonts.notoSans(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: colorScheme.onBackground,
        ),
        headlineMedium: GoogleFonts.notoSans(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: colorScheme.onBackground,
        ),
        headlineSmall: GoogleFonts.notoSans(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: colorScheme.onBackground,
        ),
        bodyLarge: GoogleFonts.notoSans(
          fontSize: 16,
          color: colorScheme.onBackground,
        ),
        bodyMedium: GoogleFonts.notoSans(
          fontSize: 14,
          color: colorScheme.onBackground,
        ),
        bodySmall: GoogleFonts.notoSans(
          fontSize: 12,
          color: colorScheme.onSurfaceVariant,
        ),
        labelLarge: GoogleFonts.notoSans(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: colorScheme.onPrimary,
        ),
      ),
      
      // 🎯 AppBar 테마
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.notoSans(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: colorScheme.onPrimary,
        ),
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: colorScheme.primary,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        ),
      ),
      
      // 🎯 Card 테마 - 색상 하드코딩 제거, ColorScheme 활용
      cardTheme: CardThemeData(
        color: colorScheme.surface,  // 🎯 surface 색상 사용 (라이트: 흰색, 다크: 회색)
        shadowColor: colorScheme.shadow,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      
      // 🎯 FloatingActionButton 테마
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      
      // 🎯 ElevatedButton 테마
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          textStyle: GoogleFonts.notoSans(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      
      // 🎯 OutlinedButton 테마
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colorScheme.primary,
          side: BorderSide(color: colorScheme.primary, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
      
      // 🎯 TextButton 테마
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colorScheme.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      
      // 🎯 Icon 테마
      iconTheme: IconThemeData(
        color: colorScheme.primary,
        size: 24,
      ),
      primaryIconTheme: IconThemeData(
        color: colorScheme.onPrimary,
        size: 24,
      ),
      
      // 🎯 PopupMenu 테마
      popupMenuTheme: PopupMenuThemeData(
        color: colorScheme.surface,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: GoogleFonts.notoSans(
          fontSize: 14,
          color: colorScheme.onSurface,
        ),
      ),
      
      // 🎯 SnackBar 테마
      snackBarTheme: SnackBarThemeData(
        backgroundColor: colorScheme.primary, // 🎨 글나무 민트색
        contentTextStyle: GoogleFonts.notoSans(
          color: colorScheme.onPrimary, // 민트색 배경에 대비되는 텍스트 색상
          fontWeight: FontWeight.w500,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        behavior: SnackBarBehavior.floating,
        elevation: 3,
      ),
      
      // 🎯 Divider 테마
      dividerTheme: DividerThemeData(
        color: colorScheme.outline,
        thickness: 1,
      ),
      
      // 🎯 기타 컴포넌트들
      chipTheme: ChipThemeData(
        backgroundColor: colorScheme.surfaceVariant,
        selectedColor: colorScheme.primary,
        labelStyle: GoogleFonts.notoSans(fontSize: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      
      // 🎯 스크롤바 테마 - 우측 끝 정렬 + 적당한 두께
      scrollbarTheme: ScrollbarThemeData(
        // 스크롤바 두께 (기본값보다 약간 두껍게, 이전보다는 얇게)
        thickness: MaterialStateProperty.all(8.0),
        // 스크롤바 색상 (라이트 모드)
        thumbColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.hovered)) {
            return colorScheme.primary.withOpacity(0.8);
          }
          if (states.contains(MaterialState.dragged)) {
            return colorScheme.primary;
          }
          return colorScheme.primary.withOpacity(0.6);
        }),
        // 스크롤바 트랙 색상
        trackColor: MaterialStateProperty.all(
          colorScheme.outline.withOpacity(0.2),
        ),
        // 스크롤바 모양
        radius: const Radius.circular(6),
        // 스크롤바가 우측 끝에 정확히 위치하도록
        crossAxisMargin: 0,
        mainAxisMargin: 4,
        // 항상 표시 설정 제거 (개별 Scrollbar 위젯에서 제어)
        thumbVisibility: MaterialStateProperty.all(false),
        trackVisibility: MaterialStateProperty.all(false),
      ),
    );
  }
  
  /// 🌙 다크 테마 - 어두운 배경 + 밝은 카드로 명확한 대비
  static ThemeData get darkTheme {
    final ColorScheme colorScheme = ColorScheme.dark(
      // 메인 색상
      primary: GeulnamuColors.primaryDark,
      onPrimary: GeulnamuColors.onPrimaryDark,
      primaryContainer: GeulnamuColors.primaryVariantDark,
      onPrimaryContainer: GeulnamuColors.onPrimaryDark,
      
      // 보조 색상
      secondary: GeulnamuColors.secondaryDark,
      onSecondary: GeulnamuColors.onBackgroundDark,
      
      // 🎯 표면 색상 - 명확한 대비 보장
      surface: GeulnamuColors.surfaceDark,               // 카드: 충분히 밝은 회색
      onSurface: GeulnamuColors.onSurfaceDark,
      surfaceVariant: GeulnamuColors.surfaceVariantDark,
      onSurfaceVariant: GeulnamuColors.onSurfaceVariantDark,
      
      // 🎯 배경 색상 - 더 어두운 검정
      background: GeulnamuColors.backgroundDark,         // 배경: 0F0F0F
      onBackground: GeulnamuColors.onBackgroundDark,
      
      // 에러 색상
      error: GeulnamuColors.error,
      onError: Colors.white,
      
      // 기타
      outline: GeulnamuColors.dividerDark,
      shadow: GeulnamuColors.shadowDark,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.background,
      
      // 다크 테마용 폰트
      textTheme: GoogleFonts.notoSansTextTheme().copyWith(
        headlineLarge: GoogleFonts.notoSans(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: colorScheme.onBackground,
        ),
        headlineMedium: GoogleFonts.notoSans(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: colorScheme.onBackground,
        ),
        headlineSmall: GoogleFonts.notoSans(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: colorScheme.onBackground,
        ),
        bodyLarge: GoogleFonts.notoSans(
          fontSize: 16,
          color: colorScheme.onBackground,
        ),
        bodyMedium: GoogleFonts.notoSans(
          fontSize: 14,
          color: colorScheme.onBackground,
        ),
        bodySmall: GoogleFonts.notoSans(
          fontSize: 12,
          color: colorScheme.onSurfaceVariant,
        ),
        labelLarge: GoogleFonts.notoSans(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: colorScheme.onPrimary,
        ),
      ),
      
      // 🎯 다크 모드 AppBar - surface 사용으로 더 자연스럽게
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.notoSans(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface,
        ),
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: colorScheme.surface,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        ),
      ),
      
      // 🎯 다크 모드 Card - surface 색상 자동 사용
      cardTheme: CardThemeData(
        color: colorScheme.surface,  // 🎯 다크모드: 밝은 회색 (#1E1E1E)
        shadowColor: colorScheme.shadow,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          textStyle: GoogleFonts.notoSans(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colorScheme.primary,
          side: BorderSide(color: colorScheme.primary, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
      
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colorScheme.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      
      iconTheme: IconThemeData(
        color: colorScheme.primary,
        size: 24,
      ),
      primaryIconTheme: IconThemeData(
        color: colorScheme.onPrimary,
        size: 24,
      ),
      
      popupMenuTheme: PopupMenuThemeData(
        color: colorScheme.surface,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: GoogleFonts.notoSans(
          fontSize: 14,
          color: colorScheme.onSurface,
        ),
      ),
      
      snackBarTheme: SnackBarThemeData(
        backgroundColor: colorScheme.primary, // 🎨 글나무 민트색 (다크 모드)
        contentTextStyle: GoogleFonts.notoSans(
          color: colorScheme.onPrimary, // 민트색 배경에 대비되는 텍스트 색상
          fontWeight: FontWeight.w500,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        behavior: SnackBarBehavior.floating,
        elevation: 3,
      ),
      
      dividerTheme: DividerThemeData(
        color: colorScheme.outline,
        thickness: 1,
      ),
      
      chipTheme: ChipThemeData(
        backgroundColor: colorScheme.surfaceVariant,
        selectedColor: colorScheme.primary,
        labelStyle: GoogleFonts.notoSans(fontSize: 14, color: colorScheme.onSurfaceVariant),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      
      // 🎯 스크롤바 테마 - 다크 모드용
      scrollbarTheme: ScrollbarThemeData(
        // 스크롤바 두께 (기본값보다 약간 두껍게, 이전보다는 얇게)
        thickness: MaterialStateProperty.all(8.0),
        // 스크롤바 색상 (다크 모드)
        thumbColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.hovered)) {
            return colorScheme.primary.withOpacity(0.9);
          }
          if (states.contains(MaterialState.dragged)) {
            return colorScheme.primary;
          }
          return colorScheme.primary.withOpacity(0.7);
        }),
        // 스크롤바 트랙 색상 (다크 모드에서 더 밝게)
        trackColor: MaterialStateProperty.all(
          colorScheme.outline.withOpacity(0.3),
        ),
        // 스크롤바 모양
        radius: const Radius.circular(6),
        // 스크롤바가 우측 끝에 정확히 위치하도록
        crossAxisMargin: 0,
        mainAxisMargin: 4,
        // 항상 표시 설정 제거 (개별 Scrollbar 위젯에서 제어)
        thumbVisibility: MaterialStateProperty.all(false),
        trackVisibility: MaterialStateProperty.all(false),
      ),
    );
  }
}

/// 🎯 테마 관련 확장 메서드 (편의성 제공)
extension GeulnamuThemeExtension on BuildContext {
  /// 현재 테마의 ColorScheme
  ColorScheme get colors => Theme.of(this).colorScheme;
  
  /// 현재 테마의 TextTheme
  TextTheme get textStyles => Theme.of(this).textTheme;
  
  /// 다크 모드 여부
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;
  
  /// 편의 색상 접근자
  Color get primaryColor => colors.primary;
  Color get backgroundColor => colors.background;
  Color get surfaceColor => colors.surface;
  Color get textColor => colors.onBackground;
  
  /// 의미별 색상 (확장)
  Color get successColor => GeulnamuColors.success;
  Color get warningColor => GeulnamuColors.warning;
  Color get errorColor => GeulnamuColors.error;
  Color get infoColor => GeulnamuColors.info;
  
  /// 현재 테마에 맞는 그라데이션
  LinearGradient get primaryGradient => isDarkMode 
      ? GeulnamuColors.primaryGradientDark 
      : GeulnamuColors.primaryGradientLight;
}
