import 'dart:async';

/// 웹 캐시 유틸리티 (모바일용 스텁)
/// 
/// 모바일 환경에서는 Service Worker가 없으므로
/// 항상 성공을 반환합니다.
class WebCacheUtils {
  WebCacheUtils._();
  
  /// API 캐시만 삭제 (모바일: 항상 성공)
  static Future<bool> clearUserCache() async {
    print('💡 [WebCacheUtils-Stub] 모바일 환경, 스킵');
    return true;
  }
  
  /// 모든 캐시 삭제 (모바일: 항상 성공)
  static Future<bool> clearAllCache() async {
    print('💡 [WebCacheUtils-Stub] 모바일 환경, 스킵');
    return true;
  }
}
