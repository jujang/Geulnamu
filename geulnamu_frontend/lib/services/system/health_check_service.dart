import 'package:dio/dio.dart';
import '../../core/config/app_config.dart';
import '../../core/utils/api_utils.dart';

/// 🏥 헬스 체크 서비스
///
/// 백엔드 서버의 상태를 확인하는 서비스
/// - Health Check API 호출
/// - 서버 응답 시간 측정
class HealthCheckService {
  // 싱글톤 패턴
  static final HealthCheckService _instance = HealthCheckService._internal();
  factory HealthCheckService() => _instance;
  HealthCheckService._internal();

  final Dio _dio = ApiUtils.createDioWithTimeout(
    enableInterceptorLogging: false, // Health Check는 인터셉터 로깅 비활성화
  );

  /// 🏥 헬스 체크 API 호출
  ///
  /// 반환값:
  /// - success: API 호출 성공 여부
  /// - message: 응답 메시지
  /// - responseTime: 서버 응답 시간 (ms)
  Future<Map<String, dynamic>> checkHealth() async {
    final stopwatch = Stopwatch()..start();

    try {
      // 🏥 요청 시작
      if (AppConfig.debugMode) {
        print('🏥 [Health Check] 요청 시작...');
      }

      final response = await _dio.get(
        AppConfig.getApiEndpoint('hello/health-check'),
      );

      stopwatch.stop();
      final responseTime = stopwatch.elapsedMilliseconds;

      if (response.statusCode == 200) {
        // ✅ ApiUtils로 백엔드 응답 처리
        final processedResponse = ApiUtils.processBackendResponse(
          response,
          'Health Check',
          expectData: false,
        );

        // ✅ 응답 및 결과
        if (AppConfig.debugMode) {
          print('✅ [Health Check] 응답 받음: ${response.statusCode} (${responseTime}ms)');
        }

        return {
          'success': processedResponse['success'],
          'message': processedResponse['message'],
          'responseTime': responseTime,
        };
      } else {
        if (AppConfig.debugMode) {
          print('❌ [Health Check] HTTP 오류: ${response.statusCode}');
        }
        throw Exception('[Health Check] HTTP 오류: ${response.statusCode}');
      }
    } catch (e) {
      stopwatch.stop();
      final responseTime = stopwatch.elapsedMilliseconds;

      // ❌ 에러 발생
      if (AppConfig.debugMode) {
        print('❌ [Health Check] 에러: $e (${responseTime}ms)');
      }

      // ✅ ApiUtils로 에러 처리
      if (e is DioException) {
        final exception = ApiUtils.processDioException(e, 'Health Check');
        
        return {
          'success': false,
          'message': exception.toString(),
          'responseTime': responseTime,
        };
      }

      return {
        'success': false,
        'message': e.toString(),
        'responseTime': responseTime,
      };
    }
  }

  /// 🏥 헬스 체크 (간단한 버전 - 성공/실패만)
  Future<bool> isServerHealthy() async {
    try {
      final result = await checkHealth();
      return result['success'] == true;
    } catch (e) {
      return false;
    }
  }
}
