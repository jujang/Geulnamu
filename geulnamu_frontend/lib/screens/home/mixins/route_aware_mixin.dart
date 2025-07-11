import 'package:flutter/material.dart';
import '../../../services/home/home_route_service.dart';

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
  }

  @override
  void didPop() {
    super.didPop();
    debugPrint('🚪 [RouteAwareMixin] 화면 종료 감지');
    _routeService.onPop();
  }
}
