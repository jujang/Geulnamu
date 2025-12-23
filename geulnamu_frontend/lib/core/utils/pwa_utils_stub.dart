/// PWA Utils Stub for non-web platforms
///
/// 이 파일은 네이티브 플랫폼(iOS, Android)에서 빌드 시 사용됩니다.
/// 웹 전용 기능을 대체하는 빈 구현입니다.

/// 🎯 PWA 뒤로가기 핸들러 콜백 타입 (스텁)
typedef BackPressCallback = Future<bool> Function();

/// PWA 설치 상태 확인 (네이티브에서는 항상 false)
bool isInstalledPWA() => false;

/// PWA 히스토리 초기화 (네이티브에서는 아무 동작 안 함)
void initializePWAHistory() {}

/// 브라우저 히스토리 길이 확인 (네이티브에서는 항상 0)
int getHistoryLength() => 0;

/// 브라우저 히스토리에 현재 URL 추가 (네이티브에서는 아무 동작 안 함)
void ensureHistoryEntry() {}

/// 🎯 PWA 뒤로가기 핸들러 등록 (네이티브에서는 아무 동작 안 함)
void registerBackPressHandler(BackPressCallback callback) {}

/// 🎯 PWA 뒤로가기 핸들러 해제 (네이티브에서는 아무 동작 안 함)
void unregisterBackPressHandler() {}
