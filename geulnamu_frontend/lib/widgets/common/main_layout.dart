import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/home/home_service.dart';
import 'app_header.dart';
import 'app_drawer.dart';

/// 글나무 앱의 메인 레이아웃 위젯
///
/// 모든 주요 화면에서 사용하는 공통 레이아웃:
/// - AppHeader (상단바) + AppDrawer (사이드바) 조합
/// - 네비게이션 패턴: 🍔햄버거 vs ←뒤로가기 독립 제어
/// - 시스템 뒤로가기: isRootPage로 별도 제어
/// - 편집 모드 지원
/// - 사용자 메뉴 통합
/// - 반응형 레이아웃
///
/// 🎯 v2.0 개선사항:
/// - isHomePage → showDrawerButton + isRootPage 분리
/// - 햄버거 버튼 표시와 시스템 뒤로가기 제어를 독립적으로 관리
class MainLayout extends StatelessWidget {
  /// 화면 제목
  final String title;

  /// 메인 콘텐츠 위젯
  final Widget body;

  /// @deprecated isHomePage 대신 showDrawerButton과 isRootPage를 사용하세요
  /// 하위 호환성을 위해 유지됨
  final bool? isHomePage;

  /// 🍔 햄버거(Drawer) 버튼 표시 여부 (UI 제어)
  /// true: 햄버거 버튼 표시, false: 뒤로가기 버튼 표시
  final bool? showDrawerButton;

  /// ← 뒤로가기 버튼 표시 여부 (UI 제어)
  /// showDrawerButton이 true이면 무시됨
  final bool? showBackButton;

  /// 🏠 루트 페이지 여부 (시스템 뒤로가기 제어)
  /// true: 시스템 뒤로가기 차단 (홈 화면 등)
  /// false: 시스템 뒤로가기 허용 (일반 서브 화면)
  final bool isRootPage;

  /// 상단바 액션 버튼들
  final List<Widget>? actions;

  /// FAB (플로팅 액션 버튼)
  final Widget? floatingActionButton;

  /// 하단 네비게이션/액션 바
  final Widget? bottomNavigationBar;

  /// 사용자 메뉴 위젯 (null이면 기본 프로필 메뉴 사용)
  final Widget? customProfileWidget;

  /// 사용자 메뉴 표시 여부 (기본: true)
  final bool showProfileMenu;

  /// 로고 클릭 핸들러 (홈으로 이동 등)
  final VoidCallback? onLogoTap;

  /// 사이드바 메뉴 탭 핸들러
  final Function(String)? onMenuTap;

  /// 로그인 버튼 핸들러
  final VoidCallback? onLoginTap;

  /// 로그아웃 핸들러
  final VoidCallback? onLogoutTap;

  /// 뒤로가기 버튼 커스텀 핸들러 (null이면 기본 Navigator.pop)
  final VoidCallback? onBackPressed;

  /// 키보드가 올라올 때 화면 크기 자동 조정 여부 (기본: true)
  /// PWA 환경에서 키보드 처리를 직접 할 때 false로 설정
  final bool resizeToAvoidBottomInset;

  const MainLayout({
    super.key,
    required this.title,
    required this.body,
    @Deprecated('Use showDrawerButton and isRootPage instead')
    this.isHomePage,
    this.showDrawerButton,
    this.showBackButton,
    this.isRootPage = false,
    this.actions,
    this.floatingActionButton,
    this.bottomNavigationBar,
    this.customProfileWidget,
    this.showProfileMenu = true,
    this.onLogoTap,
    this.onMenuTap,
    this.onLoginTap,
    this.onLogoutTap,
    this.onBackPressed,
    this.resizeToAvoidBottomInset = true,
  });

  /// 🎯 햄버거 버튼 표시 여부 계산
  /// 우선순위: showDrawerButton > isHomePage > 기본값(false)
  bool get _showDrawerButton {
    if (showDrawerButton != null) return showDrawerButton!;
    if (isHomePage != null) return isHomePage!;
    return false;
  }

  /// 🎯 뒤로가기 버튼 표시 여부 계산
  /// 햄버거 버튼이 표시되면 뒤로가기는 숨김
  bool get _showBackButton {
    if (_showDrawerButton) return false;
    if (showBackButton != null) return showBackButton!;
    return true;
  }

