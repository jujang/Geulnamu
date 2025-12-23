import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_web_plugins/url_strategy.dart'; // 🎯 URL 전략 (# 제거)
import 'firebase_options.dart';

// Core imports
import 'core/config/app_config.dart';
import 'core/config/kakao_config.dart';
import 'core/theme.dart';

// Provider imports
import 'providers/auth_provider.dart';
import 'providers/theme_provider.dart';
import 'services/home/home_service.dart';

// Router import
import 'routes/app_router.dart';

// Service imports
import 'services/meeting/meeting_service.dart';
import 'services/attendance/attendance_service.dart';
import 'services/member/member_service.dart';
import 'services/profile/profile_service.dart';
import 'services/presentation/presentation_service.dart';
import 'services/notification/fcm_service.dart';
import 'services/navigation/web_navigation_service.dart';  // 🎯 웹 네비게이션 서비스

// PWA Utils
import 'core/utils/pwa_utils.dart';

void main() async {
  // 🎯 URL 전략 설정: hash(#) 제거 → 깔끔한 path URL 사용
  // localhost:3030/#/home → localhost:3030/home
  // ⚠️ WidgetsFlutterBinding 전에 호출해야 함!
  usePathUrlStrategy();
  
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('✅ Firebase 초기화 완료');

    await AppConfig.initialize();
    KakaoConfig.initialize();

    // 🎯 PWA 히스토리 초기화 (뒤로가기 문제 해결)
    PWAUtils.initializePWAHistory();
    
    // 🎯 웹 네비게이션 콜백 등록 (Service Worker postMessage 처리)
    WebNavigationService.registerNavigationCallback((url) {
      print('📩 [Main] Service Worker에서 네비게이션 요청: $url');
      // GoRouter로 이동
      AppRouter.router.go(url);
    });

    MeetingService();
    AttendanceService();
    MemberService();
    ProfileService();
    PresentationService();

    FcmService().initialize().then((_) {
      if (AppConfig.debugMode) {
        print('✅ FCM 서비스 백그라운드 초기화 완료');
      }
    }).catchError((e) {
      if (AppConfig.debugMode) {
        print('⚠️ FCM 서비스 초기화 실패: $e');
      }
    });

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
        ChangeNotifierProvider(
          create: (_) {
            final themeProvider = ThemeProvider();
            Future.microtask(() => themeProvider.initialize());
            return themeProvider;
          },
        ),
        ChangeNotifierProvider(create: (_) => HomeService()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp.router(
            title: '글나무 - 독서 토론 커뮤니티',
            debugShowCheckedModeBanner: false,
            theme: GeulnamuTheme.lightTheme,
            darkTheme: GeulnamuTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('ko', 'KR'),
              Locale('en', 'US'),
            ],
            locale: const Locale('ko', 'KR'),
            routerConfig: AppRouter.router,
          );
        },
      ),
    );
  }
}

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
                      Icon(Icons.error_outline, size: 64, color: colorScheme.error),
                      const SizedBox(height: 16),
                      Text(
                        '앱 초기화 중 오류가 발생했습니다.',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: colorScheme.onSurface,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '.env 파일과 카카오 키 설정을 확인해주세요.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurface,
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
