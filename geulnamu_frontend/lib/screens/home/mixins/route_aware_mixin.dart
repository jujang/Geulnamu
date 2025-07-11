import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../services/home/home_route_service.dart';
import '../../../providers/auth_provider.dart';

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

  // 🎯 RouteObserver 등록/해제 메서드들
  
  void registerRouteObserver() {
    debugPrint('🔄 [RouteAwareMixin] RouteObserver 등록 시도');
    _routeService.registerRouteObserver(context, this);
  }

  void unregisterRouteObserver() {
    debugPrint('🔄 [RouteAwareMixin] RouteObserver 구독 해제');
    _routeService.unregisterRouteObserver(this);
  }

  // 🎯 RouteAware 라이프사이클 메서드들

  @override
  void didPush() {
    super.didPush();
    debugPrint('🏠 [RouteAwareMixin] 화면 진입 감지');
    _routeService.onPush();
    
    // 개인정보 상태 확인 (로그인 상태에서만)
    _checkProfileStatusOnScreenEnter();
  }

  @override
  void didPushNext() {
    super.didPushNext();
    debugPrint('🚪 [RouteAwareMixin] 다른 화면으로 이동 감지');
    _routeService.onPushNext();
  }

  @override
  void didPopNext() {
    super.didPopNext();
    debugPrint('🔄 [RouteAwareMixin] 화면 복귀 감지');
    _routeService.onPopNext(context);
    
    // 개인정보 상태 확인 (로그인 상태에서만)
    _checkProfileStatusOnScreenEnter();
  }

  @override
  void didPop() {
    super.didPop();
    debugPrint('🚪 [RouteAwareMixin] 화면 종료 감지');
    _routeService.onPop();
  }

  // 🔍 개인정보 상태 확인 (화면 진입/복귀 시)
  void _checkProfileStatusOnScreenEnter() {
    // 비동기로 실행하여 UI 블록킹 방지
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        
        // 로그인 상태에서만 실행
        if (authProvider.isAuthenticated) {
          debugPrint('🔍 [RouteAwareMixin] 개인정보 상태 확인 시작');
          await authProvider.checkProfileStatus();
        } else {
          debugPrint('🔍 [RouteAwareMixin] 비로그인 상태 - 개인정보 확인 스킵');
        }
      } catch (e) {
        debugPrint('❌ [RouteAwareMixin] 개인정보 상태 확인 오류: $e');
        // 오류가 발생해도 UI에 영향주지 않음
      }
    });
  }
}
