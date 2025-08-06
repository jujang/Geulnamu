/// 토론 그룹 수동 구성 요청 모델
/// 
/// 백엔드 AssignDiscussionGroupsRequest에 대응
/// 전체 그룹 구성을 한 번에 설정할 때 사용
class AssignDiscussionGroupsRequest {
  /// 토론 그룹들의 목록
  final List<DiscussionGroupRequest> groups;

  const AssignDiscussionGroupsRequest({
    required this.groups,
  });

  /// JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'groups': groups.map((group) => group.toJson()).toList(),
    };
  }

  @override
  String toString() {
    return 'AssignDiscussionGroupsRequest{groups: $groups}';
  }
}

/// 개별 토론 그룹 요청 모델
/// 
/// 백엔드 DiscussionGroupRequest에 대응
class DiscussionGroupRequest {
  /// 해당 그룹에 속할 출석 ID 목록
  final List<int> attendanceIdList;

  const DiscussionGroupRequest({
    required this.attendanceIdList,
  });

  /// JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'attendanceIdList': attendanceIdList,
    };
  }

  /// 그룹이 비었는지 확인
  bool get isEmpty => attendanceIdList.isEmpty;

  /// 그룹 멤버 수
  int get memberCount => attendanceIdList.length;

  @override
  String toString() {
    return 'DiscussionGroupRequest{memberCount: $memberCount, attendanceIds: $attendanceIdList}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is DiscussionGroupRequest &&
      other.attendanceIdList.length == attendanceIdList.length &&
      _listEquals(other.attendanceIdList, attendanceIdList);
  }

  @override
  int get hashCode => attendanceIdList.hashCode;

  /// 리스트 동등성 비교 헬퍼 메서드
  bool _listEquals<T>(List<T> a, List<T> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
