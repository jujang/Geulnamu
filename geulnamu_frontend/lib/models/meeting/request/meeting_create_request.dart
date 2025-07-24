/// 모임 생성 요청 모델
/// 
/// 백엔드 MeetingCreateRequest와 매핑되는 모델
/// API: POST /meetings/create
class MeetingCreateRequest {
  final String meetingType;        // REGULAR, FLASH, SPECIAL
  final String meetingName;        // 모임 제목
  final String meetingDate;        // yyyyMMdd HH:mm 형식
  final String? lateThresholdTime; // yyyyMMdd HH:mm 형식 (선택)
  final String meetingPlace;       // 모임 장소
  final String? description;       // 상세 내용 (선택)

  const MeetingCreateRequest({
    required this.meetingType,
    required this.meetingName,
    required this.meetingDate,
    this.lateThresholdTime,
    required this.meetingPlace,
    this.description,
  });

  /// DateTime을 백엔드 요구 형식으로 변환
  static String formatDateTime(DateTime dateTime) {
    return '${dateTime.year.toString().padLeft(4, '0')}'
        '${dateTime.month.toString().padLeft(2, '0')}'
        '${dateTime.day.toString().padLeft(2, '0')} '
        '${dateTime.hour.toString().padLeft(2, '0')}:'
        '${dateTime.minute.toString().padLeft(2, '0')}';
  }

  /// JSON 변환
  Map<String, dynamic> toJson() {
    return {
      'meetingType': meetingType,
      'meetingName': meetingName,
      'meetingDate': meetingDate,
      if (lateThresholdTime != null) 'lateThresholdTime': lateThresholdTime,
      'meetingPlace': meetingPlace,
      if (description != null && description!.isNotEmpty) 'description': description,
    };
  }

  @override
  String toString() {
    return 'MeetingCreateRequest{'
        'meetingType: $meetingType, '
        'meetingName: $meetingName, '
        'meetingDate: $meetingDate, '
        'lateThresholdTime: $lateThresholdTime, '
        'meetingPlace: $meetingPlace, '
        'description: $description'
        '}';
  }
}

/// 모임 타입 enum (백엔드와 일치)
enum MeetingType {
  regular('REGULAR', '정기'),
  flash('FLASH', '번개'),
  special('SPECIAL', '특수');

  const MeetingType(this.apiValue, this.displayName);
  
  final String apiValue;
  final String displayName;
  
  static MeetingType fromApiValue(String apiValue) {
    return MeetingType.values.firstWhere(
      (type) => type.apiValue == apiValue,
      orElse: () => MeetingType.regular,
    );
  }
}
