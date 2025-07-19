import 'package:dio/dio.dart';
import '../config/app_config.dart';
import '../utils/api_utils.dart';

/// 🔧 개인정보 상태 확인 서비스 (스마트 캐싱 + 강제 로그아웃 감지)
///
/// 개선된 버전: 토큰을 파라미터로 받아서 더 유연하게 사용 + HTTP 캐싱 비활성화
class ProfileStatusService {
  static final ProfileStatusService _instance =
      ProfileStatusService._internal();
  factory ProfileStatusService() => _instance;
  ProfileStatusService._internal() {
    _setupDio(); // 🔧 Dio 초기 설정
  }

  late final Dio _dio;

  // 🕒 캐싱 관련 변수들
  bool? _cachedProfileStatus;
  DateTime? _lastFetchTime;
  static const Duration _cacheExpiryDuration = Duration(
    minutes: 1,
  ); // 테스트 용으로 1분으로 사용, TODO: 실 운용시 5분으로 복구할 것

  /// 🔧 Dio 초기 설정 - HTTP 캐싱 완전 비활성화
  void _setupDio() {
    _dio = Dio();

    // 🚫 HTTP 캐싱 완전 비활성화 설정
    _dio.options.headers.addAll({
      'Cache-Control': 'no-cache, no-store, must-revalidate',
      'Pragma': 'no-cache',
      'Expires': '0',
    });

    // 🔍 디버깅용 인터셉터 추가 (에러만 로깅)
    if (AppConfig.debugMode) {
      _dio.interceptors.add(
        InterceptorsWrapper(
          onError: (error, handler) {
            print(
              '❌ [ProfileStatusService] HTTP 오류: ${error.type} - ${error.message}',
            );
            handler.next(error);
          },
        ),
      );
    }
  }

  /// 🎯 개인정보 상태 확인 (스마트 캐싱) - 개선된 버전
  ///
  /// [accessToken]: JWT 액세스 토큰
  /// [forceRefresh]: 캐시 무시하고 강제 새로고침
  /// [onAutoLogout]: 401 오류 시 호출될 즉시 실행 콜백 함수
  ///
  /// 반환값:
  /// - true: 개인정보 입력 완료
  /// - false: 개인정보 미입력
  /// - null: API 오류 또는 로그아웃 처리됨
  Future<bool?> checkProfileStatus({
    required String accessToken,
    bool forceRefresh = false,
    required void Function() onAutoLogout,
  }) async {
    // 🔄 캐시 유효성 검사
    if (!forceRefresh && _isCacheValid()) {
      if (AppConfig.debugMode) {
        print('📦 [개인정보 상태 확인] 캐시된 결과 사용: $_cachedProfileStatus');
      }
      return _cachedProfileStatus;
    }

    // 🚀 API 호출
    try {
      if (AppConfig.debugMode) {
        print('🔍 [개인정보 상태 확인] API 호출 시작...');
      }

      final response = await _dio.get(
        AppConfig.getApiEndpoint('members/me/profile-status'),
        options: Options(
          headers: {
            'Authorization': 'Bearer $accessToken',
            // 🚫 추가 캐싱 방지 헤더
            'Cache-Control': 'no-cache, no-store, must-revalidate',
            'Pragma': 'no-cache',
            'Expires': '0',
            // 🔄 매번 다른 요청으로 인식하도록 타임스탬프 추가
            'X-Request-Time': DateTime.now().millisecondsSinceEpoch.toString(),
          },
        ),
        // 🚫 쿼리 파라미터로도 캐싱 방지
        queryParameters: {'_t': DateTime.now().millisecondsSinceEpoch},
      );

      if (response.statusCode == 200) {
        // ✅ 성공: 백엔드 응답 처리
        final processedResponse = ApiUtils.processBackendResponse(
          response,
          '개인정보 상태 확인',
        );

        final profileStatus = processedResponse['data'] as bool;

        // 캐시 업데이트
        _updateCache(profileStatus);

        return profileStatus;
      } else {
        throw Exception('[개인정보 상태 확인] HTTP 오류: ${response.statusCode}');
      }
    } catch (e) {
      if (e is DioException) {
        // HTTP 401 오류 감지: 강제 로그아웃 처리
        if (e.response?.statusCode == 401) {
          _handleForceLogout(e, onAutoLogout);
          return null;
        } else {
          throw ApiUtils.processDioException(e, '개인정보 상태 확인');
        }
      } else {
        // 백엔드 비즈니스 코드 401 또는 인증 관련 에러 감지
        if (_isBackendAuthError(e)) {
          // 더미 DioException 생성
          final dummyDioException = DioException(
            requestOptions: RequestOptions(path: ''),
            response: Response(
              requestOptions: RequestOptions(path: ''),
              statusCode: 401,
              data: {'message': e.toString()},
            ),
            type: DioExceptionType.badResponse,
            message: e.toString(),
          );
          _handleForceLogout(dummyDioException, onAutoLogout);
          return null;
        } else {
          rethrow;
        }
      }
    }
  }

