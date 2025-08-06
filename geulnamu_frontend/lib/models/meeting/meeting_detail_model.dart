import 'package:intl/intl.dart';
import '../../core/config/app_config.dart';
import 'group_member_model.dart';

/// 모임 상세 정보 모델
///
/// 백엔드 MeetingDetailResponse와 매핑
/// GET /meetings/{meetingId} API 응답용
class MeetingDetailInfo {
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

  // 출석 관련
  final int? attendanceId;
  final String attendanceStatus;
  final String? note;

  // 토론 관련
  final DateTime? discussionTime;
  final String? alarmMessage;
  final bool? wantDiscussion;
  final List<GroupMember>? groupMemberList;

  const MeetingDetailInfo({
    // 모임 관련
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
    // 출석 관련
    this.attendanceId,
    required this.attendanceStatus,
    this.note,
    // 토론 관련
    this.discussionTime,
    this.alarmMessage,
    this.wantDiscussion,
    this.groupMemberList,
  });

  /// JSON에서 객체 생성
  factory MeetingDetailInfo.fromJson(Map<String, dynamic> json) {
    try {
      final meetingDetail = MeetingDetailInfo(
        // 모임 관련
        meetingId: _parseIntSafely(json['meetingId'], '모임ID'),
        meetingCreatorName: _parseStringSafely(
          json['meetingCreatorName'],
          '개설자명',
        ),
        meetingCreatorId: _parseIntSafely(json['meetingCreatorId'], '개설자ID'),
        meetingType: _parseStringSafely(json['meetingType'], '모임유형'),
        meetingName: _parseStringSafely(json['meetingName'], '모임제목'),
        meetingDateTime: _parseDateTimeSafely(json['meetingDateTime'], '모임일시'),
        lateThresholdTime: _parseDateTimeSafely(
          json['lateThresholdTime'],
          '지각기준시간',
        ),
        meetingPlace: _parseStringSafely(json['meetingPlace'], '모임장소'),
        description: _parseStringSafely(json['description'], '모임설명'),
        createdAt: _parseDateTimeSafely(json['createdAt'], '모임개설일자'),
        // 출석 관련
        attendanceId: _parseIntNullable(json['attendanceId']),
        attendanceStatus: _parseStringSafely(json['attendanceStatus'], '출석상태'),
        note: _parseStringNullable(json['note']),
        // 토론 관련
        discussionTime: _parseDateTimeNullable(json['discussionTime']),
        alarmMessage: _parseStringNullable(json['alarmMessage']),
        wantDiscussion: _parseBoolNullable(json['wantDiscussion']),
        groupMemberList: _parseGroupMemberList(json['groupMemberList']),
      );

      return meetingDetail;
    } catch (e) {
      if (AppConfig.debugMode) {
        print('❌ [MeetingDetailInfo.fromJson] 파싱 오류: $e');
        print('🔍 입력 JSON: $json');
      }
      rethrow;
    }
  }

