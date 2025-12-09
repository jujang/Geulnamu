import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/auth_provider.dart';
import '../../services/navigation/pending_navigation_service.dart';
import '../../core/config/app_config.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _navigateToHome();
  }

  void _setupAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );

    // 애니메이션 시작
    _fadeController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      _scaleController.forward();
    });
  }

  Future<void> _navigateToHome() async {
    if (AppConfig.debugMode) {
      print('🚀 [Splash] _navigateToHome 시작...');
    }

    // 🎯 폰트 프리로딩 (플래시 방지) - 완료 후 즉시 이동
    await _preloadFonts();

    if (mounted) {
      if (AppConfig.debugMode) {
        print('🔐 [Splash] checkAuthStatus 호출 전...');
      }

      // 🔐 로그인 상태 확인 (await로 완료 대기)
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.checkAuthStatus();

      if (AppConfig.debugMode) {
        print('🔐 [Splash] checkAuthStatus 완료!');
        print('🔐 [Splash] 로그인 상태: ${authProvider.isAuthenticated}');
        print('🔐 [Splash] AuthStatus: ${authProvider.status}');
        print('🔐 [Splash] 사용자 정보: ${authProvider.userInfo}');
      }

      if (mounted) {
        // 📩 Pending Navigation 처리 (알림 클릭으로 앱 시작 시)
        await _handlePendingNavigation(authProvider);
      }
    }
  }

  /// 📩 Pending Navigation 처리
  /// 
  /// 알림 클릭으로 앱이 시작된 경우, 저장된 목적지로 이동
  /// - 로그인 상태: 해당 페이지로 바로 이동
  /// - 비로그인 상태: 홈으로 이동 (Pending 유지, 로그인 후 처리)
  Future<void> _handlePendingNavigation(AuthProvider authProvider) async {
    final pendingService = PendingNavigationService();
    
    try {
      final pending = await pendingService.getPendingNavigation();
      
      if (pending != null) {
        if (AppConfig.debugMode) {
          print('📩 [Splash] Pending Navigation 발견!');
          print('📩 [Splash] route: ${pending.route}');
          print('📩 [Splash] arguments: ${pending.arguments}');
          print('📩 [Splash] 로그인 상태: ${authProvider.isAuthenticated}');
        }
        
        if (authProvider.isAuthenticated) {
          // ✅ 로그인 상태: Pending Navigation 삭제 후 해당 페이지로 이동
          await pendingService.clearPendingNavigation();
          
          if (mounted) {
            // 🎯 URL 형식으로 이동 (쿼리 파라미터 포함)
            final url = _buildUrlWithArguments(pending.route, pending.arguments);
            
            if (AppConfig.debugMode) {
              print('🚀 [Splash] 로그인됨 → Pending 페이지로 이동: $url');
            }
            
            context.go(url);
          }
        } else {
          // ⏳ 비로그인 상태: Pending 유지하고 홈으로 이동
          // (로그인 후 HomeScreen 또는 다른 곳에서 처리 가능)
          if (AppConfig.debugMode) {
            print('⏳ [Splash] 비로그인 → 홈으로 이동 (Pending 유지)');
          }
          
          if (mounted) {
            context.go('/home');
          }
        }
      } else {
        // 📭 Pending Navigation 없음: 일반 홈 화면 이동
        if (AppConfig.debugMode) {
          print('📭 [Splash] Pending Navigation 없음 → 홈으로 이동');
        }
        
        if (mounted) {
          context.go('/home');
        }
      }
    } catch (e) {
      if (AppConfig.debugMode) {
        print('❌ [Splash] Pending Navigation 처리 오류: $e');
      }
      
      // 오류 발생 시 안전하게 홈으로 이동
      if (mounted) {
        context.go('/home');
      }
    }
  }

  /// URL에 arguments를 쿼리 파라미터로 추가
  String _buildUrlWithArguments(String route, Map<String, dynamic>? arguments) {
    if (arguments == null || arguments.isEmpty) {
      return route;
    }
    
    // 이미 쿼리 파라미터가 있는 경우
    if (route.contains('?')) {
      final params = arguments.entries
          .map((e) => '${e.key}=${Uri.encodeComponent(e.value.toString())}')
          .join('&');
      return '$route&$params';
    } else {
      final params = arguments.entries
          .map((e) => '${e.key}=${Uri.encodeComponent(e.value.toString())}')
          .join('&');
      return '$route?$params';
    }
  }

  /// 🎯 폰트 프리로딩 - 앱에서 사용하는 모든 폰트 weight 미리 로드
  Future<void> _preloadFonts() async {
    try {
      await GoogleFonts.pendingFonts([
        GoogleFonts.notoSans(fontWeight: FontWeight.w400), // Regular
        GoogleFonts.notoSans(fontWeight: FontWeight.w500), // Medium
        GoogleFonts.notoSans(fontWeight: FontWeight.w600), // SemiBold
        GoogleFonts.notoSans(fontWeight: FontWeight.w700), // Bold
      ]);
    } catch (e) {
      // 폰트 로드 실패해도 앱은 계속 진행 (시스템 폰트로 대체)
      debugPrint('⚠️ [폰트] 프리로딩 실패: $e');
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      // 🎯 scaffoldBackgroundColor와 동일하게 설정 (다른 화면과 일관성 유지)
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 로고 이미지 (책갈피 디자인 컨셉) - 둥근 사각형 배경
                Container(
                  width: 230,
                  height: 230,
                  decoration: BoxDecoration(
                    color: colorScheme.primary,
                    borderRadius: BorderRadius.circular(32),
                    boxShadow: [
                      BoxShadow(
                        color: colorScheme.primary.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(15),
                  child: Image.asset(
                    'assets/logo/app_logo.png',
                    fit: BoxFit.contain,
                  ),
                ),

                const SizedBox(height: 24),

                // 앱 이름
                Text(
                  '글나무',
                  style: GoogleFonts.notoSans(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                    letterSpacing: 2.0,
                  ),
                ),

                const SizedBox(height: 8),

                // 서브 타이틀
                Text(
                  'BOOK CLUB',
                  style: GoogleFonts.roboto(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: colorScheme.primary,
                    letterSpacing: 1.5,
                  ),
                ),

                const SizedBox(height: 16),

                // 설명 텍스트
                Text(
                  '독서 토론의 새로운 시작\n함께 읽고, 함께 성장해요',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.notoSans(
                    fontSize: 16,
                    color: colorScheme.onSurfaceVariant,
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 40),

                // 로딩 인디케이터
                SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      colorScheme.primary,
                    ),
                    strokeWidth: 2.5,
                  ),
                ),

                const SizedBox(height: 16),

                // 로딩 텍스트
                Text(
                  '앱을 시작하는 중...',
                  style: GoogleFonts.notoSans(
                    fontSize: 14,
                    color: colorScheme.onSurfaceVariant.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
