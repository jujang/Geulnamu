import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/config/app_config.dart';
import '../../../services/home/home_route_service.dart';
import '../../../providers/auth_provider.dart';
import '../../../services/navigation/pending_navigation_service.dart';
import '../../../routes/app_router.dart'; // 🎯 GoRouter navigatorKey

/// RouteAware 기능을 담당하는 mixin
/// 
/// 제공 기능:
/// - RouteObserver 등록/해제
/// - 화면 전환 감지 및 처리
/// - 캐시 만료 체크 (30초 쿨다운)
/// 
/// 의존성: HomeRouteService (Singleton)
/// 사용법: with RouteAwareMixin
/// 
/// 주의: RouteAware를 함께 with 해야 함
mixin RouteAwareMixin<T extends StatefulWidget> on State<T>, RouteAware {
  final HomeRouteService _routeService = HomeRouteService();
  final PendingNavigationService _pendingNavigationService = PendingNavigationService();
  
  // 🚨 Pending Navigation 처리 중복 방지 플래그
  bool _isProcessingPendingNavigation = false;

  // 🎯 RouteObserver 등록/해제 메서드들
  
  void registerRouteObserver() {
    _routeService.registerRouteObserver(context, this);
  }

  void unregisterRouteObserver() {
    _routeService.unregisterRouteObserver(this);
  }

  // 🎯 RouteAware 라이프사이클 메서드들

  @override
  void didPush() {
    super.didPush();
    _routeService.onPush();
    _checkProfileStatusOnScreenEnter();
  }

  @override
  void didPushNext() {
    super.didPushNext();
    _routeService.onPushNext();
  }

  @override
  void didPopNext() {
    super.didPopNext();
    _routeService.onPopNext(context);
    _checkProfileStatusOnScreenEnter();
  }

  @override
  void didPop() {
    super.didPop();
    _routeService.onPop();
  }

  void _checkProfileStatusOnScreenEnter() {
    // 비동기로 실행하여 UI 블록킹 방지
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        
        // 로그인 상태에서만 실행
        if (authProvider.isAuthenticated) {
          // 🚀 Pending Navigation 처리 (로그인 완료 후)
          await _processPendingNavigation();
          
          try {
            await authProvider.checkProfileStatus();
          } catch (profileError) {
            // 🎯 백엔드 응답 구조 기반 인증 에러 감지
            if (_isAuthenticationError(profileError)) {
              if (AppConfig.debugMode) {
                print('🚨 [RouteAwareMixin] 인증 에러 감지 - 자동 로그아웃 처리됨');
              }
              // 🔥 강제 로그아웃이 이미 처리되었으므로 에러를 throw하지 않고 조용히 처리
              // AuthProvider._forceLogoutWithoutContext()가 이미 실행되어 상태가 변경됨
              return; // 🎯 에러를 throw하지 않고 메서드 종료
            }
            // 다른 에러들은 조용히 처리 (네트워크, 타임아웃 등)
          }
        }
      } catch (e) {
        // 최상위 에러 처리: Provider 오류 등
        if (AppConfig.debugMode) {
          print('❌ [RouteAwareMixin] 예상치 못한 오류: $e');
        }
        // UI에 영향주지 않음
      }
    });
  }

  /// 🚀 Pending Navigation 처리
  Future<void> _processPendingNavigation() async {
    if (_isProcessingPendingNavigation) return;

    try {
      _isProcessingPendingNavigation = true;
      final pending = await _pendingNavigationService.getPendingNavigation();
      
      if (pending == null) return;

      if (AppConfig.debugMode) {
        print('🚀 [RouteAware] Pending 처리: ${pending.route}');
      }

      if (AppRouter.navigatorKey.currentContext != null) {
        await _pendingNavigationService.clearPendingNavigation();
        await Future.delayed(const Duration(milliseconds: 300));
        
        final routerContext = AppRouter.navigatorKey.currentContext!;
        GoRouter.of(routerContext).push(
          pending.route,
          extra: pending.arguments,
        );
      }
    } catch (e) {
      if (AppConfig.debugMode) {
        print('❌ [RouteAware] Pending 오류: $e');
      }
    } finally {
      _isProcessingPendingNavigation = false;
    }
  }

  /// 🔍 인증 에러 여부 감지
  bool _isAuthenticationError(dynamic error) {
    try {
      final errorString = error.toString();
      
      // ApiUtils에서 던진 Exception 메시지 파싱
      final backendErrorPattern = RegExp(r'백엔드 오류 \((\d+)\):');
      final match = backendErrorPattern.firstMatch(errorString);
      
      if (match != null) {
        final errorCode = int.tryParse(match.group(1) ?? '');
        if (errorCode == 401) return true;
      }
      
      // 폴백: 문자열 검색
      final lowerError = errorString.toLowerCase();
      return lowerError.contains('백엔드 오류 (401)') ||
          lowerError.contains('인증') ||
          lowerError.contains('토큰') ||
          lowerError.contains('만료') ||
          lowerError.contains('unauthorized') ||
          lowerError.contains('token');
    } catch (e) {
      return false;
    }
  }
}
