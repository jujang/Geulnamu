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

    try {
      // 🎯 전체 초기화에 타임아웃 적용 (최대 10초)
      await _initializeApp().timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          if (AppConfig.debugMode) {
            print('⏰ [Splash] 초기화 타임아웃! 강제로 홈 이동');
          }
          // 타임아웃 시 홈으로 이동
          _safeNavigateToHome();
        },
      );
    } catch (e) {
      if (AppConfig.debugMode) {
        print('❌ [Splash] 초기화 중 오류 발생: $e');
      }
      // 오류 발생 시에도 홈으로 이동
      _safeNavigateToHome();
    }
  }

  /// 🎯 앱 초기화 로직 (타임아웃에서 분리)
  Future<void> _initializeApp() async {
    // 🎯 폰트 프리로딩 (타임아웃 2초)
    await _preloadFonts();

    if (!mounted) {
      if (AppConfig.debugMode) {
        print('⚠️ [Splash] 폰트 로딩 후 mounted=false, 종료');
      }
      return;
    }

    if (AppConfig.debugMode) {
      print('🔐 [Splash] checkAuthStatus 호출 전...');
    }

    // 🔐 로그인 상태 확인
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.checkAuthStatus();

    if (AppConfig.debugMode) {
      print('🔐 [Splash] checkAuthStatus 완료!');
      print('🔐 [Splash] 로그인 상태: ${authProvider.isAuthenticated}');
      print('🔐 [Splash] AuthStatus: ${authProvider.status}');
    }

    if (!mounted) {
      if (AppConfig.debugMode) {
        print('⚠️ [Splash] checkAuthStatus 후 mounted=false, 종료');
      }
      return;
    }

    // 📩 Pending Navigation 처리
    await _handlePendingNavigation(authProvider);
  }

  /// 🎯 안전하게 홈으로 이동 (mounted 체크 + fallback)
  void _safeNavigateToHome() {
    if (mounted) {
      if (AppConfig.debugMode) {
        print('🏠 [Splash] 안전하게 홈으로 이동');
      }
      AppRouter.markInitialized();
      context.go('/home');
    } else {
      if (AppConfig.debugMode) {
        print('⚠️ [Splash] mounted=false, 이동 불가');
      }
    }
  }

  /// 📩 Pending Navigation 처리
  /// 
  /// 알림 클릭으로 앱이 시작된 경우, 저장된 목적지로 이동
  /// - 로그인 상태: 해당 페이지로 바로 이동
  /// - 비로그인 상태: 홈으로 이동 (Pending 유지, 로그인 후 처리)
  /// 
  /// 🚨 중요: 모든 분기에서 반드시 이동이 되어야 함!
  Future<void> _handlePendingNavigation(AuthProvider authProvider) async {
    final pendingService = PendingNavigationService();
    bool navigationCompleted = false;  // 🆕 이동 완료 플래그
    
    try {
      // 🆕 1. URL 쿼리 파라미터에서 pending URL 확인 (Service Worker에서 전달)
      String? pendingUrl = _getPendingUrlFromQueryParams();
      
      if (pendingUrl != null) {
        if (AppConfig.debugMode) {
          print('📩 [Splash] URL 쿼리 파라미터에서 pending 발견: $pendingUrl');
          print('📩 [Splash] 로그인 상태: ${authProvider.isAuthenticated}');
        }
        
        if (authProvider.isAuthenticated) {
          if (AppConfig.debugMode) {
            print('🚀 [Splash] 로그인됨 → Pending URL로 이동: $pendingUrl');
          }
          
          if (mounted) {
            AppRouter.markInitialized();
            context.go(pendingUrl);
            navigationCompleted = true;
          }
        } else {
          if (AppConfig.debugMode) {
            print('⏳ [Splash] 비로그인 → Pending 저장 후 홈으로 이동');
          }
          
          await _savePendingFromUrl(pendingUrl);
          
          if (mounted) {
            AppRouter.markInitialized();
            context.go('/home');
            navigationCompleted = true;
          }
        }
        
        // 🆕 이동 완료되면 여기서 종료
        if (navigationCompleted) return;
      }
      
      // 2. 기존 PendingNavigationService에서 확인
      final pending = await pendingService.getPendingNavigation();
      
      if (pending != null) {
        if (AppConfig.debugMode) {
          print('📩 [Splash] Pending Navigation 발견!');
          print('📩 [Splash] route: ${pending.route}');
          print('📩 [Splash] 로그인 상태: ${authProvider.isAuthenticated}');
        }
        
        if (authProvider.isAuthenticated) {
          await pendingService.clearPendingNavigation();
          
          if (mounted) {
            final url = _buildUrlWithArguments(pending.route, pending.arguments);
            if (AppConfig.debugMode) {
              print('🚀 [Splash] 로그인됨 → Pending 페이지로 이동: $url');
            }
            AppRouter.markInitialized();
            context.go(url);
            navigationCompleted = true;
          }
        } else {
          if (AppConfig.debugMode) {
            print('⏳ [Splash] 비로그인 → 홈으로 이동 (Pending 유지)');
          }
          
          if (mounted) {
            AppRouter.markInitialized();
            context.go('/home');
            navigationCompleted = true;
          }
        }
        
        // 🆕 이동 완료되면 여기서 종료
        if (navigationCompleted) return;
      } else {
        // 📭 Pending Navigation 없음: 일반 홈 화면 이동
        if (AppConfig.debugMode) {
          print('📭 [Splash] Pending Navigation 없음 → 홈으로 이동');
        }
        
        if (mounted) {
          AppRouter.markInitialized();
          context.go('/home');
          navigationCompleted = true;
        }
      }
    } catch (e) {
      if (AppConfig.debugMode) {
        print('❌ [Splash] Pending Navigation 처리 오류: $e');
      }
    }
    
    // 🆕 홈 Fallback: 어떤 이유로든 이동이 안 되었으면 홈으로 강제 이동
    if (!navigationCompleted && mounted) {
      if (AppConfig.debugMode) {
        print('🚨 [Splash] 이동 실패! Fallback으로 홈 이동');
      }
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

  /// 🆕 URL 쿼리 파라미터에서 pending URL 추출
  /// Service Worker가 /splash?pending=/discussion-group?meetingId=33 형식으로 전달
  String? _getPendingUrlFromQueryParams() {
    if (!kIsWeb) return null;
    
    try {
      final uri = Uri.base;
      final pendingParam = uri.queryParameters['pending'];
      
      if (pendingParam != null && pendingParam.isNotEmpty) {
        // URL 디코딩 (Service Worker에서 encodeURIComponent 사용)
        final decodedUrl = Uri.decodeComponent(pendingParam);
        
        if (AppConfig.debugMode) {
          print('🔗 [Splash] pending 파라미터 발견: $pendingParam');
          print('🔗 [Splash] 디코딩된 URL: $decodedUrl');
        }
        
        return decodedUrl;
      }
    } catch (e) {
      if (AppConfig.debugMode) {
        print('⚠️ [Splash] pending 파라미터 파싱 오류: $e');
      }
    }
    
    return null;
  }

  /// 🆕 URL에서 Pending Navigation 저장
  Future<void> _savePendingFromUrl(String url) async {
    try {
      final pendingService = PendingNavigationService();
      final uri = Uri.parse(url);
      
      Map<String, dynamic>? arguments;
      if (uri.queryParameters.isNotEmpty) {
        arguments = Map<String, dynamic>.from(uri.queryParameters);
        
        // meetingId를 int로 변환
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
      
      if (AppConfig.debugMode) {
        print('📌 [Splash] Pending Navigation 저장 완료: ${uri.path}');
      }
    } catch (e) {
      if (AppConfig.debugMode) {
        print('❌ [Splash] Pending 저장 실패: $e');
      }
    }
  }

  /// 🎯 폰트 프리로딩 - 앱에서 사용하는 모든 폰트 weight 미리 로드
  /// 타임아웃 2초 적용 - 네트워크 불안정 시 무한 대기 방지
  Future<void> _preloadFonts() async {
    if (AppConfig.debugMode) {
      print('🔤 [Splash] 폰트 프리로딩 시작...');
    }
    
    try {
      // 🎯 폰트 로딩에 2초 타임아웃 적용
      await GoogleFonts.pendingFonts([
        GoogleFonts.notoSans(fontWeight: FontWeight.w400), // Regular
        GoogleFonts.notoSans(fontWeight: FontWeight.w500), // Medium
        GoogleFonts.notoSans(fontWeight: FontWeight.w600), // SemiBold
        GoogleFonts.notoSans(fontWeight: FontWeight.w700), // Bold
      ]).timeout(
        const Duration(seconds: 2),
        onTimeout: () {
          if (AppConfig.debugMode) {
            print('⏰ [Splash] 폰트 로딩 타임아웃, 건너뜀');
          }
          // 타임아웃 시 빈 리스트 반환 (시스템 폰트로 대체)
          return <TextStyle>[];
        },
      );
      
      if (AppConfig.debugMode) {
        print('✅ [Splash] 폰트 프리로딩 완료');
      }
    } catch (e) {
      // 폰트 로드 실패해도 앱은 계속 진행 (시스템 폰트로 대체)
      if (AppConfig.debugMode) {
        print('⚠️ [Splash] 폰트 프리로딩 실패: $e');
      }
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
