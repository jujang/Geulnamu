import 'package:dio/dio.dart';
import '../../core/config/app_config.dart';
import '../../core/utils/api_utils.dart';
import '../../models/voc/voc_model.dart';
import '../../models/voc/voc_filter_model.dart';

/// VoC (문의함) 관리 서비스
///
/// 싱글톤 패턴으로 구현
class VoCService {
  static final VoCService _instance = VoCService._internal();
  factory VoCService() => _instance;
  VoCService._internal();

  final Dio _dio = Dio();

  /// 이슈 목록 조회 (관리자용)
  Future<VoCListResponse> getIssueList({
    required String accessToken,
    required int page,
    required VoCFilter filter,
  }) async {
    try {
      // 🔥 캐시 방지를 위한 타임스탬프 추가
      final queryParams = filter.toQueryParams(page);
      queryParams['_t'] = DateTime.now().millisecondsSinceEpoch.toString();

      final response = await _dio.get(
        AppConfig.getApiEndpoint('voc/list'),
        queryParameters: queryParams,
        options: Options(
          headers: {
            'Authorization': 'Bearer $accessToken',
            'Cache-Control': 'no-cache, no-store, must-revalidate',  // 🔥 캐시 방지
            'Pragma': 'no-cache',  // 🔥 HTTP/1.0 캐시 방지
            'Expires': '0',  // 🔥 캐시 만료
          },
        ),
      );

      if (response.statusCode == 200) {
        final processedResponse = ApiUtils.processBackendResponse(
          response,
          '이슈 목록 조회',
        );

        return VoCListResponse.fromJson(
          processedResponse['data'] as Map<String, dynamic>,
        );
      } else {
        throw Exception('[이슈 목록 조회] HTTP 오류: ${response.statusCode}');
      }
    } catch (e) {
      if (e is DioException) {
        throw ApiUtils.processDioException(e, '이슈 목록 조회');
      }
      rethrow;
    }
  }

  /// 이슈 상태 변경 (관리자용)
  Future<void> updateIssueStatus({
    required String accessToken,
    required int vocId,
    required IssueStatus newStatus,
    String? adminComment,
  }) async {
    try {
      final requestBody = <String, dynamic>{
        'issueStatus': newStatus.value,
      };

      if (adminComment != null && adminComment.isNotEmpty) {
        requestBody['adminComment'] = adminComment;
      }

      final response = await _dio.patch(
        AppConfig.getApiEndpoint('voc/$vocId/status'),
        data: requestBody,
        options: Options(
          headers: {'Authorization': 'Bearer $accessToken'},
        ),
      );

      if (response.statusCode == 200) {
        ApiUtils.processBackendResponse(
          response,
          '이슈 상태 변경',
          expectData: false,
        );
      } else {
        throw Exception('[이슈 상태 변경] HTTP 오류: ${response.statusCode}');
      }
    } catch (e) {
      if (e is DioException) {
        throw ApiUtils.processDioException(e, '이슈 상태 변경');
      }
      rethrow;
    }
  }
}
