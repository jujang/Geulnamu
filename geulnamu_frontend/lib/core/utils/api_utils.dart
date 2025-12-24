import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';  // 🎯 GoRouter import 추가
import 'dart:html' as html show document;
import '../config/app_config.dart';
import '../../widgets/common/error_dialog.dart';

/// 🔧 백엔드 API 통합 처리 유틸리티
/// 모든 서비스에서 백엔드 커스텀 응답 구조와 에러 처리를 일관되게 처리
class ApiUtils {
  // ⏰ API 타임아웃 설정 (초 단위)
  static const int connectionTimeoutSeconds = 5;
  static const int receiveTimeoutSeconds = 3; // 적절한 사용자 경험을 위한 3초 설정
  static const int sendTimeoutSeconds = 5;

  /// 🔧 타임아웃이 설정된 Dio 인스턴스 생성 (캐시 무효화 포함)
  static Dio createDioWithTimeout({
    String? baseUrl,
    Map<String, String>? headers,
    bool enableInterceptorLogging = true, // 인터셉터 로깅 제어
  }) {
    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl ?? AppConfig.apiBaseUrl,
        connectTimeout: Duration(seconds: connectionTimeoutSeconds),
        receiveTimeout: Duration(seconds: receiveTimeoutSeconds),
        // 🌐 Flutter Web에서 sendTimeout 경고 방지
        sendTimeout: kIsWeb ? null : Duration(seconds: sendTimeoutSeconds),
        headers: headers,
      ),
    );

    // 글로벌 캐시 무효화 인터셉터
    dio.interceptors.add(_CacheControlInterceptor());

    // 디버그 모드에서 요청/응답 로깅 인터셉터 (제어 가능)
    if (AppConfig.debugMode && enableInterceptorLogging) {
      dio.interceptors.add(_DebugLoggingInterceptor());
    }

    return dio;
  }

  /// 🔧 백엔드 커스텀 응답 구조 통합 처리 메서드
  static Map<String, dynamic> processBackendResponse(
    Response response,
    String apiName, {
    bool expectData = true,
  }) {
    final data = response.data;

    if (data is! Map) {
      throw Exception('[$apiName] 백엔드 응답 형식이 올바르지 않습니다: $data');
    }

    final responseCode = data['code'];
    final responseMessage = data['message'] ?? '알 수 없는 오류';
    final responseData = data['data'];

    if (responseCode == 200) {
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
    Exception resultException;

    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        resultException = Exception('[$apiName] 서버 연결 시간이 초과되었습니다.');
        if (context != null && showDialog) {
          ErrorDialog.showTimeoutError(context);
        }
        break;

      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode ?? 0;
        final responseData = e.response?.data;
        String message = '서버 오류가 발생했습니다.';

        // 460 비활성화 계정 특별 처리
        if (statusCode == 460) {
          // 🏠 메인 화면으로 리다이렉트 후 다이얼로그 표시
          if (context != null) {
            Future.microtask(() {
              // 🎯 GoRouter: 메인 화면으로 이동 (로그인 화면 히스토리 제거)
              context.go('/home');

              // 짧은 딸레이 후 다이얼로그 표시 (화면 전환 완료 대기)
              Future.delayed(const Duration(milliseconds: 300), () {
                ErrorDialog.showAccountDeactivatedError(context);
              });
            });
          }

          resultException = Exception('[$apiName] 비활성화된 계정입니다.');
          break;
        }

        // 403 금지된 접근 특별 처리
        if (statusCode == 403) {
          message = '접근 권한이 없습니다.';

          // 관리자 모드 관련 API인 경우 특별 처리
          if (apiName.contains('모임원') && context != null && showDialog) {
            // 비동기로 홈으로 리다이렉트
            Future.microtask(() {
              // 🎯 GoRouter: 메인 화면으로 이동 (권한 없음 경고)
              context.go('/home');

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Row(
                    children: [
                      Icon(Icons.security, color: Colors.white),
                      SizedBox(width: 8),
                      Text('모임원 관리 권한이 없습니다.'),
                    ],
                  ),
                  backgroundColor: Theme.of(context).colorScheme.error,
                  behavior: SnackBarBehavior.floating,
                  duration: const Duration(seconds: 4),
                ),
              );
            });

            resultException = Exception('[$apiName] 권한 없음 (403): $message');
            break;
          }
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

          resultException = Exception(
            '[$apiName] 백엔드 오류 (HTTP: $statusCode, 코드: $backendCode): $message',
          );
        } else if (responseData is String) {
          message = responseData;
          resultException = Exception(
            '[$apiName] 서버 오류 ($statusCode): $message',
          );
        } else {
          resultException = Exception(
            '[$apiName] 서버 오류 ($statusCode): $message',
          );
        }

        // 403 에러가 아닌 경우에만 다이얼로그 표시
        if (context != null && showDialog && statusCode != 403) {
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
        resultException = Exception(
          '[$apiName] 네트워크 오류가 발생했습니다: ${e.message ?? '알 수 없는 오류'}',
        );
        if (context != null && showDialog) {
          ErrorDialog.showErrorFromException(
            context,
            resultException,
            apiName: apiName,
          );
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

            return token;
          }
        }
      } catch (e) {
        // 브라우저 쿠키 읽기 오류 무시
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

          return token;
        }
      }
    }

    return null;
  }
}

