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
    // 스플래시 화면 표시 시간
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      // 백그라운드에서 로그인 상태 확인 (UI에 영향 없음)
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      authProvider.checkAuthStatus();

      // 항상 메인 화면으로 이동
      Navigator.pushReplacementNamed(context, '/home');
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
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 로고 아이콘 (책갈피 디자인 컨셉)
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: const Color(0xFF7DD3C0),
                    borderRadius: BorderRadius.circular(60),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF7DD3C0).withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.auto_stories_rounded,
                    size: 60,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 24),

                // 앱 이름
                Text(
                  '글나무',
                  style: GoogleFonts.notoSans(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF2C3E50),
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
                    color: const Color(0xFF7DD3C0),
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
                    color: const Color(0xFF7F8C8D),
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 40),

                // 로딩 인디케이터
                const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Color(0xFF7DD3C0),
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
                    color: const Color(0xFF95A5A6),
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
