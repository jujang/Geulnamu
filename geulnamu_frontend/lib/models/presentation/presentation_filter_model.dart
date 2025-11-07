import '../../core/config/app_config.dart';

/// 발제문 목록 필터 모델
///
/// 모임 필터와 유사하지만 발제문 관점에서 재구성
class PresentationListFilter {
  final int page;
  final int size;
  final PresentationTypeOption presentationType;
  final bool? isTodayMeeting;
  final AttendanceStatusOption attendanceStatus;
  final PresentationSortBy sortBy;
  final bool isAsc;

  const PresentationListFilter({
    this.page = 1,
    this.size = 12, // 🎯 기본값 12개 (모바일은 ResponsiveHelper가 6개로 설정)
    this.presentationType = PresentationTypeOption.all,
    this.isTodayMeeting,
    this.attendanceStatus = AttendanceStatusOption.all,
    this.sortBy = PresentationSortBy.meetingDate,
    this.isAsc = false,
  });

  /// 필터 복사 (일부 값 변경)
  PresentationListFilter copyWith({
    int? page,
    int? size,
    PresentationTypeOption? presentationType,
    bool? isTodayMeeting,
    AttendanceStatusOption? attendanceStatus,
    PresentationSortBy? sortBy,
    bool? isAsc,
  }) {
    return PresentationListFilter(
      page: page ?? this.page,
      size: size ?? this.size,
      presentationType: presentationType ?? this.presentationType,
      isTodayMeeting: isTodayMeeting ?? this.isTodayMeeting,
      attendanceStatus: attendanceStatus ?? this.attendanceStatus,
      sortBy: sortBy ?? this.sortBy,
      isAsc: isAsc ?? this.isAsc,
    );
  }

  /// 필터 초기화
  PresentationListFilter reset() {
    return const PresentationListFilter();
  }

  /// 쿼리 매개변수로 변환 (백엔드 API 호출용)
  Map<String, dynamic> toQueryParameters({bool isStaffMode = false}) {
    final params = <String, dynamic>{
      'page': page,
      'size': size,
      'sortBy': sortBy.value,
      'isAsc': isAsc,
    };

    // 발제문 유형 필터 (백엔드에서 지원하는 경우만)
    if (presentationType != PresentationTypeOption.all) {
      params['meetingType'] = presentationType.backendValue;
    }

    // 오늘 모임 필터 (백엔드에서 지원하는 경우만)
    if (isTodayMeeting == true) {
      params['isTodayMeeting'] = true;
    }

    // 출석 상태 필터 (백엔드에서 지원하는 경우만)
    // 주석 처리: 백엔드에서 지원하지 않는 경우
    // if (attendanceStatus != AttendanceStatusOption.all) {
    //   params['attendanceStatus'] = attendanceStatus.backendValue;
    // }

    if (AppConfig.debugMode) {
      print('📋 [발제문 필터] 쿼리 파라미터: $params');
    }

    return params;
  }

  @override
  String toString() {
    return 'PresentationListFilter{page: $page, size: $size, presentationType: $presentationType, isTodayMeeting: $isTodayMeeting, attendanceStatus: $attendanceStatus, sortBy: $sortBy, isAsc: $isAsc}';
  }

  /// 필터가 기본값인지 확인
  bool get isDefault {
    return page == 1 &&
        size == 12 &&
        presentationType == PresentationTypeOption.all &&
        isTodayMeeting == null &&
        attendanceStatus == AttendanceStatusOption.all &&
        sortBy == PresentationSortBy.meetingDate &&
        isAsc == false;
  }

  /// 활성 필터 개수
  int get activeFilterCount {
    int count = 0;

    if (presentationType != PresentationTypeOption.all) count++;
    if (isTodayMeeting == true) count++;
    if (attendanceStatus != AttendanceStatusOption.all) count++;
    if (sortBy != PresentationSortBy.meetingDate || isAsc != false) count++;

    return count;
  }
}

/// 발제문 유형 옵션
enum PresentationTypeOption {
  all('전체', null),
  regular('정기', 'REGULAR'),
  flash('번개', 'FLASH'),
  special('특수', 'SPECIAL');

  const PresentationTypeOption(this.displayName, this.backendValue);

  final String displayName;
  final String? backendValue;
}

/// 출석 상태 옵션 (발제문용)
enum AttendanceStatusOption {
  all('전체', null),
  attend('참석', 'ATTEND'),
  attendLate('지각', 'ATTEND_LATE'),
  notAttend('불참', 'NOT_ATTEND'),
  notStarted('진행 전', 'NOT_STARTED');

  const AttendanceStatusOption(this.displayName, this.backendValue);

  final String displayName;
  final String? backendValue;
}

/// 발제문 정렬 기준
enum PresentationSortBy {
  meetingDate('모임일시', 'meetingDate'),
  id('등록순', 'id');

  const PresentationSortBy(this.displayName, this.value);

  final String displayName;
  final String value;
}
