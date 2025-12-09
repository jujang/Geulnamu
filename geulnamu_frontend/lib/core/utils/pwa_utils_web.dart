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

/// 🎯 PWA 히스토리 초기화
/// PWA 시작 시 브라우저 히스토리가 비어있으면 Flutter PopScope가 동작하지 않음
/// 더미 히스토리 항목을 추가하여 뒤로가기가 앱 내에서 처리되도록 함
void initializePWAHistory() {
  try {
    // PWA가 아니면 실행하지 않음
    if (!isInstalledPWA()) return;
    
    final history = web.window.history;
    
    // 현재 히스토리 길이 확인
    if (history.length <= 1) {
      // 더미 히스토리 항목 추가 (현재 URL 유지)
      history.pushState(null, '', web.window.location.href);
      
      if (kDebugMode) {
        print('🎯 [PWAUtils] PWA 히스토리 초기화 완료 (length: ${history.length})');
      }
    }
  } catch (e) {
    if (kDebugMode) {
      print('⚠️ [PWAUtils] PWA 히스토리 초기화 실패: $e');
    }
  }
}

/// 🎯 브라우저 히스토리 길이 확인
int getHistoryLength() {
  try {
    return web.window.history.length;
  } catch (e) {
    return 0;
  }
}

/// 🎯 브라우저 히스토리에 현재 URL 추가 (중복 방지용)
void ensureHistoryEntry() {
  try {
    final history = web.window.history;
    // 히스토리가 너무 짧으면 추가
    if (history.length <= 2) {
      history.pushState(null, '', web.window.location.href);
      if (kDebugMode) {
        print('🎯 [PWAUtils] 히스토리 항목 추가됨');
      }
    }
  } catch (e) {
    if (kDebugMode) {
      print('⚠️ [PWAUtils] 히스토리 항목 추가 실패: $e');
    }
  }
}
