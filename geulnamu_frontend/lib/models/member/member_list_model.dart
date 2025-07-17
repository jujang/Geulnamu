/// 모임원 목록 조회 응답 모델
///
/// 백엔드 API 응답과 매핑되는 모임원 목록 데이터
class MemberListResponse {
  final PagingResponse pagingResponse;
  final List<MemberListItem> memberList;

  const MemberListResponse({
    required this.pagingResponse,
    required this.memberList,
  });

  /// 백엔드 API 응답에서 MemberListResponse 생성
  factory MemberListResponse.fromJson(Map<String, dynamic> json) {
    return MemberListResponse(
      pagingResponse: PagingResponse.fromJson(json['pagingResponse']),
      memberList: (json['memberList'] as List)
          .map((item) => MemberListItem.fromJson(item))
          .toList(),
    );
  }
}

/// 페이지네이션 정보 모델
class PagingResponse {
  final int pageNumber;
  final int totalPages;
  final int totalElements;

  const PagingResponse({
    required this.pageNumber,
    required this.totalPages,
    required this.totalElements,
  });

  factory PagingResponse.fromJson(Map<String, dynamic> json) {
    return PagingResponse(
      pageNumber: json['pageNumber'] as int,
      totalPages: json['totalPages'] as int,
      totalElements: json['totalElements'] as int,
    );
  }

  @override
  String toString() {
    return 'PagingResponse(pageNumber: $pageNumber, totalPages: $totalPages, totalElements: $totalElements)';
  }
}

/// 모임원 목록 아이템 모델
class MemberListItem {
  final int memberId;
  final String? name; // null 허용 - 이름 미입력
  final String? gender; // null 허용 - 성별 미선택
  final String? birthDate; // null 허용 - 생년월일 미입력
  final String nickname;
  final String role;
  final String? deletedAt; // null이면 활성 계정

  const MemberListItem({
    required this.memberId,
    this.name,
    this.gender,
    this.birthDate,
    required this.nickname,
    required this.role,
    this.deletedAt,
  });

  /// 백엔드 API 응답에서 MemberListItem 생성
  factory MemberListItem.fromJson(Map<String, dynamic> json) {
    return MemberListItem(
      memberId: json['memberId'] as int,
      name: json['name'] as String?,
      gender: json['gender'] as String?,
      birthDate: json['birthDate'] as String?,
      nickname: json['nickname'] as String,
      role: json['role'] as String,
      deletedAt: json['deletedAt'] as String?,
    );
  }

  /// 계정이 활성화되어 있는지 확인
  bool get isActive => deletedAt == null;

  /// 성별 한국어 표시
  String get genderDisplayName {
    if (gender == null) return '미선택';

    switch (gender!) {
      case 'MALE':
        return '남성';
      case 'FEMALE':
        return '여성';
      default:
        return '미설정';
    }
  }

  /// 권한 한국어 표시
  String get roleDisplayName {
    switch (role) {
      case 'LEADER':
        return '모임장';
      case 'VICE_LEADER':
        return '부모임장';
      case 'ADMIN':
        return '관리자';
      case 'STAFF':
        return '운영진';
      case 'VICE_STAFF':
        return '준운영진';
      case 'MEMBER':
        return '일반 회원';
      default:
        return '알 수 없음';
    }
  }

  /// 표시용 이름 (빈 값 처리)
  String get displayName {
    if (name == null || name!.trim().isEmpty) {
      return '이름 미입력';
    }
    return name!;
  }

  /// 표시용 생년월일 (간단 형식)
  String get displayBirthDate {
    if (birthDate == null) {
      return '생년월일 미입력';
    }
    
    // 2022-01-01 형식을 22.01.01 형식으로 변경
    try {
      final parts = birthDate!.split('-');
      if (parts.length == 3) {
        final year = parts[0].substring(2); // 2022 -> 22
        final month = parts[1];
        final day = parts[2];
        return '$year.$month.$day';
      }
    } catch (e) {
      // 파싱 실패 시 원본 반환
    }
    return birthDate!;
  }

  /// 권한 레벨 (정렬용)
  int get roleLevel {
    switch (role) {
      case 'LEADER':
        return 6;
      case 'VICE_LEADER':
        return 5;
      case 'ADMIN':
        return 4;
      case 'STAFF':
        return 3;
      case 'VICE_STAFF':
        return 2;
      case 'MEMBER':
        return 1;
      default:
        return 0;
    }
  }