/// 📄 캐시 제어 인터셉터
/// 모든 GET 요청에 자동으로 캐시 무효화 헤더 추가
class _CacheControlInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // GET 요청에만 캐시 제어 헤더 추가
    if (options.method.toUpperCase() == 'GET') {
      // 🔥 Flutter Web에서 더 강력한 캐시 무효화
      options.headers.addAll({
        'Cache-Control': 'no-cache, no-store, must-revalidate, max-age=0',
        'Pragma': 'no-cache',
        'Expires': '0',
        // HTTP/1.1 및 HTTP/1.0 호환성을 위한 추가 헤더
        'If-Modified-Since': 'Thu, 01 Jan 1970 00:00:00 GMT',
        'If-None-Match': '*', // ETag 캐시 무효화
      });

      // Flutter Web에서 타임스탬프 쿼리 파라미터 추가 (필요시)
      if (kIsWeb) {
        final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
        options.queryParameters['_nocache'] = timestamp;
      }

      if (AppConfig.debugMode) {
        // Health Check API는 로그 출력 제외
        if (!options.path.contains('health-check')) {
          print('📅 [캐시 무효화] ${options.method} ${options.path}');
          if (kIsWeb) {
            print('🌐 [Flutter Web] 타임스탬프 캐시버스터 추가');
          }
        }
      }
    }

    super.onRequest(options, handler);
  }
}

/// 🔍 디버깅 로깅 인터셉터
/// 디버그 모드에서 API 요청/응답 상세 로깅
class _DebugLoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    print('[API 요청] ${options.method} ${options.uri}');
    if (options.data != null) {
      print('📊 [요청 데이터] ${options.data}');
    }
    print('──────────────────────────────');
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    print('✅ [API 응답] ${response.statusCode} ${response.requestOptions.uri}');
    if (response.data != null) {
      final dataStr = response.data.toString();
      if (dataStr.length > 500) {
        print('📊 [응답 데이터] ${dataStr.substring(0, 500)}...(truncated)');
      } else {
        print('📊 [응답 데이터] $dataStr');
      }
    }
    print('──────────────────────────────\n');
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    print('❌ [API 오류] ${err.requestOptions.method} ${err.requestOptions.uri}');
    print('🛠️ [오류 타입] ${err.type}');
    print('📝 [오류 메시지] ${err.message}');
    if (err.response != null) {
      print('📊 [오류 응답] ${err.response?.data}');
    }
    print('──────────────────────────────\n');
    super.onError(err, handler);
  }
}
