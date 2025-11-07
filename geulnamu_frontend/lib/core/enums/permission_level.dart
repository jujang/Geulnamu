/// 글나무 앱의 권한 레벨 정의
///
/// 사용처:
/// - HomeService: 메뉴 접근 제어
/// - AuthService: 사용자 권한 확인
/// - 기타 권한이 필요한 모든 서비스
///
/// 확장 방법:
/// - 새로운 권한 레벨 추가 시 이 enum에 추가
/// - index 순서에 따라 권한 레벨이 결정됨 (낮은 index = 낮은 권한)
enum PermissionLevel {
  /// 비로그인 사용자 - 공개된 기능만 접근 가능
  PUBLIC,

  /// (일반) 모임원 - 로그인 필요, 기본적인 회원 기능 사용 가능
  MEMBER,

  /// 운영진/준운영진 - 모임 관리 등 운영 기능 사용 가능
  STAFF,

  /// 관리자 - 회원 관리 등 최고 권한 기능 사용 가능
  ADMIN,
}

/// PermissionLevel 확장 메서드
extension PermissionLevelExtension on PermissionLevel {
  /// 권한 레벨 이름 (한글)
  String get displayName {
    switch (this) {
      case PermissionLevel.PUBLIC:
        return '비회원';
      case PermissionLevel.MEMBER:
        return '모임원';
      case PermissionLevel.STAFF:
        return '운영진';
      case PermissionLevel.ADMIN:
        return '관리자';
    }
  }

  /// 권한 레벨 설명
  String get description {
    switch (this) {
      case PermissionLevel.PUBLIC:
        return '로그인 없이 이용 가능한 기본 기능';
      case PermissionLevel.MEMBER:
        return '로그인 후 이용 가능한 회원 기능';
      case PermissionLevel.STAFF:
        return '모임 관리 등 운영진 전용 기능';
      case PermissionLevel.ADMIN:
        return '회원 관리 등 관리자 전용 기능';
    }
  }

  /// 특정 권한 레벨 이상인지 확인
  bool hasPermission(PermissionLevel requiredLevel) {
    return index >= requiredLevel.index;
  }
}
