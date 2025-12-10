import 'dart:async';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';
import 'package:flutter/foundation.dart';
import 'package:web/web.dart' as web;

/// 🎯 PWA 뒤로가기 핸들러 콜백 타입
/// 반환값: true면 뒤로가기 허용, false면 차단
typedef BackPressCallback = Future<bool> Function();

/// 현재 등록된 뒤로가기 핸들러
BackPressCallback? _backPressCallback;

/// popstate 이벤트 리스너 참조 (해제용)
JSFunction? _popStateListener;

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
    // JavaScript의 navigator.standalone 속성 접근 (dart:js_interop_unsafe 방식)
    final navigator = web.window.navigator as JSObject;
    final standaloneValue = navigator['standalone'];
    if (standaloneValue.isA<JSBoolean>()) {
      return (standaloneValue as JSBoolean).toDart;
    }
    return false;
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

/// 🎯 PWA 뒤로가기 핸들러 등록
/// 
/// [callback]: 뒤로가기 시 호출될 콜백
/// - 반환값이 true면 실제로 뒤로가기 수행
/// - 반환값이 false면 뒤로가기 차단 (현재 화면 유지)
void registerBackPressHandler(BackPressCallback callback) {
  // PWA가 아니면 등록하지 않음
  if (!isInstalledPWA()) {
    if (kDebugMode) {
      print('🎯 [PWAUtils] PWA가 아니므로 뒤로가기 핸들러 등록 스킵');
    }
    return;
  }

  // 기존 리스너가 있으면 먼저 해제
  unregisterBackPressHandler();

  _backPressCallback = callback;

  // popstate 이벤트 리스너 생성
  _popStateListener = (web.Event event) {
    _handlePopState(event);
  }.toJS;

  // 이벤트 리스너 등록
  web.window.addEventListener('popstate', _popStateListener);

  // 히스토리에 더미 항목 추가 (뒤로가기 감지용)
  _ensureHistoryForBackPress();

  if (kDebugMode) {
    print('🎯 [PWAUtils] PWA 뒤로가기 핸들러 등록 완료');
  }
}

/// 🎯 PWA 뒤로가기 핸들러 해제
void unregisterBackPressHandler() {
  if (_popStateListener != null) {
    web.window.removeEventListener('popstate', _popStateListener);
    _popStateListener = null;
    if (kDebugMode) {
      print('🎯 [PWAUtils] PWA 뒤로가기 핸들러 해제 완료');
    }
  }
  _backPressCallback = null;
}

/// 🎯 popstate 이벤트 핸들러
void _handlePopState(web.Event event) async {
  if (_backPressCallback == null) return;

  if (kDebugMode) {
    print('🎯 [PWAUtils] popstate 이벤트 감지');
  }

  try {
    // 콜백 호출하여 뒤로가기 허용 여부 확인
    final shouldExit = await _backPressCallback!();

    if (shouldExit) {
      // 뒤로가기 허용 - 핸들러 해제 후 실제 뒤로가기 수행
      if (kDebugMode) {
        print('🎯 [PWAUtils] 뒤로가기 허용 - 앱 종료');
      }
      unregisterBackPressHandler();
      web.window.history.back();
    } else {
      // 뒤로가기 차단 - 히스토리 복구
      if (kDebugMode) {
        print('🎯 [PWAUtils] 뒤로가기 차단 - 히스토리 복구');
      }
      _ensureHistoryForBackPress();
    }
  } catch (e) {
    if (kDebugMode) {
      print('⚠️ [PWAUtils] 뒤로가기 핸들러 오류: $e');
    }
    // 오류 시 히스토리 복구
    _ensureHistoryForBackPress();
  }
}

/// 🎯 뒤로가기 감지를 위한 히스토리 항목 확보
void _ensureHistoryForBackPress() {
  try {
    // 현재 URL로 히스토리 항목 추가
    web.window.history.pushState(null, '', web.window.location.href);
    if (kDebugMode) {
      print('🎯 [PWAUtils] 뒤로가기 감지용 히스토리 추가 (length: ${web.window.history.length})');
    }
  } catch (e) {
    if (kDebugMode) {
      print('⚠️ [PWAUtils] 히스토리 추가 실패: $e');
    }
  }
}
