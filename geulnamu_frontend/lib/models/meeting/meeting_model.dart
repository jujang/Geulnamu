import 'package:intl/intl.dart';
import '../../core/config/app_config.dart';

/// 모임 정보 모델
/// 
/// 백엔드 MeetingInfoResponse와 매핑
class MeetingInfo {
  final int meetingId;
  final String meetingCreatorName;
  final int meetingCreatorId;
  final MeetingType meetingType;
  final String meetingName;
  final DateTime meetingDateTime;
  final String meetingPlace;
  final AttendanceStatus attendanceStatus;
  final DateTime? discussionTime;
  final bool isPrivate;

  const MeetingInfo({
    required this.meetingId,
    required this.meetingCreatorName,
    required this.meetingCreatorId,
    required this.meetingType,
    required this.meetingName,
    required this.meetingDateTime,
    required this.meetingPlace,
    required this.attendanceStatus,
    this.discussionTime,
    required this.isPrivate,
  });

  /// JSON에서 객체 생성
  factory MeetingInfo.fromJson(Map<String, dynamic> json) {
    try {
      if (AppConfig.debugMode) {
        print('📝 [모임정보 파싱] JSON 데이터: $json');
      }

      return MeetingInfo(
        meetingId: _parseIntSafely(json['meetingId'], '모임ID'),
        meetingCreatorName: _parseStringSafely(json['meetingCreatorName'], '개설자명'),
        meetingCreatorId: _parseIntSafely(json['meetingCreatorId'], '개설자ID'),
        meetingType: MeetingType.fromString(json['meetingType'] as String? ?? 'REGULAR'),
        meetingName: _parseStringSafely(json['meetingName'], '모임제목'),
        meetingDateTime: _parseDateTimeSafely(json['meetingDateTime'], '모임일시'),
        meetingPlace: _parseStringSafely(json['meetingPlace'], '모임장소'),
        attendanceStatus: AttendanceStatus.fromString(json['attendanceStatus'] as String? ?? 'NOT_ATTEND'),
        discussionTime: _parseDiscussionTimeNullable(json['discussionTime'], json['meetingDateTime'], '토론시간'),
        isPrivate: json['isPrivate'] as bool? ?? false,
      );
    } catch (e) {
      if (AppConfig.debugMode) {
        print('❌ [모임정보 파싱] 오류: $e');
        print('❌ [모임정보 파싱] 문제 JSON: $json');
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
      'meetingType': meetingType.value,
      'meetingName': meetingName,
      'meetingDateTime': meetingDateTime.toIso8601String(),
      'meetingPlace': meetingPlace,
      'attendanceStatus': attendanceStatus.value,
      'discussionTime': discussionTime?.toIso8601String(),
      'isPrivate': isPrivate,
    };
  }

  // Display 관련 getters

  /// 모임 유형 표시명
  String get meetingTypeDisplayName => meetingType.displayName;

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
    // 원본 데이터가 시간만 이라면 그대로 사용
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
    final meetingDate = DateTime(meetingDateTime.year, meetingDateTime.month, meetingDateTime.day);
    return today == meetingDate;
  }

  @override
  String toString() {
    return 'MeetingInfo{meetingId: $meetingId, meetingName: $meetingName, meetingType: $meetingType, meetingDateTime: $meetingDateTime}';
  }

  // 🔧 Helper 메서드들
  static int _parseIntSafely(dynamic value, String fieldName) {
    if (value == null) {
      if (AppConfig.debugMode) {
        print('⚠️ [모임정보 파싱] $fieldName이 null입니다. 기본값 0 사용');
      }
      return 0;
    }
    if (value is int) return value;
    if (value is String) {
      final parsed = int.tryParse(value);
      if (parsed != null) return parsed;
    }
    
    if (AppConfig.debugMode) {
      print('❌ [모임정보 파싱] $fieldName 파싱 실패: $value (타입: ${value.runtimeType})');
    }
    throw TypeError();
  }

  static String _parseStringSafely(dynamic value, String fieldName) {
    if (value == null) {
      if (AppConfig.debugMode) {
        print('⚠️ [모임정보 파싱] $fieldName이 null입니다. 기본값 빈 문자열 사용');
      }
      return '';
    }
    return value.toString();
  }

  static DateTime _parseDateTimeSafely(dynamic value, String fieldName) {
    if (value == null) {
      if (AppConfig.debugMode) {
        print('⚠️ [모임정보 파싱] $fieldName이 null입니다. 현재 시간 사용');
      }
      return DateTime.now();
    }
    
    try {
      if (value is String) {
        // 백엔드 날짜 형식: "2025.06.26 11:12"
        if (value.contains('.') && value.contains(' ')) {
          // "2025.06.26 11:12" -> "2025-06-26 11:12:00"
          final formatted = value
              .replaceAll('.', '-')
              .trim() + ':00';
          
          if (AppConfig.debugMode) {
            print('📝 [모임정보 파싱] $fieldName 날짜 변환: "$value" -> "$formatted"');
          }
          
          return DateTime.parse(formatted);
        }
        
        // 표준 ISO 형식인 경우
        return DateTime.parse(value);
      }
      
      if (AppConfig.debugMode) {
        print('❌ [모임정보 파싱] $fieldName 파싱 실패: $value (타입: ${value.runtimeType})');
      }
      throw TypeError();
    } catch (e) {
      if (AppConfig.debugMode) {
        print('❌ [모임정보 파싱] $fieldName 날짜 파싱 오류: $e');
      }
      return DateTime.now();
    }
  }

