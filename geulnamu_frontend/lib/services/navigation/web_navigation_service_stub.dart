/// 웹 네비게이션 서비스 (모바일용 스텁)
/// 
/// 모바일 환경에서는 아무 동작도 하지 않습니다.
class WebNavigationService {
  WebNavigationService._();
  
  /// Service Worker postMessage 리스너 등록 (모바일: 아무것도 안 함)
  static void registerNavigationCallback(void Function(String url) onNavigate) {
    // 모바일에서는 Service Worker postMessage가 없으므로 무시
    print('💡 [WebNavigationService-Stub] 모바일 환경, 스킵');
  }
}
