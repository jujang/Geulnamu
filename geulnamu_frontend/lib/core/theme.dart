import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'colors.dart';
import 'text_styles.dart';

/// 글나무 앱의 테마 정의
/// 책갈피 디자인 컨셉에 따른 따뜻하고 친근한 UI 테마
class GeulnamuTheme {
  /// 라이트 테마 (기본 테마)
  static ThemeData get lightTheme {
    return ThemeData(
      // ========== 기본 색상 체계 ==========
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: GeulnamuColors.primary,
        brightness: Brightness.light,
        primary: GeulnamuColors.primary,
        secondary: GeulnamuColors.secondary,
        surface: GeulnamuColors.surface,
        background: GeulnamuColors.background,
        error: GeulnamuColors.error,
        onPrimary: GeulnamuColors.textOnPrimary,
        onSecondary: GeulnamuColors.textPrimary,
        onSurface: GeulnamuColors.textPrimary,
        onBackground: GeulnamuColors.textPrimary,
        onError: Colors.white,
      ),

      // ========== 앱바 테마 ==========
      appBarTheme: AppBarTheme(
        backgroundColor: GeulnamuColors.primary,
        foregroundColor: GeulnamuColors.textOnPrimary,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GeulnamuTextStyles.appBarTitle,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: GeulnamuColors.primary,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
        ),
      ),

      // ========== 카드 테마 ==========
      cardTheme: CardThemeData(
        color: GeulnamuColors.surface,
        elevation: 2,
        shadowColor: GeulnamuColors.shadow,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),