  /// 객체를 JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      // 모임 관련
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
      // 출석 관련
      'attendanceId': attendanceId,
      'attendanceStatus': attendanceStatus,
      'note': note,
      // 토론 관련
      'discussionTime': discussionTime?.toIso8601String(),
      'alarmMessage': alarmMessage,
      'wantDiscussion': wantDiscussion,
      'groupMemberList': groupMemberList
          ?.map((member) => member.toJson())
          .toList(),
    };
  }

  // Display 관련 getters

  /// 모임 유형 표시명
  String get meetingTypeDisplayName {
    switch (meetingType) {
      case 'REGULAR':
        return '정기';
      case 'FLASH':
        return '번개';
      case 'SPECIAL':
        return '특수';
      default:
        return meetingType;
    }
  }

  /// 모임 개최일자 표시 (yyyy.MM.dd HH:mm)
  String get displayMeetingDateTime {
    return DateFormat('yyyy.MM.dd HH:mm').format(meetingDateTime);
  }

  /// 모임 개최 날짜만 (yyyy.MM.dd)
  String get displayMeetingDate {
    return DateFormat('yyyy.MM.dd').format(meetingDateTime);
  }

  /// 모임 개최 시간만 (HH:mm)
  String get displayMeetingTime {
    return DateFormat('HH:mm').format(meetingDateTime);
  }

  /// 지각 기준 시간 표시 (yyyy.MM.dd HH:mm)
  String get displayLateThresholdTime {
    return DateFormat('yyyy.MM.dd HH:mm').format(lateThresholdTime);
  }

  /// 토론 시간 표시 (HH:mm) - 시간만 표시
  String get displayDiscussionTime {
    if (discussionTime == null) return '-';
    return DateFormat('HH:mm').format(discussionTime!);
  }

  /// 모임 개설일자 표시 (yyyy.MM.dd HH:mm)
  String get displayCreatedAt {
    return DateFormat('yyyy.MM.dd HH:mm').format(createdAt);
  }

  /// 출석 상태 표시명
  String get attendanceStatusDisplayName {
    switch (attendanceStatus) {
      case 'ATTEND':
        return '참석';
      case 'ATTEND_LATE':
        return '지각';
      case 'NOT_ATTEND':
        return '불참';
      case 'NOT_STARTED':
        return '진행 전';
      default:
        return attendanceStatus;
    }
  }

  /// 출석 상태 색상
  String get attendanceStatusColorName {
    switch (attendanceStatus) {
      case 'ATTEND':
        return 'green';
      case 'ATTEND_LATE':
        return 'orange';
      case 'NOT_ATTEND':
        return 'grey';
      case 'NOT_STARTED':
        return 'blue';
      default:
        return 'grey';
    }
  }

  /// 토론 참석 희망 여부 표시
  String get displayWantDiscussion {
    if (wantDiscussion == null) return '-';
    return wantDiscussion! ? '토론할래요' : '독서만 할래요';
  }

  /// 오늘 모임 여부
  bool get isToday {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final meetingDate = DateTime(
      meetingDateTime.year,
      meetingDateTime.month,
      meetingDateTime.day,
    );
    return today == meetingDate;
  }

  @override
  String toString() {
    return 'MeetingDetailInfo{meetingId: $meetingId, meetingName: $meetingName, meetingType: $meetingType, meetingDateTime: $meetingDateTime}';
  }

  // 🔧 Helper 메서드들
  static int _parseIntSafely(dynamic value, String fieldName) {
    if (value == null) {
      return 0;
    }
    if (value is int) return value;
    if (value is String) {
      final parsed = int.tryParse(value);
      if (parsed != null) return parsed;
    }

    throw TypeError();
  }

  static int? _parseIntNullable(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) {
      return int.tryParse(value);
    }
    return null;
  }

  static String _parseStringSafely(dynamic value, String fieldName) {
    if (value == null) {
      return '';
    }
    return value.toString();
  }

  static String? _parseStringNullable(dynamic value) {
    if (value == null) return null;
    return value.toString();
  }

  static bool? _parseBoolNullable(dynamic value) {
    if (value == null) return null;
    if (value is bool) return value;
    if (value is String) {
      return value.toLowerCase() == 'true';
    }
    return null;
  }

  static DateTime _parseDateTimeSafely(dynamic value, String fieldName) {
    if (value == null) {
      return DateTime.now();
    }

    try {
      if (value is String) {
        // 백엔드 날짜 형식: "2025.06.26 11:12"
        if (value.contains('.') && value.contains(' ')) {
          // "2025.06.26 11:12" -> "2025-06-26 11:12:00"
          final formatted = '${value.replaceAll('.', '-').trim()}:00';
          return DateTime.parse(formatted);
        }

        // 표준 ISO 형식인 경우
        return DateTime.parse(value);
      }

      throw TypeError();
    } catch (e) {
      return DateTime.now();
    }
  }

  static DateTime? _parseDateTimeNullable(dynamic value) {
    if (value == null) return null;

    try {
      if (value is String) {
        // 백엔드 날짜 형식: "2025.06.26 11:12"
        if (value.contains('.') && value.contains(' ')) {
          // "2025.06.26 11:12" -> "2025-06-26 11:12:00"
          final formatted = '${value.replaceAll('.', '-').trim()}:00';
          return DateTime.parse(formatted);
        }

        // 표준 ISO 형식인 경우
        return DateTime.parse(value);
      }

      throw TypeError();
    } catch (e) {
      return null;
    }
  }

  static List<GroupMember>? _parseGroupMemberList(dynamic value) {
    if (value == null) return null;

    try {
      if (value is List) {
        return value
            .map((item) => GroupMember.fromJson(item as Map<String, dynamic>))
            .toList();
      }

      return null;
    } catch (e) {
      if (AppConfig.debugMode) {
        print('❌ [MeetingDetailInfo] groupMemberList 파싱 오류: $e');
        print('❌ [MeetingDetailInfo] 오류 발생한 value: $value');
      }
      return null;
    }
  }
}
