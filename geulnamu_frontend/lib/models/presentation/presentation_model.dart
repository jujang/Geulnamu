import 'package:intl/intl.dart';
import '../../core/config/app_config.dart';

/// 발제문 정보 모델
///
/// 모임 정보를 기반으로 하되 발제문 관점에서 재구성
class PresentationInfo {
  final int meetingId;
  final String meetingCreatorName;
  final int meetingCreatorId;
  final PresentationType presentationType;
  final String meetingName;
  final DateTime meetingDateTime;
  final String meetingPlace;
  final AttendanceStatus attendanceStatus;
  final DateTime? discussionTime;
  final bool isPrivate;

  const PresentationInfo({
    required this.meetingId,
    required this.meetingCreatorName,
    required this.meetingCreatorId,
    required this.presentationType,
    required this.meetingName,
    required this.meetingDateTime,
    required this.meetingPlace,
    required this.attendanceStatus,
    this.discussionTime,
    required this.isPrivate,
  });

  /// JSON에서 객체 생성 (기존 모임 API 응답 활용)
  factory PresentationInfo.fromJson(Map<String, dynamic> json) {
    try {
      final presentationInfo = PresentationInfo(
        meetingId: _parseIntSafely(json['meetingId'], '모임ID'),
        meetingCreatorName: _parseStringSafely(json['meetingCreatorName'], '개설자명'),
        meetingCreatorId: _parseIntSafely(json['meetingCreatorId'], '개설자ID'),
        presentationType: PresentationType.fromString(json['meetingType'] as String? ?? 'REGULAR'),
        meetingName: _parseStringSafely(json['meetingName'], '모임제목'),
        meetingDateTime: _parseDateTimeSafely(json['meetingDateTime'], '모임일시'),
        meetingPlace: _parseStringSafely(json['meetingPlace'], '모임장소'),
        attendanceStatus: _parseAttendanceStatusSafely(json['attendanceStatus'], '출석상태'),
        discussionTime: _parseDiscussionTimeNullable(json['discussionTime'], json['meetingDateTime'], '토론시간'),
        isPrivate: json['isPrivate'] as bool? ?? false,
      );
      
      return presentationInfo;
    } catch (e) {
      if (AppConfig.debugMode) {
        print('❌ [PresentationInfo.fromJson] 파싱 오류: $e');
        print('🔍 입력 JSON: $json');
      }
      rethrow;
    }
  }

