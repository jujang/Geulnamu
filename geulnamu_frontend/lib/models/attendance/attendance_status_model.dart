/// 출석 현황 관련 모델들
/// 
/// 백엔드 MeetingAttendanceDetailsResponse와 대응되는 Dart 모델

/// 모임 출석 현황 전체 응답
class MeetingAttendanceDetails {
  final AttendanceSummary summary;
  final List<AttendanceStatus> attendanceList;

  const MeetingAttendanceDetails({
    required this.summary,
    required this.attendanceList,
  });

  factory MeetingAttendanceDetails.fromJson(Map<String, dynamic> json) {
    return MeetingAttendanceDetails(
      summary: AttendanceSummary.fromJson(json['meetingAttendanceSummaryResponse']),
      attendanceList: (json['meetingAttendanceStatusResponseList'] as List)
          .map((item) => AttendanceStatus.fromJson(item))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'meetingAttendanceSummaryResponse': summary.toJson(),
      'meetingAttendanceStatusResponseList': attendanceList.map((item) => item.toJson()).toList(),
    };
  }
}

/// 출석 요약 정보
class AttendanceSummary {
  final DateTime meetingDate;
  final DateTime lateThresholdTime;
  final int totalAttendCount;
  final int attendCount;
  final int lateAttendCount;
  final int wantDiscussionCount;  // 🆕 토론 참여 희망자 수

  const AttendanceSummary({
    required this.meetingDate,
    required this.lateThresholdTime,
    required this.totalAttendCount,
    required this.attendCount,
    required this.lateAttendCount,
    required this.wantDiscussionCount,
  });

  factory AttendanceSummary.fromJson(Map<String, dynamic> json) {
    return AttendanceSummary(
      meetingDate: _parseDateTime(json['meetingDate']),
      lateThresholdTime: _parseTimeAsDateTime(
        json['lateThresholdTime']?.toString(), 
        json['meetingDate']?.toString()
      ),
      totalAttendCount: (json['totalAttendCount'] as num?)?.toInt() ?? 0,
      attendCount: (json['attendCount'] as num?)?.toInt() ?? 0,
      lateAttendCount: (json['lateAttendCount'] as num?)?.toInt() ?? 0,
      wantDiscussionCount: (json['wantDiscussionCount'] as num?)?.toInt() ?? 0,  // 🆕 파싱
    );
  }

  /// DateTime 파싱 (null 안전)
  static DateTime _parseDateTime(dynamic dateStr) {
    if (dateStr == null) {
      return DateTime.now(); // null인 경우 현재 시간 반환
    }
    try {
      return DateTime.parse(dateStr.toString().replaceAll('.', '-').replaceAll(' ', 'T'));
    } catch (e) {
      return DateTime.now(); // 파싱 실패 시 현재 시간 반환
    }
  }

  /// HH:mm 형식의 시간을 meetingDate와 결합하여 DateTime으로 변환 (null 안전)
  static DateTime _parseTimeAsDateTime(String? timeStr, String? dateStr) {
    if (timeStr == null || dateStr == null) {
      return DateTime.now(); // null인 경우 현재 시간 반환
    }
    
    try {
      // dateStr: "yyyy.MM.dd HH:mm" -> yyyy-MM-dd 추출
      final datePart = dateStr.split(' ')[0].replaceAll('.', '-');
      // timeStr: "HH:mm"
      final fullDateTimeStr = '${datePart}T$timeStr:00';
      return DateTime.parse(fullDateTimeStr);
    } catch (e) {
      return DateTime.now(); // 파싱 실패 시 현재 시간 반환
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'meetingDate': meetingDate.toIso8601String(),
      'lateThresholdTime': lateThresholdTime.toIso8601String(),
      'totalAttendCount': totalAttendCount,
      'attendCount': attendCount,
      'lateAttendCount': lateAttendCount,
      'wantDiscussionCount': wantDiscussionCount,
    };
  }

  /// 결석자 수 계산
  int get absentCount => totalAttendCount - attendCount;
}

/// 개별 출석 상태 정보
class AttendanceStatus {
  final int attendanceId;
  final int memberId;  // 🆕 회원 ID 추가 (푸시 알림 수신자용)
  final String name;
  final DateTime attendanceTime;
  final bool isLate;
  final bool? wantDiscussion;  // 🆕 토론 참여 희망 여부 추가

  const AttendanceStatus({
    required this.attendanceId,
    required this.memberId,
    required this.name,
    required this.attendanceTime,
    required this.isLate,
    this.wantDiscussion,
  });

  factory AttendanceStatus.fromJson(Map<String, dynamic> json) {
    return AttendanceStatus(
      attendanceId: (json['attendanceId'] as num?)?.toInt() ?? 0,
      memberId: (json['memberId'] as num?)?.toInt() ?? 0,  // 🆕 memberId 파싱
      name: json['name']?.toString() ?? '알 수 없음',
      attendanceTime: _parseDateTime(json['attendanceTime']),
      isLate: json['isLate'] as bool? ?? false,
      wantDiscussion: json['wantDiscussion'] as bool?,  // 🆕 wantDiscussion 파싱
    );
  }

  /// DateTime 파싱 (null 안전)
  static DateTime _parseDateTime(dynamic dateStr) {
    if (dateStr == null) {
      return DateTime.now();
    }
    try {
      return DateTime.parse(dateStr.toString().replaceAll('.', '-').replaceAll(' ', 'T'));
    } catch (e) {
      return DateTime.now();
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'attendanceId': attendanceId,
      'memberId': memberId,
      'name': name,
      'attendanceTime': attendanceTime.toIso8601String(),
      'isLate': isLate,
      'wantDiscussion': wantDiscussion,
    };
  }
}
