import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Core imports
import 'core/config/app_config.dart';
import 'core/config/kakao_config.dart';
import 'core/theme.dart';  // 🎯 모든 테마 설정이 여기에!

// Provider imports
import 'providers/auth_provider.dart';

// Screen imports
import 'screens/splash/splash_screen.dart';
import 'screens/auth/login_screen.dart';
// import 'screens/auth/oauth_callback_screen.dart'; // HTML에서 처리
import 'screens/home/home_screen.dart';
import 'screens/home/home_screen_logic.dart'; // 🎯 RouteObserver import

void main() async {
  // Flutter 바인딩 초기화
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // 환경변수 초기화
    await AppConfig.initialize();

    // 카카오 SDK 초기화
    KakaoConfig.initialize();

    // 앱 설정 정보 출력 (디버그용)
    AppConfig.printConfig();

    runApp(const GeulnamuApp());
  } catch (e) {
    print('❌ 앱 초기화 실패: $e');
    runApp(const ErrorApp());
  }
}

class GeulnamuApp extends StatelessWidget {
  const GeulnamuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        // 추후 다른 Provider들 추가 가능
      ],
      child: MaterialApp(
        title: '글나무 - 독서 토론 커뮤니티',
        debugShowCheckedModeBanner: false,

        // 🎯 핵심: Material Theme + 시스템 다크모드 지원
        theme: GeulnamuTheme.lightTheme,      // 라이트 테마 (FAFAFA 배경 + 흰색 카드)
        darkTheme: GeulnamuTheme.darkTheme,   // 다크 테마 (0F0F0F 배경 + 회색 카드)
        themeMode: ThemeMode.system,          // 시스템 설정에 따라 자동 전환

        // 라우트 설정 + RouteObserver 등록
        navigatorObservers: [HomeScreenLogic.routeObserver], // 🎯 RouteObserver 등록
        initialRoute: '/splash',
        routes: {
          '/splash': (context) => const SplashScreen(),
          '/login': (context) => const LoginScreen(),
          // '/auth/callback': (context) => const OAuthCallbackScreen(), // 주석 처리 - HTML에서 처리
          '/home': (context) => const HomeScreen(),
        },

        // 404 처리
        onUnknownRoute: (settings) {
          return MaterialPageRoute(builder: (context) => const LoginScreen());
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
