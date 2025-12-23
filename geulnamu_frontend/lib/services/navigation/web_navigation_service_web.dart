import 'dart:js_interop';
import 'dart:js_interop_unsafe';

/// 웹 네비게이션 서비스 (웹 전용)
/// 
/// Service Worker의 postMessage를 받아 Flutter 앱에서 처리합니다.
class WebNavigationService {
  WebNavigationService._();
  
  static void Function(String url)? _navigateCallback;
  
  /// Service Worker postMessage 리스너 등록
  /// 
  /// JavaScript의 window.flutterNavigateTo 함수를 등록합니다.
  /// Service Worker에서 NOTIFICATION_CLICK 메시지를 받으면
  /// index.html이 이 함수를 호출합니다.
  static void registerNavigationCallback(void Function(String url) onNavigate) {
    _navigateCallback = onNavigate;
    
    // 🎯 JavaScript window 객체에 함수 등록
    globalContext['flutterNavigateTo'] = ((JSString url) {
      final dartUrl = url.toDart;
      print('📩 [WebNavigationService-Web] JS에서 호출됨: $dartUrl');
      
      if (_navigateCallback != null) {
        _navigateCallback!(dartUrl);
      } else {
        print('⚠️ [WebNavigationService-Web] 콜백이 등록되지 않음');
      }
    }).toJS;
    
    print('✅ [WebNavigationService-Web] window.flutterNavigateTo 함수 등록 완료');
  }
}
