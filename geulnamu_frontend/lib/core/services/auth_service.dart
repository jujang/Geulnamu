import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:html' as html show window, sessionStorage, indexedDB, navigator, IFrameElement, document;
import '../config/app_config.dart';
import '../utils/api_utils.dart';
import '../../widgets/common/error_dialog.dart';

/// 🔐 글나무 인증 서비스
///
/// 백엔드 API와 완전 호환되는 카카오 OAuth 로그인 시스템
/// - 웹/모바일 환경 자동 감지 및 처리
/// - ApiUtils 통합 사용으로 일관된 에러 처리
/// - 자동 토큰 갱신 및 인터셉터 설정
///
/// 사용법:
/// ```dart
/// final authService = AuthService();
/// final result = await authService.loginWithKakao();
/// ```
class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal() {
    _initializeDio();
  }

  late final Dio _dio;

  // 🔑 로컬 저장소 키
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userInfoKey = 'user_info';

  /// 🔧 Dio 초기화 및 설정
  void _initializeDio() {
    // ⏰ ApiUtils의 타임아웃 설정을 사용하여 Dio 인스턴스 생성
    _dio = ApiUtils.createDioWithTimeout(
      baseUrl: AppConfig.apiBaseUrl,
      headers: {'User-Agent': 'GeulnamuApp/${AppConfig.appVersion}'},
    );

    // 쿠키 포함 요청 활성화
    _dio.options.extra['withCredentials'] = true;

    // 인터셉터 설정
    _setupInterceptors();

    if (AppConfig.debugMode) {
      print('🔧 AuthService 초기화 완료');
    }
  }

  /// 🔄 인터셉터 설정 - 자동 토큰 관리
  void _setupInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // 인증이 필요한 API에 액세스 토큰 자동 추가
          if (_needsAuthentication(options.path)) {
            final accessToken = await getAccessToken();
            if (accessToken != null && accessToken.isNotEmpty) {
              options.headers['Authorization'] = 'Bearer $accessToken';
            }
          }

          handler.next(options);
        },
        onResponse: (response, handler) {
          handler.next(response);
        },
        onError: (error, handler) async {
          // 401 에러 시 자동 토큰 갱신 시도
          if (error.response?.statusCode == 401 &&
              _needsAuthentication(error.requestOptions.path)) {
            final refreshed = await _attemptTokenRefresh();

            if (refreshed) {
              // 토큰 갱신 성공 시 원래 요청 재시도
              final accessToken = await getAccessToken();
              error.requestOptions.headers['Authorization'] =
                  'Bearer $accessToken';

              try {
                final response = await _dio.fetch(error.requestOptions);
                handler.resolve(response);
                return;
              } catch (e) {
                // 재요청 실패 시 원래 에러로 진행
              }
            }
          }

          handler.next(error);
        },
      ),
    );
  }

  /// 🔍 인증이 필요한 API인지 확인
  bool _needsAuthentication(String path) {
    // 로그인, 회원가입 등은 인증 불필요
    if (path.contains('/login/oauth/') || path.contains('/login/re-issue/')) {
      return false;
    }

    // 로그아웃은 인증 필요
    if (path.contains('/login/logout')) {
      return true;
    }

    // /api/ 경로는 인증 필요
    if (path.contains('/api/')) {
      return true;
    }

    return false;
  }

  /// 🥕 카카오 OAuth 로그인 - 메인 진입점
  ///
  /// 웹/모바일 환경을 자동 감지하여 적절한 OAuth 플로우 실행
  /// 
  /// [forceAccountSelection]: true로 설정하면 카카오 로그아웃 후 계정 선택 (다른 계정으로 로그인 시 사용)
  Future<Map<String, dynamic>> loginWithKakao({
    BuildContext? context,
    bool forceAccountSelection = false,
  }) async {
    try {
      if (AppConfig.debugMode) {
        print('🥕 카카오 로그인 시작 (${kIsWeb ? "웹" : "모바일"})...');
      }

      // 🔄 다른 계정으로 로그인 시 카카오 로그아웃 먼저 수행
      if (forceAccountSelection && kIsWeb) {
        await _logoutFromKakao();
        // 잠깐 대기 (로그아웃 완료 보장)
        await Future.delayed(const Duration(milliseconds: 500));
      }

      if (kIsWeb) {
        return await _webLoginFlow(context, forceAccountSelection);
      } else {
        return await _mobileLoginFlow(context, forceAccountSelection);
      }
    } catch (error) {
      if (AppConfig.debugMode) {
        print('❌ 카카오 로그인 실패: $error');
      }
      rethrow;
    }
  }

  /// 🌐 웹 환경 OAuth 플로우
  Future<Map<String, dynamic>> _webLoginFlow(
    BuildContext? context,
    bool forceAccountSelection,
  ) async {
    final kakaoAuthUrl = _buildKakaoAuthUrl(
      forceAccountSelection: forceAccountSelection,
    );

    if (AppConfig.debugMode) {
      print('🌐 웹 OAuth 진행 중...');
    }

    try {
      // 팝업으로 카카오 인증 페이지 열기
      final popup = html.window.open(
        kakaoAuthUrl,
        'kakao_login',
        'width=500,height=600,scrollbars=yes,resizable=yes',
      );

      // Authorization Code 대기
      final authCode = await _waitForAuthCode(popup);

      // 백엔드로 코드 전송 및 토큰 교환
      return await _processAuthCode(authCode, context);
    } catch (e) {
      if (AppConfig.debugMode) {
        print('❌ 웹 OAuth 오류: $e');
      }
      rethrow;
    }
  }

  /// 📱 모바일 환경 OAuth 플로우
  Future<Map<String, dynamic>> _mobileLoginFlow(
    BuildContext? context,
    bool forceAccountSelection,
  ) async {
    final kakaoAuthUrl = _buildKakaoAuthUrl(
      forceAccountSelection: forceAccountSelection,
    );

    if (AppConfig.debugMode) {
      print('📱 모바일 OAuth 진행 중...');
    }

    try {
      // FlutterWebAuth2로 OAuth 진행
      final result = await FlutterWebAuth2.authenticate(
        url: kakaoAuthUrl,
        callbackUrlScheme: _getCallbackScheme(),
        options: const FlutterWebAuth2Options(
          intentFlags: 0x10000000, // FLAG_ACTIVITY_NEW_TASK
          preferEphemeral: true,
        ),
      );

      // Authorization Code 추출
      final uri = Uri.parse(result);
      final code = uri.queryParameters['code'];

      if (code == null || code.isEmpty) {
        throw Exception('카카오 OAuth에서 인증 코드를 받지 못했습니다.');
      }

      // 백엔드로 코드 전송 및 토큰 교환
      return await _processAuthCode(code, context);
    } catch (e) {
      if (AppConfig.debugMode) {
        print('❌ 모바일 OAuth 오류: $e');
      }
      rethrow;
    }
  }

  /// 🔗 카카오 인증 URL 생성
  String _buildKakaoAuthUrl({bool forceAccountSelection = false}) {
    final clientId = kIsWeb
        ? AppConfig.kakaoJavaScriptAppKey
        : AppConfig.kakaoNativeAppKey;

    final redirectUri = AppConfig.kakaoRedirectUri;
    final state = DateTime.now().millisecondsSinceEpoch.toString();

    final params = {
      'client_id': clientId,
      'redirect_uri': redirectUri,
      'response_type': 'code',
      'scope': 'profile_nickname',
      'state': state,
      if (forceAccountSelection) 'prompt': 'select_account', // 🔄 계정 선택 강제
    };

    final queryString = params.entries
        .map(
          (e) =>
              '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}',
        )
        .join('&');

    return 'https://kauth.kakao.com/oauth/authorize?$queryString';
  }

  /// 🚪 카카오 계정 로그아웃 (다른 계정으로 로그인 시 사용)
  Future<void> _logoutFromKakao() async {
    if (!kIsWeb) return;

    try {
      if (AppConfig.debugMode) {
        print('🚪 카카오 계정 로그아웃 시작...');
      }

      final clientId = AppConfig.kakaoJavaScriptAppKey;
      final logoutRedirectUri = AppConfig.kakaoRedirectUri;

      // 카카오 로그아웃 URL
      final logoutUrl = 'https://kauth.kakao.com/oauth/logout'
          '?client_id=$clientId'
          '&logout_redirect_uri=$logoutRedirectUri';

      // iframe으로 조용히 로그아웃 (사용자에게 보이지 않게)
      final iframe = html.IFrameElement()
        ..src = logoutUrl
        ..style.display = 'none';

      html.document.body?.append(iframe);

      // 로그아웃 완료 대기 (1초)
      await Future.delayed(const Duration(seconds: 1));

      // iframe 제거
      iframe.remove();

      if (AppConfig.debugMode) {
        print('✅ 카카오 계정 로그아웃 완료');
      }
    } catch (e) {
      if (AppConfig.debugMode) {
        print('⚠️ 카카오 로그아웃 오류 (무시): $e');
      }
      // 로그아웃 실패해도 계속 진행
    }
  }

  /// 🕒 웹 팝업에서 Authorization Code 대기
  Future<String> _waitForAuthCode(dynamic popup) async {
    final completer = Completer<String>();
    late StreamSubscription messageSubscription;
    late Timer popupCheckTimer;
    late Timer timeoutTimer;

    // PostMessage 리스너 등록
    messageSubscription = html.window.onMessage.listen((event) {
      if (event.data is String) {
        final data = event.data as String;
        if (data.startsWith('KAKAO_AUTH_CODE:')) {
          final code = data.replaceFirst('KAKAO_AUTH_CODE:', '');
          if (code.isNotEmpty && !completer.isCompleted) {
            _cleanupListeners(
              messageSubscription,
              popupCheckTimer,
              timeoutTimer,
            );
            _closePopup(popup);
            completer.complete(code);
          }
        }
      }
    });

    // 팝업 상태 주기적 확인
    popupCheckTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      try {
        if (popup?.closed == true && !completer.isCompleted) {
          _cleanupListeners(messageSubscription, timer, timeoutTimer);
          completer.completeError(Exception('사용자가 로그인을 취소했습니다.'));
        }
      } catch (e) {}
    });

    // 타임아웃 설정 (5분)
    timeoutTimer = Timer(const Duration(minutes: 5), () {
      if (!completer.isCompleted) {
        _cleanupListeners(messageSubscription, popupCheckTimer, timeoutTimer);
        _closePopup(popup);
        completer.completeError(Exception('로그인 시간이 초과되었습니다.'));
      }
    });

    return completer.future;
  }

  /// 🧹 리스너 정리 헬퍼
  void _cleanupListeners(
    StreamSubscription messageSubscription,
    Timer popupCheckTimer,
    Timer timeoutTimer,
  ) {
    try {
      messageSubscription.cancel();
      popupCheckTimer.cancel();
      timeoutTimer.cancel();
    } catch (e) {}
  }

  /// 🪟 팝업 닫기 헬퍼
  void _closePopup(dynamic popup) {
    try {
      popup?.close();
    } catch (e) {}
  }

  /// 📱 콜백 스킴 결정
  String _getCallbackScheme() {
    return kIsWeb ? 'http' : 'geulnamu'; // 웹에서 HTTP 사용 (개발용)
  }

  /// 🔄 Authorization Code 처리 및 토큰 교환
  Future<Map<String, dynamic>> _processAuthCode(
    String code,
    BuildContext? context,
  ) async {
    try {
      if (AppConfig.debugMode) {
        print('🔄 백엔드로 인증 코드 전송 중...');
      }

      // ✅ POST + RequestBody로 변경
      final response = await _dio.post(
        AppConfig.getApiEndpoint('login/oauth/kakao'),
        data: {'code': code},
        options: Options(
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json', // JSON 형태로 전송
            'User-Agent': 'GeulnamuApp/${AppConfig.appVersion}',
          },
          followRedirects: false,
          extra: {
            'withCredentials': true, // 쿠키 포함 요청
          },
        ),
      );

      if (response.statusCode == 200) {
        // ✅ ApiUtils 통합 응답 처리
        final processedResponse = ApiUtils.processBackendResponse(
          response,
          '카카오 로그인',
        );

        // ✅ ApiUtils 통합 토큰 추출
        final refreshToken = ApiUtils.extractRefreshToken(response);

        final authData = {
          'accessToken': processedResponse['data']['accessToken'],
          'refreshToken': refreshToken ?? '',
          'userInfo': {
            'memberId': processedResponse['data']['memberId'],
            'memberName':
                processedResponse['data']['memberName'], // null일 수 있음 (정보 미등록 상태)
            'role': processedResponse['data']['role'],
            'newMember': processedResponse['data']['newMember'],
          },
        };

        // 토큰 저장
        await _saveAuthData(authData);

        if (AppConfig.debugMode) {
          print('✅ 카카오 OAuth 로그인 완료');
          print('👤 멤버 ID: ${authData['userInfo']['memberId']}');
          print(
            '📝 사용자 이름: ${authData['userInfo']['memberName'] ?? '미등록'}',
          ); // null 처리
          print('🎭 역할: ${authData['userInfo']['role']}');
          print('🆕 신규 회원: ${authData['userInfo']['newMember']}');
        }

        return authData;
      } else {
        throw Exception('백엔드 인증 실패: HTTP ${response.statusCode}');
      }
    } catch (e) {
      // 🎯 460 에러 등 processBackendResponse에서 발생한 Exception도 처리
      if (e is DioException) {
        // ✅ ApiUtils 통합 에러 처리 (에러 다이얼로그 표시)
        throw ApiUtils.processDioException(
          e,
          '카카오 로그인',
          context: context,
          showDialog: context != null, // context가 있을 때만 다이얼로그 표시
        );
      } else {
        // 🎯 processBackendResponse에서 발생한 Exception 처리 (460 에러 등)
        final errorMessage = e.toString();

        // 460 에러 감지 시 특별 처리
        if (errorMessage.contains('460') || errorMessage.contains('비활성화된 계정')) {
          if (AppConfig.debugMode) {
            print('🚫 [카카오 로그인] 460 에러 감지 - 메인으로 리다이렉트');
          }

          // 🏠 메인 화면으로 리다이렉트 후 다이얼로그 표시
          if (context != null) {
            Future.microtask(() {
              // 메인 화면으로 이동 (로그인 화면 닫기)
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/home',
                (route) => false,
              );

              // 짧은 딜레이 후 다이얼로그 표시 (화면 전환 완료 대기)
              Future.delayed(const Duration(milliseconds: 300), () {
                ErrorDialog.showAccountDeactivatedError(context);
              });
            });
          }
        }

        rethrow;
      }
    }
  }

  /// 웹 환경에서 OAuth 코드 처리 (콜백 화면용)
  ///
  /// 카카오 OAuth 콜백 페이지에서 직접 호출하는 메서드
  Future<Map<String, dynamic>> processOAuthCode(
    String code, {
    BuildContext? context,
  }) async {
    try {
      if (AppConfig.debugMode) {
        print('🔄 웹 OAuth 코드 직접 처리 시작...');
      }

      return await _processAuthCode(code, context);
    } catch (error) {
      if (AppConfig.debugMode) {
        print('❌ 웹 OAuth 코드 처리 실패: $error');
      }
      rethrow;
    }
  }

  /// 🔄 토큰 갱신
  Future<Map<String, dynamic>?> refreshToken() async {
    try {
      if (AppConfig.debugMode) {
        print('🔄 액세스 토큰 갱신 시도...');
      }

      final refreshToken = await getRefreshToken();
      if (refreshToken == null || refreshToken.isEmpty) {
        if (AppConfig.debugMode) {
          print('❌ 리프레시 토큰이 없습니다');
        }
        return null;
      }

      final response = await _dio.post(
        AppConfig.getApiEndpoint('login/re-issue/accessToken'),
        options: Options(
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/x-www-form-urlencoded',
            'Cookie': 'refreshToken=$refreshToken',
          },
        ),
      );

      if (response.statusCode == 200) {
        // ✅ ApiUtils 통합 응답 처리
        final processedResponse = ApiUtils.processBackendResponse(
          response,
          '토큰 갱신',
        );

        // ✅ ApiUtils 통합 토큰 추출
        final newRefreshToken = ApiUtils.extractRefreshToken(response);
        final userInfo = await getUserInfo();

        final refreshedData = {
          'accessToken': processedResponse['data'],
          'refreshToken': newRefreshToken ?? refreshToken,
          'userInfo': userInfo,
        };

        await _saveAuthData(refreshedData);

        if (AppConfig.debugMode) {
          print('✅ 토큰 갱신 완료');
        }

        return refreshedData;
      } else {
        throw Exception('토큰 갱신 실패: HTTP ${response.statusCode}');
      }
    } catch (e) {
      if (AppConfig.debugMode) {
        print('❌ 토큰 갱신 오류: $e');
      }

      if (e is DioException) {
        final statusCode = e.response?.statusCode;
        if (statusCode == 401 || statusCode == 403) {
          // 리프레시 토큰도 만료된 경우 로그아웃 처리
          await _clearAuthData();
        }

        // ✅ ApiUtils 통합 에러 처리 (로그만 출력, null 반환)
        final processedException = ApiUtils.processDioException(e, '토큰 갱신');
        if (AppConfig.debugMode) {
          print('⚠️ 토큰 갱신 세부 오류: $processedException');
        }
      }

      return null;
    }
  }

  /// 👋 로그아웃 (선택적 캐시 정리 포함)
  Future<void> logout({BuildContext? context}) async {
    try {
      if (AppConfig.debugMode) {
        print('👋 로그아웃 시작...');
      }

      // 백엔드 로그아웃 시도
      try {
        final accessToken = await getAccessToken();
        if (accessToken != null && accessToken.isNotEmpty) {
          final response = await _dio.post(
            AppConfig.getApiEndpoint('login/logout'),
            options: Options(
              headers: {
                'Authorization': 'Bearer $accessToken', // Bearer 접두사 추가
                'Accept': 'application/json',
                'Content-Type': 'application/x-www-form-urlencoded',
              },
            ),
          );

          if (AppConfig.debugMode) {
            print(
              '🔑 로그아웃 Authorization 헤더: Bearer ${accessToken.substring(0, 20)}...',
            );
          }

          if (response.statusCode == 200) {
            // ✅ ApiUtils 통합 응답 처리
            ApiUtils.processBackendResponse(response, '로그아웃');
          }

          if (AppConfig.debugMode) {
            print('✅ 백엔드 로그아웃 완료');
          }
        }
      } catch (e) {
        if (AppConfig.debugMode) {
          print('⚠️ 백엔드 로그아웃 오류 (계속 진행): $e');
        }

        // ✅ ApiUtils 통합 에러 처리 (로그아웃은 자체 처리)
        if (e is DioException) {
          final processedException = ApiUtils.processDioException(
            e,
            '로그아웃',
            showDialog: false, // 로그아웃은 사용자 의도이므로 다이얼로그 표시 안함
          );
          if (AppConfig.debugMode) {
            print('⚠️ 로그아웃 세부 오류: $processedException');
          }
        }
      }

      // 🧹 선택적 스토리지 정리 (사용자 데이터만)
      await _clearAllUserData();

      if (AppConfig.debugMode) {
        print('✅ 로그아웃 완료 (사용자 데이터 모두 삭제)');
      }
    } catch (e) {
      if (AppConfig.debugMode) {
        print('❌ 로그아웃 오류: $e');
      }
      // 오류가 발생해도 로컬 데이터는 삭제
      await _clearAllUserData();
      rethrow;
    }
  }

  /// 🔍 로그인 상태 확인
  Future<bool> isLoggedIn() async {
    try {
      final accessToken = await getAccessToken();
      final userInfo = await getUserInfo();

      return accessToken != null && accessToken.isNotEmpty && userInfo != null;
    } catch (e) {
      if (AppConfig.debugMode) {
        print('❌ 로그인 상태 확인 오류: $e');
      }
      return false;
    }
  }

  /// 🔄 자동 토큰 갱신 시도 (내부 메서드)
  Future<bool> _attemptTokenRefresh() async {
    try {
      final result = await refreshToken();
      return result != null;
    } catch (e) {
      return false;
    }
  }

  /// 💾 인증 데이터 저장
  Future<void> _saveAuthData(Map<String, dynamic> authData) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(_accessTokenKey, authData['accessToken'] ?? '');
    await prefs.setString(_refreshTokenKey, authData['refreshToken'] ?? '');
    await prefs.setString(_userInfoKey, jsonEncode(authData['userInfo'] ?? {}));

    if (AppConfig.debugMode) {
      print('💾 인증 데이터 저장 완료');
    }
  }

  /// 🗑️ 인증 데이터 삭제 (SharedPreferences만)
  Future<void> _clearAuthData() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(_accessTokenKey);
    await prefs.remove(_refreshTokenKey);
    await prefs.remove(_userInfoKey);

    if (AppConfig.debugMode) {
      print('🗑️ SharedPreferences 인증 데이터 삭제 완료');
    }
  }

  /// 🧹 모든 사용자 데이터 삭제 (선택적 캐시 정리)
  /// 
  /// 삭제 항목:
  /// - ✅ SharedPreferences (토큰, 사용자 정보)
  /// - ✅ IndexedDB (Flutter 앱 데이터)
  /// - ✅ Session Storage (세션 데이터)
  /// - ❌ Cache Storage (Flutter 프레임워크 유지)
  Future<void> _clearAllUserData() async {
    try {
      // 1️⃣ SharedPreferences 삭제
      await _clearAuthData();

      // 2️⃣ 웹 환경에서만 추가 정리
      if (kIsWeb) {
        if (AppConfig.debugMode) {
          print('🧹 [웹] 브라우저 스토리지 정리 시작...');
        }

        // 3️⃣ Session Storage 전체 삭제
        try {
          html.window.sessionStorage.clear();
          if (AppConfig.debugMode) {
            print('✅ Session Storage 삭제 완료');
          }
        } catch (e) {
          if (AppConfig.debugMode) {
            print('⚠️ Session Storage 삭제 실패: $e');
          }
        }

        // 4️⃣ IndexedDB 삭제 (사용자 관련 데이터만)
        try {
          // Flutter가 사용하는 주요 IndexedDB들
          final dbNames = [
            'geulnamu_user_data',
            'flutter_cache',
            'flutter_settings',
          ];

          for (final dbName in dbNames) {
            try {
              html.window.indexedDB?.deleteDatabase(dbName);
            } catch (e) {
              // 개별 DB 삭제 실패는 무시 (존재하지 않을 수 있음)
            }
          }

          if (AppConfig.debugMode) {
            print('✅ IndexedDB 사용자 데이터 삭제 완료');
          }
        } catch (e) {
          if (AppConfig.debugMode) {
            print('⚠️ IndexedDB 삭제 실패: $e');
          }
        }

        // 5️⃣ Service Worker에 캐시 정리 메시지 전송
        try {
          if (html.window.navigator.serviceWorker != null) {
            final registration = await html.window.navigator.serviceWorker?.ready;
            registration?.active?.postMessage({
              'type': 'CLEAR_USER_CACHE',
            });

            if (AppConfig.debugMode) {
              print('✅ Service Worker 캐시 정리 요청 전송');
            }
          }
        } catch (e) {
          if (AppConfig.debugMode) {
            print('⚠️ Service Worker 메시지 전송 실패: $e');
          }
        }

        if (AppConfig.debugMode) {
          print('✅ [웹] 브라우저 스토리지 정리 완료');
        }
      }
    } catch (e) {
      if (AppConfig.debugMode) {
        print('❌ 사용자 데이터 삭제 중 오류: $e');
      }
      // 오류가 발생해도 최소한 SharedPreferences는 삭제됨
    }
  }

  /// 🔑 액세스 토큰 가져오기
  Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_accessTokenKey);
  }

  /// 🔄 리프레시 토큰 가져오기
  Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_refreshTokenKey);
  }

  /// 👤 사용자 정보 가져오기 (로컬 저장소)
  Future<Map<String, dynamic>?> getUserInfo() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userInfoString = prefs.getString(_userInfoKey);

      if (userInfoString != null && userInfoString.isNotEmpty) {
        return jsonDecode(userInfoString);
      }
      return null;
    } catch (e) {
      if (AppConfig.debugMode) {
        print('❌ 사용자 정보 파싱 오류: $e');
      }
      return null;
    }
  }

  /// 🔄 백엔드에서 최신 사용자 정보 가져오기 및 로컬 업데이트
  ///
  /// AuthProvider.updateUserInfo()에서 호출
  Future<Map<String, dynamic>?> fetchAndUpdateUserInfo() async {
    try {
      if (AppConfig.debugMode) {
        print('🔄 [AuthService] 백엔드에서 최신 사용자 정보 조회 시작...');
      }

      final accessToken = await getAccessToken();
      if (accessToken == null || accessToken.isEmpty) {
        if (AppConfig.debugMode) {
          print('❌ [AuthService] 액세스 토큰이 없습니다');
        }
        return null;
      }

      // 🚫 캐시 방지 전용 Dio 인스턴스 생성 (ProfileService와 동일한 방식)
      final noCacheDio = Dio();
      noCacheDio.options.headers.addAll({
        'Cache-Control': 'no-cache, no-store, must-revalidate',
        'Pragma': 'no-cache',
        'Expires': '0',
      });

      // 백엔드 API 호출 (강력한 캐시 방지 적용)
      final response = await noCacheDio.get(
        AppConfig.getApiEndpoint('members/me/profile'),
        options: Options(
          headers: {
            'Authorization': 'Bearer $accessToken',
            'Content-Type': 'application/json',
            // 🚫 강력한 캐시 방지 헤더 추가
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
        // ApiUtils를 사용하여 백엔드 커스텀 응답 처리
        final processedResponse = ApiUtils.processBackendResponse(
          response,
          '사용자 정보 조회',
        );

        if (processedResponse['success']) {
          final profileData = processedResponse['data'];

          // 기존 사용자 정보 가져오기
          final existingUserInfo = await getUserInfo() ?? {};

          // 새로운 사용자 정보 생성 (프로필 데이터로 업데이트)
          final updatedUserInfo = {
            ...existingUserInfo,
            'memberName': profileData['name'], // 🎯 이름 업데이트
            // 다른 필드들은 기존 값 유지
          };

          // 로컬 저장소에 업데이트된 정보 저장
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString(_userInfoKey, jsonEncode(updatedUserInfo));

          if (AppConfig.debugMode) {
            print(
              '✅ [AuthService] 사용자 정보 업데이트 완료: ${updatedUserInfo['memberName']}',
            );
          }

          return updatedUserInfo;
        } else {
          throw Exception('[사용자 정보 조회] ${processedResponse['message']}');
        }
      } else {
        throw Exception('[사용자 정보 조회] HTTP 오류: ${response.statusCode}');
      }
    } catch (e) {
      if (AppConfig.debugMode) {
        print('❌ [AuthService] 사용자 정보 조회 실패: $e');
      }

      if (e is DioException) {
        // ApiUtils를 사용하여 통합 에러 처리
        throw ApiUtils.processDioException(e, '사용자 정보 조회');
      }
      rethrow;
    }
  }

  /// 🎭 사용자 역할 가져오기
  Future<String?> getUserRole() async {
    final userInfo = await getUserInfo();
    return userInfo?['role'];
  }

  /// 🆔 사용자 ID 가져오기
  Future<int?> getMemberId() async {
    final userInfo = await getUserInfo();
    return userInfo?['memberId'];
  }

  /// 신규 회원 여부 확인
  Future<bool> isNewMember() async {
    final userInfo = await getUserInfo();
    return userInfo?['newMember'] ?? false;
  }

  /// 📝 사용자 이름 가져오기
  Future<String?> getMemberName() async {
    final userInfo = await getUserInfo();
    return userInfo?['memberName'];
  }

  /// 🗑️ 로컬 인증 데이터만 삭제 (백엔드 API 호출 없이)
  ///
  /// 강제 로그아웃 시 사용 - 토큰이 이미 만료된 상황에서 로컬 데이터만 정리
  Future<void> clearLocalAuthData() async {
    try {
      await _clearAuthData();
      if (AppConfig.debugMode) {
        print('🗑️ 로컬 인증 데이터 삭제 완료 (백엔드 호출 없이)');
      }
    } catch (e) {
      if (AppConfig.debugMode) {
        print('❌ 로컬 인증 데이터 삭제 중 오류: $e');
      }
      rethrow;
    }
  }

  /// 🔍 디버그용 - 저장된 인증 정보 출력
  Future<void> printStoredInfo() async {
    if (AppConfig.debugMode) {
      print('🔍 === 저장된 인증 정보 ===');

      final accessToken = await getAccessToken();
      final refreshToken = await getRefreshToken();
      final userInfo = await getUserInfo();

      print('Access Token: ${accessToken?.substring(0, 30) ?? 'null'}...');
      print('Refresh Token: ${refreshToken?.substring(0, 30) ?? 'null'}...');
      print('User Info: $userInfo');
      print('Member ID: ${userInfo?['memberId']}');
      print('Member Name: ${userInfo?['memberName'] ?? '미등록'}'); // null 처리
      print('Role: ${userInfo?['role']}');
      print('New Member: ${userInfo?['newMember']}');
      print('========================');
    }
  }
}
