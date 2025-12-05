import 'dart:js_util' as js_util;
import 'package:flutter/foundation.dart';
import 'package:web/web.dart' as web;

/// PWA 설치 상태 확인 (웹 전용 구현)
bool isInstalledPWA() {
  try {
    // 1. display-mode: standalone 체크 (Android Chrome, Desktop PWA)
    final standaloneQuery = web.window.matchMedia('(display-mode: standalone)');
    if (standaloneQuery.matches) return true;

    // 2. display-mode: fullscreen 체크
    final fullscreenQuery = web.window.matchMedia('(display-mode: fullscreen)');
    if (fullscreenQuery.matches) return true;

    // 3. iOS Safari standalone 모드 체크
    if (_isIOSStandalone()) return true;

    return false;
  } catch (e) {
    if (kDebugMode) {
      print('⚠️ [PWAUtils] PWA 상태 감지 실패: $e');
    }
    return false;
  }
}

/// iOS Safari의 standalone 속성 확인
bool _isIOSStandalone() {
  try {
    // JavaScript의 navigator.standalone 속성 접근
    final navigator = web.window.navigator;
    final standalone = js_util.getProperty<bool?>(navigator, 'standalone');
    return standalone ?? false;
  } catch (e) {
    return false;
  }
}
