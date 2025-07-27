/// 토론 조 구성원 모델
/// 
/// 백엔드 MemberIdAndNameResponse와 매핑
class GroupMember {
  final int memberId;
  final String memberName;

  const GroupMember({
    required this.memberId,
    required this.memberName,
  });

  /// JSON에서 객체 생성
  factory GroupMember.fromJson(Map<String, dynamic> json) {
    return GroupMember(
      memberId: json['memberId'] as int,
      memberName: json['memberName'] as String,
    );
  }

  /// 객체를 JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'memberId': memberId,
      'memberName': memberName,
    };
  }

  @override
  String toString() {
    return 'GroupMember{memberId: $memberId, memberName: $memberName}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GroupMember &&
          runtimeType == other.runtimeType &&
          memberId == other.memberId &&
          memberName == other.memberName;

  @override
  int get hashCode => memberId.hashCode ^ memberName.hashCode;
}
