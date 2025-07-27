import 'package:dio/dio.dart';
import '../../core/config/app_config.dart';
import '../../core/utils/api_utils.dart';
import '../../models/meeting/meeting_model.dart';
import '../../models/meeting/meeting_filter_model.dart';
import '../../models/meeting/request/meeting_create_request.dart';
import '../../models/meeting/meeting_detail_model.dart';
import '../../models/meeting/meeting_detail_staff_model.dart';
import '../../models/meeting/request/meeting_update_requests.dart';

/// 모임 관리 서비스 (Singleton)
///
/// 제공 기능:
/// - 모임 목록 조회
/// - 모임 생성
/// - 향후: 모임 수정, 삭제 등
class MeetingService {
  static final MeetingService _instance = MeetingService._internal();
  factory MeetingService() => _instance;
  MeetingService._internal() {
    // 🔧 생성자에서 즉시 Dio 초기화
    _dio = ApiUtils.createDioWithTimeout(baseUrl: AppConfig.apiBaseUrl);
  }

  late final Dio _dio;

  /// 모임 생성
  ///
  /// API: POST /meetings/create
  /// 권한: STAFF 이상
  Future<int> createMeeting({
    required MeetingCreateRequest request,
    required String accessToken,
  }) async {
    try {
      if (AppConfig.debugMode) {
        print('🚀 [모임 생성] API 요청 시작...');
        print('🔗 [모임 생성] 요청 URL: ${_dio.options.baseUrl}/meetings/create');
        print('📝 [모임 생성] 요청 데이터: ${request.toString()}');
      }

      final response = await _dio.post(
        '/meetings/create',
        data: request.toJson(),
        options: Options(
          headers: {
            'Authorization': 'Bearer $accessToken',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        final processedResponse = ApiUtils.processBackendResponse(
          response,
          '모임 생성',
        );

        final meetingId = processedResponse['data'] as int;

        if (AppConfig.debugMode) {
          print('✅ [모임 생성] 성공 - 생성된 모임 ID: $meetingId');
        }

        return meetingId;
      } else {
        throw Exception('[모임 생성] HTTP 오류: ${response.statusCode}');
      }
    } catch (e) {
      if (AppConfig.debugMode) {
        print('❌ [모임 생성] 오류 발생: $e');
      }

      if (e is DioException) {
        throw ApiUtils.processDioException(e, '모임 생성');
      }
      rethrow;
    }
  }

  /// 모임 목록 조회
  ///
  /// API: GET /meetings/list
  /// 권한: MEMBER 이상
  Future<MeetingListResponse> getMeetingList({
    required MeetingListFilter filter,
    required String accessToken,
    bool isStaffMode = false, // 🆕 운영진용 모드 여부
  }) async {
    try {
      if (AppConfig.debugMode) {
        print('🚀 [모임 목록 조회] API 요청 시작... (${isStaffMode ? "운영진용" : "일반용"})');
      }
      
      // 🔥 강제 캐시 버스트 추가
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final queryParams = filter.toQueryParameters(isStaffMode: isStaffMode);
      queryParams['_cache_bust'] = timestamp.toString();
      queryParams['_t'] = timestamp.toString();
      queryParams['_refresh'] = 'true';

      if (AppConfig.debugMode) {
        print('📅 [캐시 무효화] GET /meetings/list?${queryParams.entries.map((e) => '${e.key}=${e.value}').join('&')}');
      }

      final response = await _dio.get(
        '/meetings/list',
        queryParameters: queryParams,
        options: Options(
          headers: {
            'Authorization': 'Bearer $accessToken',
            'Content-Type': 'application/json',
            // 🔥 강력한 캐시 무효화 헤더
            'Cache-Control': 'no-cache, no-store, must-revalidate, max-age=0',
            'Pragma': 'no-cache',
            'Expires': '0',
            'If-Modified-Since': 'Mon, 26 Jul 1997 05:00:00 GMT',
            'X-Requested-With': 'XMLHttpRequest',
          },
        ),
      );

      if (response.statusCode == 200) {
        final processedResponse = ApiUtils.processBackendResponse(
          response,
          '모임 목록 조회',
        );

        final meetingListResponse = MeetingListResponse.fromJson(
          processedResponse['data'],
        );

        if (AppConfig.debugMode) {
          print('✅ [모임 목록 조회] 성공 - 총 ${meetingListResponse.meetingList.length}개 모임, 페이지: ${meetingListResponse.pagingResponse.pageNumber}/${meetingListResponse.pagingResponse.totalPages}');
        }

        return meetingListResponse;
      } else {
        throw Exception('[모임 목록 조회] HTTP 오류: ${response.statusCode}');
      }
    } catch (e) {
      if (e is DioException) {
        throw ApiUtils.processDioException(e, '모임 목록 조회');
      }
      rethrow;
    }
  }

  /// 모임 상세 조회
  ///
  /// API: GET /meetings/{meetingId}
  /// 권한: MEMBER 이상
  Future<MeetingDetailInfo> getMeetingDetail({
    required int meetingId,
    required String accessToken,
  }) async {
    try {
      final response = await _dio.get(
        '/meetings/$meetingId',
        options: Options(
          headers: {
            'Authorization': 'Bearer $accessToken',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        final processedResponse = ApiUtils.processBackendResponse(
          response,
          '모임 상세 조회',
        );

        final meetingDetail = MeetingDetailInfo.fromJson(
          processedResponse['data'],
        );

        return meetingDetail;
      } else {
        throw Exception('[모임 상세 조회] HTTP 오류: ${response.statusCode}');
      }
    } catch (e) {
      if (e is DioException) {
        throw ApiUtils.processDioException(e, '모임 상세 조회');
      }
      rethrow;
    }
  }

  /// 운영진용 모임 상세 조회
  /// 
  /// API: GET /meetings/{meetingId}/staff
  /// 권한: STAFF 이상
  Future<MeetingDetailStaffInfo> getMeetingDetailForStaff({
  required int meetingId,
  required String accessToken,
    bool forceRefresh = false, // 강제 새로고침 옵션
  }) async {
  try {
  if (AppConfig.debugMode) {
    print('🚀 [운영진용 모임 상세 조회] API 요청 시작...');
        if (forceRefresh) {
      print('📅 [캐시 무효화] GET /meetings/$meetingId/staff');
  }
  }

  // 강제 새로고침 시 캐시 버스트 매개변수 추가
  final Map<String, dynamic> queryParams = {};
  if (forceRefresh) {
  final timestamp = DateTime.now().millisecondsSinceEpoch;
    queryParams['_cache_bust'] = timestamp.toString();
        queryParams['_t'] = timestamp.toString();
        queryParams['_refresh'] = 'true';
      }

      final response = await _dio.get(
        '/meetings/$meetingId/staff',
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
        options: Options(
          headers: {
            'Authorization': 'Bearer $accessToken',
            'Content-Type': 'application/json',
            // 강제 새로고침 시 강력한 캐시 무효화 헤더
            if (forceRefresh) ...{
              'Cache-Control': 'no-cache, no-store, must-revalidate, max-age=0',
              'Pragma': 'no-cache',
              'Expires': '0',
              'If-Modified-Since': 'Mon, 26 Jul 1997 05:00:00 GMT',
              'X-Requested-With': 'XMLHttpRequest',
            },
          },
        ),
      );

      if (response.statusCode == 200) {
        final processedResponse = ApiUtils.processBackendResponse(
          response,
          '운영진용 모임 상세 조회',
        );

        final meetingDetail = MeetingDetailStaffInfo.fromJson(
          processedResponse['data'],
        );

        return meetingDetail;
      } else {
        throw Exception('[운영진용 모임 상세 조회] HTTP 오류: ${response.statusCode}');
      }
    } catch (e) {
      if (e is DioException) {
        throw ApiUtils.processDioException(e, '운영진용 모임 상세 조회');
      }
      rethrow;
    }
  }

  /// 모임 기본 정보 수정
  ///
  /// API: PATCH /meetings/{meetingId}/basic
  /// 권한: STAFF 이상
  Future<void> updateMeetingBasicInfo({
    required int meetingId,
    required MeetingBasicUpdateRequest request,
    required String accessToken,
  }) async {
    try {
      if (AppConfig.debugMode) {
        print('🚀 [모임 기본 정보 수정] API 요청 시작...');
        print('📝 [모임 기본 정보 수정] 요청 데이터: ${request.toString()}');
      }

      final response = await _dio.patch(
        '/meetings/$meetingId/basic',
        data: request.toJson(),
        options: Options(
          headers: {
            'Authorization': 'Bearer $accessToken',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        final processedResponse = ApiUtils.processBackendResponse(
          response,
          '모임 기본 정보 수정',
        );

        if (AppConfig.debugMode) {
          print('✅ [모임 기본 정보 수정] 성공');
        }
      } else {
        throw Exception('[모임 기본 정보 수정] HTTP 오류: ${response.statusCode}');
      }
    } catch (e) {
      if (e is DioException) {
        throw ApiUtils.processDioException(e, '모임 기본 정보 수정');
      }
      rethrow;
    }
  }

  /// 토론 정보 수정
  ///
  /// API: PATCH /meetings/{meetingId}/discussion
  /// 권한: STAFF 이상
  Future<void> updateMeetingDiscussionInfo({
    required int meetingId,
    required MeetingDiscussionUpdateRequest request,
    required String accessToken,
  }) async {
    try {
      if (AppConfig.debugMode) {
        print('🚀 [토론 정보 수정] API 요청 시작...');
        print('📝 [토론 정보 수정] 요청 데이터: ${request.toString()}');
      }

      final response = await _dio.patch(
        '/meetings/$meetingId/discussion',
        data: request.toJson(),
        options: Options(
          headers: {
            'Authorization': 'Bearer $accessToken',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        final processedResponse = ApiUtils.processBackendResponse(
          response,
          '토론 정보 수정',
        );

        if (AppConfig.debugMode) {
          print('✅ [토론 정보 수정] 성공');
        }
      } else {
        throw Exception('[토론 정보 수정] HTTP 오류: ${response.statusCode}');
      }
    } catch (e) {
      if (e is DioException) {
        throw ApiUtils.processDioException(e, '토론 정보 수정');
      }
      rethrow;
    }
  }

  /// 모임 삭제
  ///
  /// API: DELETE /meetings/{meetingId}/remove
  /// 권한: STAFF 이상 (생성자) 또는 관리자
  Future<void> deleteMeeting({
    required int meetingId,
    required String accessToken,
  }) async {
    try {
      if (AppConfig.debugMode) {
        print('🚀 [모임 삭제] API 요청 시작...');
      }

      final response = await _dio.delete(
        '/meetings/$meetingId/remove',
        options: Options(
          headers: {
            'Authorization': 'Bearer $accessToken',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        final processedResponse = ApiUtils.processBackendResponse(
          response,
          '모임 삭제',
        );

        if (AppConfig.debugMode) {
          print('✅ [모임 삭제] 성공');
        }
      } else {
        throw Exception('[모임 삭제] HTTP 오류: ${response.statusCode}');
      }
    } catch (e) {
      if (e is DioException) {
        throw ApiUtils.processDioException(e, '모임 삭제');
      }
      rethrow;
    }
  }

  /// 모임 비공개 처리
  ///
  /// API: PATCH /meetings/{meetingId}/make-private
  /// 권한: 관리자 (ADMIN, LEADER, VICE_LEADER)
  Future<void> makeMeetingPrivate({
    required int meetingId,
    required String accessToken,
  }) async {
    try {
      if (AppConfig.debugMode) {
        print('🚀 [모임 비공개 처리] API 요청 시작...');
      }

      final response = await _dio.patch(
        '/meetings/$meetingId/make-private',
        options: Options(
          headers: {
            'Authorization': 'Bearer $accessToken',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        final processedResponse = ApiUtils.processBackendResponse(
          response,
          '모임 비공개 처리',
        );

        if (AppConfig.debugMode) {
          print('✅ [모임 비공개 처리] 성공');
        }
      } else {
        throw Exception('[모임 비공개 처리] HTTP 오류: ${response.statusCode}');
      }
    } catch (e) {
      if (e is DioException) {
        throw ApiUtils.processDioException(e, '모임 비공개 처리');
      }
      rethrow;
    }
  }

  /// 모임 공개 처리
  ///
  /// API: PATCH /meetings/{meetingId}/make-public
  /// 권한: 관리자 (ADMIN, LEADER, VICE_LEADER)
  Future<void> makeMeetingPublic({
    required int meetingId,
    required String accessToken,
  }) async {
    try {
      if (AppConfig.debugMode) {
        print('🚀 [모임 공개 처리] API 요청 시작...');
      }

      final response = await _dio.patch(
        '/meetings/$meetingId/make-public',
        options: Options(
          headers: {
            'Authorization': 'Bearer $accessToken',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        final processedResponse = ApiUtils.processBackendResponse(
          response,
          '모임 공개 처리',
        );

        if (AppConfig.debugMode) {
          print('✅ [모임 공개 처리] 성공');
        }
      } else {
        throw Exception('[모임 공개 처리] HTTP 오류: ${response.statusCode}');
      }
    } catch (e) {
      if (e is DioException) {
        throw ApiUtils.processDioException(e, '모임 공개 처리');
      }
      rethrow;
    }
  }

  /// 출석현황 확인 처리 (향후 구현 예정)
  ///
  /// [meetingId] 모임 ID
  void handleAttendanceCheck(int meetingId) {
    // TODO: 향후 출석현황 페이지 구현 시 아래 코드 활성화
    // Navigator.pushNamed(context, '/meeting/$meetingId/attendance');
  }
}
