import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:dio/dio.dart';

import '../../core/config/app_config.dart';
import '../../core/utils/api_utils.dart';

/// 🔥 FCM 푸시 알림 서비스
///
/// 주요 기능:
/// - FCM 토큰 발급 및 관리
/// - 알림 권한 요청
/// - 포그라운드/백그라운드 알림 처리
/// - 백엔드에 토큰 등록
class FcmService {
  // Singleton 패턴
  static final FcmService _instance = FcmService._internal();
  factory FcmService() => _instance;
  FcmService._internal();

  // Firebase Messaging 인스턴스
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  // Dio 인스턴스
  final Dio _dio = Dio();

  // 현재 FCM 토큰
  String? _currentToken;
  String? get currentToken => _currentToken;

  // 초기화 여부
  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

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
    // 웹에서는 브라우저 알림으로 표시
    // 모바일에서는 로컬 알림으로 표시 (flutter_local_notifications 필요)

    // 현재는 로그만 출력
    // TODO: 인앱 알림 UI 또는 로컬 알림 표시 구현
    _log('포그라운드 메시지 처리 완료');
  }

  /// 🔔 알림 클릭 처리
  void _handleNotificationClick(RemoteMessage message) {
    // 알림 데이터에 따라 특정 화면으로 이동
    final data = message.data;

    if (data.containsKey('meetingId')) {
      final meetingId = data['meetingId'];
      _log('모임 상세 화면으로 이동: $meetingId');
      // TODO: Navigator로 모임 상세 화면 이동
    } else if (data.containsKey('route')) {
      final route = data['route'];
      _log('지정된 라우트로 이동: $route');
      // TODO: Navigator로 해당 라우트 이동
    }
  }

  /// 🌐 백엔드에 FCM 토큰 등록
  Future<bool> registerTokenToServer(String token) async {
    try {
      _log('백엔드에 FCM 토큰 등록 중...');

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
            // TODO: 인증 토큰 추가
            // 'Authorization': 'Bearer $accessToken',
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

  /// 🗑️ 백엔드에서 FCM 토큰 삭제 (로그아웃 시)
  Future<bool> unregisterTokenFromServer() async {
    if (_currentToken == null) return true;

    try {
      _log('백엔드에서 FCM 토큰 삭제 중...');

      final response = await _dio.delete(
        AppConfig.getApiEndpoint('fcm/token'),
        data: {'token': _currentToken},
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            // TODO: 인증 토큰 추가
          },
        ),
      );

      if (response.statusCode == 200) {
        _log('FCM 토큰 백엔드 삭제 성공! ✅');
        return true;
      }

      return false;
    } catch (e) {
      _log('FCM 토큰 백엔드 삭제 실패: $e', isError: true);
      return false;
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
