import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'dart:html' as html;
import 'dart:js' as js;
import 'dart:convert';

import '../../core/config/app_config.dart';
import '../../core/utils/api_utils.dart';
import '../../core/services/auth_service.dart';
import '../../models/fcm/fcm_send_result.dart';
import '../../main.dart' show navigatorKey;

/// FCM 푸시 알림 서비스
///
/// 주요 기능:
/// - FCM 토큰 발급 및 관리
/// - 알림 권한 요청
/// - 포그라운드/백그라운드 알림 처리
/// - 백엔드에 토큰 등록
/// - 알림 클릭 시 화면 이동
class FcmService {
  static final FcmService _instance = FcmService._internal();
  factory FcmService() => _instance;
  FcmService._internal();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final Dio _dio = Dio();
  final AuthService _authService = AuthService();

  String? _currentToken;
  String? get currentToken => _currentToken;

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  static const String typeDiscussionGroup = 'DISCUSSION_GROUP';

  /// FCM 서비스 초기화
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      final settings = await requestPermission();

      if (settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional) {
        await _getToken();
        _setupTokenRefreshListener();
        _setupForegroundMessageListener();
        _setupNotificationClickListener();

        if (kIsWeb) {
          _setupServiceWorkerMessageListener();
        }

        _isInitialized = true;
        _log('FCM 서비스 초기화 완료');
      } else {
        _log('알림 권한 거부됨', isError: true);
      }
    } catch (e) {
      _log('FCM 초기화 실패: $e', isError: true);
    }
  }

  /// 알림 권한 요청
  Future<NotificationSettings> requestPermission() async {
    return await _messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
  }

  /// FCM 토큰 발급
  Future<String?> _getToken() async {
    try {
      String? token;

      if (kIsWeb) {
        token = await _messaging.getToken(vapidKey: _getVapidKey());
      } else {
        token = await _messaging.getToken();
      }

      if (token != null) {
        _currentToken = token;
        await registerTokenToServer(token);
      }

      return token;
    } catch (e) {
      _log('토큰 발급 실패: $e', isError: true);
      return null;
    }
  }

  /// 토큰 갱신 리스너
  void _setupTokenRefreshListener() {
    _messaging.onTokenRefresh.listen((newToken) {
      _currentToken = newToken;
      registerTokenToServer(newToken);
    });
  }

  /// 포그라운드 메시지 리스너
  void _setupForegroundMessageListener() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _handleForegroundMessage(message);
    });
  }

  /// 알림 클릭 리스너 (Firebase - 모바일용)
  void _setupNotificationClickListener() {
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _handleNotificationClick(message);
    });

    _messaging.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        _handleNotificationClick(message);
      }
    });
  }

  /// Service Worker 메시지 리스너 (웹 전용)
  void _setupServiceWorkerMessageListener() {
    // Service Worker 메시지 리스너 등록
    final jsCode = '''
      (function() {
        if ('serviceWorker' in navigator) {
          navigator.serviceWorker.addEventListener('message', function(event) {
            if (event.data && event.data.type === 'NOTIFICATION_CLICK') {
              window.postMessage({
                source: 'service-worker',
                type: 'NOTIFICATION_CLICK',
                url: event.data.url,
                data: event.data.data
              }, '*');
            }
          });
        }
      })();
    ''';
    
    js.context.callMethod('eval', [jsCode]);

    // window.postMessage 리스너
    html.window.onMessage.listen((html.MessageEvent event) {
      try {
        if (event.data is Map) {
          final data = Map<String, dynamic>.from(event.data as Map);
          
          if (data['source'] == 'service-worker' && 
              data['type'] == 'NOTIFICATION_CLICK') {
            _handleServiceWorkerNotificationClick(data);
          }
        }
      } catch (e) {
        _log('메시지 처리 오류: $e', isError: true);
      }
    });
  }

  /// Service Worker 알림 클릭 처리
  void _handleServiceWorkerNotificationClick(Map<String, dynamic> message) {
    final url = message['url'] as String?;
    final notificationData = message['data'];

    if (url != null && url.isNotEmpty) {
      _navigateToUrl(url);
    } else if (notificationData != null) {
      final data = notificationData is Map 
          ? Map<String, dynamic>.from(notificationData)
          : <String, dynamic>{};
      _navigateByNotificationData(data);
    }
  }

  /// URL로 화면 이동
  void _navigateToUrl(String url) {
    if (navigatorKey.currentState == null) {
      Future.delayed(const Duration(milliseconds: 500), () {
        _navigateToUrl(url);
      });
      return;
    }

    try {
      navigatorKey.currentState?.pushNamed(url);
    } catch (e) {
      _log('화면 이동 실패: $e', isError: true);
    }
  }

  /// 포그라운드 메시지 처리 (data-only 메시지 방식)
  void _handleForegroundMessage(RemoteMessage message) {
    // 🎯 data-only 메시지: title/body를 message.data에서 가져옴
    final title = message.data['title'] ?? '글나무';
    final body = message.data['body'] ?? '';

    if (kIsWeb) {
      _showBrowserNotification(title, body, message.data);
    }
  }

  /// 브라우저 알림 표시
  Future<void> _showBrowserNotification(String title, String body, Map<String, dynamic> data) async {
    try {
      if (html.Notification.permission == 'granted') {
        String dataJsonString;
        try {
          dataJsonString = jsonEncode(data);
        } catch (e) {
          dataJsonString = '{}';
        }
        
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
            } catch (e) {
              console.error('[FCM] 알림 표시 실패:', e);
            }
          })();
        ''';
        
        js.context.callMethod('eval', [jsCode]);
      } else if (html.Notification.permission == 'default') {
        html.Notification.requestPermission();
      }
    } catch (e) {
      _log('브라우저 알림 표시 실패: $e', isError: true);
    }
  }
  
  /// JavaScript 문자열 이스케이프 처리
  String _escapeJsString(String input) {
    return input
        .replaceAll('\\', '\\\\')
        .replaceAll('"', '\\"')
        .replaceAll("'", "\\'")
        .replaceAll('\n', '\\n')
        .replaceAll('\r', '\\r');
  }

  /// 알림 클릭 처리 (Firebase 방식)
  void _handleNotificationClick(RemoteMessage message) {
    if (navigatorKey.currentState == null) {
      Future.delayed(const Duration(milliseconds: 500), () {
        _navigateByNotificationData(message.data);
      });
      return;
    }

    _navigateByNotificationData(message.data);
  }

  /// 알림 데이터에 따라 화면 이동
  void _navigateByNotificationData(Map<String, dynamic> data) {
    final type = data['type'] as String?;
    final meetingIdStr = data['meetingId'] as String?;

    switch (type) {
      case typeDiscussionGroup:
        _navigateToDiscussionGroup(meetingIdStr);
        break;
      
      case 'ATTENDANCE':
        _navigateToAttendanceStatus(meetingIdStr);
        break;
      
      default:
        if (meetingIdStr != null && meetingIdStr.isNotEmpty) {
          _navigateToDiscussionGroup(meetingIdStr);
        } else if (data.containsKey('route')) {
          final route = data['route'] as String?;
          if (route != null && route.isNotEmpty) {
            _navigateToRoute(route);
          }
        }
    }
  }

  /// 토론 조 화면으로 이동
  void _navigateToDiscussionGroup(String? meetingIdStr) {
    if (meetingIdStr == null || meetingIdStr.isEmpty) return;

    final meetingId = int.tryParse(meetingIdStr);
    if (meetingId == null) return;

    try {
      navigatorKey.currentState?.pushNamed(
        '/discussion-group',
        arguments: {'meetingId': meetingId, 'meetingTitle': null},
      );
    } catch (e) {
      _log('화면 이동 실패: $e', isError: true);
    }
  }

  /// 출석 현황 화면으로 이동
  void _navigateToAttendanceStatus(String? meetingIdStr) {
    if (meetingIdStr == null || meetingIdStr.isEmpty) return;

    final meetingId = int.tryParse(meetingIdStr);
    if (meetingId == null) return;

    try {
      navigatorKey.currentState?.pushNamed(
        '/attendance/status',
        arguments: {'meetingId': meetingId, 'meetingTitle': null},
      );
    } catch (e) {
      _log('화면 이동 실패: $e', isError: true);
    }
  }

  /// 지정된 라우트로 이동
  void _navigateToRoute(String route) {
    try {
      navigatorKey.currentState?.pushNamed(route);
    } catch (e) {
      _log('화면 이동 실패: $e', isError: true);
    }
  }

  /// 백엔드에 FCM 토큰 등록
  Future<bool> registerTokenToServer(String token) async {
    try {
      final accessToken = await _authService.getAccessToken();
      if (accessToken == null || accessToken.isEmpty) return false;

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
        return result['success'] == true;
      }

      return false;
    } catch (e) {
      // 토큰 등록 실패는 앱 동작에 영향 없음 (조용히 실패)
      return false;
    }
  }

  /// 푸시 알림 발송 (관리자 전용)
  Future<FcmSendResult?> sendNotification({
    required String title,
    required String body,
    required List<int> memberIds,
    required String accessToken,
  }) async {
    try {
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
          return FcmSendResult.fromJson(result['data']);
        }
      }

      return null;
    } catch (e) {
      _log('푸시 알림 발송 실패: $e', isError: true);
      return null;
    }
  }

  /// VAPID 키 (웹 푸시용)
  String _getVapidKey() {
    return 'BLSz2JcQqCnn4UUrvfc7UFylmfnaXXgzx2nvT2yn9wma13CY5lmFPoRukKhy6Fv52nL82bDFwlnIATzLbbatn78';
  }

  /// 디버그 로그 (에러만 출력)
  void _log(String message, {bool isError = false}) {
    if (AppConfig.debugMode && isError) {
      debugPrint('❌ [FCM] $message');
    }
  }

  /// 토큰 일부만 표시 (보안)
  String _truncateToken(String token) {
    if (token.length > 20) {
      return '${token.substring(0, 10)}...${token.substring(token.length - 10)}';
    }
    return token;
  }

  /// 현재 알림 권한 상태 확인
  Future<AuthorizationStatus> getPermissionStatus() async {
    final settings = await _messaging.getNotificationSettings();
    return settings.authorizationStatus;
  }

  /// 토큰 강제 갱신
  Future<String?> refreshToken() async {
    await _messaging.deleteToken();
    return await _getToken();
  }
}
