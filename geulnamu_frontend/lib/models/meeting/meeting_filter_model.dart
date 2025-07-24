import 'meeting_model.dart';

/// 모임 목록 필터 모델
/// 
/// 백엔드 MeetingListRequest와 매핑
class MeetingListFilter {
  final MeetingTypeOption meetingType;
  final bool isTodayMeeting; // 🎯 null 제거
  final AttendanceStatusOption attendanceStatus;
  final SortByOption sortBy;
  final bool isAsc;
  final int page;
  final int size;

  const MeetingListFilter({
    this.meetingType = MeetingTypeOption.all,
    this.isTodayMeeting = false, // 🎯 기본값: false (전체 모임 조회)
    this.attendanceStatus = AttendanceStatusOption.all,
    this.sortBy = SortByOption.meetingDate,
    this.isAsc = false, // 기본값: 내림차순
    this.page = 1,
    this.size = 10,
  });

  /// 필터 복사 (일부 값 변경)
  MeetingListFilter copyWith({
    MeetingTypeOption? meetingType,
    bool? isTodayMeeting, // 🎯 널 체크는 유지 (선택적 매개변수)
    AttendanceStatusOption? attendanceStatus,
    SortByOption? sortBy,
    bool? isAsc,
    int? page,
    int? size,
  }) {
    return MeetingListFilter(
      meetingType: meetingType ?? this.meetingType,
      isTodayMeeting: isTodayMeeting ?? this.isTodayMeeting, // 🎯 널 체크 사용
      attendanceStatus: attendanceStatus ?? this.attendanceStatus,
      sortBy: sortBy ?? this.sortBy,
      isAsc: isAsc ?? this.isAsc,
      page: page ?? this.page,
      size: size ?? this.size,
    );
  }

  /// 필터 초기화
  MeetingListFilter reset() {
    return const MeetingListFilter(
      meetingType: MeetingTypeOption.all,
      isTodayMeeting: false, // 🎯 초기화 시도 false
      attendanceStatus: AttendanceStatusOption.all,
      sortBy: SortByOption.meetingDate,
      isAsc: false,
      page: 1,
      size: 10,
    );
  }

  /// 백엔드 쿼리 파라미터로 변환
  Map<String, dynamic> toQueryParameters() {
    final Map<String, dynamic> params = {
      'page': page,
      'size': size,
      'sortBy': sortBy.value,
      'isAsc': isAsc.toString(),
    };

    // 모임 유형 필터
    if (meetingType != MeetingTypeOption.all) {
      params['meetingType'] = meetingType.value;
    }

    // 오늘 모임 필터 (🎯 항상 값 전송)
    params['isTodayMeeting'] = isTodayMeeting.toString();

    // 출석 상태 필터
    if (attendanceStatus != AttendanceStatusOption.all) {
      params['attendanceStatus'] = attendanceStatus.value;
    }

    return params;
  }

  @override
  String toString() {
    return 'MeetingListFilter{meetingType: $meetingType, isTodayMeeting: $isTodayMeeting, attendanceStatus: $attendanceStatus, sortBy: $sortBy, isAsc: $isAsc, page: $page}';
  }
}

/// 모임 유형 옵션
enum MeetingTypeOption {
  all('', '전체'),
  regular('REGULAR', '정기'),
  flash('FLASH', '번개'),
  special('SPECIAL', '특수');

  const MeetingTypeOption(this.value, this.displayName);

  final String value;
  final String displayName;

  static MeetingTypeOption fromValue(String? value) {
    if (value == null || value.isEmpty) return MeetingTypeOption.all;
    return MeetingTypeOption.values.firstWhere(
      (option) => option.value == value,
      orElse: () => MeetingTypeOption.all,
    );
  }
}

/// 출석 상태 옵션
enum AttendanceStatusOption {
  all('', '전체'),
  attend('ATTEND', '참석'),
  attendLate('ATTEND_LATE', '지각'),
  notAttend('NOT_ATTEND', '불참');

  const AttendanceStatusOption(this.value, this.displayName);

  final String value;
  final String displayName;

  static AttendanceStatusOption fromValue(String? value) {
    if (value == null || value.isEmpty) return AttendanceStatusOption.all;
    return AttendanceStatusOption.values.firstWhere(
      (option) => option.value == value,
      orElse: () => AttendanceStatusOption.all,
    );
  }
}

/// 정렬 기준 옵션
enum SortByOption {
  meetingDate('meetingDate', '개최일시'),
  id('id', '모임번호');

  const SortByOption(this.value, this.displayName);

  final String value;
  final String displayName;

  static SortByOption fromValue(String? value) {
    if (value == null || value.isEmpty) return SortByOption.meetingDate;
    return SortByOption.values.firstWhere(
      (option) => option.value == value,
      orElse: () => SortByOption.meetingDate,
    );
  }
}
