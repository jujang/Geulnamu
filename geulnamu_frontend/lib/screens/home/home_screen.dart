import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../core/config/app_config.dart';
import '../../widgets/common/app_header.dart';
import '../../widgets/common/responsive_container.dart';
import '../../widgets/home/pwa_install_card.dart';
import '../../services/home/home_service.dart';
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
    
    if (AppConfig.debugMode) {
      print('🔍 [HomeScreen] 인증 상태 확인: ${authProvider.status}');
    }
    
    // 🎯 비로그인 상태에서는 리다이렉트 하지 않음
    // HomeScreen에서 로그인 버튼을 보여주면 됨
    if (AppConfig.debugMode) {
      if (authProvider.status == AuthStatus.unauthenticated) {
        print('✅ [HomeScreen] 비로그인 상태 - 로그인 버튼 표시');
      } else {
        print('✅ [HomeScreen] 로그인 상태 - 일반 홈 화면 표시');
      }
    }
  }


  // 🔒 모임 만들기 FAB 표시 여부 결정
  bool _shouldShowCreateMeetingFAB(AuthProvider authProvider) {
    final homeService = HomeService();
    return homeService.canAccessFeature('모임 만들기', authProvider);
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
                  ? HomeWidgets.buildProfileMenu(
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
                      // 🎯 동적 환영 카드 (Static Method 사용)
                      HomeWidgets.buildDynamicWelcomeCard(
                        context,
                        authProvider,
                        onProfileInputTap:
                            navigateToProfileInput, // 개인정보 입력 버튼 핸들러
                      ),
                      const SizedBox(height: 24),

                      // 🎯 통일된 빠른 메뉴 (Static Method 사용)
                      HomeWidgets.buildQuickMenuGrid(
                        context,
                        authProvider,
                        handleMenuTap, // mixin 메서드 사용
                      ),
                      const SizedBox(height: 24),

                      // 🎯 로그인 상태에 따른 추가 콘텐츠
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
            // 🎯 권한 체크를 통해 FAB 표시 여부 결정
            floatingActionButton: _shouldShowCreateMeetingFAB(authProvider)
                ? FloatingActionButton.extended(
                    onPressed: showCreateMeetingDialog, // mixin 메서드 사용
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