  @override
  String toString() {
    return 'MemberListItem(memberId: $memberId, name: $name, gender: $gender, '
        'birthDate: $birthDate, nickname: $nickname, role: $role, deletedAt: $deletedAt)';
  }
}

/// 모임원 목록 필터 옵션
class MemberListFilter {
  final String? gender; // null이면 전체
  final String? role; // null이면 전체
  final bool? isDeleted; // null이면 전체
  final String sortBy; // 정렬 기준
  final bool isAsc; // 오름차순 여부
  final int page;
  final int size;

  const MemberListFilter({
    this.gender,
    this.role,
    this.isDeleted,
    this.sortBy = 'id', // 기본값: ID순으로 변경
    this.isAsc = false, // 기본값: 내림차순 (높은 ID부터)
    this.page = 1,
    this.size = 10, // 페이지 크기 10명으로 변경
  });

  /// 쿼리 파라미터로 변환
  Map<String, dynamic> toQueryParameters() {
    final params = <String, dynamic>{
      'page': page,
      'size': size,
      'sortBy': sortBy,
      'isAsc': isAsc,
    };

    if (gender != null) {
      params['gender'] = gender;
    }
    if (role != null) {
      params['role'] = role;
    }
    if (isDeleted != null) {
      params['isDeleted'] = isDeleted.toString();
    }

    return params;
  }

  /// 필터 복사 (일부 값 변경)
  MemberListFilter copyWith({
    String? gender,
    String? role,
    bool? isDeleted,
    String? sortBy,
    bool? isAsc,
    int? page,
    int? size,
  }) {
    return MemberListFilter(
      gender: gender ?? this.gender,
      role: role ?? this.role,
      isDeleted: isDeleted ?? this.isDeleted,
      sortBy: sortBy ?? this.sortBy,
      isAsc: isAsc ?? this.isAsc,
      page: page ?? this.page,
      size: size ?? this.size,
    );
  }

  /// 필터 초기화
  MemberListFilter reset() {
    return const MemberListFilter();
  }

  @override
  String toString() {
    return 'MemberListFilter(gender: $gender, role: $role, isDeleted: $isDeleted, '
        'sortBy: $sortBy, isAsc: $isAsc, page: $page, size: $size)';
  }
}

/// 정렬 옵션 열거형
enum SortOption {
  id('id', 'ID 순'),
  role('role', '권한 순'),
  name('name', '이름 순'),
  gender('gender', '성별 순'),
  birthDate('birthDate', '생년월일 순');

  const SortOption(this.value, this.displayName);

  final String value;
  final String displayName;

  static SortOption fromValue(String value) {
    return values.firstWhere(
      (option) => option.value == value,
      orElse: () => SortOption.id, // 기본값을 ID순으로 변경
    );
  }
}

/// 성별 옵션 열거형
enum GenderOption {
  all(null, '전체'),
  male('MALE', '남성'),
  female('FEMALE', '여성');

  const GenderOption(this.value, this.displayName);

  final String? value;
  final String displayName;

  static GenderOption fromValue(String? value) {
    return values.firstWhere(
      (option) => option.value == value,
      orElse: () => GenderOption.all,
    );
  }
}

/// 권한 옵션 열거형
enum RoleOption {
  all(null, '전체'),
  leader('LEADER', '모임장'),
  viceLeader('VICE_LEADER', '부모임장'),
  admin('ADMIN', '관리자'),
  staff('STAFF', '운영진'),
  viceStaff('VICE_STAFF', '준운영진'),
  member('MEMBER', '일반 회원');

  const RoleOption(this.value, this.displayName);

  final String? value;
  final String displayName;

  static RoleOption fromValue(String? value) {
    return values.firstWhere(
      (option) => option.value == value,
      orElse: () => RoleOption.all,
    );
  }

  /// 해당 권한이 항상 활성 계정만 보여야 하는지 확인
  /// 이 옵션은 사용하지 않음 (모든 권한에 대해 계정 상태 선택 가능)
  bool get forceActiveOnly {
    return false; // 모든 권한에 대해 계정 상태 선택 가능도록 수정
  }
}
