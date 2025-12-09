import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:go_router/go_router.dart';

import '../core/config/app_config.dart';
import '../services/navigation/pending_navigation_service.dart';

// Screen imports
import '../screens/splash/splash_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/oauth_callback_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/introduction/introduction_screen.dart';
import '../screens/member/member_list_screen.dart';
import '../screens/meeting/meeting_list_screen.dart';
import '../screens/meeting/meeting_list_staff_screen.dart';
import '../screens/meeting/meeting_create_screen.dart';
import '../screens/meeting/meeting_detail_screen.dart';
import '../screens/meeting/meeting_detail_staff_screen.dart';
import '../screens/meeting/meeting_qr_scanner_screen.dart';
import '../screens/meeting/meeting_qr_display_screen.dart'; // 🆕 QR 표시 화면
import '../screens/attendance/attendance_status_screen.dart';
import '../screens/discussion/discussion_group_screen.dart';
import '../screens/presentation/presentation_list_screen.dart';
import '../screens/book_question/book_question_detail_screen.dart'; // 🆕 발제문 상세
import '../screens/contact/contact_screen.dart';
import '../screens/voc_management/voc_management_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/app_info/app_info_screen.dart';
import '../screens/push_notification/push_notification_screen.dart';

/// 글나무 앱 라우터 설정
/// 
/// GoRouter를 사용하여 PWA 브라우저 히스토리와 완벽하게 연동
/// 
/// 주요 특징:
/// - URL 기반 라우팅 (딥링크, URL 공유 지원)
/// - 브라우저 뒤로/앞으로 버튼 완벽 지원
/// - 쿼리 파라미터 및 path 파라미터 지원
/// - 리다이렉트를 통한 인증 처리
class AppRouter {
  AppRouter._();
  
  /// 🎯 Global Navigator Key
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  
  /// 🎯 GoRouter 인스턴스 (싱글톤)
  static GoRouter? _router;
  
  /// GoRouter 인스턴스 가져오기
  static GoRouter get router {
    _router ??= _createRouter();
    return _router!;
  }
  
