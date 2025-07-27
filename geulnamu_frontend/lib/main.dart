import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart'; // 🎯 한국어 지원

// Core imports
import 'core/config/app_config.dart';
import 'core/config/kakao_config.dart';
import 'core/theme.dart';  // 🎯 모든 테마 설정이 여기에!

// Provider imports
import 'providers/auth_provider.dart';
import 'providers/theme_provider.dart';
import 'services/home/home_service.dart';

// Screen imports
import 'screens/splash/splash_screen.dart';
import 'screens/auth/login_screen.dart';
// import 'screens/auth/oauth_callback_screen.dart'; // HTML에서 처리
import 'screens/home/home_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/introduction/introduction_screen.dart'; // 글나무 소개 화면
import 'screens/member/member_list_screen.dart'; // 모임원 목록 화면
import 'screens/meeting/meeting_list_screen.dart'; // 모임 목록 화면
import 'screens/meeting/meeting_list_staff_screen.dart'; // 🆕 운영진용 모임 목록 화면
import 'screens/meeting/meeting_create_screen.dart'; // 🆕 모임 만들기 화면
import 'screens/meeting/meeting_detail_screen.dart'; // 🆕 모임 상세 화면
import 'screens/settings_screen.dart'; // 설정 화면
import 'services/home/home_route_service.dart'; // 🎯 RouteObserver import
import 'services/meeting/meeting_service.dart'; // 🆕 모임 서비스
import 'services/attendance/attendance_service.dart'; // 🆕 출석 서비스
import 'services/member/member_service.dart'; // 🆕 모임원 서비스
import 'services/profile/profile_service.dart'; // 🆕 프로필 서비스

// 🎯 Global Navigator Key - 전역에서 접근 가능
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  // Flutter 바인딩 초기화
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // 환경변수 초기화
    await AppConfig.initialize();

    // 카카오 SDK 초기화
    KakaoConfig.initialize();

    // 🎯 서비스 초기화 - Singleton 인스턴스 생성 (생성자에서 자동 초기화)
    MeetingService(); // Singleton 인스턴스 생성
    AttendanceService(); // Singleton 인스턴스 생성
    MemberService(); // Singleton 인스턴스 생성
    ProfileService(); // Singleton 인스턴스 생성

    // 앱 설정 정보 출력 (디버그용)
    AppConfig.printConfig();

    runApp(const GeulnamuApp());
  } catch (e) {
    print('❌ 앱 초기화 실패: $e');
    runApp(const ErrorApp());
  }
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
        ChangeNotifierProvider(create: (_) {
          final themeProvider = ThemeProvider();
          // 비동기로 초기화 실행
          Future.microtask(() => themeProvider.initialize());
          return themeProvider;
        }),
        ChangeNotifierProvider(create: (_) => HomeService()), // 🔄 HomeService 추가
        // 추후 다른 Provider들 추가 가능
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            navigatorKey: navigatorKey,  // 🎯 Global Navigator Key 설정
            title: '글나무 - 독서 토론 커뮤니티',
            debugShowCheckedModeBanner: false,

            // 🎯 핵심: ThemeProvider와 연동된 테마 시스템
            theme: GeulnamuTheme.lightTheme,      // 라이트 테마 (FAFAFA 배경 + 흰색 카드)
            darkTheme: GeulnamuTheme.darkTheme,   // 다크 테마 (0F0F0F 배경 + 회색 카드)
            themeMode: themeProvider.themeMode,   // 🎯 ThemeProvider에서 관리하는 테마 모드

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
        navigatorObservers: [HomeRouteService.routeObserver], // 🎯 RouteObserver 등록
        initialRoute: '/splash',
        onGenerateRoute: (settings) {
          if (settings.name == null) return null;
          
          final uri = Uri.parse(settings.name!);
          final path = uri.path; // 쿼리 파라미터 제외한 순수 경로
          final queryParams = uri.queryParameters;
          
          // 🎯 동적 경로 처리 (모임 상세)
          if (path.startsWith('/meeting/') && path.split('/').length == 3) {
            final meetingIdStr = path.split('/')[2];
            final meetingId = int.tryParse(meetingIdStr);
            if (meetingId != null) {
              return MaterialPageRoute(
                builder: (context) => MeetingDetailScreen(meetingId: meetingId),
                settings: settings,
              );
            }
          }
          
          // 🎯 정확한 라우트 매칭 시스템
          switch (path) {
            // 🆕 운영진용 모임 목록 화면 (정확한 매칭)
            case '/meeting-list-staff':
              final filterType = queryParams['filter'];
              return MaterialPageRoute(
                builder: (context) => MeetingListStaffScreen(
                  initialFilterType: filterType,
                ),
                settings: settings,
              );
            
            // 🎯 일반 모임 목록 화면 (정확한 매칭)
            case '/meeting-list':
              final filterType = queryParams['filter'];
              return MaterialPageRoute(
                builder: (context) => MeetingListScreen(
                  initialFilterType: filterType,
                ),
                settings: settings,
              );
            
            // 🎯 프로필 화면 (정확한 매칭)
            case '/profile':
              final memberId = queryParams['memberId'];
              final mode = queryParams['mode'];
              final returnPage = queryParams['returnPage'];
              
              return MaterialPageRoute(
                builder: (context) => ProfileScreen(
                  memberId: memberId != null ? int.tryParse(memberId) : null,
                  mode: mode ?? 'self',
                  returnPage: returnPage != null ? int.tryParse(returnPage) : null,
                ),
                settings: settings,
              );
          }
          
          // 나머지 기본 라우트들 (쿼리 파라미터 불필요)
          final routeMap = {
            '/splash': (context) => const SplashScreen(),
            '/login': (context) => const LoginScreen(),
            '/home': (context) => const HomeScreen(),
            '/introduction': (context) => const IntroductionScreen(),
            '/member-list': (context) => const MemberListScreen(),
            '/meeting-create': (context) => const MeetingCreateScreen(), // 🆕 모임 만들기
            '/settings': (context) => const SettingsScreen(),
          };
          
          final builder = routeMap[settings.name];
          if (builder != null) {
            return MaterialPageRoute(builder: builder, settings: settings);
          }
          
          return null;
        },

            // 404 처리
            onUnknownRoute: (settings) {
              return MaterialPageRoute(builder: (context) => const LoginScreen());
            },
          );
        },
      ),
    );
  }
}

// 🎯 에러 앱도 테마 시스템 사용 - 색상 설정 없음!
class ErrorApp extends StatelessWidget {
  const ErrorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '글나무 - 오류',
      theme: GeulnamuTheme.lightTheme,    // 🎯 통일된 테마 사용
      darkTheme: GeulnamuTheme.darkTheme, // 🎯 다크모드도 지원
      themeMode: ThemeMode.system,        // 🎯 시스템 설정 따라감
      home: Scaffold(
        // 🎯 backgroundColor 없음! 테마가 자동으로 처리
        body: Center(
          child: Card(
            // 🎯 색상 없음! 테마의 surface 색상 자동 사용
            margin: const EdgeInsets.all(32),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    // 🎯 색상 없음! 테마의 primary 색상 자동 사용
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '앱 초기화 중 오류가 발생했습니다.',
                    // 🎯 테마의 headlineMedium 스타일 자동 사용
                    style: Theme.of(context).textTheme.headlineMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '.env 파일과 카카오 키 설정을 확인해주세요.',
                    // 🎯 테마의 bodyMedium 스타일 자동 사용
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
