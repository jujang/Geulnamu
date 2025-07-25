import 'package:dio/dio.dart';
import '../../core/config/app_config.dart';
import '../../core/utils/api_utils.dart';
import '../../models/meeting/meeting_model.dart';
import '../../models/meeting/meeting_filter_model.dart';
import '../../models/meeting/request/meeting_create_request.dart';

/// 모임 관리 서비스 (Singleton)
/// 
/// 제공 기능:
/// - 모임 목록 조회
/// - 모임 생성
/// - 향후: 모임 수정, 삭제 등
class MeetingService {
  static final MeetingService _instance = MeetingService._internal();
  factory MeetingService() => _instance;
  MeetingService._internal();

  final Dio _dio = Dio();

  /// 서비스 초기화
  void initialize() {
    _dio.options.baseUrl = AppConfig.apiBaseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 5);
    _dio.options.receiveTimeout = const Duration(seconds: 3);
  }

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
        print('🚀 [모임 목록 조회] API 요청 시작...');
      }

      final response = await _dio.get(
        '/meetings/list',
        queryParameters: filter.toQueryParameters(isStaffMode: isStaffMode), // 🆕 isStaffMode 전달
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
          '모임 목록 조회',
        );

        final meetingListResponse = MeetingListResponse.fromJson(processedResponse['data']);
        
        if (AppConfig.debugMode) {
          print('✅ [모임 목록 조회] 성공 - 총 ${meetingListResponse.meetingList.length}개 모임 로드');
        }

        return meetingListResponse;
      } else {
        throw Exception('[모임 목록 조회] HTTP 오류: ${response.statusCode}');
      }
    } catch (e) {
      if (AppConfig.debugMode) {
        print('❌ [모임 목록 조회] 오류 발생: $e');
      }
      
      if (e is DioException) {
        throw ApiUtils.processDioException(e, '모임 목록 조회');
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
