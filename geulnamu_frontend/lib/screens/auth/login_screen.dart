import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../core/config/app_config.dart';
import '../../core/theme.dart';

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

  // 🎯 카카오 버튼 호버/클릭 상태 관리
  bool _isHovering = false;
  bool _isPressed = false;

  // 🔄 다른 계정 버튼 호버/클릭 상태 관리
  bool _isDifferentAccountHovering = false;
  bool _isDifferentAccountPressed = false;

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

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeOutBack),
        );

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
    final colorScheme = Theme.of(context).colorScheme;
    
    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back_ios, color: colorScheme.onBackground),
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
    final colorScheme = Theme.of(context).colorScheme;
    
    return Column(
      children: [
        // 로고 이미지 (책갈피 디자인 컨셉)
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: colorScheme.primary,
            borderRadius: BorderRadius.circular(60),
            boxShadow: [
              BoxShadow(
                color: colorScheme.primary.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          padding: const EdgeInsets.all(20),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(40),
            child: Image.asset(
              'assets/logo/app_logo.png',
              fit: BoxFit.contain,
            ),
          ),
        ),

        const SizedBox(height: 24),

        // 글나무 로고 텍스트
        Text(
          '글나무',
          style: GoogleFonts.notoSans(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: colorScheme.onBackground,
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
      ],
    );
  }

  Widget _buildLoginButtonSection() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return Column(
          children: [
            // 에러 메시지 표시 (빈 문자열인 경우 숨김)
            if (authProvider.errorMessage != null &&
                authProvider.errorMessage!.trim().isNotEmpty) ...[
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
                    Icon(
                      Icons.error_outline,
                      color: Colors.red.shade600,
                      size: 20,
                    ),
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

            // 🔄 다른 계정으로 로그인 버튼
            _buildDifferentAccountButton(authProvider),

            const SizedBox(height: 16),

            // 🎯 로딩 상태 중복 표시 제거 - 버튼 안의 로딩만 유지
          ],
        );
      },
    );
  }

  Widget _buildKakaoLoginButton(AuthProvider authProvider) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: authProvider.isLoading
          ? Container(
              width: double.infinity,
              height: 56,
              decoration: BoxDecoration(
                color: const Color(0xFFFEE500).withOpacity(0.6),
                borderRadius: BorderRadius.circular(12), // 🎯 카카오 공식 가이드: 12px
              ),
              child: const Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Color(0xFF3C1E1E),
                    ),
                  ),
                ),
              ),
            )
          : GestureDetector(
              onTapDown: (_) => setState(() => _isPressed = true),
              onTapUp: (_) => setState(() => _isPressed = false),
              onTapCancel: () => setState(() => _isPressed = false),
              onTap: () => _handleKakaoLogin(),
              child: MouseRegion(
                cursor: SystemMouseCursors.click, // 👆 웹에서 마우스 커서를 포인터(손가락)로 변경
                onEnter: (_) => setState(() => _isHovering = true),
                onExit: (_) => setState(() => _isHovering = false),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150), // 🎯 부드러운 애니메이션
                  curve: Curves.easeInOut,
                  width: double.infinity,
                  height: 56,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(
                      12,
                    ), // 🎯 카카오 공식 가이드: 12px
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFEE500).withOpacity(
                          _isPressed
                              ? 0.2
                              : (_isHovering ? 0.5 : 0.3), // 🎯 눠남에 따른 음영 강도
                        ),
                        blurRadius: _isPressed
                            ? 2
                            : (_isHovering ? 8 : 4), // 🎯 눠남에 따른 블러 강도
                        offset: Offset(
                          0,
                          _isPressed ? 1 : (_isHovering ? 4 : 2),
                        ), // 🎯 눠남에 따른 오프셋
                      ),
                    ],
                  ),
                  child: ColorFiltered(
                    colorFilter: ColorFilter.mode(
                      Colors.black.withOpacity(
                        _isPressed
                            ? 0.15
                            : (_isHovering ? 0.05 : 0.0), // 🎯 눠남에 따른 어두워지는 정도
                      ),
                      BlendMode.darken,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(
                        'assets/images/kakao_login_large_wide.png',
                        width: double.infinity,
                        height: 56,
                        fit: BoxFit.contain, // 🎯 이미지 전체가 보이도록 변경 (잘리지 않음)
                        errorBuilder: (context, error, stackTrace) {
                          // 🎯 이미지 로드 실패 시 간단한 폴백
                          debugPrint('❌ 카카오 로그인 이미지 로드 실패: $error');
                          return Container(
                            width: double.infinity,
                            height: 56,
                            decoration: BoxDecoration(
                              color: const Color(0xFFFEE500),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.error_outline,
                                color: Color(0xFF3C1E1E),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildFooterSection() {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Text(
      '로그인하면 서비스 이용약관 및 개인정보처리방침에 동의하게 됩니다.',
      textAlign: TextAlign.center,
      style: GoogleFonts.notoSans(
        fontSize: 12,
        color: colorScheme.onSurfaceVariant.withOpacity(0.6),
        height: 1.4,
      ),
    );
  }

  Widget _buildDifferentAccountButton(AuthProvider authProvider) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: authProvider.isLoading
          ? const SizedBox.shrink() // 로딩 중에는 숨김
          : GestureDetector(
              onTapDown: (_) =>
                  setState(() => _isDifferentAccountPressed = true),
              onTapUp: (_) =>
                  setState(() => _isDifferentAccountPressed = false),
              onTapCancel: () =>
                  setState(() => _isDifferentAccountPressed = false),
              onTap: () => _handleDifferentAccountLogin(),
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                onEnter: (_) =>
                    setState(() => _isDifferentAccountHovering = true),
                onExit: (_) =>
                    setState(() => _isDifferentAccountHovering = false),
                child: Builder(
                  builder: (context) {
                    final colorScheme = Theme.of(context).colorScheme;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      curve: Curves.easeInOut,
                      width: double.infinity,
                      height: 56,
                      decoration: BoxDecoration(
                        color: colorScheme.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: colorScheme.primary,
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: colorScheme.primary.withOpacity(
                              _isDifferentAccountPressed
                                  ? 0.1
                                  : (_isDifferentAccountHovering ? 0.3 : 0.15),
                            ),
                        blurRadius: _isDifferentAccountPressed
                            ? 2
                            : (_isDifferentAccountHovering ? 8 : 4),
                        offset: Offset(
                          0,
                          _isDifferentAccountPressed
                              ? 1
                              : (_isDifferentAccountHovering ? 4 : 2),
                        ),
                      ),
                    ],
                  ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.swap_horiz_rounded,
                            color: colorScheme.primary,
                            size: 24,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '다른 계정으로 로그인',
                            style: GoogleFonts.notoSans(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                ),
              ),
            ),
    );
  }

  void _handleKakaoLogin() async {
    // 🎯 클릭 후 상태 초기화
    setState(() => _isPressed = false);

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    final success = await authProvider.loginWithKakao(context: context);

    if (success && mounted) {
      // 로그인 성공 시 현재 화면을 닫고 홈 화면으로 돌아가기
      Navigator.of(context).pop();
    }
    // 실패 시에는 AuthProvider의 errorMessage가 자동으로 표시됩니다
  }

  void _handleDifferentAccountLogin() async {
    // 🎯 클릭 후 상태 초기화
    setState(() => _isDifferentAccountPressed = false);

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    if (AppConfig.debugMode) {
      print('🔄 [다른 계정 로그인] 버튼 클릭');
    }

    final success = await authProvider.loginWithDifferentAccount(
      context: context,
    );

    if (success && mounted) {
      // 로그인 성공 시 현재 화면을 닫고 홈 화면으로 돌아가기
      Navigator.of(context).pop();
    }
    // 실패 시에는 AuthProvider의 errorMessage가 자동으로 표시됩니다
  }
}
