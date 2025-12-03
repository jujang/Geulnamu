import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:dio/dio.dart';
import 'dart:html' as html; // 🔔 브라우저 알림용
import 'dart:js' as js; // 🔔 JavaScript 호출용

import '../../core/config/app_config.dart';
import '../../core/utils/api_utils.dart';
import '../../core/services/auth_service.dart'; // 🔐 인증 토큰용
import '../../models/fcm/fcm_send_result.dart'; // 📤 발송 결과 모델
import '../../main.dart' show navigatorKey; // 🎯 전역 Navigator Key

/// 🔥 FCM 푸시 알림 서비스
///
/// 주요 기능:
/// - FCM 토큰 발급 및 관리
/// - 알림 권한 요청
/// - 포그라운드/백그라운드 알림 처리
/// - 백엔드에 토큰 등록
/// - 알림 클릭 시 화면 이동
class FcmService {
  // Singleton 패턴
  static final FcmService _instance = FcmService._internal();
  factory FcmService() => _instance;
  FcmService._internal();

  // Firebase Messaging 인스턴스
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  // Dio 인스턴스
  final Dio _dio = Dio();

  // 🔐 AuthService 인스턴스 (인증 토큰 조회용)
  final AuthService _authService = AuthService();

  // 현재 FCM 토큰
  String? _currentToken;
  String? get currentToken => _currentToken;

  // 초기화 여부
  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  // 🎯 알림 타입 상수 (백엔드와 일치)
  static const String typeDiscussionGroup = 'DISCUSSION_GROUP';

  /// 🔥 FCM 서비스 초기화
  ///
  /// 앱 시작 시 호출하여 FCM을 설정합니다.
  Future<void> initialize() async {
    if (_isInitialized) {
      _log('이미 초기화됨');
      return;
    }

    try {
      _log('FCM 서비스 초기화 시작...');

      // 1️⃣ 알림 권한 요청
      final settings = await requestPermission();
      _log('알림 권한 상태: ${settings.authorizationStatus}');

      if (settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional) {
        // 2️⃣ FCM 토큰 발급
        await _getToken();

        // 3️⃣ 토큰 갱신 리스너 설정
        _setupTokenRefreshListener();

        // 4️⃣ 포그라운드 메시지 리스너 설정
        _setupForegroundMessageListener();

        // 5️⃣ 알림 클릭 리스너 설정
        _setupNotificationClickListener();

        _isInitialized = true;
        _log('FCM 서비스 초기화 완료! ✅');
      } else {
        _log('알림 권한이 거부되었습니다. ❌');
      }
    } catch (e) {
      _log('FCM 서비스 초기화 실패: $e', isError: true);
    }
  }

  /// 📱 알림 권한 요청
  Future<NotificationSettings> requestPermission() async {
    _log('알림 권한 요청 중...');

    final settings = await _messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    _log('권한 요청 결과: ${settings.authorizationStatus}');
    return settings;
  }

  /// 🔑 FCM 토큰 발급
  Future<String?> _getToken() async {
    try {
      String? token;

      if (kIsWeb) {
        // 🌐 웹: VAPID 키 필요
        // Firebase Console > 프로젝트 설정 > 클라우드 메시징 > 웹 구성에서 확인
        token = await _messaging.getToken(vapidKey: _getVapidKey());
      } else {
        // 📱 모바일: VAPID 키 불필요
        token = await _messaging.getToken();
      }

      if (token != null) {
        _currentToken = token;
        _log('FCM 토큰 발급 성공: ${_truncateToken(token)}');

        // 토큰을 백엔드에 등록
        await registerTokenToServer(token);
      } else {
        _log('FCM 토큰이 null입니다.', isError: true);
      }

      return token;
    } catch (e) {
      _log('FCM 토큰 발급 실패: $e', isError: true);
      return null;
    }
  }

  /// 🔄 토큰 갱신 리스너
  void _setupTokenRefreshListener() {
    _messaging.onTokenRefresh.listen((newToken) {
      _log('FCM 토큰 갱신됨: ${_truncateToken(newToken)}');
      _currentToken = newToken;

      // 새 토큰을 백엔드에 등록
      registerTokenToServer(newToken);
    });
  }

  /// 📬 포그라운드 메시지 리스너
  void _setupForegroundMessageListener() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _log('📬 포그라운드 메시지 수신!');
      _log('  제목: ${message.notification?.title}');
      _log('  내용: ${message.notification?.body}');
      _log('  데이터: ${message.data}');

