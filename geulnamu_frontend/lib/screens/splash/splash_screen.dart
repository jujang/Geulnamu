import 'dart:async';  // 🆕 TimeoutException
import 'package:flutter/foundation.dart' show kIsWeb;  // 🆕 웹 플랫폼 확인
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/auth_provider.dart';
import '../../services/navigation/pending_navigation_service.dart';
import '../../core/config/app_config.dart';
import '../../routes/app_router.dart';

class SplashScreen extends StatefulWidget {
  final String? pendingUrl;  // 🎯 GoRouter에서 전달받은 pending URL
  
  const SplashScreen({super.key, this.pendingUrl});

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
    
    // 🎯 최초 로그: 앱이 로드되었는지 확인
    if (AppConfig.debugMode) {
      print('🚀 [Splash] 시작 (pendingUrl: ${widget.pendingUrl})');
    }
    
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
    try {
      await _initializeApp().timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          if (AppConfig.debugMode) print('⏰ [Splash] 타임아웃');
          _safeNavigateToHome();
        },
      );
    } catch (e) {
      if (AppConfig.debugMode) print('❌ [Splash] 초기화 오류: $e');
      _safeNavigateToHome();
    }
  }

  /// 🎯 앱 초기화 로직
  Future<void> _initializeApp() async {
    await _preloadFonts();
    if (!mounted) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.checkAuthStatus();

    if (AppConfig.debugMode) {
      print('🔐 [Splash] 인증: ${authProvider.isAuthenticated}');
    }

    if (!mounted) return;
    await _handlePendingNavigation(authProvider);
  }

  /// 🎯 안전하게 홈으로 이동
  void _safeNavigateToHome() {
    if (mounted) {
      AppRouter.markInitialized();
      context.go('/home');
    }
  }

  /// 📩 Pending Navigation 처리
  Future<void> _handlePendingNavigation(AuthProvider authProvider) async {
    final pendingService = PendingNavigationService();
    bool navigationCompleted = false;
    
    try {
      // 1. URL 쿼리 파라미터에서 pending URL 확인
      String? pendingUrl = _getPendingUrlFromQueryParams();
      
      if (pendingUrl != null) {
        if (AppConfig.debugMode) {
          print('📩 [Splash] Pending URL: $pendingUrl');
        }
        
        if (authProvider.isAuthenticated) {
          if (mounted) {
            AppRouter.markInitialized();
            context.go(pendingUrl);
            navigationCompleted = true;
          }
        } else {
          await _savePendingFromUrl(pendingUrl);
          if (mounted) {
            AppRouter.markInitialized();
            context.go('/home');
            navigationCompleted = true;
          }
        }
        
        if (navigationCompleted) return;
      }
      
      // 2. PendingNavigationService에서 확인
      final pending = await pendingService.getPendingNavigation();
      
      if (pending != null) {
        if (AppConfig.debugMode) {
          print('📩 [Splash] Pending: ${pending.route}');
        }
        
        if (authProvider.isAuthenticated) {
          await pendingService.clearPendingNavigation();
          if (mounted) {
            final url = _buildUrlWithArguments(pending.route, pending.arguments);
            AppRouter.markInitialized();
            context.go(url);
            navigationCompleted = true;
          }
        } else {
          if (mounted) {
            AppRouter.markInitialized();
            context.go('/home');
            navigationCompleted = true;
          }
        }
        
        if (navigationCompleted) return;
      } else {
        if (mounted) {
          AppRouter.markInitialized();
          context.go('/home');
          navigationCompleted = true;
        }
      }
    } catch (e) {
      if (AppConfig.debugMode) {
        print('❌ [Splash] Pending 오류: $e');
      }
    }
    
    // Fallback
    if (!navigationCompleted && mounted) {
      AppRouter.markInitialized();
      context.go('/home');
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

  /// URL 쿼리 파라미터에서 pending URL 추출
  String? _getPendingUrlFromQueryParams() {
    // 1순위: GoRouter에서 전달받은 pendingUrl
    if (widget.pendingUrl != null && widget.pendingUrl!.isNotEmpty) {
      return widget.pendingUrl;
    }
    
    // 2순위: Uri.base에서 직접 추출 (웹 환경)
    if (!kIsWeb) return null;
    
    try {
      final uri = Uri.base;
      final pendingParam = uri.queryParameters['pending'];
      
      if (pendingParam != null && pendingParam.isNotEmpty) {
        return Uri.decodeComponent(pendingParam);
      }
    } catch (e) {
      if (AppConfig.debugMode) {
        print('⚠️ [Splash] pending 파싱 오류: $e');
      }
    }
    
    return null;
  }

  /// URL에서 Pending Navigation 저장
  Future<void> _savePendingFromUrl(String url) async {
    try {
      final pendingService = PendingNavigationService();
      final uri = Uri.parse(url);
      
      Map<String, dynamic>? arguments;
      if (uri.queryParameters.isNotEmpty) {
        arguments = Map<String, dynamic>.from(uri.queryParameters);
        
        if (arguments.containsKey('meetingId')) {
          final meetingIdStr = arguments['meetingId'] as String?;
          if (meetingIdStr != null) {
            arguments['meetingId'] = int.tryParse(meetingIdStr) ?? meetingIdStr;
          }
        }
      }
      
      await pendingService.savePendingNavigation(
        route: uri.path,
        arguments: arguments,
      );
    } catch (e) {
      if (AppConfig.debugMode) {
        print('❌ [Splash] Pending 저장 실패: $e');
      }
    }
  }

  /// 폰트 프리로딩
  Future<void> _preloadFonts() async {
    try {
      await GoogleFonts.pendingFonts([
        GoogleFonts.notoSans(fontWeight: FontWeight.w400),
        GoogleFonts.notoSans(fontWeight: FontWeight.w500),
        GoogleFonts.notoSans(fontWeight: FontWeight.w600),
        GoogleFonts.notoSans(fontWeight: FontWeight.w700),
      ]).timeout(
        const Duration(seconds: 2),
        onTimeout: () => <TextStyle>[],
      );
    } catch (e) {
      // 폰트 로드 실패해도 앱은 계속 진행
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
