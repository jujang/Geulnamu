import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../screens/meeting/meeting_detail_screen.dart';

/// 홈화면 비즈니스 로직을 담당하는 Singleton Service
///
/// 기능:
/// - 메뉴 탭 처리
/// - 로그아웃 처리
/// - 프로필 메뉴 선택 처리
/// - 다이얼로그 및 스낵바 표시
/// - 네비게이션 처리
class HomeService {
  static final HomeService _instance = HomeService._internal();
  factory HomeService() => _instance;
  HomeService._internal();

  // 🎯 메뉴 탭 처리
  void handleMenuTap(BuildContext context, String menuTitle) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    if (menuTitle == '모임 소개') {
      // 🎯 모임 소개 페이지로 이동
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const MeetingDetailScreen()),
      );
    } else if (authProvider.isAuthenticated) {
      // 로그인 후: 실제 기능 사용 (현재는 개발 중 메시지)
      _showSnackBar(context, '$menuTitle 기능은 개발 중입니다.');
    } else {
      // 로그인 전: 로그인 유도
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$menuTitle 기능은 로그인 후 이용할 수 있습니다'),
          duration: const Duration(seconds: 2),
          backgroundColor: Theme.of(context).colorScheme.primary,
          action: SnackBarAction(
            label: '로그인',
            textColor: Theme.of(context).colorScheme.onPrimary,
            onPressed: () => navigateToLogin(context),
          ),
        ),
      );
    }
  }

  // 🎯 프로필 메뉴 선택 처리
  Future<void> handleProfileMenuSelection(
    BuildContext context,
    String value,
    AuthProvider authProvider,
  ) async {
    switch (value) {
      case 'profile':
        _showSnackBar(context, '프로필 기능은 개발 중입니다.');
        break;
      case 'settings':
        _showSnackBar(context, '설정 기능은 개발 중입니다.');
        break;
      case 'logout':
        await handleLogout(context, authProvider);
        break;
    }
  }

  // 🎯 로그아웃 처리
  Future<void> handleLogout(
    BuildContext context,
    AuthProvider authProvider,
  ) async {
    final confirmed = await _showLogoutDialog(context);

    if (confirmed == true) {
      await authProvider.logout();
      _showSnackBar(context, '로그아웃되었습니다.');
    }
  }

  // 🎯 모임 만들기 다이얼로그
  void showCreateMeetingDialog(BuildContext context) {
    _showSnackBar(context, '모임 만들기 기능은 개발 중입니다.');
  }

  // 🎯 네비게이션 메서드들
  void navigateToLogin(BuildContext context) {
    Navigator.pushNamed(context, '/login');
  }

  // 🎯 PWA 설치 안내
  void showInstallInstructions(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          '앱 설치 방법',
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600),
        ),
        content: const SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // PC 브라우저
              Text('💻 PC 브라우저', style: TextStyle(fontWeight: FontWeight.bold)),
              Text('• 크롬: 주소창 오른쪽 설치 버튼 클릭'),
              Text('• 엣지: 주소창 오른쪽 앱 설치 버튼'),
              SizedBox(height: 12),

              // 안드로이드 모바일
              Text('📱 안드로이드', style: TextStyle(fontWeight: FontWeight.bold)),
              Text('• 크롬: 메뉴(⋮) → "홈 화면에 추가"'),
              Text('• 삼성 브라우저: 메뉴 → "홈 화면에 추가"'),
              SizedBox(height: 12),

              // 아이폰
              Text(
                '🍎 아이폰 (iOS)',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('• 사파리: 공유버튼(↑) → "홈 화면에 추가"'),
              Text('• 크롬: 메뉴(⋮) → "홈 화면에 추가"'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  // 🎯 Private 메서드들

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.inverseSurface,
      ),
    );
  }

  Future<bool?> _showLogoutDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          '로그아웃',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        content: const Text('정말 로그아웃하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              '취소',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              '로그아웃',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }

  /// 개인정보 입력 화면으로 이동
  void navigateToProfileInput(BuildContext context) {
    // TODO: 개인정보 입력 화면 경로가 준비되면 업데이트
    print('🔍 [HomeService] 개인정보 입력 화면으로 이동 요청');
    
    // 임시로 스낵바 메시지 표시
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('개인정보 입력 화면을 준비 중입니다.'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        action: SnackBarAction(
          label: '확인',
          textColor: Theme.of(context).colorScheme.onPrimary,
          onPressed: () {},
        ),
      ),
    );
    
    // 나중에 이것으로 대체:
    // Navigator.pushNamed(context, '/profile/input');
  }
}
