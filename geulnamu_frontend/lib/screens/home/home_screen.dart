import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

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
    return Scaffold(
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Consumer<AuthProvider>(
          builder: (context, authProvider, child) {
            // 로그인 상태에 따라 다른 화면 표시
            if (authProvider.isAuthenticated) {
              return _buildAuthenticatedHome(authProvider);
            } else {
              return _buildUnauthenticatedHome(authProvider);
            }
          },
        ),
      ),
    );
  }

  // 로그인하지 않은 사용자를 위한 메인 화면
  Widget _buildUnauthenticatedHome(AuthProvider authProvider) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: const Color(0xFF7DD3C0),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.auto_stories_rounded,
                size: 20,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              '글나무',
              style: GoogleFonts.notoSans(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF2C3E50),
              ),
            ),
          ],
        ),
        actions: [
          // 로그인 버튼
          TextButton.icon(
            onPressed: () => Navigator.pushNamed(context, '/login'),
            icon: const Icon(Icons.login, size: 20),
            label: Text(
              '로그인',
              style: GoogleFonts.notoSans(
                fontWeight: FontWeight.w600,
              ),
            ),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF7DD3C0),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 40),
            
            // 메인 로고 및 소개
            _buildMainIntroSection(),
            
            const SizedBox(height: 40),
            
            // 서비스 소개
            _buildServiceIntroSection(),
            
            const SizedBox(height: 40),
            
            // 주요 기능 소개
            _buildFeaturesSection(),
            
            const SizedBox(height: 40),
            
            // 로그인 유도 섹션
            _buildLoginPromptSection(),
            
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // 로그인한 사용자를 위한 홈 화면
  Widget _buildAuthenticatedHome(AuthProvider authProvider) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: const Color(0xFF7DD3C0),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.auto_stories_rounded,
                size: 20,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              '글나무',
              style: GoogleFonts.notoSans(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF2C3E50),
              ),
            ),
          ],
        ),
        actions: [
          // 사용자 프로필 버튼
          PopupMenuButton<String>(
            icon: CircleAvatar(
              backgroundColor: const Color(0xFF7DD3C0),
              child: Text(
                authProvider.userNickname[0],
                style: GoogleFonts.notoSans(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'profile',
                child: Row(
                  children: [
                    const Icon(Icons.person_outline, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      '프로필',
                      style: GoogleFonts.notoSans(),
                    ),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'settings',
                child: Row(
                  children: [
                    const Icon(Icons.settings_outlined, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      '설정',
                      style: GoogleFonts.notoSans(),
                    ),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    const Icon(Icons.logout, size: 20, color: Colors.red),
                    const SizedBox(width: 8),
                    Text(
                      '로그아웃',
                      style: GoogleFonts.notoSans(color: Colors.red),
                    ),
                  ],
                ),
              ),
            ],
            onSelected: (value) => _handleMenuSelection(value, authProvider),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 환영 메시지
            _buildWelcomeSection(authProvider),
            
            const SizedBox(height: 24),
            
            // 빠른 액션 카드들
            _buildQuickActions(),
            
            const SizedBox(height: 24),
            
            // 최근 모임 섹션
            _buildRecentMeetingsSection(),
            
            const SizedBox(height: 24),
            
            // 개발 중 알림
            _buildDevelopmentNotice(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateMeetingDialog(),
        backgroundColor: const Color(0xFF7DD3C0),
        label: Text(
          '모임 만들기',
          style: GoogleFonts.notoSans(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        icon: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  // 메인 소개 섹션 (로그인 전 화면)
  Widget _buildMainIntroSection() {
    return Column(
      children: [
        // 대형 로고
        Container(
          width: 150,
          height: 150,
          decoration: BoxDecoration(
            color: const Color(0xFF7DD3C0),
            borderRadius: BorderRadius.circular(75),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF7DD3C0).withOpacity(0.3),
                blurRadius: 30,
                offset: const Offset(0, 15),
              ),
            ],
          ),
          child: const Icon(
            Icons.auto_stories_rounded,
            size: 80,
            color: Colors.white,
          ),
        ),
        
        const SizedBox(height: 24),
        
        Text(
          '글나무에 오신 것을 환영합니다!',
          style: GoogleFonts.notoSans(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF2C3E50),
          ),
          textAlign: TextAlign.center,
        ),
        
        const SizedBox(height: 12),
        
        Text(
          '독서 토론의 새로운 시작\n함께 읽고, 함께 성장하는 커뮤니티',
          style: GoogleFonts.notoSans(
            fontSize: 16,
            color: const Color(0xFF7F8C8D),
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  // 서비스 소개 섹션
  Widget _buildServiceIntroSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF7DD3C0).withOpacity(0.1),
            const Color(0xFF7DD3C0).withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF7DD3C0).withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          Text(
            '독서 토론을 더욱 즐겁게',
            style: GoogleFonts.notoSans(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF2C3E50),
            ),
          ),
          
          const SizedBox(height: 16),
          
          Text(
            '글나무는 독서를 사랑하는 사람들이 모여\n생각을 나누고 성장할 수 있는 공간입니다.\n책을 통해 새로운 관점을 발견하고\n의미 있는 대화를 나누어보세요.',
            style: GoogleFonts.notoSans(
              fontSize: 14,
              color: const Color(0xFF7F8C8D),
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // 주요 기능 소개
  Widget _buildFeaturesSection() {
    final features = [
      {'icon': Icons.people, 'title': '모임 관리', 'desc': '독서 모임을 쉽게 만들고 관리하세요'},
      {'icon': Icons.calendar_today, 'title': '출석 체크', 'desc': '간편한 QR 코드로 출석을 확인하세요'},
      {'icon': Icons.edit_note, 'title': '발제 작성', 'desc': '체계적인 발제문 작성 도구를 제공합니다'},
      {'icon': Icons.forum, 'title': '토론 참여', 'desc': '활발한 토론으로 깊이 있는 대화를 나누세요'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '주요 기능',
          style: GoogleFonts.notoSans(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF2C3E50),
          ),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1.1,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: features.length,
          itemBuilder: (context, index) {
            final feature = features[index];
            return Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      feature['icon'] as IconData,
                      size: 32,
                      color: const Color(0xFF7DD3C0),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      feature['title'] as String,
                      style: GoogleFonts.notoSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF2C3E50),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      feature['desc'] as String,
                      style: GoogleFonts.notoSans(
                        fontSize: 12,
                        color: const Color(0xFF7F8C8D),
                        height: 1.3,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  // 로그인 유도 섹션
  Widget _buildLoginPromptSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF7DD3C0),
            const Color(0xFF7DD3C0).withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7DD3C0).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            '지금 시작해보세요!',
            style: GoogleFonts.notoSans(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          
          const SizedBox(height: 12),
          
          Text(
            '카카오 계정으로 간편하게 로그인하고\n글나무의 모든 기능을 체험해보세요',
            style: GoogleFonts.notoSans(
              fontSize: 14,
              color: Colors.white.withOpacity(0.9),
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 20),
          
          ElevatedButton.icon(
            onPressed: () => Navigator.pushNamed(context, '/login'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF7DD3C0),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
            icon: const Icon(Icons.login, size: 20),
            label: Text(
              '로그인하기',
              style: GoogleFonts.notoSans(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 환영 메시지 (로그인 후)
  Widget _buildWelcomeSection(AuthProvider authProvider) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF7DD3C0),
            const Color(0xFF7DD3C0).withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7DD3C0).withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '안녕하세요, ${authProvider.userNickname}님! 👋',
            style: GoogleFonts.notoSans(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '오늘도 즐거운 독서 토론을 시작해보세요',
            style: GoogleFonts.notoSans(
              fontSize: 14,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
          if (authProvider.userEmail != null) ...[
            const SizedBox(height: 4),
            Text(
              authProvider.userEmail!,
              style: GoogleFonts.notoSans(
                fontSize: 12,
                color: Colors.white.withOpacity(0.7),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // 빠른 액션 (로그인 후)
  Widget _buildQuickActions() {
    final actions = [
      {'icon': Icons.people, 'title': '내 모임', 'subtitle': '참여 중인 모임'},
      {'icon': Icons.calendar_today, 'title': '출석 체크', 'subtitle': '오늘의 출석'},
      {'icon': Icons.edit_note, 'title': '발제 작성', 'subtitle': '오늘의 발제'},
      {'icon': Icons.history, 'title': '이력', 'subtitle': '나의 활동'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '빠른 메뉴',
          style: GoogleFonts.notoSans(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF2C3E50),
          ),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1.5,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: actions.length,
          itemBuilder: (context, index) {
            final action = actions[index];
            return Card(
              child: InkWell(
                onTap: () => _handleQuickAction(action['title'] as String),
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        action['icon'] as IconData,
                        size: 28,
                        color: const Color(0xFF7DD3C0),
                      ),
                      const Spacer(),
                      Text(
                        action['title'] as String,
                        style: GoogleFonts.notoSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF2C3E50),
                        ),
                      ),
                      Text(
                        action['subtitle'] as String,
                        style: GoogleFonts.notoSans(
                          fontSize: 12,
                          color: const Color(0xFF7F8C8D),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  // 최근 모임 섹션 (로그인 후)
  Widget _buildRecentMeetingsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '최근 모임',
          style: GoogleFonts.notoSans(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF2C3E50),
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Icon(
                  Icons.library_books_outlined,
                  size: 48,
                  color: const Color(0xFF7DD3C0).withOpacity(0.6),
                ),
                const SizedBox(height: 16),
                Text(
                  '참여 중인 모임이 없습니다',
                  style: GoogleFonts.notoSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF2C3E50),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '새로운 모임을 만들거나 기존 모임에 참여해보세요!',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.notoSans(
                    fontSize: 14,
                    color: const Color(0xFF7F8C8D),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // 개발 중 알림 (로그인 후)
  Widget _buildDevelopmentNotice() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: Colors.blue.shade600),
              const SizedBox(width: 8),
              Text(
                '개발 중인 기능들',
                style: GoogleFonts.notoSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.blue.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '• 모임 관리 기능\n• 출석 체크 시스템\n• 발제문 작성 도구\n• 토론 그룹 관리',
            style: GoogleFonts.notoSans(
              fontSize: 13,
              color: Colors.blue.shade600,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
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

  void _handleQuickAction(String action) {
    _showSnackBar('$action 기능은 개발 중입니다.');
  }

  void _showCreateMeetingDialog() {
    _showSnackBar('모임 만들기 기능은 개발 중입니다.');
  }

  Future<void> _handleLogout(AuthProvider authProvider) async {
    // 로그아웃 확인 다이얼로그
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