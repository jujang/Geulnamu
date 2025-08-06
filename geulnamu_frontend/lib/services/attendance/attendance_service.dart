import 'package:dio/dio.dart';
import '../../core/config/app_config.dart';
import '../../core/utils/api_utils.dart';
import '../../models/attendance/request/attendance_note_request.dart';
import '../../models/attendance/attendance_status_model.dart';

/// 출석 관리 서비스 (Singleton)
/// 
/// 제공 기능:
/// - 모임 출석 체크인
/// - 본인 출석 정보 조회
/// - 모임별 출석 현황 조회
/// - 비고 작성
/// - 토론 참석 의사 변경
/// - 출석 삭제 (관리자급)
class AttendanceService {
  static final AttendanceService _instance = AttendanceService._internal();
  factory AttendanceService() => _instance;
  
  // 🔧 Dio 인스턴스 선언 (상단으로 이동)
  late final Dio _dio;
  
  AttendanceService._internal() {
    // 🔧 생성자에서 즉시 Dio 초기화
    _dio = ApiUtils.createDioWithTimeout(
      baseUrl: AppConfig.apiBaseUrl,
    );
  }

  /// 모임 출석 체크인
  /// 
  /// API: POST /attendances/check-in?meetingId={meetingId}
  /// 권한: MEMBER 이상
  Future<int> checkIn({
    required int meetingId,
    required String accessToken,
  }) async {
    try {
      if (AppConfig.debugMode) {
        print('🚀 [출석 체크인] API 요청 시작...');
        print('🔗 [출석 체크인] 요청 URL: ${_dio.options.baseUrl}/attendances/check-in?meetingId=$meetingId');
      }

      final response = await _dio.post(
        '/attendances/check-in',
        queryParameters: {'meetingId': meetingId},
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
          '출석 체크인',
        );

        final attendanceId = processedResponse['data'] as int;
        
        if (AppConfig.debugMode) {
          print('✅ [출석 체크인] 성공 - 출석 ID: $attendanceId');
        }

        return attendanceId;
      } else {
        throw Exception('[출석 체크인] HTTP 오류: ${response.statusCode}');
      }
    } catch (e) {
      if (AppConfig.debugMode) {
        print('❌ [출석 체크인] 오류 발생: $e');
      }
      
      if (e is DioException) {
        throw ApiUtils.processDioException(e, '출석 체크인');
      }
      rethrow;
    }
  }

  /// 비고 작성
  /// 
  /// API: PATCH /attendances/{attendanceId}/note
  /// 권한: MEMBER 이상 (본인 출석만 수정 가능)
  Future<void> writeNote({
    required int attendanceId,
    required String note,
    required String accessToken,
  }) async {
    try {
      if (AppConfig.debugMode) {
        print('🚀 [비고 작성] API 요청 시작...');
        print('🔗 [비고 작성] 요청 URL: ${_dio.options.baseUrl}/attendances/$attendanceId/note');
        print('📝 [비고 작성] 비고 내용: $note');
      }

      final request = AttendanceNoteRequest(note: note);

      final response = await _dio.patch(
        '/attendances/$attendanceId/note',
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
          '비고 작성',
          expectData: false, // Void 응답이므로 data 없음
        );
        
        if (AppConfig.debugMode) {
          print('✅ [비고 작성] 성공');
        }
      } else {
        throw Exception('[비고 작성] HTTP 오류: ${response.statusCode}');
      }
    } catch (e) {
      if (AppConfig.debugMode) {
        print('❌ [비고 작성] 오류 발생: $e');
      }
      
      if (e is DioException) {
        throw ApiUtils.processDioException(e, '비고 작성');
      }
      rethrow;
    }
  }

  /// 독서만 할래요 (토론 불참)
  /// 
  /// API: PATCH /attendances/{attendanceId}/just-read
  /// 권한: MEMBER 이상
  Future<void> setJustRead({
    required int attendanceId,
    required String accessToken,
  }) async {
    try {
      if (AppConfig.debugMode) {
        print('🚀 [독서만 할래요] API 요청 시작...');
      }

      final response = await _dio.patch(
        '/attendances/$attendanceId/just-read',
        options: Options(
          headers: {
            'Authorization': 'Bearer $accessToken',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        ApiUtils.processBackendResponse(
          response,
          '독서만 할래요',
          expectData: false,
        );
        
        if (AppConfig.debugMode) {
          print('✅ [독서만 할래요] 성공');
        }
      } else {
        throw Exception('[독서만 할래요] HTTP 오류: ${response.statusCode}');
      }
    } catch (e) {
      if (AppConfig.debugMode) {
        print('❌ [독서만 할래요] 오류 발생: $e');
      }
      
      if (e is DioException) {
        throw ApiUtils.processDioException(e, '독서만 할래요');
      }
      rethrow;
    }
  }

  /// 토론할래요 (토론 참석)
  /// 
  /// API: PATCH /attendances/{attendanceId}/want-discussion
  /// 권한: MEMBER 이상
  Future<void> setWantDiscussion({
    required int attendanceId,
    required String accessToken,
  }) async {
    try {
      if (AppConfig.debugMode) {
        print('🚀 [토론할래요] API 요청 시작...');
      }

      final response = await _dio.patch(
        '/attendances/$attendanceId/want-discussion',
        options: Options(
          headers: {
            'Authorization': 'Bearer $accessToken',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        ApiUtils.processBackendResponse(
          response,
          '토론할래요',
          expectData: false,
        );
        
        if (AppConfig.debugMode) {
          print('✅ [토론할래요] 성공');
        }
      } else {
        throw Exception('[토론할래요] HTTP 오류: ${response.statusCode}');
      }
    } catch (e) {
      if (AppConfig.debugMode) {
        print('❌ [토론할래요] 오류 발생: $e');
      }
      
      if (e is DioException) {
        throw ApiUtils.processDioException(e, '토론할래요');
      }
      rethrow;
    }
  }

  /// 모임별 출석 현황 조회
  /// 
  /// API: GET /attendances/list?meetingId={meetingId}
  /// 권한: MEMBER 이상
  Future<MeetingAttendanceDetails> getMeetingAttendanceStatus({
    required int meetingId,
    required String accessToken,
  }) async {
    try {
      if (AppConfig.debugMode) {
        print('🚀 [출석 현황 조회] API 요청 시작...');
        print('🔗 [출석 현황 조회] 요청 URL: ${_dio.options.baseUrl}/attendances/list?meetingId=$meetingId');
      }

      final response = await _dio.get(
        '/attendances/list',
        queryParameters: {'meetingId': meetingId},
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
          '출석 현황 조회',
        );

        final attendanceDetails = MeetingAttendanceDetails.fromJson(
          processedResponse['data'] as Map<String, dynamic>
        );
        
        if (AppConfig.debugMode) {
          print('✅ [출석 현황 조회] 성공 - 출석자 ${attendanceDetails.attendanceList.length}명');
        }

        return attendanceDetails;
      } else {
        throw Exception('[출석 현황 조회] HTTP 오류: ${response.statusCode}');
      }
    } catch (e) {
      if (AppConfig.debugMode) {
        print('❌ [출석 현황 조회] 오류 발생: $e');
      }
      
      if (e is DioException) {
        throw ApiUtils.processDioException(e, '출석 현황 조회');
      }
      rethrow;
    }
  }

  /// 모임별 출석 현황 조회 (전체 출석자 목록)
  /// 
  /// API: GET /attendances/list?meetingId={meetingId}
  /// 권한: MEMBER 이상
  Future<MeetingAttendanceDetails> getMeetingAttendanceStatus({
    required int meetingId,
    required String accessToken,
  }) async {
    try {
      if (AppConfig.debugMode) {
        print('🚀 [모임 출석 현황 조회] API 요청 시작...');
        print('🔗 [모임 출석 현황 조회] 요청 URL: ${_dio.options.baseUrl}/attendances/list?meetingId=$meetingId');
      }

      final response = await _dio.get(
        '/attendances/list',
        queryParameters: {'meetingId': meetingId},
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
          '모임 출석 현황 조회',
        );
        
        final attendanceDetails = MeetingAttendanceDetails.fromJson(
          processedResponse['data'] as Map<String, dynamic>,
        );
        
        if (AppConfig.debugMode) {
          print('✅ [모임 출석 현황 조회] 성공 - 총 출석자: ${attendanceDetails.attendanceList.length}명');
        }
        
        return attendanceDetails;
      } else {
        throw Exception('[모임 출석 현황 조회] HTTP 오류: ${response.statusCode}');
      }
    } catch (e) {
      if (AppConfig.debugMode) {
        print('❌ [모임 출석 현황 조회] 오류 발생: $e');
      }
      
      if (e is DioException) {
        throw ApiUtils.processDioException(e, '모임 출석 현황 조회');
      }
      rethrow;
    }
  }

  /// 출석 삭제
  /// 
  /// API: DELETE /attendances/{attendanceId}
  /// 권한: ADMIN 이상 (관리자급)
  Future<void> deleteAttendance({
    required int attendanceId,
    required String accessToken,
  }) async {
    try {
      if (AppConfig.debugMode) {
        print('🚀 [출석 삭제] API 요청 시작...');
        print('🔗 [출석 삭제] 요청 URL: ${_dio.options.baseUrl}/attendances/$attendanceId');
      }

      final response = await _dio.delete(
        '/attendances/$attendanceId',
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
          '출석 삭제',
          expectData: false, // Void 응답이므로 data 없음
        );
        
        if (AppConfig.debugMode) {
          print('✅ [출석 삭제] 성공 - attendanceId: $attendanceId');
        }
      } else {
        throw Exception('[출석 삭제] HTTP 오류: ${response.statusCode}');
      }
    } catch (e) {
      if (AppConfig.debugMode) {
        print('❌ [출석 삭제] 오류 발생: $e');
      }
      
      if (e is DioException) {
        throw ApiUtils.processDioException(e, '출석 삭제');
      }
      rethrow;
    }
  }
}