      // ========== 버튼 테마 ==========
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: GeulnamuColors.primary,
          foregroundColor: GeulnamuColors.textOnPrimary,
          elevation: 2,
          shadowColor: GeulnamuColors.shadow,
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GeulnamuTextStyles.button,
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: GeulnamuColors.primary,
          side: BorderSide(color: GeulnamuColors.primary, width: 1.5),
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GeulnamuTextStyles.button.withColor(
            GeulnamuColors.primary,
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: GeulnamuColors.primary,
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: GeulnamuTextStyles.button.withColor(
            GeulnamuColors.primary,
          ),
        ),
      ),

      // ========== 플로팅 액션 버튼 ==========
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: GeulnamuColors.primary,
        foregroundColor: GeulnamuColors.textOnPrimary,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),

      // ========== 입력 필드 테마 ==========
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: GeulnamuColors.surfaceVariant,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: GeulnamuColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: GeulnamuColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: GeulnamuColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: GeulnamuColors.error),
        ),
        labelStyle: GeulnamuTextStyles.label,
        hintStyle: GeulnamuTextStyles.body2,
        errorStyle: GeulnamuTextStyles.error,
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),

      // ========== 바텀 네비게이션 ==========
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: GeulnamuColors.surface,
        selectedItemColor: GeulnamuColors.primary,
        unselectedItemColor: GeulnamuColors.textTertiary,
        selectedLabelStyle: GeulnamuTextStyles.bottomNavLabelActive,
        unselectedLabelStyle: GeulnamuTextStyles.bottomNavLabel,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        showSelectedLabels: true,
        showUnselectedLabels: true,
      ),

      // ========== 탭바 테마 ==========
      tabBarTheme: TabBarThemeData(
        labelColor: GeulnamuColors.primary,
        unselectedLabelColor: GeulnamuColors.textSecondary,
        labelStyle: GeulnamuTextStyles.tabLabelActive,
        unselectedLabelStyle: GeulnamuTextStyles.tabLabel,
        indicator: UnderlineTabIndicator(
          borderSide: BorderSide(color: GeulnamuColors.primary, width: 2),
          insets: EdgeInsets.symmetric(horizontal: 16),
        ),
      ),

      // ========== 다이얼로그 테마 ==========
      dialogTheme: DialogThemeData(
        backgroundColor: GeulnamuColors.surface,
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        titleTextStyle: GeulnamuTextStyles.heading3,
        contentTextStyle: GeulnamuTextStyles.body1,
      ),

      // ========== 스낵바 테마 ==========
      snackBarTheme: SnackBarThemeData(
        backgroundColor: GeulnamuColors.textPrimary,
        contentTextStyle: GeulnamuTextStyles.body1.withColor(Colors.white),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        behavior: SnackBarBehavior.floating,
        // margin 속성은 SnackBarThemeData에서 지원되지 않음
      ),

      // ========== 체크박스 테마 ==========
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return GeulnamuColors.primary;
          }
          return GeulnamuColors.surface;
        }),
        checkColor: WidgetStateProperty.all(GeulnamuColors.textOnPrimary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),

      // ========== 라디오 테마 ==========
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return GeulnamuColors.primary;
          }
          return GeulnamuColors.textSecondary;
        }),
      ),

      // ========== 스위치 테마 ==========
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return GeulnamuColors.textOnPrimary;
          }
          return GeulnamuColors.textSecondary;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return GeulnamuColors.primary;
          }
          return GeulnamuColors.disabled;
        }),
      ),

      // ========== 진행 표시기 테마 ==========
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: GeulnamuColors.primary,
        linearTrackColor: GeulnamuColors.primaryWithOpacity20,
        circularTrackColor: GeulnamuColors.primaryWithOpacity20,
      ),

      // ========== 슬라이더 테마 ==========
      sliderTheme: SliderThemeData(
        activeTrackColor: GeulnamuColors.primary,
        inactiveTrackColor: GeulnamuColors.primaryWithOpacity20,
        thumbColor: GeulnamuColors.primary,
        overlayColor: GeulnamuColors.primaryWithOpacity20,
        valueIndicatorColor: GeulnamuColors.primary,
        valueIndicatorTextStyle: GeulnamuTextStyles.caption.withColor(
          Colors.white,
        ),
      ),

      // ========== 구분선 테마 ==========
      dividerTheme: DividerThemeData(
        color: GeulnamuColors.divider,
        thickness: 1,
        space: 1,
      ),

      // ========== 리스트 타일 테마 ==========
      listTileTheme: ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        selectedTileColor: GeulnamuColors.primaryWithOpacity10,
        selectedColor: GeulnamuColors.primary,
        iconColor: GeulnamuColors.textSecondary,
        textColor: GeulnamuColors.textPrimary,
        titleTextStyle: GeulnamuTextStyles.body1,
        subtitleTextStyle: GeulnamuTextStyles.body2,
      ),

      // ========== 칩 테마 ==========
      chipTheme: ChipThemeData(
        backgroundColor: GeulnamuColors.secondary,
        selectedColor: GeulnamuColors.primary,
        disabledColor: GeulnamuColors.disabled,
        labelStyle: GeulnamuTextStyles.caption,
        secondaryLabelStyle: GeulnamuTextStyles.caption.withColor(Colors.white),
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),

      // ========== 기본 텍스트 테마 ==========
      textTheme: TextTheme(
        displayLarge: GeulnamuTextStyles.heading1,
        displayMedium: GeulnamuTextStyles.heading2,
        displaySmall: GeulnamuTextStyles.heading3,
        headlineLarge: GeulnamuTextStyles.heading2,
        headlineMedium: GeulnamuTextStyles.heading3,
        headlineSmall: GeulnamuTextStyles.heading4,
        titleLarge: GeulnamuTextStyles.heading3,
        titleMedium: GeulnamuTextStyles.heading4,
        titleSmall: GeulnamuTextStyles.bodyBold,
        bodyLarge: GeulnamuTextStyles.body1,
        bodyMedium: GeulnamuTextStyles.body2,
        bodySmall: GeulnamuTextStyles.caption,
        labelLarge: GeulnamuTextStyles.button,
        labelMedium: GeulnamuTextStyles.label,
        labelSmall: GeulnamuTextStyles.caption,
      ),

      // ========== 스크롤바 테마 ==========
      scrollbarTheme: ScrollbarThemeData(
        thumbColor: WidgetStateProperty.all(
          GeulnamuColors.primaryWithOpacity30,
        ),
        trackColor: WidgetStateProperty.all(
          GeulnamuColors.primaryWithOpacity10,
        ),
        radius: Radius.circular(8),
        thickness: WidgetStateProperty.all(8),
      ),
    );
  }

  /// 다크 테마 (추후 구현 예정)
  static ThemeData get darkTheme {
    // TODO: 다크 모드 테마 구현
    return lightTheme; // 임시로 라이트 테마 사용
  }
}

/// 테마 관련 확장 메서드
extension ThemeExtensions on BuildContext {
  /// 현재 테마의 ColorScheme 가져오기
  ColorScheme get colorScheme => Theme.of(this).colorScheme;

  /// 현재 테마의 TextTheme 가져오기
  TextTheme get textTheme => Theme.of(this).textTheme;

  /// 글나무 브랜드 색상 가져오기
  GeulnamuColors get colors => GeulnamuColors();

  /// 다크 모드 여부 확인
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;
}