  /// 라우터 생성
  static GoRouter _createRouter() {
    // 🎯 핵심 설정: 명령형 API (push, pop 등) 호출 시 URL이 브라우저 주소창에 반영되도록!
    // 이 옵션이 없으면 context.push() 호출해도 URL이 안 바뀜!
    GoRouter.optionURLReflectsImperativeAPIs = true;
    
    return GoRouter(
      navigatorKey: navigatorKey,
      initialLocation: _getInitialLocation(),
      debugLogDiagnostics: AppConfig.debugMode,
      
      // 🎯 라우트 정의
      routes: [
        // ==================== 기본 라우트 ====================
        GoRoute(
          path: '/',
          redirect: (context, state) => '/splash',
        ),
        
        GoRoute(
          path: '/splash',
          name: 'splash',
          builder: (context, state) => const SplashScreen(),
        ),
        
        GoRoute(
          path: '/login',
          name: 'login',
          builder: (context, state) => const LoginScreen(),
        ),
        
        GoRoute(
          path: '/auth/callback',
          name: 'oauth-callback',
          builder: (context, state) => const OAuthCallbackScreen(),
        ),
        
        GoRoute(
          path: '/home',
          name: 'home',
          builder: (context, state) => const HomeScreen(),
        ),
        
        // ==================== 프로필 ====================
        GoRoute(
          path: '/profile',
          name: 'profile',
          builder: (context, state) {
            final memberId = state.uri.queryParameters['memberId'];
            final mode = state.uri.queryParameters['mode'] ?? 'self';
            final returnPage = state.uri.queryParameters['returnPage'];
            
            return ProfileScreen(
              memberId: memberId != null ? int.tryParse(memberId) : null,
              mode: mode,
              returnPage: returnPage != null ? int.tryParse(returnPage) : null,
            );
          },
        ),
        
        // ==================== 정보 화면들 ====================
        GoRoute(
          path: '/introduction',
          name: 'introduction',
          builder: (context, state) => const IntroductionScreen(),
        ),
        
        GoRoute(
          path: '/member-list',
          name: 'member-list',
          builder: (context, state) => const MemberListScreen(),
        ),
        
        // ==================== 모임 관련 ====================
        GoRoute(
          path: '/meeting-list',
          name: 'meeting-list',
          builder: (context, state) {
            final filterType = state.uri.queryParameters['filter'];
            return MeetingListScreen(initialFilterType: filterType);
          },
        ),
        
        GoRoute(
          path: '/meeting-list-staff',
          name: 'meeting-list-staff',
          builder: (context, state) {
            final filterType = state.uri.queryParameters['filter'];
            return MeetingListStaffScreen(initialFilterType: filterType);
          },
        ),
        
        GoRoute(
          path: '/meeting-create',
          name: 'meeting-create',
          builder: (context, state) => const MeetingCreateScreen(),
        ),
        
        // 🎯 동적 경로: 모임 상세
        GoRoute(
          path: '/meeting/:meetingId',
          name: 'meeting-detail',
          builder: (context, state) {
            final meetingId = int.tryParse(state.pathParameters['meetingId'] ?? '');
            if (meetingId == null) {
              return const HomeScreen(); // 잘못된 ID면 홈으로
            }
            return MeetingDetailScreen(meetingId: meetingId);
          },
          routes: [
            // 🎯 중첩 라우트: 운영진용 모임 상세
            GoRoute(
              path: 'staff',
              name: 'meeting-detail-staff',
              builder: (context, state) {
                final meetingId = int.tryParse(state.pathParameters['meetingId'] ?? '');
                if (meetingId == null) {
                  return const HomeScreen();
                }
                return MeetingDetailStaffScreen(meetingId: meetingId);
              },
            ),
            // 🎯 중첩 라우트: QR 표시 화면
            GoRoute(
              path: 'qr-display',
              name: 'meeting-qr-display',
              builder: (context, state) {
                final meetingId = int.tryParse(state.pathParameters['meetingId'] ?? '');
                if (meetingId == null) {
                  return const HomeScreen();
                }
                // meetingTitle은 extra로 전달받거나 기본값 사용
                final extra = state.extra as Map<String, dynamic>?;
                final meetingTitle = extra?['meetingTitle'] as String? ?? '모임 $meetingId';
                return MeetingQrDisplayScreen(
                  meetingId: meetingId,
                  meetingTitle: meetingTitle,
                );
              },
            ),
          ],
        ),
        
        // ==================== 출석 관련 ====================
        GoRoute(
          path: '/qr-scanner',
          name: 'qr-scanner',
          builder: (context, state) => const MeetingQrScannerScreen(),
        ),
        
        GoRoute(
          path: '/attendance/status',
          name: 'attendance-status',
          builder: (context, state) {
            // 쿼리 파라미터에서 가져오기
            final meetingIdStr = state.uri.queryParameters['meetingId'];
            final meetingTitle = state.uri.queryParameters['meetingTitle'];
            
            // extra에서 가져오기 (push로 전달된 경우)
            final extra = state.extra as Map<String, dynamic>?;
            
            final meetingId = meetingIdStr != null 
                ? int.tryParse(meetingIdStr) 
                : extra?['meetingId'] as int?;
            final title = meetingTitle ?? extra?['meetingTitle'] as String?;
            
            if (meetingId == null) {
              return const HomeScreen(); // meetingId 없으면 홈으로
            }
            
            return AttendanceStatusScreen(
              meetingId: meetingId,
              meetingTitle: title,
            );
          },
        ),
        
        // ==================== 토론 관련 ====================
        GoRoute(
          path: '/discussion-group',
          name: 'discussion-group',
          builder: (context, state) {
            // 쿼리 파라미터에서 가져오기
            final meetingIdStr = state.uri.queryParameters['meetingId'];
            final meetingTitle = state.uri.queryParameters['meetingTitle'];
            
            // extra에서 가져오기 (push로 전달된 경우)
            final extra = state.extra as Map<String, dynamic>?;
            
            final meetingId = meetingIdStr != null 
                ? int.tryParse(meetingIdStr) 
                : extra?['meetingId'] as int?;
            final title = meetingTitle ?? extra?['meetingTitle'] as String?;
            
            if (meetingId == null) {
              return const HomeScreen();
            }
            
            return DiscussionGroupScreen(
              meetingId: meetingId,
              meetingTitle: title,
            );
          },
        ),
        
        // ==================== 발제문 ====================
        GoRoute(
          path: '/presentation-list',
          name: 'presentation-list',
          builder: (context, state) => const PresentationListScreen(),
        ),
        
        // 🎯 동적 경로: 발제문 상세
        GoRoute(
          path: '/book-question/:meetingId',
          name: 'book-question-detail',
          builder: (context, state) {
            final meetingId = int.tryParse(state.pathParameters['meetingId'] ?? '');
            if (meetingId == null) {
              return const HomeScreen();
            }
            // meetingTitle은 extra 또는 쿼리 파라미터에서 가져오기
            final extra = state.extra as Map<String, dynamic>?;
            final meetingTitle = state.uri.queryParameters['title'] ?? extra?['meetingTitle'] as String?;
            return BookQuestionDetailScreen(
              meetingId: meetingId,
              meetingTitle: meetingTitle,
            );
          },
        ),
        
        // ==================== 기타 ====================
        GoRoute(
          path: '/contact',
          name: 'contact',
          builder: (context, state) => const ContactScreen(),
        ),
        
        GoRoute(
          path: '/voc-management',
          name: 'voc-management',
          builder: (context, state) => const VoCManagementScreen(),
        ),
        
        GoRoute(
          path: '/settings',
          name: 'settings',
          builder: (context, state) => const SettingsScreen(),
        ),
        
        GoRoute(
          path: '/app-info',
          name: 'app-info',
          builder: (context, state) => const AppInfoScreen(),
        ),
        
        GoRoute(
          path: '/push-notification',
          name: 'push-notification',
          builder: (context, state) => const PushNotificationScreen(),
        ),
      ],
      
      // 🎯 에러 처리 (404)
      errorBuilder: (context, state) {
        if (AppConfig.debugMode) {
          print('❌ [GoRouter] 알 수 없는 경로: ${state.uri}');
        }
        return const HomeScreen();
      },
    );
  }
  
