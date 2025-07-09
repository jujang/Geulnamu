import 'package:flutter/material.dart';
import 'breakpoints.dart';

class ResponsiveHelper {
  // 화면 크기 판단
  static bool isDesktop(BuildContext context) => 
      MediaQuery.of(context).size.width >= Breakpoints.desktop;
  
  static bool isTablet(BuildContext context) => 
      MediaQuery.of(context).size.width >= Breakpoints.tablet &&
      MediaQuery.of(context).size.width < Breakpoints.desktop;
  
  static bool isMobile(BuildContext context) => 
      MediaQuery.of(context).size.width < Breakpoints.tablet;
  
  static bool isLargeMobile(BuildContext context) => 
      MediaQuery.of(context).size.width >= Breakpoints.mobile &&
      MediaQuery.of(context).size.width < Breakpoints.tablet;
  
  static bool isSmallMobile(BuildContext context) => 
      MediaQuery.of(context).size.width < Breakpoints.mobile;

  // 동적 크기 계산
  static double getScreenWidth(BuildContext context) => 
      MediaQuery.of(context).size.width;

  // 아이콘 크기 (예전 로직 그대로)
  static double getIconSize(BuildContext context) {
    final width = getScreenWidth(context);
    if (width >= Breakpoints.desktop) return 96;
    if (width >= Breakpoints.tablet) return 78;
    if (width >= Breakpoints.mobile) return 60;
    return 44;
  }

  // 폰트 크기 (예전 로직 그대로)
  static double getTitleFontSize(BuildContext context) {
    final width = getScreenWidth(context);
    if (width >= Breakpoints.desktop) return 24;
    if (width >= Breakpoints.tablet) return 20;
    if (width >= Breakpoints.mobile) return 17;
    return 15;
  }

  static double getSubtitleFontSize(BuildContext context) {
    final width = getScreenWidth(context);
    if (width >= Breakpoints.desktop) return 15;
    if (width >= Breakpoints.tablet) return 14;
    if (width >= Breakpoints.mobile) return 13;
    return 12;
  }

  // 패딩 (예전 로직 그대로)
  static double getCardPadding(BuildContext context) {
    final width = getScreenWidth(context);
    if (width >= Breakpoints.desktop) return 16.0;
    if (width >= Breakpoints.tablet) return 14.0;
    if (width >= Breakpoints.mobile) return 12.0;
    return 10.0;
  }

  // 그리드 설정
  static int getGridCrossAxisCount(BuildContext context) {
    // 모든 화면 크기에서 2열 (예전 디자인 그대로)
    return 2;
  }

  // PWA 설정
  static double getPWACardPadding(BuildContext context) {
    return getScreenWidth(context) >= Breakpoints.tablet ? 20.0 : 16.0;
  }

  static double getPWAIconSize(BuildContext context) {
    return getScreenWidth(context) >= Breakpoints.tablet ? 36.0 : 32.0;
  }
}
