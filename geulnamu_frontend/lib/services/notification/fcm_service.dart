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
import '../navigation/pending_navigation_service.dart';

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
  final PendingNavigationService _pendingNavigationService = PendingNavigationService();

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
    if (AppConfig.debugMode) {
      print('📡 [FCM] Service Worker 메시지 리스너 설정 시작...');
    }

    // Service Worker 메시지 리스너 등록
    final jsCode = '''
      (function() {
        console.log('[글나무 JS] Service Worker 메시지 리스너 등록 시작...');
        
        if ('serviceWorker' in navigator && navigator.serviceWorker.controller) {
          console.log('[글나무 JS] Service Worker controller 존재!');
          
          navigator.serviceWorker.addEventListener('message', function(event) {
            console.log('[글나무 JS] SW에서 메시지 수신:', event.data);
            
            if (event.data && event.data.type === 'NOTIFICATION_CLICK') {
              console.log('[글나무 JS] NOTIFICATION_CLICK 감지, window.postMessage 전송...');
              window.postMessage({
                source: 'service-worker',
                type: 'NOTIFICATION_CLICK',
                url: event.data.url,
                data: event.data.data
              }, '*');
            }
          });
          
          console.log('[글나무 JS] Service Worker 메시지 리스너 등록 완료!');
        } else {
          console.warn('[글나무 JS] Service Worker controller가 없음!');
          
          // controller가 아직 없으면 ready 대기
          navigator.serviceWorker.ready.then(function(registration) {
            console.log('[글나무 JS] Service Worker ready, 리스너 등록...');
            
            navigator.serviceWorker.addEventListener('message', function(event) {
              console.log('[글나무 JS] SW에서 메시지 수신:', event.data);
              
              if (event.data && event.data.type === 'NOTIFICATION_CLICK') {
                console.log('[글나무 JS] NOTIFICATION_CLICK 감지, window.postMessage 전송...');
                window.postMessage({
                  source: 'service-worker',
                  type: 'NOTIFICATION_CLICK',
                  url: event.data.url,
                  data: event.data.data
                }, '*');
              }
            });
          });
        }
      })();
    ''';
    
    js.context.callMethod('eval', [jsCode]);

    // window.postMessage 리스너
    html.window.onMessage.listen((html.MessageEvent event) {
      try {
        if (AppConfig.debugMode) {
          print('📨 [FCM] window.onMessage 수신: ${event.data}');
        }
        
        if (event.data is Map) {
          final data = Map<String, dynamic>.from(event.data as Map);
          
          if (data['source'] == 'service-worker' && 
              data['type'] == 'NOTIFICATION_CLICK') {
            if (AppConfig.debugMode) {
              print('✅ [FCM] NOTIFICATION_CLICK 메시지 확인!');
            }
            _handleServiceWorkerNotificationClick(data);
          }
        }
      } catch (e) {
        _log('메시지 처리 오류: $e', isError: true);
      }
    });

    if (AppConfig.debugMode) {
      print('✅ [FCM] Service Worker 메시지 리스너 설정 완료!');
    }
  }

  /// Service Worker 알림 클릭 처리
  void _handleServiceWorkerNotificationClick(Map<String, dynamic> message) async {
    if (AppConfig.debugMode) {
      print('📩 [FCM] Service Worker 알림 클릭 수신!');
      print('📩 [FCM] 메시지 전체: $message');
    }

    final url = message['url'] as String?;
    final notificationData = message['data'];

    if (AppConfig.debugMode) {
      print('📩 [FCM] URL: $url');
      print('📩 [FCM] data: $notificationData');
    }

    // 🔐 로그인 상태 확인
    final isLoggedIn = await _authService.isLoggedIn();
    
    if (AppConfig.debugMode) {
      print('🔐 [FCM] 로그인 상태: ${isLoggedIn ? '로그인됨' : '비로그인'}');
    }

    if (url != null && url.isNotEmpty) {
      if (isLoggedIn) {
        if (AppConfig.debugMode) {
          print('🚀 [FCM] 로그인 상태 - URL로 바로 이동: $url');
        }
        _navigateToUrl(url);
      } else {
        if (AppConfig.debugMode) {
          print('📌 [FCM] 비로그인 상태 - Pending Navigation 저장: $url');
        }
        await _pendingNavigationService.savePendingNavigationFromUrl(url);
        // 홈화면으로 이동 (로그인 유도)
        _navigateToUrl('/home');
      }
    } else if (notificationData != null) {
      final data = notificationData is Map 
          ? Map<String, dynamic>.from(notificationData)
          : <String, dynamic>{};
      
      if (isLoggedIn) {
        if (AppConfig.debugMode) {
          print('🚀 [FCM] 로그인 상태 - data로 바로 이동: $data');
        }
        _navigateByNotificationData(data);
      } else {
        if (AppConfig.debugMode) {
          print('📌 [FCM] 비로그인 상태 - Pending Navigation 저장 (data): $data');
        }
        await _savePendingNavigationFromData(data);
        // 홈화면으로 이동 (로그인 유도)
        _navigateToUrl('/home');
      }
    } else {
      if (AppConfig.debugMode) {
        print('⚠️ [FCM] 이동할 URL이나 data가 없음!');
      }
    }
  }

  /// 알림 data를 기반으로 Pending Navigation 저장
  Future<void> _savePendingNavigationFromData(Map<String, dynamic> data) async {
    final type = data['type'] as String?;
    final meetingIdStr = data['meetingId'] as String?;
    final meetingTitle = data['meetingTitle'] as String?;

    String route;
    Map<String, dynamic>? arguments;

    switch (type) {
      case typeDiscussionGroup:
        route = '/discussion-group';
        break;
      case 'ATTENDANCE':
        route = '/attendance/status';
        break;
      default:
        // 기본값: 토론 조 화면
        if (meetingIdStr != null && meetingIdStr.isNotEmpty) {
          route = '/discussion-group';
        } else if (data.containsKey('route')) {
          route = data['route'] as String? ?? '/home';
        } else {
          route = '/home';
        }
    }

    if (meetingIdStr != null && meetingIdStr.isNotEmpty) {
      final meetingId = int.tryParse(meetingIdStr);
      if (meetingId != null) {
        arguments = {
          'meetingId': meetingId,
          if (meetingTitle != null) 'meetingTitle': meetingTitle,
        };
      }
    }

    await _pendingNavigationService.savePendingNavigation(
      route: route,
      arguments: arguments,
    );
  }

  /// URL로 화면 이동
  void _navigateToUrl(String url) {
    if (AppConfig.debugMode) {
      print('🎯 [FCM] _navigateToUrl 호출: $url');
      print('🎯 [FCM] navigatorKey.currentState: ${navigatorKey.currentState}');
    }

    if (navigatorKey.currentState == null) {
      if (AppConfig.debugMode) {
        print('⚠️ [FCM] Navigator 없음, 500ms 후 재시도...');
      }
      Future.delayed(const Duration(milliseconds: 500), () {
        _navigateToUrl(url);
      });
      return;
    }

    try {
      if (AppConfig.debugMode) {
        print('✅ [FCM] pushNamed 실행: $url');
      }
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
