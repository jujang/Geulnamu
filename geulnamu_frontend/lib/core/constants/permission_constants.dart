import '../enums/permission_level.dart';

/// 글나무 앱의 권한 관련 상수들을 중앙 관리
///
/// 포함 내용:
/// - 개인정보 입력 예외 기능 목록
/// - 메뉴별 권한 레벨 매핑
/// - 백엔드 role과 PermissionLevel 매핑
///
/// 사용법:
/// ```dart
/// final requiredLevel = PermissionConstants.menuPermissions['오늘의 모임'];
/// final isExempt = PermissionConstants.profileExemptMenus.contains('프로필');
/// ```
class PermissionConstants {
  // 🔒 개인정보 입력 없이도 접근 가능한 기능들 (예외 리스트)
  ///
  /// 이 리스트에 포함된 기능들은 로그인은 되어 있지만
  /// 개인정보를 아직 입력하지 않은 상태에서도 접근 가능
  static const Set<String> profileExemptMenus = {
    '개인정보 입력하기', // 당연히 접근 가능해야 함
    '글나무 소개', // 공개 정보이므로 접근 가능
    '프로필', // 본인 정보 확인을 위해 접근 가능
    '설정', // 앱 설정을 위해 접근 가능
    '로그아웃', // 언제든 로그아웃 가능해야 함
  };

  // 📋 메뉴별 권한 레벨 매핑
  ///
  /// 각 메뉴/기능에 필요한 최소 권한 레벨을 정의
  /// 정의되지 않은 기능은 기본적으로 MEMBER 권한 필요
  static const Map<String, PermissionLevel> menuPermissions = {
    // PUBLIC: 누구나 접근 가능 (비로그인 포함)
    '글나무 소개': PermissionLevel.PUBLIC,

    // MEMBER: 로그인 필요 (개인정보 입력 여부는 별도 체크)
    '개인정보 입력하기': PermissionLevel.MEMBER,
    '프로필': PermissionLevel.MEMBER,
    '설정': PermissionLevel.MEMBER,
    '로그아웃': PermissionLevel.MEMBER,
    '모임 목록': PermissionLevel.MEMBER, // 🆕 일반 모임 목록
    '오늘의 모임': PermissionLevel.MEMBER,
    '출석 체크': PermissionLevel.MEMBER,
    '발제 작성': PermissionLevel.MEMBER,
    '발제문 목록': PermissionLevel.MEMBER, // 🆕 발제문 목록
    '모임 참여': PermissionLevel.MEMBER,
    '개인 대시보드': PermissionLevel.MEMBER,

    // STAFF: 운영진 이상 (모임 관리 관련)
    '모임원 목록': PermissionLevel.STAFF, // 🆕 모임원 목록
    '모임 목록 (운영진용)': PermissionLevel.STAFF, // 🆕 운영진용 모임 목록
    '모임 만들기': PermissionLevel.STAFF, // 🔥 STAFF로 변경
    '모임 관리': PermissionLevel.STAFF,
    '모임 수정': PermissionLevel.STAFF,
    '모임 삭제': PermissionLevel.STAFF,
    '출석 관리': PermissionLevel.STAFF,
    '발제 관리': PermissionLevel.STAFF,
    '공지사항 작성': PermissionLevel.STAFF,

    // ADMIN: 관리자만 (시스템 관리 관련)
    '회원 관리': PermissionLevel.ADMIN,
    '권한 관리': PermissionLevel.ADMIN,
    '시스템 설정': PermissionLevel.ADMIN,
    '통계 조회': PermissionLevel.ADMIN,
    '로그 조회': PermissionLevel.ADMIN,
  };

  // 🔄 백엔드 role과 PermissionLevel 매핑
  ///
  /// 백엔드에서 받은 role 문자열을 PermissionLevel로 변환
  static const Map<String, PermissionLevel> roleToPermissionLevel = {
    'GUEST': PermissionLevel.PUBLIC, // 비회원
    'MEMBER': PermissionLevel.MEMBER, // 모임원
    'VICE_STAFF': PermissionLevel.STAFF, // 준운영진 → STAFF
    'STAFF': PermissionLevel.STAFF, // 운영진 → STAFF
    'VICE_LEADER': PermissionLevel.ADMIN, // 부모임장 → ADMIN ✅
    'LEADER': PermissionLevel.ADMIN, // 모임장 → ADMIN ✅
    'ADMIN': PermissionLevel.ADMIN, // 관리자 → ADMIN ✅
  };

  // 🎯 편의 메서드들

  /// 특정 메뉴의 필요 권한 레벨 조회
  static PermissionLevel getRequiredPermissionLevel(String menuTitle) {
    return menuPermissions[menuTitle] ?? PermissionLevel.MEMBER;
  }

  /// 개인정보 입력 예외 메뉴인지 확인
  static bool isProfileExemptMenu(String menuTitle) {
    return profileExemptMenus.contains(menuTitle);
  }

  /// 백엔드 role을 PermissionLevel로 변환
  static PermissionLevel convertRoleToPermissionLevel(String? role) {
    if (role == null) return PermissionLevel.PUBLIC;
    return roleToPermissionLevel[role.toUpperCase()] ?? PermissionLevel.MEMBER;
  }

  /// 모든 권한 레벨 목록 (디버깅/설정 화면용)
  static List<PermissionLevel> get allPermissionLevels =>
      PermissionLevel.values;

  /// 특정 권한 레벨에 해당하는 메뉴들 조회 (디버깅용)
  static List<String> getMenusByPermissionLevel(PermissionLevel level) {
    return menuPermissions.entries
        .where((entry) => entry.value == level)
        .map((entry) => entry.key)
        .toList();
  }
}
