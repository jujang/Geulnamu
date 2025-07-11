import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../services/home/home_service.dart';

/// 홈화면 비즈니스 로직 mixin
/// 
/// 제공 기능:
/// - 메뉴 탭 처리 (handleMenuTap)
/// - 프로필 메뉴 선택 처리 (handleProfileMenuSelection)
/// - 로그아웃 처리 (handleLogout)
/// - 모임 만들기 다이얼로그 (showCreateMeetingDialog)
/// - 네비게이션 (navigateToLogin)
/// - PWA 설치 안내 (showInstallInstructions)
/// 
/// 의존성: HomeService (Singleton)
/// 사용법: with HomeLogicMixin
mixin HomeLogicMixin<T extends StatefulWidget> on State<T> {
  final HomeService _homeService = HomeService();

  // 🎯 메뉴 탭 처리
  void handleMenuTap(String menu) {
    debugPrint('🎯 [HomeLogicMixin] 메뉴 탭: $menu');
    _homeService.handleMenuTap(context, menu);
  }

  // 🎯 프로필 메뉴 선택 처리
  void handleProfileMenuSelection(String value) {
    debugPrint('🎯 [HomeLogicMixin] 프로필 메뉴 선택: $value');
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    _homeService.handleProfileMenuSelection(context, value, authProvider);
  }

  // 🎯 로그아웃 처리
  void handleLogout() {
    debugPrint('🎯 [HomeLogicMixin] 로그아웃 처리');
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    _homeService.handleLogout(context, authProvider);
  }

  // 🎯 모임 만들기 다이얼로그
  void showCreateMeetingDialog() {
    debugPrint('🎯 [HomeLogicMixin] 모임 만들기 다이얼로그');
    _homeService.showCreateMeetingDialog(context);
  }

  // 🎯 로그인 화면으로 이동
  void navigateToLogin() {
    debugPrint('🎯 [HomeLogicMixin] 로그인 화면으로 이동');
    _homeService.navigateToLogin(context);
  }

  // 🎯 PWA 설치 안내
  void showInstallInstructions() {
    debugPrint('🎯 [HomeLogicMixin] PWA 설치 안내');
    _homeService.showInstallInstructions(context);
  }

  // 🔍 개인정보 입력 화면으로 이동
  void navigateToProfileInput() {
    debugPrint('🔍 [HomeLogicMixin] 개인정보 입력 화면으로 이동');
    _homeService.navigateToProfileInput(context);
  }
}
