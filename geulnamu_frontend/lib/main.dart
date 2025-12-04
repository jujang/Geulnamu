import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart'; // 🎯 한국어 지원
import 'package:firebase_core/firebase_core.dart'; // 🔥 Firebase Core
import 'firebase_options.dart'; // 🔥 Firebase 설정

// Core imports
import 'core/config/app_config.dart';
import 'core/config/kakao_config.dart';
import 'core/theme.dart'; // 🎯 모든 테마 설정이 여기에!

// Provider imports
import 'providers/auth_provider.dart';
import 'providers/theme_provider.dart';
import 'services/home/home_service.dart';

// Screen imports
import 'screens/splash/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/oauth_callback_screen.dart'; // OAuth 콜백 처리
import 'screens/home/home_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/introduction/introduction_screen.dart'; // 글나무 소개 화면
import 'screens/member/member_list_screen.dart'; // 모임원 목록 화면
import 'screens/meeting/meeting_list_screen.dart'; // 모임 목록 화면
import 'screens/meeting/meeting_list_staff_screen.dart'; // 운영진용 모임 목록 화면
import 'screens/meeting/meeting_create_screen.dart'; // 모임 만들기 화면
import 'screens/meeting/meeting_detail_screen.dart'; // 모임 상세 화면
import 'screens/meeting/meeting_detail_staff_screen.dart'; // 운영진용 모임 상세 화면
import 'screens/meeting/meeting_qr_scanner_screen.dart'; // QR 스캐너 화면
import 'screens/attendance/attendance_status_screen.dart'; // 출석 현황 화면
import 'screens/discussion/discussion_group_screen.dart'; // 토론 조 화면
import 'screens/presentation/presentation_list_screen.dart'; // 발제문 목록 화면
import 'screens/contact/contact_screen.dart'; // 문의하기 화면
import 'screens/voc_management/voc_management_screen.dart'; // 문의 목록 화면
import 'screens/settings_screen.dart'; // 설정 화면
import 'screens/app_info/app_info_screen.dart'; // 앱 정보 화면
import 'screens/push_notification/push_notification_screen.dart'; // 푸시 알림 발송 화면 (관리자)
import 'services/home/home_route_service.dart'; // 🎯 RouteObserver import
import 'services/meeting/meeting_service.dart'; // 모임 서비스
import 'services/attendance/attendance_service.dart'; // 출석 서비스
import 'services/member/member_service.dart'; // 모임원 서비스
import 'services/profile/profile_service.dart'; // 프로필 서비스
import 'services/presentation/presentation_service.dart'; // 발제문 서비스
import 'services/notification/fcm_service.dart'; // 🔥 FCM 푸시 알림 서비스

// 🎯 Global Navigator Key - 전역에서 접근 가능
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  // Flutter 바인딩 초기화
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // 🔥 Firebase 초기화 (가장 먼저!)
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('✅ Firebase 초기화 완료');

    // 환경변수 초기화
    await AppConfig.initialize();

    // 카카오 SDK 초기화
    KakaoConfig.initialize();

    // 🎯 서비스 초기화 - Singleton 인스턴스 생성 (생성자에서 자동 초기화)
    MeetingService(); // Singleton 인스턴스 생성
    AttendanceService(); // Singleton 인스턴스 생성
    MemberService(); // Singleton 인스턴스 생성
    ProfileService(); // Singleton 인스턴스 생성
    PresentationService(); // Singleton 인스턴스 생성

    // 🔥 FCM 푸시 알림 서비스 초기화 (비동기로 백그라운드 실행 - 앱 시작 지연 방지)
    FcmService().initialize().then((_) {
      if (AppConfig.debugMode) {
        print('✅ FCM 서비스 백그라운드 초기화 완료');
      }
    }).catchError((e) {
      if (AppConfig.debugMode) {
        print('⚠️ FCM 서비스 초기화 실패 (앱 실행에는 영향 없음): $e');
      }
    });

    // 앱 설정 정보 출력 (디버그용)
    AppConfig.printConfig();

    runApp(const GeulnamuApp());
  } catch (e) {
    print('❌ 앱 초기화 실패: $e');
    runApp(const ErrorApp());
  }
}

/// 🎯 웹에서 초기 라우트 결정 (OAuth 콜백 지원)
/// 모바일 redirect 방식으로 돌아올 때 /auth/callback을 처리
String _getInitialRoute() {
  if (kIsWeb) {
    try {
      final uri = Uri.base; // 현재 브라우저 URL
      final path = uri.path;
      
      if (AppConfig.debugMode) {
        print('🌐 [초기 라우트] 현재 URL path: $path');
        print('🌐 [초기 라우트] 쿼리 파라미터: ${uri.queryParameters}');
      }
      
      // OAuth 콜백 URL인 경우
      if (path == '/auth/callback' || path.contains('auth/callback')) {
        if (AppConfig.debugMode) {
          print('🎯 [초기 라우트] OAuth 콜백 감지 → /auth/callback으로 이동');
        }
        return '/auth/callback';
      }
    } catch (e) {
      if (AppConfig.debugMode) {
        print('⚠️ [초기 라우트] URL 파싱 오류: $e');
      }
    }
  }
  return '/splash';
}

