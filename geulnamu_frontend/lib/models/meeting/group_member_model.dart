/// 토론 조 구성원 모델
/// 
/// 백엔드 응답 구조에 맞게 수정: attendanceId + memberName
class GroupMember {
  final int attendanceId; // 🆕 memberId → attendanceId 변경
  final String memberName;

  const GroupMember({
    required this.attendanceId, // 🆕 변경된 필드
    required this.memberName,
  });

  /// JSON에서 객체 생성
  factory GroupMember.fromJson(Map<String, dynamic> json) {
    return GroupMember(
      attendanceId: json['attendanceId'] as int, // 🆕 백엔드 응답 필드와 매핑
      memberName: json['memberName'] as String,
    );
  }

  /// 객체를 JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'attendanceId': attendanceId, // 🆕 변경된 필드
      'memberName': memberName,
    };
  }

  @override
  String toString() {
    return 'GroupMember{attendanceId: $attendanceId, memberName: $memberName}'; // 🆕 출력 필드 변경
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GroupMember &&
          runtimeType == other.runtimeType &&
          attendanceId == other.attendanceId && // 🆕 비교 필드 변경
          memberName == other.memberName;

  @override
  int get hashCode => attendanceId.hashCode ^ memberName.hashCode; // 🆕 해시 필드 변경
}
