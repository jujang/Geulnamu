import 'package:flutter/foundation.dart';
import 'pwa_utils_web.dart' if (dart.library.io) 'pwa_utils_stub.dart'
    as platform;

/// PWA 관련 유틸리티 클래스
///
/// PWA 설치 상태 감지 및 관련 기능 제공
/// 웹 환경에서만 동작하며, 네이티브 환경에서는 기본값 반환
class PWAUtils {
  PWAUtils._();

  /// PWA로 설치되어 실행 중인지 확인
  ///
  /// 다음 조건 중 하나라도 만족하면 true:
  /// - display-mode: standalone (Android Chrome, Desktop)
  /// - display-mode: fullscreen
  /// - iOS Safari의 standalone 모드
  static bool isInstalledPWA() {
    if (!kIsWeb) return false;
    return platform.isInstalledPWA();
  }

  /// 브라우저에서 실행 중인지 확인 (PWA 설치 안 된 상태)
  static bool isRunningInBrowser() {
    if (!kIsWeb) return false;
    return !isInstalledPWA();
  }

  /// PWA 설치 가능한 환경인지 확인
  /// (웹이면서 아직 설치되지 않은 상태)
  static bool canShowInstallPrompt() {
    return kIsWeb && !isInstalledPWA();
  }
}