class GeulnamuApp extends StatefulWidget {
  const GeulnamuApp({super.key});

  @override
  State<GeulnamuApp> createState() => _GeulnamuAppState();
}

class _GeulnamuAppState extends State<GeulnamuApp> {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(
          create: (_) {
            final themeProvider = ThemeProvider();
            // 비동기로 초기화 실행
            Future.microtask(() => themeProvider.initialize());
            return themeProvider;
          },
        ),
        ChangeNotifierProvider(
          create: (_) => HomeService(),
        ), // 🔄 HomeService 추가
        // 추후 다른 Provider들 추가 가능
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            navigatorKey: navigatorKey, // 🎯 Global Navigator Key 설정
            title: '글나무 - 독서 토론 커뮤니티',
            debugShowCheckedModeBanner: false,

            // 🎯 핵심: ThemeProvider와 연동된 테마 시스템
            theme: GeulnamuTheme.lightTheme, // 라이트 테마 (FAFAFA 배경 + 흰색 카드)
            darkTheme: GeulnamuTheme.darkTheme, // 다크 테마 (0F0F0F 배경 + 회색 카드)
            themeMode: themeProvider.themeMode, // 🎯 ThemeProvider에서 관리하는 테마 모드
            // 🎯 한국어 지원 추가
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('ko', 'KR'), // 한국어
              Locale('en', 'US'), // 영어
            ],
            locale: const Locale('ko', 'KR'), // 기본 로케일 한국어
            // 라우트 설정 + RouteObserver 등록
            navigatorObservers: [
              HomeRouteService.routeObserver,
            ], // 🎯 RouteObserver 등록
            initialRoute: _getInitialRoute(), // 🎯 동적 초기 라우트 (OAuth 콜백 지원)
            onGenerateRoute: (settings) {
              if (settings.name == null) return null;

              final uri = Uri.parse(settings.name!);
              final path = uri.path; // 쿼리 파라미터 제외한 순수 경로
              final queryParams = uri.queryParameters;

              // 🎯 동적 경로 처리 (모임 상세)
              if (path.startsWith('/meeting/') &&
                  path.endsWith('/staff') &&
                  path.split('/').length == 4) {
                final meetingIdStr = path.split('/')[2];
                final meetingId = int.tryParse(meetingIdStr);
                if (meetingId != null) {
                  return MaterialPageRoute(
                    builder: (context) =>
                        MeetingDetailStaffScreen(meetingId: meetingId),
                    settings: settings,
                  );
                }
              }

              if (path.startsWith('/meeting/') && path.split('/').length == 3) {
                final meetingIdStr = path.split('/')[2];
                final meetingId = int.tryParse(meetingIdStr);
                if (meetingId != null) {
                  return MaterialPageRoute(
                    builder: (context) =>
                        MeetingDetailScreen(meetingId: meetingId),
                    settings: settings,
                  );
                }
              }

              // 🎯 정확한 라우트 매칭 시스템
              switch (path) {
                // 🎯 OAuth 콜백 처리 (redirect 방식 지원)
                case '/auth/callback':
                  return MaterialPageRoute(
                    builder: (context) => const OAuthCallbackScreen(),
                    settings: settings,
                  );

                // 운영진용 모임 목록 화면 (정확한 매칭)
                case '/meeting-list-staff':
                  final filterType = queryParams['filter'];
                  return MaterialPageRoute(
                    builder: (context) =>
                        MeetingListStaffScreen(initialFilterType: filterType),
                    settings: settings,
                  );

                // 🎯 일반 모임 목록 화면 (정확한 매칭)
                case '/meeting-list':
                  final filterType = queryParams['filter'];
                  return MaterialPageRoute(
                    builder: (context) =>
                        MeetingListScreen(initialFilterType: filterType),
                    settings: settings,
                  );

                // 🎯 프로필 화면 (정확한 매칭)
                case '/profile':
                  final memberId = queryParams['memberId'];
                  final mode = queryParams['mode'];
                  final returnPage = queryParams['returnPage'];

                  return MaterialPageRoute(
                    builder: (context) => ProfileScreen(
                      memberId: memberId != null
                          ? int.tryParse(memberId)
                          : null,
                      mode: mode ?? 'self',
                      returnPage: returnPage != null
                          ? int.tryParse(returnPage)
                          : null,
                    ),
                    settings: settings,
                  );

                // 출석 현황 화면 (정확한 매칭)
                // 🎯 쿼리 파라미터 방식 지원 (Service Worker 알림 클릭)
                // 예: /attendance/status?meetingId=123
                case '/attendance/status':
                  int? meetingId;
                  String? meetingTitle;

                  // 1️⃣ 쿼리 파라미터에서 meetingId 확인 (알림 클릭 시)
                  if (queryParams.containsKey('meetingId')) {
                    meetingId = int.tryParse(queryParams['meetingId'] ?? '');
                    meetingTitle = queryParams['meetingTitle'];
                  }
                  
                  // 2️⃣ arguments에서 meetingId 확인 (일반 네비게이션)
                  if (meetingId == null) {
                    final arguments = settings.arguments as Map<String, dynamic>?;
                    if (arguments != null) {
                      meetingId = arguments['meetingId'] as int?;
                      meetingTitle = arguments['meetingTitle'] as String?;
                    }
                  }

                  // meetingId가 있으면 화면으로 이동
                  if (meetingId != null) {
                    return MaterialPageRoute(
                      builder: (context) => AttendanceStatusScreen(
                        meetingId: meetingId!,
                        meetingTitle: meetingTitle,
                      ),
                      settings: settings,
                    );
                  }
                  
                  // meetingId가 없으면 404 처리
                  return null;

                // 토론 조 화면 (푸시 알림 클릭 시)
                // 🎯 쿼리 파라미터 방식 지원
                // 예: /discussion-group?meetingId=123
                case '/discussion-group':
                  int? meetingId;
                  String? meetingTitle;

                  // 1️⃣ 쿼리 파라미터에서 meetingId 확인 (알림 클릭 시)
                  if (queryParams.containsKey('meetingId')) {
                    meetingId = int.tryParse(queryParams['meetingId'] ?? '');
                    meetingTitle = queryParams['meetingTitle'];
                  }
                  
                  // 2️⃣ arguments에서 meetingId 확인 (일반 네비게이션)
                  if (meetingId == null) {
                    final arguments = settings.arguments as Map<String, dynamic>?;
                    if (arguments != null) {
                      meetingId = arguments['meetingId'] as int?;
                      meetingTitle = arguments['meetingTitle'] as String?;
                    }
                  }

                  // meetingId가 있으면 화면으로 이동
                  if (meetingId != null) {
                    return MaterialPageRoute(
                      builder: (context) => DiscussionGroupScreen(
                        meetingId: meetingId!,
                        meetingTitle: meetingTitle,
                      ),
                      settings: settings,
                    );
                  }
                  
                  // meetingId가 없으면 404 처리
                  return null;
              }

              // 나머지 기본 라우트들 (쿼리 파라미터 불필요)
              final routeMap = {
                '/splash': (context) => const SplashScreen(),
                '/login': (context) => const LoginScreen(),
                '/auth/callback': (context) =>
                    const OAuthCallbackScreen(), // 🎯 OAuth 콜백
                '/home': (context) => const HomeScreen(),
                '/introduction': (context) => const IntroductionScreen(),
                '/member-list': (context) => const MemberListScreen(),
                '/meeting-create': (context) =>
                    const MeetingCreateScreen(), // 모임 만들기
                '/qr-scanner': (context) =>
                    const MeetingQrScannerScreen(), // QR 스캐너
                '/presentation-list': (context) =>
                    const PresentationListScreen(), // 발제문 목록
                '/contact': (context) => const ContactScreen(), // 문의하기
                '/voc-management': (context) =>
                    const VoCManagementScreen(), // 문의 목록
                '/settings': (context) => const SettingsScreen(),
                '/app-info': (context) => const AppInfoScreen(), // 앱 정보
                '/push-notification': (context) => const PushNotificationScreen(), // 푸시 알림 발송 (관리자)
              };

              final builder = routeMap[settings.name];
              if (builder != null) {
                return MaterialPageRoute(builder: builder, settings: settings);
              }

              return null;
            },

            // 404 처리
            onUnknownRoute: (settings) {
              return MaterialPageRoute(
                builder: (context) => const LoginScreen(),
              );
            },
          );
        },
      ),
    );
  }
}

// 🎯 에러 앱 - 다크 모드 텍스트 명확히 표시
class ErrorApp extends StatelessWidget {
  const ErrorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '글나무 - 오류',
      theme: GeulnamuTheme.lightTheme,
      darkTheme: GeulnamuTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: Builder(
        builder: (context) {
          final colorScheme = Theme.of(context).colorScheme;

          return Scaffold(
            backgroundColor: colorScheme.surface,
            body: Center(
              child: Card(
                color: colorScheme.surface,
                margin: const EdgeInsets.all(32),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: colorScheme.error, // 🎯 명시적 색상 설정
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '앱 초기화 중 오류가 발생했습니다.',
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(
                              color: colorScheme.onSurface, // 🎯 명시적 색상 설정
                            ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '.env 파일과 카카오 키 설정을 확인해주세요.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurface, // 🎯 명시적 색상 설정
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