      // 포그라운드에서 알림 처리
      _handleForegroundMessage(message);
    });
  }

  /// 🔔 알림 클릭 리스너
  void _setupNotificationClickListener() {
    // 앱이 백그라운드에서 열렸을 때
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _log('🔔 알림 클릭으로 앱 열림!');
      _log('  데이터: ${message.data}');

      _handleNotificationClick(message);
    });

    // 앱이 종료된 상태에서 알림으로 열렸을 때
    _messaging.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        _log('🔔 종료 상태에서 알림으로 앱 실행!');
        _log('  데이터: ${message.data}');

        _handleNotificationClick(message);
      }
    });
  }

  /// 📬 포그라운드 메시지 처리
  void _handleForegroundMessage(RemoteMessage message) {
    final title = message.notification?.title ?? '글나무';
    final body = message.notification?.body ?? '';

    // 🌐 웹: 브라우저 Notification API 사용
    if (kIsWeb) {
      _showBrowserNotification(title, body, message.data);
    } else {
      // 📱 모바일: flutter_local_notifications 필요
      // TODO: 모바일 로컬 알림 구현
      _log('모바일 포그라운드 알림 처리 (미구현)');
    }

    _log('포그라운드 메시지 처리 완료');
  }

  /// 🌐 브라우저 알림 표시 (ServiceWorker Notification API)
  /// 
  /// PWA 환경에서는 html.Notification() 생성자가 차단되므로
  /// ServiceWorkerRegistration.showNotification()을 사용해야 합니다.
  Future<void> _showBrowserNotification(String title, String body, Map<String, dynamic> data) async {
    try {
      // 알림 권한 확인
      if (html.Notification.permission == 'granted') {
        // Service Worker를 통한 알림 표시 (PWA 환경에서 필수)
        final jsCode = '''
          (async function() {
            try {
              const registration = await navigator.serviceWorker.ready;
              await registration.showNotification("${_escapeJsString(title)}", {
                body: "${_escapeJsString(body)}",
                icon: "/icons/Icon-192.png",
                badge: "/icons/Icon-192.png",
                tag: "geulnamu-foreground-notification",
                vibrate: [100, 50, 100],
                requireInteraction: false
              });
              console.log('🔔 [FCM] Service Worker 알림 표시 성공');
            } catch (e) {
              console.error('🔔 [FCM] Service Worker 알림 표시 실패:', e);
            }
          })();
        ''';
        
        js.context.callMethod('eval', [jsCode]);
        _log('🔔 브라우저 알림 표시 요청 완료: $title');
      } else if (html.Notification.permission == 'default') {
        // 권한 요청 필요
        _log('알림 권한이 아직 설정되지 않았습니다.', isError: true);
        html.Notification.requestPermission();
      } else {
        _log('알림 권한이 거부되었습니다.', isError: true);
      }
    } catch (e) {
      _log('브라우저 알림 표시 실패: $e', isError: true);
    }
  }
  
  /// 🔧 JavaScript 문자열 이스케이프 처리
  String _escapeJsString(String input) {
    return input
        .replaceAll('\\', '\\\\')
        .replaceAll('"', '\\"')
        .replaceAll("'", "\\'")
        .replaceAll('\n', '\\n')
        .replaceAll('\r', '\\r');
  }

  /// 🔔 알림 클릭 처리 - 화면 이동
  /// 
  /// 백엔드에서 보내는 데이터 구조:
  /// - type: 알림 타입 (예: "DISCUSSION_GROUP")
  /// - meetingId: 모임 ID (문자열)
  void _handleNotificationClick(RemoteMessage message) {
    final data = message.data;
    _log('🎯 알림 클릭 처리 시작');
    _log('  데이터: $data');

    // Navigator가 준비되었는지 확인
    if (navigatorKey.currentState == null) {
      _log('Navigator가 아직 준비되지 않았습니다.', isError: true);
      // 약간의 지연 후 재시도
      Future.delayed(const Duration(milliseconds: 500), () {
        _navigateByNotificationData(data);
      });
      return;
    }

    _navigateByNotificationData(data);
  }

  /// 🎯 알림 데이터에 따라 화면 이동
  void _navigateByNotificationData(Map<String, dynamic> data) {
    final type = data['type'] as String?;
    final meetingIdStr = data['meetingId'] as String?;

    _log('🎯 알림 타입: $type, 모임 ID: $meetingIdStr');

    // type에 따라 분기 처리
    switch (type) {
      case typeDiscussionGroup:
        // 🎯 토론 조 알림 → 출석 현황 화면으로 이동
        _navigateToAttendanceStatus(meetingIdStr);
        break;
      
      default:
        // type이 없거나 알 수 없는 경우, meetingId만 있으면 출석 현황으로
        if (meetingIdStr != null && meetingIdStr.isNotEmpty) {
          _navigateToAttendanceStatus(meetingIdStr);
        } else if (data.containsKey('route')) {
          // route가 있으면 해당 라우트로 이동
          final route = data['route'] as String?;
          if (route != null && route.isNotEmpty) {
            _navigateToRoute(route);
          }
        } else {
          _log('처리할 수 없는 알림 데이터입니다.', isError: true);
        }
    }
  }

  /// 🎯 출석 현황 화면으로 이동
  void _navigateToAttendanceStatus(String? meetingIdStr) {
    if (meetingIdStr == null || meetingIdStr.isEmpty) {
      _log('meetingId가 없습니다.', isError: true);
      return;
    }

    final meetingId = int.tryParse(meetingIdStr);
    if (meetingId == null) {
      _log('meetingId 파싱 실패: $meetingIdStr', isError: true);
      return;
    }

    _log('✅ 출석 현황 화면으로 이동: meetingId=$meetingId');

    try {
      navigatorKey.currentState?.pushNamed(
        '/attendance/status',
        arguments: {
          'meetingId': meetingId,
          'meetingTitle': null, // 제목은 화면에서 조회
        },
      );
    } catch (e) {
      _log('화면 이동 실패: $e', isError: true);
    }
  }

  /// 🎯 지정된 라우트로 이동
  void _navigateToRoute(String route) {
    _log('✅ 지정된 라우트로 이동: $route');

    try {
      navigatorKey.currentState?.pushNamed(route);
    } catch (e) {
      _log('화면 이동 실패: $e', isError: true);
    }
  }

  /// 🌐 백엔드에 FCM 토큰 등록
  Future<bool> registerTokenToServer(String token) async {
    try {
      _log('백엔드에 FCM 토큰 등록 중...');

      // 🔐 인증 토큰 가져오기
      final accessToken = await _authService.getAccessToken();
      if (accessToken == null || accessToken.isEmpty) {
        _log('액세스 토큰이 없습니다. 로그인 후 시도해주세요.', isError: true);
        return false;
      }

      // 디바이스 타입 결정
      String deviceType;
      if (kIsWeb) {
        deviceType = 'WEB';
      } else {
        // TODO: Platform.isAndroid / Platform.isIOS 체크
        deviceType = 'MOBILE';
      }

      final response = await _dio.post(
        AppConfig.getApiEndpoint('fcm/token'),
        data: {'token': token, 'deviceType': deviceType},
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $accessToken', // 🔐 인증 토큰 추가
          },
        ),
      );

      if (response.statusCode == 200) {
        final result = ApiUtils.processBackendResponse(response, 'FCM 토큰 등록');
        if (result['success']) {
          _log('FCM 토큰 백엔드 등록 성공! ✅');
          return true;
        }
      }

      _log('FCM 토큰 백엔드 등록 실패', isError: true);
      return false;
    } catch (e) {
      // 백엔드 API가 아직 없을 수 있으므로 에러는 경고로 처리
      _log('FCM 토큰 백엔드 등록 실패 (API 미구현?): $e', isError: false);
      return false;
    }
  }

  /// 📤 푸시 알림 발송 (관리자 전용)
  /// 
  /// API: POST /fcm/notification
  /// 권한: ADMIN
  /// 반환: FcmSendResult? (성공 시 결과 객체, 실패 시 null)
  Future<FcmSendResult?> sendNotification({
    required String title,
    required String body,
    required List<int> memberIds,
    required String accessToken,
  }) async {
    try {
      _log('푸시 알림 발송 중...');
      _log('  제목: $title');
      _log('  내용: $body');
      _log('  수신자: $memberIds');

      final response = await _dio.post(
        AppConfig.getApiEndpoint('fcm/notification'),
        data: {
          'title': title,
          'body': body,
          'memberList': memberIds,
        },
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $accessToken',
          },
        ),
      );

      if (response.statusCode == 200) {
        final result = ApiUtils.processBackendResponse(response, '푸시 알림 발송');
        if (result['success'] && result['data'] != null) {
          final sendResult = FcmSendResult.fromJson(result['data']);
          _log('푸시 알림 발송 완료! ${sendResult.resultMessage}');
          return sendResult;
        }
      }

      _log('푸시 알림 발송 실패', isError: true);
      return null;
    } catch (e) {
      _log('푸시 알림 발송 실패: $e', isError: true);
      return null;
    }
  }

  /// 🔑 VAPID 키 (웹 푸시용)
  ///
  /// Firebase Console > 프로젝트 설정 > 클라우드 메시징 > 웹 구성에서 확인
  String _getVapidKey() {
    return 'BLSz2JcQqCnn4UUrvfc7UFylmfnaXXgzx2nvT2yn9wma13CY5lmFPoRukKhy6Fv52nL82bDFwlnIATzLbbatn78';
  }

  /// 🛠️ 디버그 로그
  void _log(String message, {bool isError = false}) {
    if (AppConfig.debugMode) {
      final prefix = isError ? '❌' : '🔔';
      print('$prefix [FCM] $message');
    }
  }

  /// 🔒 토큰 일부만 표시 (보안)
  String _truncateToken(String token) {
    if (token.length > 20) {
      return '${token.substring(0, 10)}...${token.substring(token.length - 10)}';
    }
    return token;
  }

  /// 📊 현재 알림 권한 상태 확인
  Future<AuthorizationStatus> getPermissionStatus() async {
    final settings = await _messaging.getNotificationSettings();
    return settings.authorizationStatus;
  }

  /// 🔄 토큰 강제 갱신
  Future<String?> refreshToken() async {
    await _messaging.deleteToken();
    return await _getToken();
  }
}
