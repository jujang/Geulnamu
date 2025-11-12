import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../core/config/app_config.dart'; // AppConfig import 추가
import '../../core/constants/permission_constants.dart'; // 권한 상수 import

/// 홈화면 비즈니스 로직을 담당하는 Singleton Service
///
/// 기능:
/// - 권한 레벨 + 개인정보 이중 체크 시스템
/// - 메뉴 탭 처리
/// - 로그아웃 처리
/// - 프로필 메뉴 선택 처리
/// - 다이얼로그 및 스낵바 표시
/// - 네비게이션 처리
/// - 로딩 상태 관리
class HomeService extends ChangeNotifier {
  static final HomeService _instance = HomeService._internal();
  factory HomeService() => _instance;
  HomeService._internal();

  // 🔄 로딩 상태 관리
  bool _isProcessing = false;
  String? _currentOperation;

  /// 현재 처리 중인지 여부
  bool get isProcessing => _isProcessing;

  /// 현재 진행 중인 작업명
  String? get currentOperation => _currentOperation;

  // 🎯 메뉴 탭 처리 (권한 레벨 + 개인정보 이중 체크)
  void handleMenuTap(BuildContext context, String menuTitle) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // 🏠 홈 화면은 권한 체크 없이 무조건 접근 가능
    if (menuTitle == '홈 화면') {
      _processMenuAction(context, menuTitle);
      return;
    }

    // 🌿 글나무 소개도 누구나 접근 가능
    if (menuTitle == '글나무 소개') {
      _processMenuAction(context, menuTitle);
      return;
    }

    // 🔒 로그인이 필요한 기능들 체크
    final loginRequiredFeatures = [
      '모임 목록',
      '모임 목록 (운영진용)',
      '오늘의 모임',
      '모임 만들기',
      '출석 체크',
      '발제 작성',
      '모임원 목록',
      '발제문 목록',
    ];

    if (loginRequiredFeatures.contains(menuTitle)) {
      // 🚫 로그인이 안 된 상태 → 로그인 요구 다이얼로그
      if (!authProvider.isAuthenticated) {
        _showLoginRequiredDialog(context, menuTitle);
        return;
      }

      // 🔍 로그인은 됐지만 개인정보 입력이 안 된 경우 (우선 체크!)
      if (authProvider.profileCompleted == false) {
        _showProfileRequiredDialog(context, menuTitle);
        return;
      }

      // 🔐 개인정보가 있지만 권한이 부족한 경우
      if (!hasRolePermission(menuTitle, authProvider)) {
        _showInsufficientPermissionDialog(context, menuTitle);
        return;
      }
    }

