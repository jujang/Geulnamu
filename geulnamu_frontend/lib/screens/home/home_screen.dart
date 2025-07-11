import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/app_header.dart';
import '../../widgets/common/responsive_container.dart';
import '../../widgets/home/pwa_install_card.dart';
import 'home_screen_logic.dart';
import 'home_screen_widgets.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with
        TickerProviderStateMixin,
        RouteAware,
        HomeScreenLogic,
        HomeScreenWidgets {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();

    // 🎯 RouteObserver 등록을 위해 다음 프레임에서 실행
    WidgetsBinding.instance.addPostFrameCallback((_) {
      registerRouteObserver();
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

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          return Scaffold(
            // 🎯 backgroundColor 제거! 테마에서 자동 처리
            appBar: AppHeader(
              onLoginPressed: authProvider.isAuthenticated
                  ? null
                  : navigateToLogin,
              showLoginButton: !authProvider.isAuthenticated,
              profileWidget: authProvider.isAuthenticated
                  ? buildProfileMenu(
                      context,
                      authProvider,
                      handleProfileMenuSelection,
                    )
                  : null,
            ),
            body: SafeArea(
              child: ResponsiveContainer(
                padding: const EdgeInsets.all(16),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 🎯 동적 환영 카드 (로그인 상태에 따라 메시지 변경)
                      buildDynamicWelcomeCard(context, authProvider),
                      const SizedBox(height: 24),

                      // 🎯 통일된 빠른 메뉴 (카드 콘텐츠는 요청사항 반영)
                      buildQuickMenuGrid(context, authProvider, handleMenuTap),
                      const SizedBox(height: 24),

                      // 🎯 로그인 상태에 따른 추가 콘텐츠
                      if (authProvider.isAuthenticated) ...[
                        buildRecentMeetingsSection(context),
                        const SizedBox(height: 24),
                      ] else ...[
                        // PWA 설치 안내 (로그인 전에만 표시)
                        PWAInstallCard(
                          onInstallPressed: () =>
                              showInstallInstructions(context),
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
            // 🎯 로그인 후에만 FAB 표시
            floatingActionButton: authProvider.isAuthenticated
                ? FloatingActionButton.extended(
                    onPressed: showCreateMeetingDialog,
                    label: const Text('모임 만들기'),
                    icon: const Icon(Icons.add),
                  )
                : null,
          );
        },
      ),
    );
  }
}
