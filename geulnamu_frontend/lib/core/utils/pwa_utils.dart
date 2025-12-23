import 'package:flutter/foundation.dart';
import 'pwa_utils_web.dart' if (dart.library.io) 'pwa_utils_stub.dart'
    as platform;

/// 🎯 PWA 뒤로가기 핸들러 콜백 타입
/// 반환값: true면 뒤로가기 허용 (앱 종료), false면 차단 (현재 화면 유지)
typedef BackPressCallback = Future<bool> Function();

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

  /// 🎯 PWA 히스토리 초기화
  /// PWA 시작 시 브라우저 히스토리가 비어있으면 Flutter PopScope가 동작하지 않음
  /// 더미 히스토리 항목을 추가하여 뒤로가기가 앱 내에서 처리되도록 함
  static void initializePWAHistory() {
    if (!kIsWeb) return;
    platform.initializePWAHistory();
  }

  /// 브라우저 히스토리 길이 확인
  static int getHistoryLength() {
    if (!kIsWeb) return 0;
    return platform.getHistoryLength();
  }

  /// 브라우저 히스토리에 현재 URL 추가 (중복 방지용)
  static void ensureHistoryEntry() {
    if (!kIsWeb) return;
    platform.ensureHistoryEntry();
  }

  /// 🎯 PWA 뒤로가기 핸들러 등록
  ///
  /// PWA 환경에서 시스템 뒤로가기 버튼을 가로채고
  /// 커스텀 동작을 수행할 수 있게 함
  ///
  /// [callback]: 뒤로가기 시 호출될 콜백
  /// - 반환값이 true면 실제로 뒤로가기 수행 (앱 종료)
  /// - 반환값이 false면 뒤로가기 차단 (현재 화면 유지)
  ///
  /// 사용 예시:
  /// ```dart
  /// PWAUtils.registerBackPressHandler(() async {
  ///   final shouldExit = await showDialog<bool>(
  ///     context: context,
  ///     builder: (context) => AlertDialog(
  ///       title: Text('앱 종료'),
  ///       content: Text('앱을 종료하시겠습니까?'),
  ///       actions: [
  ///         TextButton(onPressed: () => Navigator.pop(context, false), child: Text('취소')),
  ///         TextButton(onPressed: () => Navigator.pop(context, true), child: Text('종료')),
  ///       ],
  ///     ),
  ///   );
  ///   return shouldExit ?? false;
  /// });
  /// ```
  static void registerBackPressHandler(BackPressCallback callback) {
    if (!kIsWeb) return;
    platform.registerBackPressHandler(callback);
  }

  /// 🎯 PWA 뒤로가기 핸들러 해제
  ///
  /// 화면을 떠날 때 반드시 호출하여 리스너를 정리해야 함
  /// dispose()에서 호출 권장
  static void unregisterBackPressHandler() {
    if (!kIsWeb) return;
    platform.unregisterBackPressHandler();
  }
}
