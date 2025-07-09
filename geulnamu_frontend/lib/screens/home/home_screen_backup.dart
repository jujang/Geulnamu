import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/auth_provider.dart';
import 'unauthenticated_home.dart';
import 'authenticated_home.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> 
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          if (authProvider.isAuthenticated) {
            return AuthenticatedHome(
              authProvider: authProvider,
              onMenuSelected: _handleMenuSelection,
              onQuickAction: _handleQuickAction,
              onCreateMeeting: _showCreateMeetingDialog,
            );
          } else {
            return UnauthenticatedHome(
              onLoginPressed: _navigateToLogin,
              onFeatureTap: _handleFeatureTap,
            );
          }
        },
      ),
    );
  }

  void _navigateToLogin() {
    Navigator.pushNamed(context, '/login');
  }

  void _handleFeatureTap(String featureTitle) {
    if (featureTitle == '모임 소개') {
      _showFeatureDialog('모임 소개', '글나무는 독서를 사랑하는 사람들이 모여\n생각을 나누고 성장할 수 있는 공간입니다.');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$featureTitle 기능은 로그인 후 이용할 수 있습니다'),
          duration: const Duration(seconds: 2),
          backgroundColor: const Color(0xFF7DD3C0),
          action: SnackBarAction(
            label: '로그인',
            textColor: Colors.white,
            onPressed: _navigateToLogin,
          ),
        ),
      );
    }
  }

  void _handleQuickAction(String action) {
    _showSnackBar('$action 기능은 개발 중입니다.');
  }

  void _showCreateMeetingDialog() {
    _showSnackBar('모임 만들기 기능은 개발 중입니다.');
  }

  void _handleMenuSelection(String value, AuthProvider authProvider) async {
    switch (value) {
      case 'profile':
        _showSnackBar('프로필 기능은 개발 중입니다.');
        break;
      case 'settings':
        _showSnackBar('설정 기능은 개발 중입니다.');
        break;
      case 'logout':
        await _handleLogout(authProvider);
        break;
    }
  }

  Future<void> _handleLogout(AuthProvider authProvider) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          '로그아웃',
          style: GoogleFonts.notoSans(fontWeight: FontWeight.w600),
        ),
        content: Text(
          '정말 로그아웃하시겠습니까?',
          style: GoogleFonts.notoSans(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              '취소',
              style: GoogleFonts.notoSans(color: const Color(0xFF7F8C8D)),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              '로그아웃',
              style: GoogleFonts.notoSans(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await authProvider.logout();
      _showSnackBar('로그아웃되었습니다.');
    }
  }

  void _showFeatureDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          title,
          style: GoogleFonts.notoSans(fontWeight: FontWeight.w600),
        ),
        content: Text(
          content,
          style: GoogleFonts.notoSans(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              '확인',
              style: GoogleFonts.notoSans(color: const Color(0xFF7DD3C0)),
            ),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.notoSans(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF2C3E50),
      ),
    );
  }
}
