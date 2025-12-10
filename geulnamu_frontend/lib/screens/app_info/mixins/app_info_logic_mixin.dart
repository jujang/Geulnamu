import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'dart:async';
import 'dart:html' as html show window;
import '../../../providers/auth_provider.dart';
import '../../../services/system/health_check_service.dart';

/// 앱 정보 화면 로직 Mixin
///
/// 주요 기능:
/// - 버전 정보 자동 로드 (pubspec.yaml 기반)
/// - 캐시 삭제 + 자동 로그아웃 (앱 완전 초기화)
mixin AppInfoLogicMixin<T extends StatefulWidget> on State<T> {
  
  // 🎯 버전 정보 상태
  String _version = '';
  String _buildNumber = '';
  bool _isLoadingVersion = true;
  
  // 버전 정보 getter
  String get version => _version;
  String get buildNumber => _buildNumber;
  bool get isLoadingVersion => _isLoadingVersion;
  
  // 🏥 헬스 체크 관련 상태
  Timer? _longPressTimer;
  final HealthCheckService _healthCheckService = HealthCheckService();
  
  @override
  void initState() {
    super.initState();
    _loadVersionInfo();
  }
  
  @override
  void dispose() {
    _longPressTimer?.cancel();
    super.dispose();
  }
  
  /// 버전 정보 로드
  Future<void> _loadVersionInfo() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      
      setState(() {
        _version = packageInfo.version;        // pubspec.yaml의 version (1.0.0)
        _buildNumber = packageInfo.buildNumber; // pubspec.yaml의 +1
        _isLoadingVersion = false;
      });
      
      debugPrint('✅ [AppInfo] 버전 정보 로드 완료: v$_version (빌드 $_buildNumber)');
    } catch (e) {
      debugPrint('❌ [AppInfo] 버전 정보 로드 실패: $e');
      setState(() {
        _version = '알 수 없음';
        _buildNumber = '0';
        _isLoadingVersion = false;
      });
    }
  }

  /// 캐시 삭제 + 자동 로그아웃 처리
  Future<void> handleClearCache(BuildContext context) async {
    // 확인 다이얼로그 표시
    final confirmed = await _showClearCacheConfirmDialog(context);
    
    if (confirmed != true) {
      return; // 사용자가 취소
    }
    
    try {
      debugPrint('🗑️ [AppInfo] 캐시 삭제 시작...');
      
      // 🎯 1단계: SharedPreferences 전체 삭제
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      debugPrint('✅ [AppInfo] SharedPreferences 전체 삭제 완료');
      
      // 🎯 2단계: 웹 환경 추가 캐시 삭제 (Session Storage, IndexedDB)
      if (kIsWeb) {
        await _clearWebCaches();
      }
      
      if (context.mounted) {
        // 🎯 3단계: AuthProvider를 통한 로그아웃 처리
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        await authProvider.logout();
        debugPrint('✅ [AppInfo] 로그아웃 완료');
        
        // 🎯 4단계: 스플래시 화면으로 이동 (앱 초기화)
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/splash',
          (route) => false, // 모든 이전 화면 제거
        );
        
        // 성공 메시지
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('캐시가 삭제되고 앱이 초기화되었습니다.'),
            duration: Duration(seconds: 3),
          ),
        );
        
        debugPrint('🎉 [AppInfo] 캐시 삭제 및 앱 초기화 완료');
      }
    } catch (e) {
      debugPrint('❌ [AppInfo] 캐시 삭제 실패: $e');
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('캐시 삭제 중 오류가 발생했습니다: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }
  
  /// 🌐 웹 환경 캐시 삭제 (Session Storage, IndexedDB)
  /// Service Worker Cache는 유지 (앱 로딩 속도 유지)
  Future<void> _clearWebCaches() async {
    try {
      // Session Storage 삭제
      html.window.sessionStorage.clear();
      debugPrint('✅ [AppInfo] Session Storage 삭제 완료');
    } catch (e) {
      debugPrint('⚠️ [AppInfo] Session Storage 삭제 실패 (무시): $e');
    }
    
    try {
      // IndexedDB 삭제 (Flutter 웹 데이터)
      await html.window.indexedDB?.deleteDatabase('FlutterStorage');
      debugPrint('✅ [AppInfo] IndexedDB (FlutterStorage) 삭제 완료');
    } catch (e) {
      debugPrint('⚠️ [AppInfo] IndexedDB 삭제 실패 (무시): $e');
    }
    
    // ⚠️ Service Worker Cache는 의도적으로 삭제하지 않음
    // 이유: 정적 리소스 캐시는 앱 성능에 중요하고, 사용자 데이터가 아님
    debugPrint('💡 [AppInfo] Service Worker Cache는 유지 (앱 성능용)');
  }
  
  /// 캐시 삭제 확인 다이얼로그
  Future<bool?> _showClearCacheConfirmDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('캐시 삭제'),
        content: const Text(
          '모든 앱 설정 및 캐시 데이터가 삭제됩니다.\n'
          '로그아웃되며 다시 로그인해야 합니다.\n\n'
          '정말 삭제하시겠습니까?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('삭제'),
          ),
        ],
      ),
    );
  }
  
  /// 🏥 로고 Long Press 시작 처리
  void handleLogoLongPressStart() {
    // 2초 타이머 시작
    _longPressTimer = Timer(const Duration(seconds: 2), () {
      debugPrint('⏰ [AppInfo] 2초 경과 - Health Check 실행');
      _executeHealthCheck();
    });
  }
  
  /// 🏥 로고 Long Press 종료 처리
  void handleLogoLongPressEnd() {
    // 타이머 취소
    _longPressTimer?.cancel();
    _longPressTimer = null;
  }
  
  /// 🏥 Health Check API 실행
  Future<void> _executeHealthCheck() async {
    try {
      // API 호출 (Service에서 로그 출력)
      final result = await _healthCheckService.checkHealth();
      
      if (!mounted) return;
      
      // 👤 사용자에게 간단한 메시지 표시 (응답 시간 포함)
      if (result['success'] == true) {
        _showSuccessSnackBar(
          context,
          '서버 연결이 정상이에요! [${result['responseTime']}ms] 😊',
        );
      } else {
        _showErrorSnackBar(
          context,
          '서버 연결에 문제가 있어요 [${result['responseTime']}ms] 😔',
        );
      }
    } catch (e) {
      debugPrint('❌ [AppInfo] Health Check 예외 발생: $e');
      
      if (mounted) {
        _showErrorSnackBar(
          context,
          '서버 연결에 문제가 있어요 😔',
        );
      }
    }
  }
  
  /// 성공 스낵바 표시
  void _showSuccessSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.primary,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
  
  /// 에러 스낵바 표시
  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