  /// 🎯 루트 페이지 여부 계산 (시스템 뒤로가기 제어)
  /// 우선순위: isRootPage 명시 > isHomePage 레거시 > 기본값(false)
  bool get _isRootPage {
    // isRootPage가 명시적으로 true로 설정되었으면 사용
    if (isRootPage) return true;
    // 레거시: isHomePage만 사용하고 새 속성이 없는 경우
    // 단, showDrawerButton이 명시되어 있으면 isRootPage 기본값(false) 사용
    if (showDrawerButton == null && isHomePage == true) return true;
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<AuthProvider, HomeService>(
      builder: (context, authProvider, homeService, child) {
        // 🎯 PopScope: 브라우저/하드웨어 뒤로가기 처리
        return PopScope(
          // 루트 페이지: 뒤로가기 막음 / 일반 화면: 시스템 기본 동작 허용
          canPop: !_isRootPage && Navigator.of(context).canPop(),
          onPopInvokedWithResult: (didPop, result) {
            if (didPop) return; // 이미 pop 되었으면 무시
            
            // 🏠 루트 페이지: 뒤로가기 무시 (아무 동작 안 함)
            if (_isRootPage) return;
            
            // 📱 일반 화면: 스택이 비어있으면 홈으로 이동
            if (!Navigator.of(context).canPop()) {
              // 🎯 GoRouter: go로 홈 화면으로 이동
              GoRouter.of(context).go('/home');
            }
          },
          child: Scaffold(
          // 🎯 테마 시스템 사용 - backgroundColor 없음
          // 🎯 키보드 처리 - 화면별로 선택 가능 (기본: true)
          resizeToAvoidBottomInset: resizeToAvoidBottomInset,
          appBar: AppHeader(
            title: title,
            // 🧭 네비게이션 패턴: 햄버거 vs 뒤로가기 버튼 (독립 제어)
            showDrawerButton: _showDrawerButton,
            showBackButton: _showBackButton,
            onBackPressed: onBackPressed,
            // 🔐 로그인 상태별 처리
            showLoginButton: !authProvider.isAuthenticated,
            onLoginPressed: authProvider.isAuthenticated ? null : onLoginTap,
            // 👤 사용자 메뉴 (로그인 시에만 + showProfileMenu가 true일 때만)
            profileWidget: authProvider.isAuthenticated && showProfileMenu
                ? (customProfileWidget ??
                      _buildDefaultProfileMenu(
                        context,
                        authProvider,
                        homeService.isProcessing,
                      ))
                : null,
            // 🏠 로고 클릭으로 홈 이동
            onLogoTap: onLogoTap,
            // ⚙️ 추가 액션 버튼들
            actions: actions,
          ),

          // 🍔 사이드바 (모든 화면에서 접근 가능)
          drawer: AppDrawer(
            onMenuTap: onMenuTap ?? _handleDefaultMenuTap,
            onLoginTap: onLoginTap,
            onLogoutTap: onLogoutTap,
          ),

          // 📱 메인 콘텐츠
          body: SafeArea(child: body),

          // 🎯 FAB 및 하단바
          floatingActionButton: floatingActionButton,
          bottomNavigationBar: bottomNavigationBar,
          ),
        ); // PopScope 닫기
      },
    );
  }

