/// 모임 기본 정보 수정 요청 모델
/// 
/// API: PATCH /meetings/{meetingId}/basic
class MeetingBasicUpdateRequest {
  final String? meetingType;
  final String? meetingName;
  final DateTime? meetingDate;
  final DateTime? lateThresholdTime;
  final String? meetingPlace;
  final String? description;

  const MeetingBasicUpdateRequest({
    this.meetingType,
    this.meetingName,
    this.meetingDate,
    this.lateThresholdTime,
    this.meetingPlace,
    this.description,
  });

  /// 변경된 필드만 포함하여 요청 생성
  factory MeetingBasicUpdateRequest.onlyChanged({
    String? originalMeetingType,
    String? newMeetingType,
    String? originalMeetingName,
    String? newMeetingName,
    DateTime? originalMeetingDate,
    DateTime? newMeetingDate,
    DateTime? originalLateThresholdTime,
    DateTime? newLateThresholdTime,
    String? originalMeetingPlace,
    String? newMeetingPlace,
    String? originalDescription,
    String? newDescription,
  }) {
    return MeetingBasicUpdateRequest(
      meetingType: _isChanged(originalMeetingType, newMeetingType) ? newMeetingType : null,
      meetingName: _isChanged(originalMeetingName, newMeetingName) ? newMeetingName : null,
      meetingDate: _isDateChanged(originalMeetingDate, newMeetingDate) ? newMeetingDate : null,
      lateThresholdTime: _isDateChanged(originalLateThresholdTime, newLateThresholdTime) ? newLateThresholdTime : null,
      meetingPlace: _isChanged(originalMeetingPlace, newMeetingPlace) ? newMeetingPlace : null,
      description: _isChanged(originalDescription, newDescription) ? newDescription : null,
    );
  }

  /// 변경사항이 있는지 확인
  bool get hasChanges {
    return meetingType != null ||
           meetingName != null ||
           meetingDate != null ||
           lateThresholdTime != null ||
           meetingPlace != null ||
           description != null;
  }

  /// 변경된 필드 개수
  int get changeCount {
    int count = 0;
    if (meetingType != null) count++;
    if (meetingName != null) count++;
    if (meetingDate != null) count++;
    if (lateThresholdTime != null) count++;
    if (meetingPlace != null) count++;
    if (description != null) count++;
    return count;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {};
    
    if (meetingType != null) json['meetingType'] = meetingType;
    if (meetingName != null) json['meetingName'] = meetingName;
    if (meetingDate != null) json['meetingDate'] = _formatDateTimeForBackend(meetingDate!);
    if (lateThresholdTime != null) json['lateThresholdTime'] = _formatDateTimeForBackend(lateThresholdTime!);
    if (meetingPlace != null) json['meetingPlace'] = meetingPlace;
    if (description != null) json['description'] = description;
    
    return json;
  }

  /// 백엔드 요구 형식으로 날짜 변환: "yyyyMMdd HH:mm"
  static String _formatDateTimeForBackend(DateTime dateTime) {
    return '${dateTime.year.toString().padLeft(4, '0')}'
           '${dateTime.month.toString().padLeft(2, '0')}'
           '${dateTime.day.toString().padLeft(2, '0')} '
           '${dateTime.hour.toString().padLeft(2, '0')}:'
           '${dateTime.minute.toString().padLeft(2, '0')}';
  }

  /// 문자열 값 변경 여부 확인 (null과 빈 문자열을 구분)
  static bool _isChanged(String? original, String? current) {
    // null을 빈 문자열로 정규화하지 않고 정확히 비교
    return original != current;
  }

  /// 날짜 값 변경 여부 확인
  static bool _isDateChanged(DateTime? original, DateTime? current) {
    if (original == null && current == null) return false;
    if (original == null || current == null) return true;
    return original.millisecondsSinceEpoch != current.millisecondsSinceEpoch;
  }

  @override
  String toString() {
    final changes = <String>[];
    if (meetingType != null) changes.add('meetingType: $meetingType');
    if (meetingName != null) changes.add('meetingName: $meetingName');
    if (meetingDate != null) changes.add('meetingDate: $meetingDate');
    if (lateThresholdTime != null) changes.add('lateThresholdTime: $lateThresholdTime');
    if (meetingPlace != null) changes.add('meetingPlace: $meetingPlace');
    if (description != null) changes.add('description: $description');
    return 'MeetingBasicUpdateRequest{${changes.join(', ')}}';
  }
}

