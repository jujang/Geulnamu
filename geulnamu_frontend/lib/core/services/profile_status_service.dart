import 'package:dio/dio.dart';
import '../config/app_config.dart';
import '../utils/api_utils.dart';

/// 🔧 개인정보 상태 확인 서비스 (스마트 캐싱 + 강제 로그아웃 감지)
/// 
/// 개선된 버전: 토큰을 파라미터로 받아서 더 유연하게 사용 + HTTP 캐싱 비활성화
class ProfileStatusService {
  static final ProfileStatusService _instance = ProfileStatusService._internal();
  factory ProfileStatusService() => _instance;
  ProfileStatusService._internal() {
    _setupDio(); // 🔧 Dio 초기 설정
  }

  late final Dio _dio;
  
  // 🕒 캐싱 관련 변수들
  bool? _cachedProfileStatus;
  DateTime? _lastFetchTime;
  static const Duration _cacheExpiryDuration = Duration(minutes: 5);

  /// 🔧 Dio 초기 설정 - HTTP 캐싱 완전 비활성화
  void _setupDio() {
    _dio = Dio();
    
    // 🚫 HTTP 캐싱 완전 비활성화 설정
    _dio.options.headers.addAll({
      'Cache-Control': 'no-cache, no-store, must-revalidate',
      'Pragma': 'no-cache',
      'Expires': '0',
    });
    
    // 🔍 디버깅용 인터셉터 추가
    if (AppConfig.debugMode) {
      _dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            print('🌐 [ProfileStatusService] 실제 HTTP 요청 시작');
            print('🔗 URL: ${options.uri}');
            print('📤 Headers: ${options.headers}');
            handler.next(options);
          },
          onResponse: (response, handler) {
            print('📨 [ProfileStatusService] HTTP 응답 수신: ${response.statusCode}');
            handler.next(response);
          },
          onError: (error, handler) {
            print('❌ [ProfileStatusService] HTTP 오류: ${error.type} - ${error.message}');
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
  /// [onAutoLogout]: 401 오류 시 호출될 콜백 함수
  /// 
  /// 반환값:
  /// - true: 개인정보 입력 완료
  /// - false: 개인정보 미입력
  /// - null: API 오류 또는 로그아웃 처리됨
  Future<bool?> checkProfileStatus({
    required String accessToken,
    bool forceRefresh = false,
    required Function() onAutoLogout,
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
        print('🚀 [개인정보 상태 확인] API 요청 시작... (캐시 만료 또는 강제 새로고침)');
        print('🔗 [개인정보 상태 확인] 요청 URL: ${AppConfig.getApiEndpoint('members/me/profile-status')}');
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
        queryParameters: {
          '_t': DateTime.now().millisecondsSinceEpoch,
        },
      );

      if (AppConfig.debugMode) {
        print('📨 [개인정보 상태 확인] HTTP 응답 수신 완료: ${response.statusCode}');
      }

      if (response.statusCode == 200) {
        // ✅ 성공: 백엔드 응답 처리
        final processedResponse = ApiUtils.processBackendResponse(
          response,
          '개인정보 상태 확인'
        );

        final profileStatus = processedResponse['data'] as bool;
        
        // 캐시 업데이트
        _updateCache(profileStatus);
        
        if (AppConfig.debugMode) {
          print('✅ [개인정보 상태 확인] 성공 - 상태: $profileStatus');
        }
        
        return profileStatus;
      } else {
        throw Exception('[개인정보 상태 확인] HTTP 오류: ${response.statusCode}');
      }
    } catch (e) {
      if (e is DioException) {
        // 🚨 401 오류 감지: 강제 로그아웃 처리
        if (e.response?.statusCode == 401) {
          await _handleForceLogout(e, onAutoLogout);
          return null; // 로그아웃 처리됨
        } else {
          // 다른 네트워크 오류
          throw ApiUtils.processDioException(e, '개인정보 상태 확인');
        }
      } else {
        // 기타 오류
        if (AppConfig.debugMode) {
          print('❌ [개인정보 상태 확인] 예상치 못한 오류: $e');
        }
        rethrow;
      }
    }
  }

  /// 🔄 캐시 유효성 검사
  bool _isCacheValid() {
    if (_cachedProfileStatus == null || _lastFetchTime == null) {
      return false;
    }
    
    final now = DateTime.now();
    final isValid = now.difference(_lastFetchTime!) < _cacheExpiryDuration;
    
    if (AppConfig.debugMode) {
      final remainingTime = _cacheExpiryDuration - now.difference(_lastFetchTime!);
      print('⏰ [개인정보 상태 확인] 캐시 유효성: $isValid (남은 시간: ${remainingTime.inMinutes}분 ${remainingTime.inSeconds % 60}초)');
    }
    
    return isValid;
  }

  /// 💾 캐시 업데이트
  void _updateCache(bool profileStatus) {
    _cachedProfileStatus = profileStatus;
    _lastFetchTime = DateTime.now();
    
    if (AppConfig.debugMode) {
      print('💾 [개인정보 상태 확인] 캐시 업데이트: $profileStatus (${_lastFetchTime})');
    }
  }

  /// 🚨 강제 로그아웃 처리
  Future<void> _handleForceLogout(
    DioException e,
    Function() onAutoLogout,
  ) async {
    if (AppConfig.debugMode) {
      print('🚨 [개인정보 상태 확인] 401 오류 감지 - 강제 로그아웃 처리 시작');
    }

    // 백엔드 에러 메시지 추출
    String logoutReason = '인증이 만료되었습니다';
    
    if (e.response?.data != null && e.response!.data is Map) {
      final backendMessage = e.response!.data['message']?.toString();
      if (backendMessage != null && backendMessage.isNotEmpty) {
        logoutReason = backendMessage;
        
        if (AppConfig.debugMode) {
          print('📝 [개인정보 상태 확인] 백엔드 메시지: $backendMessage');
        }
      }
    }

    // 캐시 초기화
    _clearCache();
    
    // 콜백을 통한 자동 로그아웃 처리
    try {
      if (AppConfig.debugMode) {
        print('🔄 [개인정보 상태 확인] 자동 로그아웃 콜백 실행');
      }
      
      onAutoLogout();
      
      if (AppConfig.debugMode) {
        print('✅ [개인정보 상태 확인] 자동 로그아웃 완료: $logoutReason');
      }
    } catch (logoutError) {
      if (AppConfig.debugMode) {
        print('❌ [개인정보 상태 확인] 자동 로그아웃 처리 중 오류: $logoutError');
      }
    }
  }

  /// 🧹 캐시 초기화
  void _clearCache() {
    _cachedProfileStatus = null;
    _lastFetchTime = null;
    
    if (AppConfig.debugMode) {
      print('🧹 [개인정보 상태 확인] 캐시 초기화 완료');
    }
  }

  /// 🎯 수동 캐시 무효화 (프로필 수정 완료 시 호출)
  void invalidateCache() {
    _clearCache();
    
    if (AppConfig.debugMode) {
      print('🔄 [개인정보 상태 확인] 수동 캐시 무효화');
    }
  }

  /// 📊 캐시 상태 정보 (디버깅용)
  Map<String, dynamic> getCacheInfo() {
    return {
      'cachedStatus': _cachedProfileStatus,
      'lastFetchTime': _lastFetchTime?.toIso8601String(),
      'isValid': _isCacheValid(),
      'cacheExpiry': _lastFetchTime?.add(_cacheExpiryDuration).toIso8601String(),
      'remainingMinutes': _lastFetchTime != null 
          ? (_cacheExpiryDuration - DateTime.now().difference(_lastFetchTime!)).inMinutes
          : null,
    };
  }

  /// 🎯 편의 메서드: 간단한 사용을 위한 래퍼
  /// 
  /// 이 메서드는 AuthProvider에서 직접 호출하기 편리합니다
  static Future<bool?> checkStatus({
    required String accessToken,
    bool forceRefresh = false,
    required Function() onAutoLogout,
  }) async {
    return await ProfileStatusService().checkProfileStatus(
      accessToken: accessToken,
      forceRefresh: forceRefresh,
      onAutoLogout: onAutoLogout,
    );
  }
}
