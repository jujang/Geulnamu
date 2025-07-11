import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> 
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutBack,
    ));

    // 애니메이션 시작
    _fadeController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      _slideController.forward();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Color(0xFF2C3E50),
          ),
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            // 반응형 처리
            final isTablet = constraints.maxWidth > 600;
            final isMobile = constraints.maxWidth <= 600;
            
            return Center(
              child: Container(
                width: isTablet ? 400 : null,
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 24.0 : 32.0,
                  vertical: 32.0,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // 상단 여백
                    const Spacer(flex: 2),
                    
                    // 로고 및 캐릭터 영역
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: _buildLogoSection(),
                      ),
                    ),
                    
                    const SizedBox(height: 60),
                    
                    // 로그인 버튼 영역
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: _buildLoginButtonSection(),
                    ),
                    
                    const Spacer(flex: 3),
                    
                    // 하단 정보
                    _buildFooterSection(),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildLogoSection() {
    return Column(
      children: [
        // 캐릭터 (책갈피의 귀여운 캐릭터 영감)
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: const Color(0xFF7DD3C0), // 터퀴즈 색상
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
        
        // 글나무 로고 텍스트
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
          'BOOK COMMUNITY',
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
      ],
    );
  }

  Widget _buildLoginButtonSection() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return Column(
          children: [
            // 에러 메시지 표시
            if (authProvider.errorMessage != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: Colors.red.shade600, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        authProvider.errorMessage!,
                        style: GoogleFonts.notoSans(
                          fontSize: 14,
                          color: Colors.red.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            
            // 카카오 로그인 버튼
            _buildKakaoLoginButton(authProvider),
            
            const SizedBox(height: 16),
            
            // 로딩 상태일 때 추가 정보
            if (authProvider.isLoading) ...[
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF7DD3C0)),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '카카오 로그인 중...',
                style: GoogleFonts.notoSans(
                  fontSize: 14,
                  color: const Color(0xFF95A5A6),
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _buildKakaoLoginButton(AuthProvider authProvider) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: authProvider.isLoading ? null : () => _handleKakaoLogin(),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFEE500), // 카카오 옐로우
          foregroundColor: const Color(0xFF3C1E1E),
          elevation: 2,
          shadowColor: const Color(0xFFFEE500).withOpacity(0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          disabledBackgroundColor: const Color(0xFFFEE500).withOpacity(0.6),
        ),
        icon: authProvider.isLoading 
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF3C1E1E)),
              ),
            )
          : Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: const Color(0xFF3C1E1E),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Icon(
                Icons.chat_bubble_outline,
                size: 16,
                color: Color(0xFFFEE500),
              ),
            ),
        label: Text(
          authProvider.isLoading ? '로그인 중...' : '카카오로 시작하기',
          style: GoogleFonts.notoSans(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildFooterSection() {
    return Column(
      children: [
        Text(
          '로그인하면 서비스 이용약관 및 개인정보처리방침에 동의하게 됩니다.',
          textAlign: TextAlign.center,
          style: GoogleFonts.notoSans(
            fontSize: 12,
            color: const Color(0xFFBDC3C7),
            height: 1.4,
          ),
        ),
        
        const SizedBox(height: 16),
        
        // 버전 정보
        Text(
          'v1.0.0',
          style: GoogleFonts.roboto(
            fontSize: 11,
            color: const Color(0xFFECF0F1),
          ),
        ),
      ],
    );
  }

  void _handleKakaoLogin() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    final success = await authProvider.loginWithKakao(context: context);
    
    if (success && mounted) {
      // 로그인 성공 시 현재 화면을 닫고 홈 화면으로 돌아가기
      Navigator.of(context).pop();
    }
    // 실패 시에는 AuthProvider의 errorMessage가 자동으로 표시됨
  }
}