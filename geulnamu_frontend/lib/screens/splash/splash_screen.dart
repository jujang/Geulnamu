import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/auth_provider.dart';

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
    // 🎯 폰트 프리로딩 (플래시 방지) - 완료 후 즉시 이동
    await _preloadFonts();

    if (mounted) {
      // 백그라운드에서 로그인 상태 확인 (UI에 영향 없음)
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      authProvider.checkAuthStatus();

      // 항상 메인 화면으로 이동
      Navigator.pushReplacementNamed(context, '/home');
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
