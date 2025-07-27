/// 운영진용 모임 상세 정보 모델
/// 
/// 백엔드 MeetingDetailResponseForStaff에 대응
class MeetingDetailStaffInfo {
  // 모임 관련
  final int meetingId;
  final String meetingCreatorName;
  final int meetingCreatorId;
  final String meetingType;
  final String meetingName;
  final DateTime meetingDateTime;
  final DateTime lateThresholdTime;
  final String meetingPlace;
  final String description;
  final DateTime createdAt;

  // 모임 관련 - 특수
  final bool isPrivateMeeting;

  // 토론 관련
  final DateTime discussionTime;
  final String alarmMessage;

  const MeetingDetailStaffInfo({
    required this.meetingId,
    required this.meetingCreatorName,
    required this.meetingCreatorId,
    required this.meetingType,
    required this.meetingName,
    required this.meetingDateTime,
    required this.lateThresholdTime,
    required this.meetingPlace,
    required this.description,
    required this.createdAt,
    required this.isPrivateMeeting,
    required this.discussionTime,
    required this.alarmMessage,
  });

  factory MeetingDetailStaffInfo.fromJson(Map<String, dynamic> json) {
    return MeetingDetailStaffInfo(
      meetingId: json['meetingId'] as int,
      meetingCreatorName: json['meetingCreatorName'] as String,
      meetingCreatorId: json['meetingCreatorId'] as int,
      meetingType: json['meetingType'] as String,
      meetingName: json['meetingName'] as String,
      meetingDateTime: DateTime.parse(json['meetingDateTime'] as String),
      lateThresholdTime: DateTime.parse(json['lateThresholdTime'] as String),
      meetingPlace: json['meetingPlace'] as String,
      description: json['description'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      isPrivateMeeting: json['isPrivateMeeting'] as bool,
      discussionTime: DateTime.parse(json['discussionTime'] as String),
      alarmMessage: json['alarmMessage'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'meetingId': meetingId,
      'meetingCreatorName': meetingCreatorName,
      'meetingCreatorId': meetingCreatorId,
      'meetingType': meetingType,
      'meetingName': meetingName,
      'meetingDateTime': meetingDateTime.toIso8601String(),
      'lateThresholdTime': lateThresholdTime.toIso8601String(),
      'meetingPlace': meetingPlace,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
      'isPrivateMeeting': isPrivateMeeting,
      'discussionTime': discussionTime.toIso8601String(),
      'alarmMessage': alarmMessage,
    };
  }

  @override
  String toString() {
    return 'MeetingDetailStaffInfo{meetingId: $meetingId, meetingName: $meetingName, meetingType: $meetingType, isPrivate: $isPrivateMeeting}';
  }
}
