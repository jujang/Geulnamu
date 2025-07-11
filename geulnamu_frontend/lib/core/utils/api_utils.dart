import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'dart:html' as html show document;
import '../config/app_config.dart';
import '../../widgets/common/error_dialog.dart';

/// 🔧 백엔드 API 통합 처리 유틸리티
/// 모든 서비스에서 백엔드 커스텀 응답 구조와 에러 처리를 일관되게 처리
class ApiUtils {
  // ⏰ API 타임아웃 설정 (초 단위)
  static const int connectionTimeoutSeconds = 5;
  static const int receiveTimeoutSeconds = 3;  // 적절한 사용자 경험을 위한 3초 설정
  static const int sendTimeoutSeconds = 5;

  /// 🔧 타임아웃이 설정된 Dio 인스턴스 생성
  static Dio createDioWithTimeout({
    String? baseUrl,
    Map<String, String>? headers,
  }) {
    final dio = Dio(BaseOptions(
      baseUrl: baseUrl ?? AppConfig.apiBaseUrl,
      connectTimeout: Duration(seconds: connectionTimeoutSeconds),
      receiveTimeout: Duration(seconds: receiveTimeoutSeconds),
      sendTimeout: Duration(seconds: sendTimeoutSeconds),
      headers: headers,
    ));

    if (AppConfig.debugMode) {
      print('🔧 [ApiUtils] Dio 인스턴스 생성 완료 (타임아웃: 연결=${connectionTimeoutSeconds}초, 수신=${receiveTimeoutSeconds}초)');
    }

    return dio;
  }
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

  /// 통합 DioException 처리 메서드 (에러 다이얼로그 포함)
  static Exception processDioException(
    DioException e, 
    String apiName, {
    BuildContext? context,
    bool showDialog = true,
  }) {
    if (AppConfig.debugMode) {
      print('❌ [$apiName] API 요청 오류: $e');
    }

    Exception resultException;
    
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        if (AppConfig.debugMode) {
          print('⏰ [$apiName] 타임아웃 에러 발생! 유형: ${e.type}');
          print('📊 [$apiName] 요청 시간: ${e.requestOptions.connectTimeout}');
          print('📊 [$apiName] 수신 시간: ${e.requestOptions.receiveTimeout}');
        }
        resultException = Exception('[$apiName] 서버 연결 시간이 초과되었습니다.');
        if (context != null && showDialog) {
          if (AppConfig.debugMode) {
            print('📦 [$apiName] 타임아웃 다이얼로그 표시 시도...');
          }
          ErrorDialog.showTimeoutError(context);
        } else {
          if (AppConfig.debugMode) {
            print('⚠️ [$apiName] 다이얼로그 표시 안함: context=${context != null}, showDialog=$showDialog');
          }
        }
        break;
        
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
          
          resultException = Exception('[$apiName] 백엔드 오류 (HTTP: $statusCode, 코드: $backendCode): $message');
        } else if (responseData is String) {
          message = responseData;
          resultException = Exception('[$apiName] 서버 오류 ($statusCode): $message');
        } else {
          resultException = Exception('[$apiName] 서버 오류 ($statusCode): $message');
        }
        
        if (context != null && showDialog) {
          ErrorDialog.showServerError(
            context,
            customMessage: message,
            errorCode: '$statusCode - $apiName',
          );
        }
        break;
        
      case DioExceptionType.connectionError:
        resultException = Exception('[$apiName] 서버에 연결할 수 없습니다.');
        if (context != null && showDialog) {
          ErrorDialog.showNetworkError(context);
        }
        break;
        
      case DioExceptionType.cancel:
        resultException = Exception('[$apiName] 요청이 취소되었습니다.');
        // 취소는 사용자 의도이므로 다이얼로그 표시 안함
        break;
        
      default:
        resultException = Exception('[$apiName] 네트워크 오류가 발생했습니다: ${e.message ?? '알 수 없는 오류'}');
        if (context != null && showDialog) {
          ErrorDialog.showErrorFromException(context, resultException, apiName: apiName);
        }
        break;
    }
    
    return resultException;
  }

  /// RefreshToken 추출 헬퍼 메서드
  static String? extractRefreshToken(Response response) {
    // 웹 환경에서는 브라우저 쿠키를 직접 읽기 (보안상 Dio가 Set-Cookie 헤더를 읽지 못함)
    if (kIsWeb) {
      try {
        final cookies = html.document.cookie ?? '';
        final cookieParts = cookies.split(';');
        
        for (final cookiePart in cookieParts) {
          final trimmed = cookiePart.trim();
          if (trimmed.startsWith('refreshToken=')) {
            final token = trimmed.substring('refreshToken='.length);
            
            if (AppConfig.debugMode) {
              print('🍪 리프레시 토큰 추출 성공: ${token.substring(0, 20)}...');
            }
            
            return token;
          }
        }
        
        if (AppConfig.debugMode) {
          print('⚠️ 브라우저 쿠키에서 refreshToken을 찾을 수 없음');
        }
      } catch (e) {
        if (AppConfig.debugMode) {
          print('❌ 브라우저 쿠키 읽기 오류: $e');
        }
      }
      return null;
    }
    
    // 비웹 환경: Response 헤더에서 찾기
    final setCookieHeader = response.headers['set-cookie'];
    if (setCookieHeader != null) {
      for (final cookie in setCookieHeader) {
        if (cookie.startsWith('refreshToken=')) {
          final tokenPart = cookie.split(';')[0];
          final token = tokenPart.split('=')[1];
          
          if (AppConfig.debugMode) {
            print('🍪 리프레시 토큰 추출 성공: ${token.substring(0, 20)}...');
          }
          
          return token;
        }
      }
    }
    
    return null;
  }
}
