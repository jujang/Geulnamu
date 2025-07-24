import 'package:dio/dio.dart';
import '../../core/config/app_config.dart';
import '../../core/utils/api_utils.dart';
import '../../models/meeting/meeting_model.dart';
import '../../models/meeting/meeting_filter_model.dart';

/// 모임 관리 서비스 (Singleton)
/// 
/// 제공 기능:
/// - 모임 목록 조회
/// - 향후: 모임 생성, 수정, 삭제 등
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
    
    if (AppConfig.debugMode) {
      print('🔧 [MeetingService] 서비스 초기화 완료');
    }
  }

  /// 모임 목록 조회
  /// 
  /// API: GET /meetings/list
  /// 권한: MEMBER 이상
  Future<MeetingListResponse> getMeetingList({
    required MeetingListFilter filter,
    required String accessToken,
  }) async {
    try {
      if (AppConfig.debugMode) {
        print('🚀 [모임 목록 조회] API 요청 시작... 필터: $filter');
        print('🔍 [모임 목록 조회] 쿼리 파라미터: ${filter.toQueryParameters()}');
      }

      final response = await _dio.get(
        '/meetings/list',
        queryParameters: filter.toQueryParameters(),
        options: Options(
          headers: {
            'Authorization': 'Bearer $accessToken',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        if (AppConfig.debugMode) {
          print('📝 [모임 목록 조회] HTTP 응늵 성공 (${response.statusCode})');
          print('📝 [모임 목록 조회] Raw 응늵: ${response.data}');
        }

        final processedResponse = ApiUtils.processBackendResponse(
          response,
          '모임 목록 조회',
        );

        if (AppConfig.debugMode) {
          print('📝 [모임 목록 조회] 처리된 응늵: ${processedResponse['data']}');
        }

        return MeetingListResponse.fromJson(processedResponse['data']);
      } else {
        throw Exception('[모임 목록 조회] HTTP 오류: ${response.statusCode}');
      }
    } catch (e) {
      if (AppConfig.debugMode) {
        print('❌ [모임 목록 조회] 에러 상세: $e');
        if (e is TypeError) {
          print('🔍 [모임 목록 조회] TypeError 발생 - 데이터 타입 문제 의심');
        }
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
    if (AppConfig.debugMode) {
      print('🎯 [MeetingService] 출석현황 확인 버튼 클릭 - 모임 ID: $meetingId');
      print('📝 [MeetingService] 향후 출석현황 페이지로 이동 예정');
    }

    // TODO: 향후 출석현황 페이지 구현 시 아래 코드 활성화
    // Navigator.pushNamed(context, '/meeting/$meetingId/attendance');
  }
}