  /// 기본 프로필 메뉴 생성 (더 시각적으로 개선 + 로딩 상태 지원)
  Widget _buildDefaultProfileMenu(
    BuildContext context,
    AuthProvider authProvider,
    bool isProcessing,
  ) {
    return PopupMenuButton<String>(
      // 더 시각적으로 구분되는 아바타 스타일
      tooltip: '사용자 메뉴',
      onSelected: (value) => _handleProfileMenuSelection(context, value),
      // 메뉴 스타일링
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 8,
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'profile',
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.person_outline,
                  size: 18,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '프로필',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'settings',
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.settings_outlined,
                  size: 18,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '설정',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
        const PopupMenuDivider(),
        PopupMenuItem(
          value: 'logout',
          enabled: !isProcessing, // 로딩 중 비활성화
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.logout,
                  size: 18,
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '로그아웃',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.error,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
      // 더 시각적으로 구분되는 아바타 스타일
      child: Container(
        padding: const EdgeInsets.all(8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 사용자 아바타
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Theme.of(
                    context,
                  ).colorScheme.onPrimary.withValues(alpha: 0.3),
                  width: 2,
                ),
              ),
              child: Center(
                child: Text(
                  authProvider.userNickname.isNotEmpty
                      ? authProvider.userNickname[0].toUpperCase()
                      : '?',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            // 드롭다운 아이콘
            Icon(
              Icons.arrow_drop_down,
              color: Theme.of(context).colorScheme.onPrimary,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  /// 기본 프로필 메뉴 선택 처리
  void _handleProfileMenuSelection(BuildContext context, String value) {
    switch (value) {
      case 'profile':
        // 🎯 GoRouter: push로 프로필 화면 이동
        context.push('/profile');
        break;
      case 'settings':
        // 🎯 GoRouter: push로 설정 화면 이동
        context.push('/settings');
        break;
      case 'logout':
        onLogoutTap?.call();
        break;
    }
  }

  /// 기본 메뉴 탭 처리 (HomeService 활용)
  void _handleDefaultMenuTap(String menu) {
    // HomeService의 메뉴 처리 로직 재사용
    // 실제 context가 필요한 경우 외부에서 onMenuTap 핸들러를 전달받아야 함
    print('🎯 [MainLayout] 메뉴 선택: $menu (기본 처리)');
  }
}

/// MainLayout의 편의 생성자들
class MainLayoutHelpers {
  /// 홈화면용 MainLayout (햄버거 버튼 + 시스템 뒤로가기 차단)
  static MainLayout home({
    required String title,
    required Widget body,
    List<Widget>? actions,
    Widget? floatingActionButton,
    Widget? bottomNavigationBar,
    Widget? customProfileWidget,
    bool showProfileMenu = true,
    VoidCallback? onLogoTap,
    Function(String)? onMenuTap,
    VoidCallback? onLoginTap,
    VoidCallback? onLogoutTap,
  }) {
    return MainLayout(
      title: title,
      body: body,
      showDrawerButton: true, // 🍔 햄버거 메뉴
      isRootPage: true, // 🏠 시스템 뒤로가기 차단
      actions: actions,
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomNavigationBar,
      customProfileWidget: customProfileWidget,
      showProfileMenu: showProfileMenu,
      onLogoTap: onLogoTap,
      onMenuTap: onMenuTap,
      onLoginTap: onLoginTap,
      onLogoutTap: onLogoutTap,
    );
  }

  /// 서브화면용 MainLayout (뒤로가기 버튼 + 시스템 뒤로가기 허용)
  static MainLayout sub({
    required String title,
    required Widget body,
    List<Widget>? actions,
    Widget? floatingActionButton,
    Widget? bottomNavigationBar,
    Widget? customProfileWidget,
    bool showProfileMenu = true,
    VoidCallback? onLogoTap,
    Function(String)? onMenuTap,
    VoidCallback? onLoginTap,
    VoidCallback? onLogoutTap,
    VoidCallback? onBackPressed,
  }) {
    return MainLayout(
      title: title,
      body: body,
      showDrawerButton: false, // ← 뒤로가기 버튼
      isRootPage: false, // 📱 시스템 뒤로가기 허용
      actions: actions,
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomNavigationBar,
      customProfileWidget: customProfileWidget,
      showProfileMenu: showProfileMenu,
      onLogoTap: onLogoTap,
      onMenuTap: onMenuTap,
      onLoginTap: onLoginTap,
      onLogoutTap: onLogoutTap,
      onBackPressed: onBackPressed,
    );
  }

  /// 햄버거 버튼을 표시하지만 시스템 뒤로가기는 허용하는 화면
  /// (모임 목록, 발제문 목록 등)
  static MainLayout drawerWithBack({
    required String title,
    required Widget body,
    List<Widget>? actions,
    Widget? floatingActionButton,
    Widget? bottomNavigationBar,
    Widget? customProfileWidget,
    bool showProfileMenu = true,
    VoidCallback? onLogoTap,
    Function(String)? onMenuTap,
    VoidCallback? onLoginTap,
    VoidCallback? onLogoutTap,
  }) {
    return MainLayout(
      title: title,
      body: body,
      showDrawerButton: true, // 🍔 햄버거 메뉴
      isRootPage: false, // 📱 시스템 뒤로가기 허용
      actions: actions,
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomNavigationBar,
      customProfileWidget: customProfileWidget,
      showProfileMenu: showProfileMenu,
      onLogoTap: onLogoTap,
      onMenuTap: onMenuTap,
      onLoginTap: onLoginTap,
      onLogoutTap: onLogoutTap,
    );
  }
}