  /// 🔄 캐시 유효성 검사
  bool _isCacheValid() {
    if (_cachedProfileStatus == null || _lastFetchTime == null) {
      return false;
    }

    final now = DateTime.now();
    return now.difference(_lastFetchTime!) < _cacheExpiryDuration;
  }

  /// 💾 캐시 업데이트
  void _updateCache(bool profileStatus) {
    _cachedProfileStatus = profileStatus;
    _lastFetchTime = DateTime.now();
  }

  /// 🚨 강제 로그아웃 처리
  void _handleForceLogout(DioException e, void Function() onAutoLogout) {
    // 백엔드 에러 메시지 추출
    String logoutReason = '인증이 만료되었습니다';

    if (e.response?.data != null && e.response!.data is Map) {
      final backendMessage = e.response!.data['message']?.toString();
      if (backendMessage != null && backendMessage.isNotEmpty) {
        logoutReason = backendMessage;
      }
    }

    // 캐시 초기화
    _clearCache();

    // 콜백을 통한 자동 로그아웃 처리 (즉시 실행)
    try {
      onAutoLogout();
    } catch (logoutError) {
      // 콜백 실행 중 오류 무시
    }
  }

  /// 🧹 캐시 초기화
  void _clearCache() {
    _cachedProfileStatus = null;
    _lastFetchTime = null;
  }

  /// 🎯 수동 캐시 무효화 (프로필 수정 완료 시 호출)
  void invalidateCache() {
    _clearCache();
  }

  /// 📊 캐시 상태 정보 (디버깅용)
  Map<String, dynamic> getCacheInfo() {
    return {
      'cachedStatus': _cachedProfileStatus,
      'lastFetchTime': _lastFetchTime?.toIso8601String(),
      'isValid': _isCacheValid(),
      'cacheExpiry': _lastFetchTime
          ?.add(_cacheExpiryDuration)
          .toIso8601String(),
      'remainingMinutes': _lastFetchTime != null
          ? (_cacheExpiryDuration - DateTime.now().difference(_lastFetchTime!))
                .inMinutes
          : null,
    };
  }

  /// 🔍 백엔드 인증 에러 여부 정확히 감지
  ///
  /// ApiUtils에서 던진 Exception을 기반으로 백엔드 인증 에러를 판단
  /// 예상 예외: "Exception: [개인정보 상태 확인] 백엔드 오류 (401): 리프레시 토큰이 유효하지 않습니다..."
  bool _isBackendAuthError(dynamic error) {
    try {
      final errorString = error.toString();

      // 🎯 우선: 백엔드 오류 코드 401 정확히 감지
      final backendErrorPattern = RegExp(r'백엔드 오류 \((\d+)\):');
      final match = backendErrorPattern.firstMatch(errorString);

      if (match != null) {
        final errorCode = int.tryParse(match.group(1) ?? '');
        if (errorCode == 401) {
          return true;
        }
      }

      // 🔄 폴백: 인증 관련 키워드 검색
      final lowerError = errorString.toLowerCase();
      if (lowerError.contains('백엔드 오류 (401)') ||
          lowerError.contains('인증') ||
          lowerError.contains('토큰') ||
          lowerError.contains('만료') ||
          lowerError.contains('unauthorized') ||
          lowerError.contains('token')) {
        return true;
      }

      return false;
    } catch (e) {
      // 파싱 오류 시 안전하게 false 반환
      return false;
    }
  }

  /// 🎯 편의 메서드: 간단한 사용을 위한 래퍼
  ///
  /// 이 메서드는 AuthProvider에서 직접 호출하기 편리합니다
  static Future<bool?> checkStatus({
    required String accessToken,
    bool forceRefresh = false,
    required void Function() onAutoLogout,
  }) async {
    return await ProfileStatusService().checkProfileStatus(
      accessToken: accessToken,
      forceRefresh: forceRefresh,
      onAutoLogout: onAutoLogout,
    );
  }
}
