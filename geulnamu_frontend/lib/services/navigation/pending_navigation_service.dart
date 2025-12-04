import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/config/app_config.dart';

/// Pending Navigation 데이터 모델
class PendingNavigation {
  final String route;
  final Map<String, dynamic>? arguments;
  final DateTime createdAt;

  PendingNavigation({
    required this.route,
    this.arguments,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  /// JSON으로 변환
  Map<String, dynamic> toJson() => {
        'route': route,
        'arguments': arguments,
        'createdAt': createdAt.toIso8601String(),
      };

  /// JSON에서 생성
  factory PendingNavigation.fromJson(Map<String, dynamic> json) {
    return PendingNavigation(
      route: json['route'] as String,
      arguments: json['arguments'] as Map<String, dynamic>?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  /// 만료 여부 확인 (기본 5분)
  bool isExpired({Duration expiration = const Duration(minutes: 5)}) {
    return DateTime.now().difference(createdAt) > expiration;
  }

  @override
  String toString() => 'PendingNavigation(route: $route, arguments: $arguments, createdAt: $createdAt)';
}

/// Pending Navigation 서비스
///
/// 알림 클릭 시 목적지를 저장하고, 로그인 완료 후 해당 페이지로 이동하는 기능을 제공합니다.
///
/// 주요 기능:
/// - 알림 클릭 시 목적지 저장 (SharedPreferences)
/// - 로그인 완료 후 목적지 조회 및 삭제
/// - 만료된 pending navigation 자동 정리
///
/// 사용 예시:
/// ```dart
/// // 알림 클릭 시 저장
/// await PendingNavigationService().savePendingNavigation(
///   route: '/discussion-group',
///   arguments: {'meetingId': 123},
/// );
///
/// // 로그인 완료 후 조회 및 처리
/// final pending = await PendingNavigationService().getPendingNavigation();
/// if (pending != null) {
///   navigatorKey.currentState?.pushNamed(pending.route, arguments: pending.arguments);
///   await PendingNavigationService().clearPendingNavigation();
/// }
/// ```
class PendingNavigationService {
  static final PendingNavigationService _instance =
      PendingNavigationService._internal();
  factory PendingNavigationService() => _instance;
  PendingNavigationService._internal();

  static const String _storageKey = 'pending_navigation';

  /// Pending Navigation 저장
  ///
  /// [route]: 이동할 라우트 경로 (예: '/discussion-group')
  /// [arguments]: 라우트에 전달할 인자 (선택)
  Future<bool> savePendingNavigation({
    required String route,
    Map<String, dynamic>? arguments,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final pending = PendingNavigation(
        route: route,
        arguments: arguments,
      );

      final jsonString = jsonEncode(pending.toJson());
      final result = await prefs.setString(_storageKey, jsonString);

      if (AppConfig.debugMode) {
        print('📌 [PendingNavigation] 저장 완료: $pending');
      }

      return result;
    } catch (e) {
      if (AppConfig.debugMode) {
        print('❌ [PendingNavigation] 저장 실패: $e');
      }
      return false;
    }
  }

  /// Pending Navigation 조회
  ///
  /// 만료된 경우 null 반환 및 자동 삭제
  /// [clearExpired]: 만료된 항목 자동 삭제 여부 (기본 true)
  Future<PendingNavigation?> getPendingNavigation({
    bool clearExpired = true,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_storageKey);

      if (jsonString == null || jsonString.isEmpty) {
        if (AppConfig.debugMode) {
          print('📭 [PendingNavigation] 저장된 항목 없음');
        }
        return null;
      }

      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      final pending = PendingNavigation.fromJson(json);

      // 만료 체크
      if (pending.isExpired()) {
        if (AppConfig.debugMode) {
          print('⏰ [PendingNavigation] 만료됨 (생성 시간: ${pending.createdAt})');
        }
        if (clearExpired) {
          await clearPendingNavigation();
        }
        return null;
      }

      if (AppConfig.debugMode) {
        print('📬 [PendingNavigation] 조회 성공: $pending');
      }

      return pending;
    } catch (e) {
      if (AppConfig.debugMode) {
        print('❌ [PendingNavigation] 조회 실패: $e');
      }
      // 파싱 오류 시 데이터 삭제
      await clearPendingNavigation();
      return null;
    }
  }

  /// Pending Navigation 삭제
  Future<bool> clearPendingNavigation() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final result = await prefs.remove(_storageKey);

      if (AppConfig.debugMode) {
        print('🗑️ [PendingNavigation] 삭제 완료');
      }

      return result;
    } catch (e) {
      if (AppConfig.debugMode) {
        print('❌ [PendingNavigation] 삭제 실패: $e');
      }
      return false;
    }
  }

  /// Pending Navigation 존재 여부 확인 (만료 포함)
  Future<bool> hasPendingNavigation() async {
    final pending = await getPendingNavigation(clearExpired: true);
    return pending != null;
  }

  /// URL 문자열로 Pending Navigation 저장 (FCM에서 사용)
  ///
  /// URL 형식: '/discussion-group?meetingId=123&meetingTitle=테스트'
  Future<bool> savePendingNavigationFromUrl(String url) async {
    try {
      final uri = Uri.parse(url);
      final route = uri.path;
      
      // 쿼리 파라미터를 arguments로 변환
      Map<String, dynamic>? arguments;
      if (uri.queryParameters.isNotEmpty) {
        arguments = Map<String, dynamic>.from(uri.queryParameters);
        
        // meetingId는 int로 변환
        if (arguments.containsKey('meetingId')) {
          arguments['meetingId'] = int.tryParse(arguments['meetingId'] ?? '') ?? arguments['meetingId'];
        }
      }

      return await savePendingNavigation(
        route: route,
        arguments: arguments,
      );
    } catch (e) {
      if (AppConfig.debugMode) {
        print('❌ [PendingNavigation] URL 파싱 실패: $e');
      }
      return false;
    }
  }

  /// 디버그용: 현재 저장된 데이터 출력
  Future<void> debugPrintStatus() async {
    if (!AppConfig.debugMode) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_storageKey);

      print('📊 [PendingNavigation] === 현재 상태 ===');
      print('📊 저장된 데이터: $jsonString');

      if (jsonString != null && jsonString.isNotEmpty) {
        final json = jsonDecode(jsonString) as Map<String, dynamic>;
        final pending = PendingNavigation.fromJson(json);
        print('📊 route: ${pending.route}');
        print('📊 arguments: ${pending.arguments}');
        print('📊 createdAt: ${pending.createdAt}');
        print('📊 만료 여부: ${pending.isExpired()}');
      }
      print('📊 ============================');
    } catch (e) {
      print('❌ [PendingNavigation] 상태 출력 실패: $e');
    }
  }
}