/// 토론 정보 수정 요청 모델
/// 
/// API: PATCH /meetings/{meetingId}/discussion
class MeetingDiscussionUpdateRequest {
  final DateTime? discussionTime;
  final bool? discussionTimeNull; // 🆕 토론 시간 null 초기화 플래그
  final String? alarmMessage;

  const MeetingDiscussionUpdateRequest({
    this.discussionTime,
    this.discussionTimeNull,
    this.alarmMessage,
  });

  /// 변경된 필드만 포함하여 요청 생성
  factory MeetingDiscussionUpdateRequest.onlyChanged({
    DateTime? originalDiscussionTime,
    DateTime? newDiscussionTime,
    bool isDiscussionTimeCleared = false, // 🆕 X 버튼으로 클리어했는지 여부
    String? originalAlarmMessage,
    String? newAlarmMessage,
  }) {
    // 🎯 토론 시간 처리 로직
    DateTime? discussionTimeToSend;
    bool? discussionTimeNullToSend;
    
    if (isDiscussionTimeCleared) {
      // X 버튼으로 클리어한 경우: discussionTime은 보내지 않고, discussionTimeNull만 true
      discussionTimeToSend = null;
      discussionTimeNullToSend = true;
    } else if (_isDateChanged(originalDiscussionTime, newDiscussionTime)) {
      // 시간이 변경된 경우: 새로운 시간 값 전송, discussionTimeNull은 보내지 않음
      discussionTimeToSend = newDiscussionTime;
      discussionTimeNullToSend = null; // 요청에 포함하지 않음
    } else {
      // 변경사항 없는 경우: 둘 다 보내지 않음
      discussionTimeToSend = null;
      discussionTimeNullToSend = null;
    }
    
    return MeetingDiscussionUpdateRequest(
      discussionTime: discussionTimeToSend,
      discussionTimeNull: discussionTimeNullToSend,
      alarmMessage: _isChanged(originalAlarmMessage, newAlarmMessage) ? newAlarmMessage : null, // 🆕 빈 문자열도 변경사항으로 인식
    );
  }

  /// 변경사항이 있는지 확인
  bool get hasChanges {
    return discussionTime != null || discussionTimeNull == true || alarmMessage != null;
  }

  /// 변경된 필드 개수
  int get changeCount {
    int count = 0;
    if (discussionTime != null) count++;
    if (discussionTimeNull == true) count++; // X 버튼으로 클리어한 경우도 변경사항
    if (alarmMessage != null) count++;
    return count;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {};
    
    // 🎯 조건부 필드 포함
    if (discussionTime != null) {
      json['discussionTime'] = _formatDateTimeForBackend(discussionTime!);
    }
    if (discussionTimeNull == true) {
      json['discussionTimeNull'] = discussionTimeNull;
    }
    if (alarmMessage != null) {
      json['alarmMessage'] = alarmMessage;
    }
    
    return json;
  }

  /// 백엔드 요구 형식으로 날짜 변환: "yyyyMMdd HH:mm"
  static String _formatDateTimeForBackend(DateTime dateTime) {
    return '${dateTime.year.toString().padLeft(4, '0')}'
           '${dateTime.month.toString().padLeft(2, '0')}'
           '${dateTime.day.toString().padLeft(2, '0')} '
           '${dateTime.hour.toString().padLeft(2, '0')}:'
           '${dateTime.minute.toString().padLeft(2, '0')}';
  }

  /// 문자열 값 변경 여부 확인
  static bool _isChanged(String? original, String? current) {
    return (original ?? '') != (current ?? '');
  }

  /// 날짜 값 변경 여부 확인
  static bool _isDateChanged(DateTime? original, DateTime? current) {
    if (original == null && current == null) return false;
    if (original == null || current == null) return true;
    return original.millisecondsSinceEpoch != current.millisecondsSinceEpoch;
  }

  @override
  String toString() {
    final changes = <String>[];
    if (discussionTime != null) changes.add('discussionTime: $discussionTime');
    if (discussionTimeNull == true) changes.add('discussionTimeNull: $discussionTimeNull');
    if (alarmMessage != null) changes.add('alarmMessage: $alarmMessage');
    return 'MeetingDiscussionUpdateRequest{${changes.join(', ')}}';
  }
}
