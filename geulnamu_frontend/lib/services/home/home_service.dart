import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../screens/meeting/meeting_detail_screen.dart';
import '../../core/enums/permission_level.dart';
import '../../core/constants/permission_constants.dart';

/// 홈화면 비즈니스 로직을 담당하는 Singleton Service
///
/// 기능:
/// - 권한 레벨 + 개인정보 이중 체크 시스템
/// - 메뉴 탭 처리
/// - 로그아웃 처리
/// - 프로필 메뉴 선택 처리
/// - 다이얼로그 및 스낵바 표시
/// - 네비게이션 처리
class HomeService {
  static final HomeService _instance = HomeService._internal();
  factory HomeService() => _instance;
  HomeService._internal();

  // 🎯 메뉴 탭 처리 (권한 레벨 + 개인정보 이중 체크)
  void handleMenuTap(BuildContext context, String menuTitle) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // 🔒 종합 접근 가능 체크
    if (!canAccessFeature(menuTitle, authProvider)) {
      if (!hasRolePermission(menuTitle, authProvider)) {
        // 권한 부족
        _showInsufficientPermissionDialog(context, menuTitle);
      } else {
        // 개인정보 입력 필요
        _showProfileRequiredDialog(context, menuTitle);
      }
      return;
    }

    // 정상 메뉴 처리
    _processMenuAction(context, menuTitle);
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
      await authProvider.logout(context: context);
      _showSnackBar(context, '로그아웃되었습니다.');
    }
  }

  // 🎯 모임 만들기 다이얼로그 (권한 체크 포함)
  void showCreateMeetingDialog(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    // 🔒 종합 접근 가능 체크
    if (!canAccessFeature('모임 만들기', authProvider)) {
      if (!hasRolePermission('모임 만들기', authProvider)) {
        _showInsufficientPermissionDialog(context, '모임 만들기');
      } else {
        _showProfileRequiredDialog(context, '모임 만들기');
      }
      return;
    }
    
    // 정상 처리 (현재는 개발 중)
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

  // 🔒 종합 접근 가능 체크
  bool canAccessFeature(String feature, AuthProvider authProvider) {
    return hasRolePermission(feature, authProvider) && 
           hasProfilePermission(feature, authProvider);
  }

  // 🔑 권한 레벨 체크
  bool hasRolePermission(String feature, AuthProvider authProvider) {
    final requiredLevel = PermissionConstants.getRequiredPermissionLevel(feature);
    final userLevel = _getUserPermissionLevel(authProvider);
    return userLevel.hasPermission(requiredLevel);
  }

  // 📝 개인정보 체크
  bool hasProfilePermission(String feature, AuthProvider authProvider) {
    // PermissionConstants의 예외 리스트 사용
    if (PermissionConstants.isProfileExemptMenu(feature)) {
      return true;
    }
    
    // 그 외에는 개인정보 입력 필수
    return authProvider.hasProfile;
  }

  // 📊 사용자 권한 레벨 결정
  PermissionLevel _getUserPermissionLevel(AuthProvider authProvider) {
    if (!authProvider.isAuthenticated) {
      return PermissionLevel.PUBLIC;
    }
    
    // PermissionConstants를 사용하여 백엔드 role 매핑
    final role = authProvider.userInfo?['role'] as String?;
    return PermissionConstants.convertRoleToPermissionLevel(role);
  }

  // 🛠️ 메뉴 액션 처리
  void _processMenuAction(BuildContext context, String menuTitle) {
    switch (menuTitle) {
      case '모임 소개':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const MeetingDetailScreen()),
        );
        break;
      case '개인정보 입력하기':
        navigateToProfileInput(context);
        break;
      default:
        _showSnackBar(context, '$menuTitle 기능은 개발 중입니다.');
    }
  }

  // 🔒 개인정보 입력 요구 다이얼로그
  void _showProfileRequiredDialog(BuildContext context, String featureName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.lock_outline,
              color: Theme.of(context).colorScheme.primary,
              size: 24,
            ),
            const SizedBox(width: 8),
            const Text('개인정보 입력 필요'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$featureName 기능을 사용하려면\n기본 개인정보를 먼저 입력해주세요.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 16,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '사용자 이름 등 기본 정보만 있으면 됩니다!',
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              '나중에',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              navigateToProfileInput(context);
            },
            child: const Text('지금 입력하기'),
          ),
        ],
      ),
    );
  }

  // 🚫 권한 부족 다이얼로그
  void _showInsufficientPermissionDialog(BuildContext context, String featureName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.security_outlined,
              color: Theme.of(context).colorScheme.error,
              size: 24,
            ),
            const SizedBox(width: 8),
            const Text('접근 권한 부족'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$featureName 기능에 접근할 권한이 없습니다.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.errorContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 16,
                    color: Theme.of(context).colorScheme.onErrorContainer,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '로그인이 필요하거나 상위 권한이 요구됩니다.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.onErrorContainer,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
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
}
