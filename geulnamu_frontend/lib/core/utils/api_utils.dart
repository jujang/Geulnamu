import 'package:dio/dio.dart';
import '../config/app_config.dart';

/// 🔧 백엔드 API 통합 처리 유틸리티
/// 모든 서비스에서 백엔드 커스텀 응답 구조와 에러 처리를 일관되게 처리
class ApiUtils {
  /// 🔧 백엔드 커스텀 응답 구조 통합 처리 메서드
  static Map<String, dynamic> processBackendResponse(
    Response response, 
    String apiName,
    {bool expectData = true}
  ) {
    if (AppConfig.debugMode) {
      print('📝 [$apiName] 백엔드 응답 구조: ${response.data}');
    }

    final data = response.data;
    
    if (data is! Map) {
      throw Exception('[$apiName] 백엔드 응답 형식이 올바르지 않습니다: $data');
    }

    final responseCode = data['code'];
    final responseMessage = data['message'] ?? '알 수 없는 오류';
    final responseData = data['data'];
    
    if (AppConfig.debugMode) {
      print('📝 [$apiName] 비즈니스 코드: $responseCode');
      print('📝 [$apiName] 비즈니스 메시지: $responseMessage');
      if (responseData != null) {
        print('📝 [$apiName] 비즈니스 데이터: $responseData');
      }
    }
    
    if (responseCode == 200) {
      if (AppConfig.debugMode) {
        print('✅ [$apiName] 백엔드 처리 성공');
      }
      
      return {
        'success': true,
        'code': responseCode,
        'message': responseMessage,
        'data': responseData,
      };
    } else {
      throw Exception('[$apiName] 백엔드 오류 ($responseCode): $responseMessage');
    }
  }

  /// 통합 DioException 처리 메서드
  static Exception processDioException(DioException e, String apiName) {
    if (AppConfig.debugMode) {
      print('❌ [$apiName] API 요청 오류: $e');
    }

    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return Exception('[$apiName] 서버 연결 시간이 초과되었습니다.');
        
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode ?? 0;
        final responseData = e.response?.data;
        String message = '서버 오류가 발생했습니다.';
        
        if (AppConfig.debugMode) {
          print('📝 [$apiName] DioException badResponse 디버그:');
          print('HTTP Status: $statusCode');
          print('Response Data: $responseData');
        }
        
        if (responseData != null && responseData is Map) {
          final backendCode = responseData['code'];
          final backendMessage = responseData['message']?.toString();
          
          if (AppConfig.debugMode) {
            print('백엔드 코드: $backendCode');
            print('백엔드 메시지: $backendMessage');
          }
          
          if (backendMessage != null && backendMessage.isNotEmpty) {
            message = backendMessage;
          }
          
          return Exception('[$apiName] 백엔드 오류 (HTTP: $statusCode, 코드: $backendCode): $message');
        } else if (responseData is String) {
          message = responseData;
        }
        
        return Exception('[$apiName] 서버 오류 ($statusCode): $message');
        
      case DioExceptionType.connectionError:
        return Exception('[$apiName] 서버에 연결할 수 없습니다.');
        
      case DioExceptionType.cancel:
        return Exception('[$apiName] 요청이 취소되었습니다.');
        
      default:
        return Exception('[$apiName] 네트워크 오류가 발생했습니다: ${e.message ?? '알 수 없는 오류'}');
    }
  }

  /// RefreshToken 추출 헬퍼 메서드
  static String? extractRefreshToken(Response response) {
    final setCookieHeader = response.headers['set-cookie'];
    if (setCookieHeader != null) {
      for (final cookie in setCookieHeader) {
        if (cookie.startsWith('refreshToken=')) {
          final tokenPart = cookie.split(';')[0];
          final token = tokenPart.split('=')[1];
          
          if (AppConfig.debugMode) {
            print('🍪 리프레시 토큰 추출: ${token.substring(0, 20)}...');
          }
          
          return token;
        }
      }
    }
    
    if (AppConfig.debugMode) {
      print('⚠️ Set-Cookie 헤더에서 refreshToken을 찾을 수 없습니다');
    }
    
    return null;
  }
}