  /// 객체를 JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'meetingId': meetingId,
      'meetingCreatorName': meetingCreatorName,
      'meetingCreatorId': meetingCreatorId,
      'meetingType': presentationType.value,
      'meetingName': meetingName,
      'meetingDateTime': meetingDateTime.toIso8601String(),
      'meetingPlace': meetingPlace,
      'attendanceStatus': attendanceStatus.value,
      'discussionTime': discussionTime?.toIso8601String(),
      'isPrivate': isPrivate,
    };
  }

  // Display 관련 getters

  /// 발제문 유형 표시명
  String get presentationTypeDisplayName => presentationType.displayName;

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

  /// 토론 시간 표시 (HH:mm) - 시간만 표시
  String get displayDiscussionTime {
    if (discussionTime == null) return '-';
    return DateFormat('HH:mm').format(discussionTime!);
  }

  /// 출석 상태 표시명
  String get attendanceStatusDisplayName => attendanceStatus.displayName;

  /// 출석 상태 색상
  String get attendanceStatusColorName => attendanceStatus.colorName;

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

  /// 책 제목 (발제문용)
  String get bookTitle => meetingName;

  /// 책 부제목 (발제문용)
  String get bookSubtitle => '${presentationTypeDisplayName} 발제문';

  @override
  String toString() {
    return 'PresentationInfo{meetingId: $meetingId, meetingName: $meetingName, presentationType: $presentationType, meetingDateTime: $meetingDateTime}';
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

  static String _parseStringSafely(dynamic value, String fieldName) {
    if (value == null) {
      return '';
    }
    return value.toString();
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

  static AttendanceStatus _parseAttendanceStatusSafely(
    dynamic value,
    String fieldName,
  ) {
    if (value == null) {
      return AttendanceStatus.notAttend;
    }

    if (value is String) {
      return AttendanceStatus.fromString(value);
    }

    return AttendanceStatus.notAttend;
  }

  static DateTime? _parseDiscussionTimeNullable(
    dynamic timeValue,
    dynamic dateValue,
    String fieldName,
  ) {
    if (timeValue == null) {
      return null;
    }

    try {
      if (timeValue is String) {
        // 시간만 오는 경우 ("11:13", "12:34")
        if (timeValue.contains(':') && !timeValue.contains(' ')) {
          // 모임일시에서 날짜 부분 추출
          final meetingDateTime = _parseDateTimeSafely(dateValue, '모임일시');
          final dateStr = DateFormat('yyyy-MM-dd').format(meetingDateTime);
          final fullTimeStr = '$dateStr $timeValue:00'; // 초 추가

          return DateTime.parse(fullTimeStr);
        }

        // 전체 날짜 시간 문자열인 경우
        return DateTime.parse(timeValue);
      }

      throw TypeError();
    } catch (e) {
      // 에러 시 null 반환
      return null;
    }
  }
}

/// 발제문 목록 응답 모델
class PresentationListResponse {
  final PagingResponse pagingResponse;
  final List<PresentationInfo> presentationList;

  const PresentationListResponse({
    required this.pagingResponse,
    required this.presentationList,
  });

  /// JSON에서 객체 생성 (기존 모임 API 응답 활용)
  factory PresentationListResponse.fromJson(Map<String, dynamic> json) {
    try {
      final pagingResponse = PagingResponse.fromJson(
        json['pagingResponse'] as Map<String, dynamic>,
      );

      final presentationList = <PresentationInfo>[];
      final meetingListJson = json['meetingList'] as List;

      for (int i = 0; i < meetingListJson.length; i++) {
        try {
          final presentation = PresentationInfo.fromJson(
            meetingListJson[i] as Map<String, dynamic>,
          );
          presentationList.add(presentation);
        } catch (e) {
          if (AppConfig.debugMode) {
            print('❌ [PresentationListResponse] 발제문 $i 파싱 실패: $e');
          }
          rethrow;
        }
      }

      return PresentationListResponse(
        pagingResponse: pagingResponse,
        presentationList: presentationList,
      );
    } catch (e) {
      if (AppConfig.debugMode) {
        print('❌ [PresentationListResponse] 파싱 오류: $e');
      }
      rethrow;
    }
  }
}

/// 페이징 응답 모델 (발제문용)
class PagingResponse {
  final int pageNumber;
  final int totalElements;
  final int totalPages;

  const PagingResponse({
    required this.pageNumber,
    required this.totalElements,
    required this.totalPages,
  });

  factory PagingResponse.fromJson(Map<String, dynamic> json) {
    try {
      return PagingResponse(
        pageNumber: _parseIntSafely(json['pageNumber'], '페이지번호'),
        totalElements: _parseIntSafely(json['totalElements'], '전체요소수'),
        totalPages: _parseIntSafely(json['totalPages'], '전체페이지수'),
      );
    } catch (e) {
      if (AppConfig.debugMode) {
        print('❌ [페이징응답 파싱] 오류: $e');
      }
      rethrow;
    }
  }

  // 계산 가능한 속성들

  /// 첫 번째 페이지 여부
  bool get first => pageNumber == 1;

  /// 마지막 페이지 여부
  bool get last => pageNumber == totalPages;

  /// 페이지 크기 (기본값 10)
  int get pageSize => 10;

  /// 다음 페이지 존재 여부
  bool get hasNext => pageNumber < totalPages;

  /// 이전 페이지 존재 여부
  bool get hasPrevious => pageNumber > 1;

  @override
  String toString() {
    return 'PagingResponse{pageNumber: $pageNumber, totalElements: $totalElements, totalPages: $totalPages}';
  }

  // Helper 메서드
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
}

/// 발제문 유형 enum (모임 유형과 동일하지만 발제문 관점으로 명명)
enum PresentationType {
  regular('REGULAR', '정기'),
  flash('FLASH', '번개'),
  special('SPECIAL', '특수');

  const PresentationType(this.value, this.displayName);

  final String value;
  final String displayName;

  static PresentationType fromString(String value) {
    return PresentationType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => PresentationType.regular,
    );
  }
}

/// 출석 상태 enum (발제문용)
enum AttendanceStatus {
  attend('ATTEND', '참석', 'green'),
  attendLate('ATTEND_LATE', '지각', 'orange'),
  notAttend('NOT_ATTEND', '불참', 'grey'),
  notStarted('NOT_STARTED', '진행 전', 'blue');

  const AttendanceStatus(this.value, this.displayName, this.colorName);

  final String value;
  final String displayName;
  final String colorName;

  static AttendanceStatus fromString(String value) {
    final result = AttendanceStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () {
        if (AppConfig.debugMode) {
          print('⚠️ [AttendanceStatus] 알 수 없는 출석상태: "$value" -> notAttend 사용');
        }
        return AttendanceStatus.notAttend;
      },
    );
    
    return result;
  }
}
