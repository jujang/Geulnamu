import 'package:flutter/material.dart';

/// 글나무 앱의 브랜딩 색상 정의
/// Material Theme + 다크모드 완벽 지원 + 명확한 카드/배경 대비
class GeulnamuColors {
  // ========== 라이트 테마 색상 ==========
  
  /// 메인 컬러: 책갈피 디자인 컨셉의 민트색
  static const Color primaryLight = Color(0xFF7DD3C0);
  static const Color primaryVariantLight = Color(0xFF6BC4AE);
  static const Color secondaryLight = Color(0xFFF5F1E8);
  
  /// 배경 및 표면 색상 (라이트) - 🎯 명확한 대비 보장
  static const Color backgroundLight = Color(0xFFFAFAFA);      // 오프화이트 배경 (유지)
  static const Color surfaceLight = Color(0xFFFFFFFF);        // 카드는 완전한 흰색 (명확한 대비!)
  static const Color surfaceVariantLight = Color(0xFFF5F5F5); // 입력 필드 등
  
  /// 텍스트 색상 (라이트)
  static const Color onPrimaryLight = Color(0xFFFFFFFF);
  static const Color onBackgroundLight = Color(0xFF2C3E50);
  static const Color onSurfaceLight = Color(0xFF2C3E50);
  static const Color onSurfaceVariantLight = Color(0xFF757575);
  
  // ========== 다크 테마 색상 (업데이트) ==========
  
  /// 메인 컬러: 다크 모드용 조정된 민트색
  static const Color primaryDark = Color(0xFF5BAB98);
  static const Color primaryVariantDark = Color(0xFF4A9B8E);
  static const Color secondaryDark = Color(0xFF3A3A3A);
  
  /// 배경 및 표면 색상 (다크) - 🎯 더 명확한 대비 제공
  static const Color backgroundDark = Color(0xFF0F0F0F);       // 더 어두운 배경 (거의 검정)
  static const Color surfaceDark = Color(0xFF1E1E1E);         // 카드는 충분히 밝은 회색 (명확한 대비!)
  static const Color surfaceVariantDark = Color(0xFF2A2A2A);  // 입력 필드는 더 밝게
  
  /// 텍스트 색상 (다크)
  static const Color onPrimaryDark = Color(0xFFFFFFFF);
  static const Color onBackgroundDark = Color(0xFFE1E1E1);
  static const Color onSurfaceDark = Color(0xFFE1E1E1);
  static const Color onSurfaceVariantDark = Color(0xFFB0B0B0);
  
  // ========== 공통 의미별 색상 ==========
  
  /// 성공 (출석 완료, 저장 완료 등)
  static const Color success = Color(0xFF4CAF50);
  static const Color successLight = Color(0xFF81C784);
  
  /// 경고 (지각, 주의사항 등)
  static const Color warning = Color(0xFFFF9800);
  static const Color warningLight = Color(0xFFFFB74D);
  
  /// 오류 (출석 실패, 에러 등)
  static const Color error = Color(0xFFF44336);
  static const Color errorLight = Color(0xFFE57373);
  
  /// 정보 (알림, 안내 등)
  static const Color info = Color(0xFF2196F3);
  static const Color infoLight = Color(0xFF64B5F6);
  
  // ========== 그라데이션 및 특수 색상 ==========
  
  /// 메인 그라데이션 (라이트 모드)
  static const LinearGradient primaryGradientLight = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryLight, primaryVariantLight],
  );
  
  /// 메인 그라데이션 (다크 모드)
  static const LinearGradient primaryGradientDark = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryDark, primaryVariantDark],
  );
  
  /// 그림자 색상
  static const Color shadowLight = Color(0x1A000000);
  static const Color shadowDark = Color(0x4A000000);
  
  /// 구분선 색상
  static const Color dividerLight = Color(0xFFE0E0E0);
  static const Color dividerDark = Color(0xFF424242);
  
  /// 비활성화된 요소
  static const Color disabledLight = Color(0xFFBDBDBD);
  static const Color disabledDark = Color(0xFF616161);
}
