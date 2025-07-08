import 'package:flutter/material.dart';

/// 글나무 앱의 브랜딩 색상 정의
/// 책갈피 디자인 컨셉을 기반으로 한 따뜻하고 친근한 색상 팔레트
class GeulnamuColors {
  // ========== 메인 색상 팔레트 ==========
  
  /// 메인 컬러: 연한 청록색/민트
  /// 책갈피의 마스코트 캐릭터에서 영감을 받은 메인 컬러
  static const Color primary = Color(0xFF7DD3C0);
  static const Color primaryLight = Color(0xFF6BC4AE);
  static const Color primaryDark = Color(0xFF5BAB98);
  
  /// 서브 컬러: 베이지/크림색
  /// 따뜻하고 편안한 느낌을 주는 보조 색상
  static const Color secondary = Color(0xFFF5F1E8);
  static const Color secondaryLight = Color(0xFFEDE7D3);
  static const Color secondaryDark = Color(0xFFE5DCC5);
  
  // ========== 배경 및 표면 색상 ==========
  
  /// 배경 컬러: 오프화이트
  static const Color background = Color(0xFFF8F8F8);
  static const Color backgroundSecondary = Color(0xFFFAFAFA);
  
  /// 표면 색상 (카드, 다이얼로그 등)
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF5F5F5);
  
  // ========== 텍스트 색상 ==========
  
  /// 텍스트: 진한 청록색 및 일반 텍스트
  static const Color textPrimary = Color(0xFF4A9B8E);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textTertiary = Color(0xFF9E9E9E);
  static const Color textOnPrimary = Color(0xFFFFFFFF);
  
  // ========== 기능별 색상 ==========
  
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
  
  // ========== 특수 색상 ==========
  
  /// 그림자 색상
  static const Color shadow = Color(0x1A000000);
  static const Color shadowLight = Color(0x0D000000);
  
  /// 구분선 색상
  static const Color divider = Color(0xFFE0E0E0);
  static const Color border = Color(0xFFBDBDBD);
  
  /// 비활성화된 요소
  static const Color disabled = Color(0xFFBDBDBD);
  static const Color disabledText = Color(0xFF9E9E9E);
  
  // ========== 투명도 적용된 색상 ==========
  
  /// 메인 컬러의 투명도 변형
  static Color get primaryWithOpacity10 => primary.withOpacity(0.1);
  static Color get primaryWithOpacity20 => primary.withOpacity(0.2);
  static Color get primaryWithOpacity30 => primary.withOpacity(0.3);
  
  /// 배경 오버레이 (모달, 로딩 화면 등)
  static Color get overlay => Colors.black.withOpacity(0.5);
  static Color get overlayLight => Colors.black.withOpacity(0.3);
  
  // ========== 그라데이션 ==========
  
  /// 메인 그라데이션 (버튼, 헤더 등에 사용)
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF7DD3C0),
      Color(0xFF6BC4AE),
    ],
  );
  
  /// 배경 그라데이션 (전체 배경에 사용)
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFFFAFAFA),
      Color(0xFFF8F8F8),
    ],
  );
}

/// 다크 모드 지원을 위한 확장 (추후 구현 예정)
extension GeulnamuColorsDark on GeulnamuColors {
  // TODO: 다크 모드 색상 팔레트 정의
  // 현재는 라이트 모드만 지원
}