  static DateTime? _parseDiscussionTimeNullable(dynamic timeValue, dynamic dateValue, String fieldName) {
    if (timeValue == null) {
      if (AppConfig.debugMode) {
        print('⚠️ [모임정보 파싱] $fieldName이 null입니다. null 반환');
      }
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
          
          if (AppConfig.debugMode) {
            print('📝 [모임정보 파싱] $fieldName 시간 변환: "$timeValue" -> "$fullTimeStr"');
          }
          
          return DateTime.parse(fullTimeStr);
        }
        
        // 전체 날짜 시간 문자열인 경우
        return DateTime.parse(timeValue);
      }
      
      if (AppConfig.debugMode) {
        print('❌ [모임정보 파싱] $fieldName 파싱 실패: $timeValue (타입: ${timeValue.runtimeType})');
      }
      throw TypeError();
    } catch (e) {
      if (AppConfig.debugMode) {
        print('❌ [모임정보 파싱] $fieldName 시간 파싱 오류: $e');
      }
      // 에러 시 null 반환
      return null;
    }
  }
}

/// 모임 목록 응답 모델
class MeetingListResponse {
  final PagingResponse pagingResponse;
  final List<MeetingInfo> meetingList;

  const MeetingListResponse({
    required this.pagingResponse,
    required this.meetingList,
  });

  /// JSON에서 객체 생성
  factory MeetingListResponse.fromJson(Map<String, dynamic> json) {
    try {
      if (AppConfig.debugMode) {
        print('📝 [모임목록응늵 파싱] 시작...');
        print('📝 [모임목록응늵 파싱] 전체 JSON: $json');
      }

      final pagingResponse = PagingResponse.fromJson(json['pagingResponse'] as Map<String, dynamic>);
      
      if (AppConfig.debugMode) {
        final meetingListJson = json['meetingList'] as List;
        print('📝 [모임목록응늵 파싱] 모임 개수: ${meetingListJson.length}');
      }

      final meetingList = <MeetingInfo>[];
      final meetingListJson = json['meetingList'] as List;
      
      for (int i = 0; i < meetingListJson.length; i++) {
        try {
          if (AppConfig.debugMode) {
            print('📝 [모임목록응늵 파싱] 모임 $i 번 파싱 시작: ${meetingListJson[i]}');
          }
          
          final meeting = MeetingInfo.fromJson(meetingListJson[i] as Map<String, dynamic>);
          meetingList.add(meeting);
          
          if (AppConfig.debugMode) {
            print('✅ [모임목록응늵 파싱] 모임 $i 번 파싱 성공: ${meeting.meetingName}');
          }
        } catch (e) {
          if (AppConfig.debugMode) {
            print('❌ [모임목록응늵 파싱] 모임 $i 번 파싱 실패: $e');
            print('❌ [모임목록응늵 파싱] 문제 모임 데이터: ${meetingListJson[i]}');
          }
          rethrow;
        }
      }

      return MeetingListResponse(
        pagingResponse: pagingResponse,
        meetingList: meetingList,
      );
    } catch (e) {
      if (AppConfig.debugMode) {
        print('❌ [모임목록응늵 파싱] 전체 오류: $e');
      }
      rethrow;
    }
  }
}

/// 페이징 응답 모델
/// 
/// 백엔드 실제 응답 구조에 맞춤
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
      if (AppConfig.debugMode) {
        print('📝 [페이징응답 파싱] JSON 데이터: $json');
      }
      
      return PagingResponse(
        pageNumber: _parseIntSafely(json['pageNumber'], '페이지번호'),
        totalElements: _parseIntSafely(json['totalElements'], '전체요소수'),
        totalPages: _parseIntSafely(json['totalPages'], '전체페이지수'),
      );
    } catch (e) {
      if (AppConfig.debugMode) {
        print('❌ [페이징응답 파싱] 오류: $e');
        print('❌ [페이징응답 파싱] 문제 JSON: $json');
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
      if (AppConfig.debugMode) {
        print('⚠️ [페이징응답 파싱] $fieldName이 null입니다. 기본값 0 사용');
      }
      return 0;
    }
    if (value is int) return value;
    if (value is String) {
      final parsed = int.tryParse(value);
      if (parsed != null) return parsed;
    }
    
    if (AppConfig.debugMode) {
      print('❌ [페이징응답 파싱] $fieldName 파싱 실패: $value (타입: ${value.runtimeType})');
    }
    throw TypeError();
  }
}

/// 모임 유형 enum
enum MeetingType {
  regular('REGULAR', '정기'),
  flash('FLASH', '번개'),
  special('SPECIAL', '특수');

  const MeetingType(this.value, this.displayName);

  final String value;
  final String displayName;

  static MeetingType fromString(String value) {
    return MeetingType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => MeetingType.regular,
    );
  }
}

/// 출석 상태 enum
enum AttendanceStatus {
  attend('ATTEND', '참석', 'green'),
  attendLate('ATTEND_LATE', '지각', 'orange'),
  notAttend('NOT_ATTEND', '불참', 'red');

  const AttendanceStatus(this.value, this.displayName, this.colorName);

  final String value;
  final String displayName;
  final String colorName;

  static AttendanceStatus fromString(String value) {
    return AttendanceStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => AttendanceStatus.notAttend,
    );
  }
}
