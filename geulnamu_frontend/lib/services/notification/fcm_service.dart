import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'dart:html' as html; // 🔔 브라우저 알림용
import 'dart:js' as js; // 🔔 JavaScript 호출용
import 'dart:convert'; // 🔔 JSON 인코딩용

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
/// - 알림 클릭 시 화면 이동 (Service Worker postMessage 방식)
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

        // 5️⃣ 알림 클릭 리스너 설정 (Firebase)
        _setupNotificationClickListener();

        // 6️⃣ 🌐 웹: Service Worker 메시지 리스너 설정
        if (kIsWeb) {
          _setupServiceWorkerMessageListener();
        }

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

  /// 🔔 알림 클릭 리스너 (Firebase - 모바일용)
  void _setupNotificationClickListener() {
    // 앱이 백그라운드에서 열렸을 때
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _log('🔔 알림 클릭으로 앱 열림! (Firebase)');
      _log('  데이터: ${message.data}');

      _handleNotificationClick(message);
    });

    // 앱이 종료된 상태에서 알림으로 열렸을 때
    _messaging.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        _log('🔔 종료 상태에서 알림으로 앱 실행! (Firebase)');
        _log('  데이터: ${message.data}');

        _handleNotificationClick(message);
      }
    });
  }

  /// 🌐 Service Worker 메시지 리스너 (웹 전용)
  /// 
  /// Service Worker에서 postMessage로 보낸 알림 클릭 이벤트를 처리합니다.
  /// navigator.serviceWorker.onmessage를 사용해야 합니다.
  void _setupServiceWorkerMessageListener() {
    _log('🌐 Service Worker 메시지 리스너 설정 중...');

    // JavaScript를 통해 Service Worker 메시지 리스너 등록
    final jsCode = '''
      (function() {
        if ('serviceWorker' in navigator) {
          navigator.serviceWorker.addEventListener('message', function(event) {
            console.log('📨 [Flutter] Service Worker 메시지 수신:', event.data);
            
            if (event.data && event.data.type === 'NOTIFICATION_CLICK') {
              // Flutter로 이벤트 전달 (window.postMessage 사용)
              window.postMessage({
                source: 'service-worker',
                type: 'NOTIFICATION_CLICK',
                url: event.data.url,
                data: event.data.data
              }, '*');
            }
          });
          console.log('✅ [Flutter] Service Worker 메시지 리스너 등록 완료');
        }
      })();
    ''';
    
    js.context.callMethod('eval', [jsCode]);

    // window.postMessage 리스너 (Service Worker → JS → Flutter)
    html.window.onMessage.listen((html.MessageEvent event) {
      try {
        // Service Worker에서 전달된 메시지인지 확인
        if (event.data is Map) {
          final data = Map<String, dynamic>.from(event.data as Map);
          
          if (data['source'] == 'service-worker' && 
              data['type'] == 'NOTIFICATION_CLICK') {
            _log('🔔 알림 클릭 메시지 수신! (Service Worker → Flutter)');
            _log('  URL: ${data['url']}');
            _log('  데이터: ${data['data']}');

            _handleServiceWorkerNotificationClick(data);
          }
        }
      } catch (e) {
        _log('메시지 처리 오류: $e', isError: true);
      }
    });

    _log('🌐 Service Worker 메시지 리스너 설정 완료! ✅');
  }

  /// 🌐 Service Worker 알림 클릭 처리
  void _handleServiceWorkerNotificationClick(Map<String, dynamic> message) {
    final url = message['url'] as String?;
    final notificationData = message['data'];

    _log('🎯 Service Worker 알림 클릭 처리');
    _log('  URL: $url');
    _log('  데이터: $notificationData');

    if (url != null && url.isNotEmpty) {
      // URL 방식으로 네비게이션
      _navigateToUrl(url);
    } else if (notificationData != null) {
      // 데이터 방식으로 네비게이션
      final data = notificationData is Map 
          ? Map<String, dynamic>.from(notificationData)
          : <String, dynamic>{};
      _navigateByNotificationData(data);
    }
  }

  /// 🎯 URL로 화면 이동 (쿼리 파라미터 방식)
  void _navigateToUrl(String url) {
    _log('🎯 URL로 화면 이동: $url');

    // Navigator가 준비되었는지 확인
    if (navigatorKey.currentState == null) {
      _log('Navigator가 아직 준비되지 않았습니다. 지연 후 재시도...', isError: true);
      Future.delayed(const Duration(milliseconds: 500), () {
        _navigateToUrl(url);
      });
      return;
    }

    try {
      // URL을 직접 pushNamed로 이동 (main.dart의 onGenerateRoute가 처리)
      navigatorKey.currentState?.pushNamed(url);
      _log('✅ 화면 이동 성공: $url');
    } catch (e) {
      _log('화면 이동 실패: $e', isError: true);
    }
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
      _log('🔔 브라우저 알림 표시 시도...');
      _log('  제목: $title');
      _log('  내용: $body');
      _log('  데이터: $data');

      // 알림 권한 확인
      if (html.Notification.permission == 'granted') {
        // 🎯 데이터를 안전하게 JSON 문자열로 변환
        String dataJsonString;
        try {
          dataJsonString = jsonEncode(data);
        } catch (e) {
          _log('데이터 JSON 변환 실패, 빈 객체 사용: $e', isError: true);
          dataJsonString = '{}';
        }
        
        // Service Worker를 통한 알림 표시 (PWA 환경에서 필수)
        final jsCode = '''
          (async function() {
            try {
              const registration = await navigator.serviceWorker.ready;
              const notificationData = $dataJsonString;
              
              await registration.showNotification("${_escapeJsString(title)}", {
                body: "${_escapeJsString(body)}",
                icon: "/icons/Icon-192.png",
                badge: "/icons/Icon-192.png",
                tag: "geulnamu-foreground-" + Date.now(),
                data: notificationData,
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
        _log('🔔 브라우저 알림 표시 요청 완료');
      } else if (html.Notification.permission == 'default') {
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

  /// 🔔 알림 클릭 처리 - 화면 이동 (Firebase 방식)
  void _handleNotificationClick(RemoteMessage message) {
    final data = message.data;
    _log('🎯 알림 클릭 처리 시작 (Firebase)');
    _log('  데이터: $data');

    // Navigator가 준비되었는지 확인
    if (navigatorKey.currentState == null) {
      _log('Navigator가 아직 준비되지 않았습니다.', isError: true);
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

    switch (type) {
      case typeDiscussionGroup:
        // 토론 조 알림 → 토론 조 화면으로 이동
        _navigateToDiscussionGroup(meetingIdStr);
        break;
      
      case 'ATTENDANCE':
        // 출석 알림 → 출석 현황 화면으로 이동
        _navigateToAttendanceStatus(meetingIdStr);
        break;
      
      default:
        if (meetingIdStr != null && meetingIdStr.isNotEmpty) {
          // 기본값: 토론 조 화면으로 이동
          _navigateToDiscussionGroup(meetingIdStr);
        } else if (data.containsKey('route')) {
          final route = data['route'] as String?;
          if (route != null && route.isNotEmpty) {
            _navigateToRoute(route);
          }
        } else {
          _log('처리할 수 없는 알림 데이터입니다.', isError: true);
        }
    }
  }

  /// 🎯 토론 조 화면으로 이동
  void _navigateToDiscussionGroup(String? meetingIdStr) {
    if (meetingIdStr == null || meetingIdStr.isEmpty) {
      _log('meetingId가 없습니다.', isError: true);
      return;
    }

    final meetingId = int.tryParse(meetingIdStr);
    if (meetingId == null) {
      _log('meetingId 파싱 실패: $meetingIdStr', isError: true);
      return;
    }

    _log('✅ 토론 조 화면으로 이동: meetingId=$meetingId');

    try {
      navigatorKey.currentState?.pushNamed(
        '/discussion-group',
        arguments: {
          'meetingId': meetingId,
          'meetingTitle': null,
        },
      );
    } catch (e) {
      _log('화면 이동 실패: $e', isError: true);
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
          'meetingTitle': null,
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

      final accessToken = await _authService.getAccessToken();
      if (accessToken == null || accessToken.isEmpty) {
        _log('액세스 토큰이 없습니다. 로그인 후 시도해주세요.', isError: true);
        return false;
      }

      String deviceType = kIsWeb ? 'WEB' : 'MOBILE';

      final response = await _dio.post(
        AppConfig.getApiEndpoint('fcm/token'),
        data: {'token': token, 'deviceType': deviceType},
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $accessToken',
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
      _log('FCM 토큰 백엔드 등록 실패 (API 미구현?): $e', isError: false);
      return false;
    }
  }

  /// 📤 푸시 알림 발송 (관리자 전용)
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
  String _getVapidKey() {
    return 'BLSz2JcQqCnn4UUrvfc7UFylmfnaXXgzx2nvT2yn9wma13CY5lmFPoRukKhy6Fv52nL82bDFwlnIATzLbbatn78';
  }

  /// 🛠️ 디버그 로그
  void _log(String message, {bool isError = false}) {
    if (AppConfig.debugMode) {
      final prefix = isError ? '❌' : '🔔';
      debugPrint('$prefix [FCM] $message');
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
