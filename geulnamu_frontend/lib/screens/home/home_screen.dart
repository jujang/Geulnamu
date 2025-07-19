import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/home/home_service.dart';
import '../../widgets/common/app_header.dart';
import '../../widgets/common/app_drawer.dart';
import '../../widgets/common/responsive_container.dart';
import '../../widgets/common/loading_widgets.dart';
import '../../widgets/home/pwa_install_card.dart';
import 'mixins/home_logic_mixin.dart';
import 'mixins/route_aware_mixin.dart';
import 'widgets/home_widgets.dart';

/// 홈화면 - 완전한 하이브리드 방식
///
/// 구조:
/// - StatefulWidget + Mixin 조합 (HomeLogicMixin, RouteAwareMixin)
/// - Service 클래스 활용 (HomeService, HomeRouteService)
/// - Static Widgets 사용 (HomeWidgets)
///
/// 제공 기능:
/// - 동적 환영 카드 (로그인 상태별)
/// - 빠른 메뉴 그리드
/// - 최근 모임 섹션
/// - PWA 설치 안내
/// - RouteAware 화면 전환 감지
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with TickerProviderStateMixin, RouteAware, HomeLogicMixin, RouteAwareMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();

    // 🎯 RouteObserver 등록을 위해 다음 프레임에서 실행
    WidgetsBinding.instance.addPostFrameCallback((_) {
      registerRouteObserver();
      _checkAuthStatus(); // 초기 인증 상태 확인
    });
  }

  void _setupAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _fadeController.forward();
  }

  @override
  void dispose() {
    unregisterRouteObserver(); // 🎯 RouteObserver 구독 해제
    _fadeController.dispose();
    super.dispose();
  }

  /// 🔍 인증 상태 확인 및 자동 리다이렉트
  void _checkAuthStatus() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // 비로그인 상태에서는 리다이렉트 하지 않음
  }

  // 🔒 모임 만들기 FAB 표시 여부 결정
  bool _shouldShowCreateMeetingFAB(AuthProvider authProvider) {
    // 로그인이 안 되어 있으면 비표시
    if (!authProvider.isAuthenticated) {
      return false;
    }

    // 개인정보 입력이 안 되어 있으면 비표시
    if (authProvider.profileCompleted == false) {
      return false;
    }

    // 모임원 목록은 임원진 이상 권한 필요 (현재는 다른 기능들은 무제한)
    // 현재 모임 만들기는 권한 제한 없음
    return true;
  }

  /// 홈화면용 프로필 메뉴 빌드
  Widget _buildProfileMenu(BuildContext context, AuthProvider authProvider) {
    return PopupMenuButton<String>(
      // 더 시각적으로 구분되는 아바타 스타일
      tooltip: '사용자 메뉴',
      onSelected: handleProfileMenuSelection,
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
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
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
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
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
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
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
          enabled: !Provider.of<HomeService>(
            context,
            listen: false,
          ).isProcessing, // 로딩 중 비활성화
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.error.withOpacity(0.1),
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
                  ).colorScheme.onPrimary.withOpacity(0.3),
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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Provider 상태 변화 감지
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _checkAuthStatus();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Consumer2<AuthProvider, HomeService>(
        builder: (context, authProvider, homeService, child) {
          return LoadingWidgets.buildOverlayLoading(
            context,
            isLoading: homeService.isProcessing,
            loadingMessage: homeService.currentOperation,
            child: Scaffold(
              // 🎯 backgroundColor 제거! 테마에서 자동 처리
              appBar: AppHeader(
                onLoginPressed: authProvider.isAuthenticated
                    ? null
                    : navigateToLogin,
                showLoginButton: !authProvider.isAuthenticated,
                showDrawerButton: true, // Drawer 버튼 표시
                onLogoTap: navigateToHome, // 로고 클릭으로 홈 이동
                profileWidget: authProvider.isAuthenticated
                    ? _buildProfileMenu(context, authProvider) // 직접 프로필 메뉴 생성
                    : null,
              ),
              // Drawer 추가!
              drawer: AppDrawer(
                onMenuTap: handleMenuTap, // mixin 메서드 재사용
                onLoginTap: navigateToLogin,
                onLogoutTap: handleLogout,
              ),
              body: SafeArea(
                child: ResponsiveContainer(
                  // 🎯 패딩 제거 - 스크롤바가 화면 끝에 위치하도록
                  child: SingleChildScrollView(
                    child: Padding(
                      // 콘텐츠에만 패딩 적용
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 동적 환영 카드 (Static Method 사용)
                          HomeWidgets.buildDynamicWelcomeCard(
                            context,
                            authProvider,
                            onProfileInputTap:
                                navigateToProfileInput, // 개인정보 입력 버튼 핸들러
                          ),
                          const SizedBox(height: 24),

                          // 통일된 빠른 메뉴 (Static Method 사용)
                          HomeWidgets.buildQuickMenuGrid(
                            context,
                            authProvider,
                            handleMenuTap, // mixin 메서드 사용
                          ),
                          const SizedBox(height: 24),

                          // 로그인 상태에 따른 추가 콘텐츠
                          if (authProvider.isAuthenticated) ...[
                            HomeWidgets.buildRecentMeetingsSection(context),
                            const SizedBox(height: 24),
                          ] else ...[
                            // PWA 설치 안내 (로그인 전에만 표시)
                            PWAInstallCard(
                              onInstallPressed:
                                  showInstallInstructions, // mixin 메서드 사용
                            ),
                            const SizedBox(height: 24),
                          ],

                          // 추가 여백
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              // 권한 체크를 통해 FAB 표시 여부 결정
              floatingActionButton: _shouldShowCreateMeetingFAB(authProvider)
                  ? FloatingActionButton.extended(
                      onPressed: homeService.isProcessing
                          ? null // 로딩 중에는 비활성화
                          : showCreateMeetingDialog, // mixin 메서드 사용
                      label: const Text('모임 만들기'),
                      icon: const Icon(Icons.add),
                    )
                  : null,
            ),
          );
        },
      ),
    );
  }
}