  /// 🎯 초기 위치 결정 (OAuth 콜백, 알림 딜링크 지원)
  static String _getInitialLocation() {
    if (kIsWeb) {
      try {
        final uri = Uri.base;
        final path = uri.path;
        
        if (AppConfig.debugMode) {
          print('🌐 [GoRouter] 초기 URL path: $path');
          print('🌐 [GoRouter] 쿼리 파라미터: ${uri.queryParameters}');
        }
        
        // OAuth 콜백 URL인 경우
        if (path == '/auth/callback' || path.contains('auth/callback')) {
          if (AppConfig.debugMode) {
            print('🎯 [GoRouter] OAuth 콜백 감지 → /auth/callback');
          }
          return '/auth/callback';
        }
        
        // 알림 딜링크 URL 처리
        if (_isNotificationDeepLink(path)) {
          if (AppConfig.debugMode) {
            print('📩 [GoRouter] 알림 딜링크 감지: $path');
          }
          _savePendingNavigationFromUrl(uri);
          return '/splash';
        }
      } catch (e) {
        if (AppConfig.debugMode) {
          print('⚠️ [GoRouter] URL 파싱 오류: $e');
        }
      }
    }
    return '/splash';
  }
  
  /// 알림 딜링크 URL인지 확인
  static bool _isNotificationDeepLink(String path) {
    final notificationPaths = [
      '/discussion-group',
      '/attendance/status',
      '/meeting/',
    ];
    
    for (final notificationPath in notificationPaths) {
      if (path.startsWith(notificationPath)) {
        return true;
      }
    }
    return false;
  }
  
  /// URL에서 Pending Navigation 저장
  static void _savePendingNavigationFromUrl(Uri uri) {
    Future.microtask(() async {
      try {
        final pendingService = PendingNavigationService();
        
        Map<String, dynamic>? arguments;
        if (uri.queryParameters.isNotEmpty) {
          arguments = Map<String, dynamic>.from(uri.queryParameters);
          
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
          print('✅ [GoRouter] Pending Navigation 저장 완료!');
        }
      } catch (e) {
        if (AppConfig.debugMode) {
          print('❌ [GoRouter] Pending Navigation 저장 실패: $e');
        }
      }
    });
  }
}

/// 🎯 GoRouter 확장 메서드 - 편의 기능
extension GoRouterExtension on BuildContext {
  /// 홈으로 이동 (스택 모두 제거)
  void goHome() {
    GoRouter.of(this).go('/home');
  }
  
  /// 로그인 화면으로 이동
  void goLogin() {
    GoRouter.of(this).push('/login');
  }
  
  /// 로그인 성공 후 홈으로 이동 (히스토리 정리)
  void goHomeAfterLogin() {
    // 🎯 PWA에서 뒤로가기로 로그인 화면 안 나오게 하려면
    // go를 사용하여 현재 URL을 /home으로 대체
    GoRouter.of(this).go('/home');
  }
  
  /// 모임 상세로 이동
  void goMeetingDetail(int meetingId) {
    GoRouter.of(this).push('/meeting/$meetingId');
  }
  
  /// 운영진용 모임 상세로 이동
  void goMeetingDetailStaff(int meetingId) {
    GoRouter.of(this).push('/meeting/$meetingId/staff');
  }
  
  /// 출석 현황으로 이동
  void goAttendanceStatus(int meetingId, {String? meetingTitle}) {
    GoRouter.of(this).push(
      '/attendance/status?meetingId=$meetingId${meetingTitle != null ? '&meetingTitle=$meetingTitle' : ''}',
    );
  }
  
  /// 토론 조 화면으로 이동
  void goDiscussionGroup(int meetingId, {String? meetingTitle}) {
    GoRouter.of(this).push(
      '/discussion-group?meetingId=$meetingId${meetingTitle != null ? '&meetingTitle=$meetingTitle' : ''}',
    );
  }
  
  /// 프로필 화면으로 이동
  void goProfile({int? memberId, String mode = 'self', int? returnPage}) {
    final params = <String>[];
    if (memberId != null) params.add('memberId=$memberId');
    params.add('mode=$mode');
    if (returnPage != null) params.add('returnPage=$returnPage');
    
    GoRouter.of(this).push('/profile?${params.join('&')}');
  }
}

/// 🎯 PWA 앱 종료 다이얼로그 위젯
/// 홈 화면에서 사용
class AppExitScope extends StatelessWidget {
  final Widget child;
  
  const AppExitScope({
    super.key,
    required this.child,
  });
  
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        
        final shouldExit = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('앱 종료'),
            content: const Text('앱을 종료하시겠습니까?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('취소'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('종료'),
              ),
            ],
          ),
        );
        
        if (shouldExit == true) {
          SystemNavigator.pop();
        }
      },
      child: child,
    );
  }
}
