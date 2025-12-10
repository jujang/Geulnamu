import 'dart:async';
import 'dart:js_interop';

/// 웹 캐시 유틸리티 (웹 전용)
/// 
/// Service Worker에 메시지를 보내 캐시를 삭제합니다.
class WebCacheUtils {
  WebCacheUtils._();
  
  /// API 캐시만 삭제 (사용자 데이터)
  static Future<bool> clearUserCache() async {
    try {
      print('🧹 [WebCacheUtils-Web] clearUserCache 호출...');
      final result = await _jsClearUserCache().toDart;
      final success = result?.dartify() as bool? ?? false;
      print('✅ [WebCacheUtils-Web] clearUserCache 결과: $success');
      return success;
    } catch (e) {
      print('❌ [WebCacheUtils-Web] clearUserCache 실패: $e');
      return false;
    }
  }
  
  /// 모든 캐시 삭제 (정적 + API)
  static Future<bool> clearAllCache() async {
    try {
      print('🧹 [WebCacheUtils-Web] clearAllCache 호출...');
      final result = await _jsClearAllCache().toDart;
      final success = result?.dartify() as bool? ?? false;
      print('✅ [WebCacheUtils-Web] clearAllCache 결과: $success');
      return success;
    } catch (e) {
      print('❌ [WebCacheUtils-Web] clearAllCache 실패: $e');
      return false;
    }
  }
}

// ===========================================
// JavaScript 함수 바인딩
// ===========================================

@JS('clearUserCache')
external JSPromise<JSAny?> _jsClearUserCache();

@JS('clearAllCache')
external JSPromise<JSAny?> _jsClearAllCache();
