import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

// Core imports
import 'core/config/app_config.dart';
import 'core/config/kakao_config.dart';

// Provider imports
import 'providers/auth_provider.dart';

// Screen imports
import 'screens/splash/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/home/home_screen.dart';

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

        // 테마 설정 (책갈피 디자인 컨셉 반영)
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF7DD3C0), // 터퀴즈 메인 컬러
            brightness: Brightness.light,
          ),

          // 폰트 설정
          textTheme: GoogleFonts.notoSansTextTheme(),

          // AppBar 테마
          appBarTheme: AppBarTheme(
            backgroundColor: Colors.white,
            foregroundColor: const Color(0xFF2C3E50),
            elevation: 0,
            centerTitle: true,
            titleTextStyle: GoogleFonts.notoSans(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF2C3E50),
            ),
          ),

          // 버튼 테마
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF7DD3C0),
              foregroundColor: Colors.white,
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              textStyle: GoogleFonts.notoSans(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          // 카드 테마
          cardTheme: CardThemeData(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            color: Colors.white,
          ),

          // 스낵바 테마
          snackBarTheme: SnackBarThemeData(
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            backgroundColor: const Color(0xFF2C3E50),
          ),
        ),

        // 라우트 설정
        initialRoute: '/splash',
        routes: {
          '/splash': (context) => const SplashScreen(),
          '/login': (context) => const LoginScreen(),
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

// 에러 발생 시 표시할 앱
class ErrorApp extends StatelessWidget {
  const ErrorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '글나무 - 오류',
      home: Scaffold(
        backgroundColor: const Color(0xFF7DD3C0),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.white),
              const SizedBox(height: 16),
              Text(
                '앱 초기화 중 오류가 발생했습니다.',
                style: GoogleFonts.notoSans(
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                '.env 파일과 카카오 키 설정을 확인해주세요.',
                style: GoogleFonts.notoSans(
                  fontSize: 14,
                  color: Colors.white70,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
