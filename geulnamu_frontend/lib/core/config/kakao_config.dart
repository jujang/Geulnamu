import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'app_config.dart';

/// 🥕 카카오 SDK 설정 클래스
/// 카카오 로그인 관련 설정을 담당합니다.
class KakaoConfig {
  
  /// 카카오 SDK 초기화
  static void initialize() {
    // 환경변수에서 키 읽어오기
    final nativeAppKey = AppConfig.kakaoNativeAppKey;
    final javaScriptAppKey = AppConfig.kakaoJavaScriptAppKey;
    
    // 유효성 검사
    if (nativeAppKey.isEmpty || javaScriptAppKey.isEmpty) {
      throw Exception('❌ 카카오 앱 키가 설정되지 않았습니다. .env 파일을 확인해주세요.');
    }
    
    // 카카오 SDK 초기화
    KakaoSdk.init(
      nativeAppKey: nativeAppKey,
      javaScriptAppKey: javaScriptAppKey,
    );
    
    // 디버그 정보 출력
    if (AppConfig.debugMode) {
      print('🥕 카카오 SDK 초기화 완료');
      print('Native App Key: ${_maskKey(nativeAppKey)}');
      print('JavaScript App Key: ${_maskKey(javaScriptAppKey)}');
    }
  }
  
  /// 키 마스킹 (보안을 위해 앞 4자리만 표시)
  static String _maskKey(String key) {
    if (key.length <= 8) return '****';
    return '${key.substring(0, 4)}${'*' * (key.length - 8)}${key.substring(key.length - 4)}';
  }
  
  /// 카카오 설정 유효성 검사
  static bool get isValidConfig {
    return AppConfig.kakaoNativeAppKey.isNotEmpty && 
           AppConfig.kakaoJavaScriptAppKey.isNotEmpty;
  }
  
  /// 리다이렉트 URI 가져오기
  static String get redirectUri => AppConfig.kakaoRedirectUri;
  
  /// 카카오 로그인 스키마 (딥링크용)
  static String get kakaoScheme => 'kakao${AppConfig.kakaoNativeAppKey}';
}