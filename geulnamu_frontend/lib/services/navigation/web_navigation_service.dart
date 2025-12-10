/// 웹 네비게이션 서비스 (조건부 export)
/// 
/// 웹 환경: web_navigation_service_web.dart 사용
/// 모바일 환경: web_navigation_service_stub.dart 사용
export 'web_navigation_service_stub.dart'
    if (dart.library.html) 'web_navigation_service_web.dart';
