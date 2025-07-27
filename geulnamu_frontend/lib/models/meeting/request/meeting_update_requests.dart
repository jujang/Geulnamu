/// 모임 기본 정보 수정 요청 모델
/// 
/// API: PATCH /meetings/{meetingId}/basic
class MeetingBasicUpdateRequest {
  final String meetingType;
  final String meetingName;
  final DateTime meetingDate;      // 백엔드에서는 meetingDate
  final DateTime lateThresholdTime;
  final String meetingPlace;
  final String? description;

  const MeetingBasicUpdateRequest({
    required this.meetingType,
    required this.meetingName,
    required this.meetingDate,     // meetingDateTime → meetingDate
    required this.lateThresholdTime,
    required this.meetingPlace,
    this.description,
  });

  Map<String, dynamic> toJson() {
    return {
      'meetingType': meetingType,
      'meetingName': meetingName,
      'meetingDate': _formatDateTimeForBackend(meetingDate),      // 백엔드 형식으로 변환
      'lateThresholdTime': _formatDateTimeForBackend(lateThresholdTime), // 백엔드 형식으로 변환
      'meetingPlace': meetingPlace,
      'description': description,
    };
  }

  /// 백엔드 요구 형식으로 날짜 변환: "yyyyMMdd HH:mm"
  static String _formatDateTimeForBackend(DateTime dateTime) {
    return '${dateTime.year.toString().padLeft(4, '0')}'
           '${dateTime.month.toString().padLeft(2, '0')}'
           '${dateTime.day.toString().padLeft(2, '0')} '
           '${dateTime.hour.toString().padLeft(2, '0')}:'
           '${dateTime.minute.toString().padLeft(2, '0')}';
  }

  @override
  String toString() {
    return 'MeetingBasicUpdateRequest{meetingName: $meetingName, meetingType: $meetingType, meetingPlace: $meetingPlace}';
  }
}

/// 토론 정보 수정 요청 모델
/// 
/// API: PATCH /meetings/{meetingId}/discussion
class MeetingDiscussionUpdateRequest {
  final DateTime discussionTime;
  final String? alarmMessage;  // null 가능

  const MeetingDiscussionUpdateRequest({
    required this.discussionTime,
    this.alarmMessage,  // nullable로 변경
  });

  Map<String, dynamic> toJson() {
    return {
      'discussionTime': _formatDateTimeForBackend(discussionTime), // 백엔드 형식으로 변환
      'alarmMessage': alarmMessage,
    };
  }

  /// 백엔드 요구 형식으로 날짜 변환: "yyyyMMdd HH:mm"
  static String _formatDateTimeForBackend(DateTime dateTime) {
    return '${dateTime.year.toString().padLeft(4, '0')}'
           '${dateTime.month.toString().padLeft(2, '0')}'
           '${dateTime.day.toString().padLeft(2, '0')} '
           '${dateTime.hour.toString().padLeft(2, '0')}:'
           '${dateTime.minute.toString().padLeft(2, '0')}';
  }

  @override
  String toString() {
    return 'MeetingDiscussionUpdateRequest{discussionTime: $discussionTime, alarmMessage: $alarmMessage}';
  }
}
