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
  final String? description;  // null 가능
  final DateTime createdAt;

  // 모임 관련 - 특수
  final bool isPrivateMeeting;

  // 토론 관련
  final DateTime? discussionTime;  // null 가능
  final String? alarmMessage;      // null 가능

  const MeetingDetailStaffInfo({
    required this.meetingId,
    required this.meetingCreatorName,
    required this.meetingCreatorId,
    required this.meetingType,
    required this.meetingName,
    required this.meetingDateTime,
    required this.lateThresholdTime,
    required this.meetingPlace,
    this.description,              // nullable로 변경
    required this.createdAt,
    required this.isPrivateMeeting,
    this.discussionTime,           // nullable로 변경
    this.alarmMessage,             // nullable로 변경
  });

  factory MeetingDetailStaffInfo.fromJson(Map<String, dynamic> json) {
    return MeetingDetailStaffInfo(
      meetingId: json['meetingId'] as int,
      meetingCreatorName: json['meetingCreatorName'] as String,
      meetingCreatorId: json['meetingCreatorId'] as int,
      meetingType: json['meetingType'] as String,
      meetingName: json['meetingName'] as String,
      meetingDateTime: _parseDateTime(json['meetingDateTime'] as String),
      lateThresholdTime: _parseDateTime(json['lateThresholdTime'] as String),
      meetingPlace: json['meetingPlace'] as String,
      description: json['description'] as String?,  // null 가능
      createdAt: _parseDateTime(json['createdAt'] as String),
      isPrivateMeeting: json['isPrivateMeeting'] as bool,
      discussionTime: json['discussionTime'] != null 
        ? _parseDateTime(json['discussionTime'] as String)
        : null, // null 그대로 유지
      alarmMessage: json['alarmMessage'] as String?, // null 가능
    );
  }

  /// 백엔드 날짜 형식 (2025.07.31 14:00)을 DateTime으로 변환
  static DateTime _parseDateTime(String dateTimeStr) {
    try {
      // 백엔드 형식: "2025.07.31 14:00"
      // Dart가 이해할 수 있는 형식으로 변환: "2025-07-31 14:00:00"
      final cleanedStr = dateTimeStr
          .replaceAll('.', '-') // . → -
          .replaceAll(' ', 'T') // 공백 → T
          + ':00'; // 초 추가
      
      return DateTime.parse(cleanedStr);
    } catch (e) {
      print('❌ 날짜 파싱 오류: $dateTimeStr -> $e');
      // 파싱 실패 시 현재 시간 반환
      return DateTime.now();
    }
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
      'discussionTime': discussionTime?.toIso8601String(),  // null 안전 처리
      'alarmMessage': alarmMessage,
    };
  }

  @override
  String toString() {
    return 'MeetingDetailStaffInfo{meetingId: $meetingId, meetingName: $meetingName, meetingType: $meetingType, isPrivate: $isPrivateMeeting}';
  }
}
