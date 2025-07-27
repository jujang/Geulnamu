/// 모임 기본 정보 수정 요청 모델
/// 
/// API: PATCH /meetings/{meetingId}/basic
class MeetingBasicUpdateRequest {
  final String meetingCreatorName;
  final String meetingType;
  final String meetingName;
  final DateTime meetingDateTime;
  final DateTime lateThresholdTime;
  final String meetingPlace;
  final String description;

  const MeetingBasicUpdateRequest({
    required this.meetingCreatorName,
    required this.meetingType,
    required this.meetingName,
    required this.meetingDateTime,
    required this.lateThresholdTime,
    required this.meetingPlace,
    required this.description,
  });

  Map<String, dynamic> toJson() {
    return {
      'meetingCreatorName': meetingCreatorName,
      'meetingType': meetingType,
      'meetingName': meetingName,
      'meetingDateTime': meetingDateTime.toIso8601String(),
      'lateThresholdTime': lateThresholdTime.toIso8601String(),
      'meetingPlace': meetingPlace,
      'description': description,
    };
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
  final String alarmMessage;

  const MeetingDiscussionUpdateRequest({
    required this.discussionTime,
    required this.alarmMessage,
  });

  Map<String, dynamic> toJson() {
    return {
      'discussionTime': discussionTime.toIso8601String(),
      'alarmMessage': alarmMessage,
    };
  }

  @override
  String toString() {
    return 'MeetingDiscussionUpdateRequest{discussionTime: $discussionTime, alarmMessage: $alarmMessage}';
  }
}
