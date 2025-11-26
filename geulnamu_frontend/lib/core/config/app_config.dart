import 'package:flutter_dotenv/flutter_dotenv.dart';

/// 🔐 환경변수 관리 클래스 (업데이트)
/// .env 파일의 값들을 안전하게 읽어오며 백엔드 API 연동을 지원합니다.
class AppConfig {
  // 싱글톤 패턴
  static final AppConfig _instance = AppConfig._internal();
  factory AppConfig() => _instance;
  AppConfig._internal();

  /// 환경변수 초기화 - 자동 환경 감지
  static Future<void> initialize() async {
    try {
      // 🎯 환경별 파일 자동 선택
      String envFile = await _detectEnvironmentFile();

      await dotenv.load(fileName: envFile);

      print('✅ 환경변수 로드 완료: $envFile');
    } catch (e) {
      print('❌ 환경변수 로드 실패: $e');
      print('💡 .env 파일이 있는지 확인하세요!');
      rethrow;
    }
  }

  /// 🔍 환경 감지 및 적절한 .env 파일 선택
  static Future<String> _detectEnvironmentFile() async {
    // 1. kIsWeb으로 웹 환경 감지
    const bool isWeb = identical(0, 0.0); // 컴파일 타임 상수로 웹 감지

    if (isWeb) {
      // 웹 환경: URL 호스트로 판단
      final String hostname = Uri.base.host;

      if (hostname == 'localhost' || hostname == '127.0.0.1') {
        print('🏠 로컬 환경 감지 (웹): .env.local 사용');
        return '.env.local';
      } else {
        print('🌐 배포 환경 감지 (웹): .env.prod 사용');
        return '.env.prod';
      }
    } else {
      // 모바일/데스크톱 환경: 기본적으로 로컬로 간주
      print('📱 로컬 환경 감지 (모바일/데스크톱): .env.local 사용');
      return '.env.local';
    }
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

  // ℹ️ REST_API_KEY는 백엔드에서 관리합니다 (보안상 이유)
  // static String get kakaoRestApiKey => dotenv.env['KAKAO_REST_API_KEY'] ?? '';

  // 🌐 백엔드 API 설정 (업데이트)
  static String get _rawApiBaseUrl =>
      dotenv.env['API_BASE_URL'] ?? 'http://localhost:8080';

  /// 완전한 API Base URL (백엔드 경로와 일치)
  static String get apiBaseUrl {
    final baseUrl = _rawApiBaseUrl.trim();
    // 백엔드가 /api 접두사 없이 설계되어 있으므로 그대로 사용
    if (baseUrl.endsWith('/')) {
      return baseUrl.substring(0, baseUrl.length - 1);
    }
    return baseUrl;
  }

  /// 실제 백엔드 서버 URL (API prefix 없이)
  static String get serverBaseUrl {
    final baseUrl = _rawApiBaseUrl.trim();
    if (baseUrl.endsWith('/')) {
      return baseUrl.substring(0, baseUrl.length - 1);
    }
    return baseUrl;
  }

  // 📱 앱 설정
  static String get androidPackageName =>
      dotenv.env['ANDROID_PACKAGE_NAME'] ?? 'com.geulnamu.app';
  static String get iosBundleId =>
      dotenv.env['IOS_BUNDLE_ID'] ?? 'com.geulnamu.app';
  static String get webDomain =>
      dotenv.env['WEB_DOMAIN'] ?? 'http://localhost:3030';

  // 🔄 OAuth 설정
  static String get kakaoRedirectUri =>
      dotenv.env['KAKAO_REDIRECT_URI'] ?? '$webDomain/auth/callback';

  // 🛠️ 디버그 설정
  static bool get debugMode =>
      dotenv.env['DEBUG_MODE']?.toLowerCase() == 'true';

  // 🌐 환경별 설정
  static bool get isProduction => appEnv.toLowerCase() == 'production';
  static bool get isDevelopment => appEnv.toLowerCase() == 'development';
  static bool get isStaging => appEnv.toLowerCase() == 'staging';

  // 🔍 유효성 검사 (프론트엔드 필수 설정)
  static bool get isValidConfig {
    final hasKakaoKeys =
        kakaoNativeAppKey.isNotEmpty && kakaoJavaScriptAppKey.isNotEmpty;
    final hasApiUrl = _rawApiBaseUrl.isNotEmpty;

    return hasKakaoKeys && hasApiUrl;
  }

  // 🚨 누락된 설정 체크
  static List<String> get missingConfigs {
    List<String> missing = [];

    if (kakaoNativeAppKey.isEmpty) {
      missing.add('KAKAO_NATIVE_APP_KEY');
    }
    if (kakaoJavaScriptAppKey.isEmpty) {
      missing.add('KAKAO_JAVASCRIPT_APP_KEY');
    }
    if (_rawApiBaseUrl.isEmpty) {
      missing.add('API_BASE_URL');
    }

    return missing;
  }

  // 🔧 API 엔드포인트 생성 헬퍼
  static String getApiEndpoint(String path) {
    final cleanPath = path.startsWith('/') ? path.substring(1) : path;
    return '$apiBaseUrl/$cleanPath';
  }

  // 📋 설정 정보 출력 (디버그용)
  static void printConfig() {
    if (debugMode) {
      print('🌿 === 글나무 앱 설정 정보 ===');
      print('앱 환경: $appEnv');
      print('앱 이름: $appName');
      print('앱 버전: $appVersion');
      print('서버 URL: $serverBaseUrl');
      print('API URL: $apiBaseUrl');
      print('웹 도메인: $webDomain');
      print('카카오 Native 키: ${kakaoNativeAppKey.isNotEmpty ? '설정됨' : '❌ 누락'}');
      print('카카오 JS 키: ${kakaoJavaScriptAppKey.isNotEmpty ? '설정됨' : '❌ 누락'}');
      print('리다이렉트 URI: $kakaoRedirectUri');
      print('디버그 모드: $debugMode');
      print('설정 유효성: ${isValidConfig ? '✅' : '❌'}');

      if (!isValidConfig) {
        print('❌ 누락된 설정: ${missingConfigs.join(', ')}');
      }

      print('================================');

      // API 엔드포인트 예시
      if (isValidConfig) {
        print('📡 주요 API 엔드포인트:');
        print('- 카카오 로그인: ${getApiEndpoint('login/oauth/kakao')}');
        print('- 토큰 갱신: ${getApiEndpoint('login/re-issue/accessToken')}');
        print('- 로그아웃: ${getApiEndpoint('login/logout')}');
        print('================================');
      }
    }
  }

  /// 🔧 환경별 설정 확인
  static void validateEnvironment() {
    if (!isValidConfig) {
      throw Exception(
        '필수 환경변수가 누락되었습니다: ${missingConfigs.join(', ')}\n'
        '.env 파일을 확인해주세요!',
      );
    }

    if (isProduction) {
      // 프로덕션 환경 추가 검증
      if (webDomain.contains('localhost')) {
        print('⚠️ 프로덕션 환경에서 localhost 도메인을 사용하고 있습니다!');
      }
      if (debugMode) {
        print('⚠️ 프로덕션 환경에서 디버그 모드가 활성화되어 있습니다!');
      }
    }

    if (debugMode) {
      print('✅ 환경 설정 검증 완료');
    }
  }

  /// 디버그용 - 전체 환경변수 출력 (민감 정보 마스킹)
  static void printAllEnvironmentVariables() {
    if (!debugMode) return;

    print('🔍 === 전체 환경변수 ===');

    dotenv.env.forEach((key, value) {
      // 민감한 정보는 마스킹
      String maskedValue = value;
      if (key.contains('KEY') ||
          key.contains('SECRET') ||
          key.contains('PASSWORD')) {
        maskedValue = value.length > 6
            ? '${value.substring(0, 3)}${'*' * (value.length - 6)}${value.substring(value.length - 3)}'
            : '***';
      }
      print('$key: $maskedValue');
    });

    print('========================');
  }
}
