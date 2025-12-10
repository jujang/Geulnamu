/// 웹 캐시 유틸리티 (조건부 export)
/// 
/// 웹 환경: web_cache_utils_web.dart 사용
/// 모바일 환경: web_cache_utils_stub.dart 사용
export 'web_cache_utils_stub.dart'
    if (dart.library.html) 'web_cache_utils_web.dart';
