/// 출석 ID와 회원 이름 정보 모델
/// 
/// 백엔드 AttendanceIdAndNameResponse에 대응
/// 토론 참여 희망자 명단에서 사용
class AttendanceIdAndNameModel {
  /// 출석 고유번호
  final int attendanceId;
  
  /// 모임원 이름
  final String memberName;

  const AttendanceIdAndNameModel({
    required this.attendanceId,
    required this.memberName,
  });

  /// JSON에서 모델 생성
  factory AttendanceIdAndNameModel.fromJson(Map<String, dynamic> json) {
    return AttendanceIdAndNameModel(
      attendanceId: json['attendanceId'] as int,
      memberName: json['memberName'] as String,
    );
  }

  /// 모델을 JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'attendanceId': attendanceId,
      'memberName': memberName,
    };
  }

  @override
  String toString() {
    return 'AttendanceIdAndNameModel{attendanceId: $attendanceId, memberName: $memberName}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is AttendanceIdAndNameModel &&
      other.attendanceId == attendanceId &&
      other.memberName == memberName;
  }

  @override
  int get hashCode => attendanceId.hashCode ^ memberName.hashCode;
}
