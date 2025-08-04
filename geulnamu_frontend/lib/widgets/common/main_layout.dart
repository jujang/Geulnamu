import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/home/home_service.dart';
import 'app_header.dart';
import 'app_drawer.dart';

/// 글나무 앱의 메인 레이아웃 위젯
///
/// 모든 주요 화면에서 사용하는 공통 레이아웃:
/// - AppHeader (상단바) + AppDrawer (사이드바) 조합
/// - 네비게이션 패턴: 홈(🍔) vs 서브(←) 자동 전환
/// - 편집 모드 지원
/// - 사용자 메뉴 통합
/// - 반응형 레이아웃
class MainLayout extends StatelessWidget {
  /// 화면 제목
  final String title;

  /// 메인 콘텐츠 위젯
  final Widget body;

  /// 홈화면 여부 (true: 🍔햄버거, false: ←뒤로가기)
  final bool isHomePage;

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

  const MainLayout({
    super.key,
    required this.title,
    required this.body,
    this.isHomePage = false,
    this.actions,
    this.floatingActionButton,
    this.bottomNavigationBar,
    this.customProfileWidget,
    this.showProfileMenu = true, // 기본값: true
    this.onLogoTap,
    this.onMenuTap,
    this.onLoginTap,
    this.onLogoutTap,
    this.onBackPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer2<AuthProvider, HomeService>(
      builder: (context, authProvider, homeService, child) {
        return Scaffold(
          // 🎯 테마 시스템 사용 - backgroundColor 없음
          appBar: AppHeader(
            title: title,
            // 🧭 네비게이션 패턴: 홈 vs 서브 화면
            showDrawerButton: isHomePage,
            showBackButton: !isHomePage,
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
        );
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
          value: 'help',
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
                  Icons.help_outline,
                  size: 18,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '도움말',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
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
        Navigator.pushNamed(context, '/profile');
        break;
      case 'settings':
        Navigator.pushNamed(context, '/settings');
        break;
      case 'help':
        // TODO: 도움말 화면 구현 후 연결
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('도움말 화면은 준비 중입니다.')));
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
  /// 홈화면용 MainLayout
  static MainLayout home({
    required String title,
    required Widget body,
    List<Widget>? actions,
    Widget? floatingActionButton,
    Widget? bottomNavigationBar,
    Widget? customProfileWidget,
    bool showProfileMenu = true, // 기본값: true
    VoidCallback? onLogoTap,
    Function(String)? onMenuTap,
    VoidCallback? onLoginTap,
    VoidCallback? onLogoutTap,
  }) {
    return MainLayout(
      title: title,
      body: body,
      isHomePage: true, // 🍔 햄버거 메뉴
      actions: actions,
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomNavigationBar,
      customProfileWidget: customProfileWidget,
      showProfileMenu: showProfileMenu, // 사용자 메뉴 표시 여부
      onLogoTap: onLogoTap,
      onMenuTap: onMenuTap,
      onLoginTap: onLoginTap,
      onLogoutTap: onLogoutTap,
    );
  }

  /// 서브화면용 MainLayout
  static MainLayout sub({
    required String title,
    required Widget body,
    List<Widget>? actions,
    Widget? floatingActionButton,
    Widget? bottomNavigationBar,
    Widget? customProfileWidget,
    bool showProfileMenu = true, // 기본값: true
    VoidCallback? onLogoTap,
    Function(String)? onMenuTap,
    VoidCallback? onLoginTap,
    VoidCallback? onLogoutTap,
    VoidCallback? onBackPressed,
  }) {
    return MainLayout(
      title: title,
      body: body,
      isHomePage: false, // ← 뒤로가기 버튼
      actions: actions,
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomNavigationBar,
      customProfileWidget: customProfileWidget,
      showProfileMenu: showProfileMenu, // 사용자 메뉴 표시 여부
      onLogoTap: onLogoTap,
      onMenuTap: onMenuTap,
      onLoginTap: onLoginTap,
      onLogoutTap: onLogoutTap,
      onBackPressed: onBackPressed,
    );
  }
}
