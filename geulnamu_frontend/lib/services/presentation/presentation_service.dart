import 'package:dio/dio.dart';
import '../../core/config/app_config.dart';
import '../../core/utils/api_utils.dart';
import '../../models/presentation/presentation_model.dart';
import '../../models/presentation/presentation_filter_model.dart';

/// 발제문 관리 서비스 (Singleton)
///
/// 제공 기능:
/// - 발제문 목록 조회 (모임 목록 API 활용)
/// - 향후: 발제문 작성, 수정, 삭제 등
class PresentationService {
  static final PresentationService _instance = PresentationService._internal();
  factory PresentationService() => _instance;
  PresentationService._internal() {
    // 🔧 생성자에서 즉시 Dio 초기화
    _dio = ApiUtils.createDioWithTimeout(baseUrl: AppConfig.apiBaseUrl);
  }

  late final Dio _dio;

  /// 발제문 목록 조회
  ///
  /// API: GET /meetings/list (기존 모임 목록 API 활용)
  /// 권한: MEMBER 이상
  Future<PresentationListResponse> getPresentationList({
    required PresentationListFilter filter,
    required String accessToken,
  }) async {
    try {
      if (AppConfig.debugMode) {
        print('🚀 [발제문 목록 조회] API 요청 시작...');
      }
      
      // 🔥 강제 캐시 버스트 추가
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final queryParams = filter.toQueryParameters();
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
          '발제문 목록 조회',
        );

        final presentationListResponse = PresentationListResponse.fromJson(
          processedResponse['data'],
        );

        if (AppConfig.debugMode) {
          print('✅ [발제문 목록 조회] 성공 - 총 ${presentationListResponse.presentationList.length}개 발제문, 페이지: ${presentationListResponse.pagingResponse.pageNumber}/${presentationListResponse.pagingResponse.totalPages}');
        }

        return presentationListResponse;
      } else {
        throw Exception('[발제문 목록 조회] HTTP 오류: ${response.statusCode}');
      }
    } catch (e) {
      if (e is DioException) {
        throw ApiUtils.processDioException(e, '발제문 목록 조회');
      }
      rethrow;
    }
  }

  /// 발제문 상세 조회 (향후 구현)
  ///
  /// API: GET /meetings/{meetingId}/presentation (가상 API)
  /// 권한: MEMBER 이상
  Future<void> getPresentationDetail({
    required int meetingId,
    required String accessToken,
  }) async {
    // TODO: 향후 발제문 상세 API 구현 시 활용
    if (AppConfig.debugMode) {
      print('🔮 [발제문 상세 조회] 향후 구현 예정 - meetingId: $meetingId');
    }
  }

  /// 발제문 작성 (향후 구현)
  ///
  /// API: POST /meetings/{meetingId}/presentation (가상 API)
  /// 권한: MEMBER 이상
  Future<void> createPresentation({
    required int meetingId,
    required String content,
    required String accessToken,
  }) async {
    // TODO: 향후 발제문 작성 API 구현 시 활용
    if (AppConfig.debugMode) {
      print('🔮 [발제문 작성] 향후 구현 예정 - meetingId: $meetingId');
    }
  }

  /// 발제문 수정 (향후 구현)
  ///
  /// API: PATCH /meetings/{meetingId}/presentation (가상 API)
  /// 권한: MEMBER 이상 (본인 작성 발제문만)
  Future<void> updatePresentation({
    required int meetingId,
    required String content,
    required String accessToken,
  }) async {
    // TODO: 향후 발제문 수정 API 구현 시 활용
    if (AppConfig.debugMode) {
      print('🔮 [발제문 수정] 향후 구현 예정 - meetingId: $meetingId');
    }
  }

  /// 발제문 삭제 (향후 구현)
  ///
  /// API: DELETE /meetings/{meetingId}/presentation (가상 API)
  /// 권한: MEMBER 이상 (본인 작성 발제문만)
  Future<void> deletePresentation({
    required int meetingId,
    required String accessToken,
  }) async {
    // TODO: 향후 발제문 삭제 API 구현 시 활용
    if (AppConfig.debugMode) {
      print('🔮 [발제문 삭제] 향후 구현 예정 - meetingId: $meetingId');
    }
  }

  /// 발제문 상세 페이지 이동 처리
  void handlePresentationDetail(int meetingId) {
    if (AppConfig.debugMode) {
      print('🎯 [PresentationService] 발제문 상세 페이지 이동: meetingId=$meetingId');
    }

    // TODO: 향후 발제문 상세 페이지 구현 시 아래 코드 활성화
    // Navigator.pushNamed(context, '/presentation/$meetingId');
  }
}
