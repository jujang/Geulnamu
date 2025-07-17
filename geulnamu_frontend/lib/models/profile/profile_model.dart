/// 프로필 데이터 모델
///
/// 백엔드 API 응답과 매핑되는 사용자 프로필 정보
/// 개인정보 미입력 시 name, gender, birthDate가 모두 null일 수 있음
class ProfileModel {
  final int memberId;
  final String? name; // null 허용 - 이름 미입력
  final String? gender; // null 허용 - 성별 미선택
  final String? birthDate; // null 허용 - 생년월일 미입력
  final String nickname;
  final String role;
  final String? deletedAt;

  const ProfileModel({
    required this.memberId,
    this.name, // nullable
    this.gender, // nullable
    this.birthDate, // nullable
    required this.nickname,
    required this.role,
    this.deletedAt,
  });

  /// 백엔드 API 응답에서 ProfileModel 생성
  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      memberId: json['memberId'] as int,
      name: json['name'] as String?, // null 허용
      gender: json['gender'] as String?, // null 허용
      birthDate: json['birthDate'] as String?, // null 허용
      nickname: json['nickname'] as String,
      role: json['role'] as String,
      deletedAt: json['deletedAt'] as String?,
    );
  }

  /// 수정용 JSON 변환 (이름, 성별, 생년월일만)
  Map<String, dynamic> toUpdateJson() {
    return {
      'name': name ?? '', // null인 경우 빈 문자열
      'gender': gender ?? 'MALE', // null인 경우 기본값 'MALE'
      'birthDate': birthDate ?? '19970101', // null인 경우 기본값 (1997년 1월 1일)
    };
  }

  /// 디버깅용 문자열 표현
  @override
  String toString() {
    return 'ProfileModel(memberId: $memberId, name: $name, gender: $gender, '
        'birthDate: $birthDate, nickname: $nickname, role: $role, deletedAt: $deletedAt)';
  }

  /// 수정 가능한 필드만으로 새 인스턴스 생성
  ProfileModel copyWithUpdates({
    String? name,
    String? gender,
    String? birthDate,
  }) {
    return ProfileModel(
      memberId: memberId,
      name: name ?? this.name,
      gender: gender ?? this.gender,
      birthDate: birthDate ?? this.birthDate,
      nickname: nickname, // 수정 불가
      role: role, // 수정 불가
      deletedAt: deletedAt,
    );
  }

  /// 계정이 활성화되어 있는지 확인
  bool get isActive => deletedAt == null;

  /// 성별 한국어 표시
  String get genderDisplayName {
    if (gender == null) return '미선택'; // null 처리

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

  /// 표시용 생년월일 (빈 값 처리)
  String get displayBirthDate {
    if (birthDate == null) {
      return '생년월일 미입력';
    }
    return birthDate!;
  }

  /// 프로필 완성도 확인
  bool get isProfileComplete {
    return name != null &&
        name!.trim().isNotEmpty &&
        gender != null &&
        birthDate != null;
  }

  /// 각 필드별 입력 상태 확인
  bool get hasName => name != null && name!.trim().isNotEmpty;
  bool get hasGender => gender != null;
  bool get hasBirthDate => birthDate != null;
}
