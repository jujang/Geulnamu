import 'package:flutter_dotenv/flutter_dotenv.dart';

/// 🔐 환경변수 관리 클래스
/// .env 파일의 값들을 안전하게 읽어오는 역할을 합니다.
class AppConfig {
  // 싱글톤 패턴
  static final AppConfig _instance = AppConfig._internal();
  factory AppConfig() => _instance;
  AppConfig._internal();

  /// 환경변수 초기화
  static Future<void> initialize() async {
    await dotenv.load(fileName: ".env");
  }

  // 🎯 앱 기본 설정
  static String get appEnv => dotenv.env['APP_ENV'] ?? 'development';
  static String get appName => dotenv.env['APP_NAME'] ?? '글나무';
  static String get appVersion => dotenv.env['APP_VERSION'] ?? '1.0.0';

  // 🔑 카카오 OAuth 키들 (프론트엔드용)
  static String get kakaoNativeAppKey => 
      dotenv.env['KAKAO_NATIVE_APP_KEY'] ?? '';
  static String get kakaoJavaScriptAppKey => 
      dotenv.env['KAKAO_JAVASCRIPT_APP_KEY'] ?? '';
  
  // ℹ️ REST_API_KEY는 백엔드에서 관리합니다
  // static String get kakaoRestApiKey => dotenv.env['KAKAO_REST_API_KEY'] ?? '';

  // 🌐 백엔드 API 설정
  static String get apiBaseUrl => 
      dotenv.env['API_BASE_URL'] ?? 'http://localhost:8080/api';

  // 📱 앱 설정
  static String get androidPackageName => 
      dotenv.env['ANDROID_PACKAGE_NAME'] ?? 'com.geulnamu.app';
  static String get iosBundleId => 
      dotenv.env['IOS_BUNDLE_ID'] ?? 'com.geulnamu.app';
  static String get webDomain => 
      dotenv.env['WEB_DOMAIN'] ?? 'https://geulnamu.com';

  // 🔄 OAuth 설정
  static String get kakaoRedirectUri => 
      dotenv.env['KAKAO_REDIRECT_URI'] ?? 'https://geulnamu.com/auth/callback';

  // 🛠️ 디버그 설정
  static bool get debugMode => 
      dotenv.env['DEBUG_MODE']?.toLowerCase() == 'true';
  static String get logLevel => 
      dotenv.env['LOG_LEVEL'] ?? 'info';

  // 🔍 유효성 검사 (프론트엔드 필수 설정)
  static bool get isValidConfig {
    return kakaoNativeAppKey.isNotEmpty && 
           kakaoJavaScriptAppKey.isNotEmpty && 
           apiBaseUrl.isNotEmpty;
  }

  // 📋 설정 정보 출력 (디버그용)
  static void printConfig() {
    if (debugMode) {
      print('🌿 === 글나무 앱 설정 정보 ===');
      print('앱 환경: $appEnv');
      print('앱 이름: $appName');
      print('앱 버전: $appVersion');
      print('API URL: $apiBaseUrl');
      print('카카오 키 설정됨: ${kakaoNativeAppKey.isNotEmpty}');
      print('디버그 모드: $debugMode');
      print('설정 유효성: $isValidConfig');
      print('================================');
    }
  }
}