    // ✅ 정상 메뉴 처리
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
        Navigator.pushNamed(context, '/profile'); // 프로필 화면으로 이동
        break;
      case 'settings':
        Navigator.pushNamed(context, '/settings');
        break;
      case 'logout':
        await handleLogout(context, authProvider);
        break;
    }
  }

  // 🎯 로그아웃 처리 (로딩 상태 포함)
  Future<void> handleLogout(
    BuildContext context,
    AuthProvider authProvider,
  ) async {
    // 이미 처리 중이면 중복 방지
    if (_isProcessing) return;

    final confirmed = await _showLogoutDialog(context);

    if (confirmed == true) {
      try {
        // 🔄 로딩 시작
        _setProcessing(true, '로그아웃 중...');

        await authProvider.logout(context: context);

        // 🎯 로그아웃 후 자동으로 홈으로 이동 (모든 이전 라우트 제거)
        if (context.mounted) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/home',
            (route) => false, // 모든 이전 라우트 제거
          );
        }

        // 🎯 홈 이동 후 스낵바 표시 (약간의 딜레이)
        if (context.mounted) {
          Future.delayed(const Duration(milliseconds: 300), () {
            if (context.mounted) {
              // 🎯 로그아웃 스낵바도 동일하게 수정
              ScaffoldMessenger.of(context).clearSnackBars();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('로그아웃되었습니다.'),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  duration: const Duration(milliseconds: 2500),
                ),
              );
            }
          });
        }
      } catch (e) {
        print('❌ [HomeService] 로그아웃 오류: $e');
        // 에러 발생 시에도 로그아웃 상태로 처리 (보안상 이유)
      } finally {
        // 🔄 로딩 완료
        _setProcessing(false);
      }
    }
  }

  // 🎯 모임 만들기 다이얼로그 (권한 체크 포함)
  void showCreateMeetingDialog(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // 🚫 로그인이 안 된 상태 → 로그인 요구 다이얼로그
    if (!authProvider.isAuthenticated) {
      _showLoginRequiredDialog(context, '모임 만들기');
      return;
    }

    // 🔍 로그인은 됐지만 개인정보 입력이 안 된 경우 (우선 체크!)
    if (authProvider.profileCompleted == false) {
      _showProfileRequiredDialog(context, '모임 만들기');
      return;
    }

    // 🔐 개인정보가 있지만 권한이 부족한 경우
    if (!hasRolePermission('모임 만들기', authProvider)) {
      _showInsufficientPermissionDialog(context, '모임 만들기');
      return;
    }

    // ✅ 정상 처리 (현재는 개발 중)
    _showSnackBar(context, '모임 만들기 기능은 개발 중입니다.');
  }

  // 🏠 홈 화면으로 이동 (로고 클릭 시)
  void navigateToHome(BuildContext context) {
    // 현재 라우트가 '/home'이 아니면 홈으로 이동
    final currentRoute = ModalRoute.of(context)?.settings.name;
    if (currentRoute != '/home') {
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/home',
        (route) => false, // 모든 이전 라우트 제거
      );
    }
  }

  // 🎯 네비게이션 메서드들
  void navigateToLogin(BuildContext context) {
    Navigator.pushNamed(context, '/login');
  }

  // 🔍 개인정보 입력 화면으로 이동
  void navigateToProfileInput(BuildContext context) {
    Navigator.pushNamed(context, '/profile'); // 프로필 화면으로 이동
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

  // 🎯 메뉴 액션 처리 (실제 기능 수행)
  void _processMenuAction(BuildContext context, String menuTitle) {
    switch (menuTitle) {
      case '홈 화면':
        navigateToHome(context);
        break;
      case '글나무 소개':
        // 🌿 글나무 소개 화면으로 이동 (로그인 무관)
        Navigator.pushNamed(context, '/introduction');
        break;
      case '모임원 목록':
        Navigator.pushNamed(context, '/member-list');
        break;
      case '오늘의 모임':
        // 🎯 모임 목록 화면으로 이동 (오늘의 모임 필터 활성화)
        Navigator.pushNamed(context, '/meeting-list?filter=today');
        break;
      case '모임 목록':
        Navigator.pushNamed(context, '/meeting-list').then((result) {
          // 모임 생성 후 돌아왔을 때 새로고침
          if (result == true) {
            // 모임 목록 페이지가 이미 로드되어 있다면 새로고침
            if (AppConfig.debugMode) {
              print('🔄 [모임 목록] 모임 생성 후 새로고침 트리거');
            }
          }
        });
        break;
      case '모임 목록 (운영진용)':
        Navigator.pushNamed(context, '/meeting-list-staff');
        break;
      case '출석 체크':
        Navigator.pushNamed(context, '/qr-scanner');
        break;
      case '발제문 목록':
        Navigator.pushNamed(context, '/presentation-list');
        break;
      case '문의하기':
        Navigator.pushNamed(context, '/contact');
        break;
      case '앱 정보':
        _showSnackBar(context, '앱 정보 기능은 개발 중입니다.');
        break;
      case '모임 만들기':
        Navigator.pushNamed(context, '/meeting-create');
        break;
      default:
        _showSnackBar(context, '$menuTitle 기능은 개발 중입니다.');
        break;
    }
  }

  // 🔒 권한 체크 메서드

  /// 역할 권한 체크
  bool hasRolePermission(String featureName, AuthProvider authProvider) {
    // 권한 상수를 사용한 통합 권한 체크 시스템
    return authProvider.hasMenuPermission(featureName);
  }

  // 🔄 로딩 상태 설정 메서드
  void _setProcessing(bool processing, [String? operation]) {
    _isProcessing = processing;
    _currentOperation = processing ? operation : null;
    notifyListeners();
  }

  // 🎯 Private 메서드들

  void _showSnackBar(BuildContext context, String message) {
    // 🎯 기존 SnackBar가 있으면 즉시 제거 (걹치기 허용)
    ScaffoldMessenger.of(context).clearSnackBars();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.primary, // 🎨 글나무 민트색
        duration: const Duration(milliseconds: 2500), // 🎯 4초 → 2.5초로 단축
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

  // 🚫 로그인 요구 다이얼로그
  void _showLoginRequiredDialog(BuildContext context, String featureName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.login_outlined,
              color: Theme.of(context).colorScheme.primary,
              size: 24,
            ),
            const SizedBox(width: 8),
            const Text('로그인 필요'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$featureName 기능을 사용하려면\n로그인이 필요합니다.',
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
                      '카카오 계정으로 간편하게 로그인하세요!',
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
              '다음에',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              navigateToLogin(context);
            },
            child: const Text('로그인하기'),
          ),
        ],
      ),
    );
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
  void _showInsufficientPermissionDialog(
    BuildContext context,
    String featureName,
  ) {
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
                      '해당 기능은 특정 권한이 있는 사용자만 사용할 수 있습니다.',
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
