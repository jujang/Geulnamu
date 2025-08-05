import 'attendance_id_and_name_model.dart';

/// 토론 그룹 정보 모델
/// 
/// 백엔드 DiscussionGroupResponse에 대응
/// 모임별 전체 토론 그룹 명단에서 사용
class DiscussionGroupModel {
  /// 토론 그룹에 속한 참여자 목록
  final List<AttendanceIdAndNameModel> members;

  const DiscussionGroupModel({
    required this.members,
  });

  /// JSON에서 모델 생성
  factory DiscussionGroupModel.fromJson(Map<String, dynamic> json) {
    final membersList = json['attendanceIdAndNameResponseList'] as List? ?? [];
    
    return DiscussionGroupModel(
      members: membersList
          .map((memberJson) => AttendanceIdAndNameModel.fromJson(memberJson as Map<String, dynamic>))
          .toList(),
    );
  }

  /// 모델을 JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'attendanceIdAndNameResponseList': members.map((member) => member.toJson()).toList(),
    };
  }

  /// 그룹이 비었는지 확인
  bool get isEmpty => members.isEmpty;

  /// 그룹 멤버 수
  int get memberCount => members.length;

  /// 멤버 이름들을 쉼표로 구분된 문자열로 반환
  String get memberNamesString {
    if (members.isEmpty) return '참여자 없음';
    return members.map((member) => member.memberName).join(', ');
  }

  @override
  String toString() {
    return 'DiscussionGroupModel{memberCount: $memberCount, members: [${memberNamesString}]}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is DiscussionGroupModel &&
      other.members.length == members.length &&
      _listEquals(other.members, members);
  }

  @override
  int get hashCode => members.hashCode;

  /// 리스트 동등성 비교 헬퍼 메서드
  bool _listEquals<T>(List<T> a, List<T> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}

/// 모든 토론 그룹들을 담는 응답 모델
class DiscussionGroupListResponse {
  /// 토론 그룹들의 목록
  final List<DiscussionGroupModel> groups;

  const DiscussionGroupListResponse({
    required this.groups,
  });

  /// JSON에서 모델 생성
  factory DiscussionGroupListResponse.fromJson(List<dynamic> jsonList) {
    return DiscussionGroupListResponse(
      groups: jsonList
          .map((groupJson) => DiscussionGroupModel.fromJson(groupJson as Map<String, dynamic>))
          .toList(),
    );
  }

  /// 모델을 JSON으로 변환
  List<Map<String, dynamic>> toJson() {
    return groups.map((group) => group.toJson()).toList();
  }

  /// 전체 토론 그룹 수
  int get groupCount => groups.length;

  /// 전체 참여자 수
  int get totalMemberCount => groups.fold(0, (sum, group) => sum + group.memberCount);

  /// 빈 그룹이 있는지 확인
  bool get hasEmptyGroups => groups.any((group) => group.isEmpty);

  @override
  String toString() {
    return 'DiscussionGroupListResponse{groupCount: $groupCount, totalMembers: $totalMemberCount}';
  }
}
