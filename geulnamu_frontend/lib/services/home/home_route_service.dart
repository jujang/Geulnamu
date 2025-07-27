import 'package:flutter/material.dart';

/// HomeScreen의 RouteAware 기능을 담당하는 Singleton Service
/// 
/// 기능:
/// - RouteObserver 관리
/// - 화면 전환 감지 및 처리
/// 
/// 제거된 기능:
/// - 캐시 쿨다운 관리 (ProfileStatusService의 5분 캐싱으로 대체)
class HomeRouteService {
  static final HomeRouteService _instance = HomeRouteService._internal();
  factory HomeRouteService() => _instance;
  HomeRouteService._internal();

  // RouteObserver 인스턴스 (정적)
  static final RouteObserver<PageRoute<dynamic>> routeObserver = 
      RouteObserver<PageRoute<dynamic>>();

  // 🎯 RouteObserver 등록/해제 메서드들
  
  void registerRouteObserver(BuildContext context, RouteAware routeAware) {
    final route = ModalRoute.of(context);
    if (route != null && route is PageRoute) {
      try {
        routeObserver.subscribe(routeAware, route as PageRoute<dynamic>);
      } catch (e) {
        debugPrint('⚠️ [HomeRouteService] RouteObserver 등록 실패: $e');
      }
    }
  }

  void unregisterRouteObserver(RouteAware routeAware) {
    try {
      routeObserver.unsubscribe(routeAware);
    } catch (e) {
      debugPrint('⚠️ [HomeRouteService] RouteObserver 구독 해제 실패: $e');
    }
  }

  // 🎯 RouteAware 이벤트 처리 메서드들 (로그 없이 기능만 유지)

  void onPush() {
    // 로그 제거: 기능만 유지
  }

  void onPushNext() {
    // 로그 제거: 기능만 유지
  }

  void onPopNext(BuildContext context) {
    // 로그 제거: 기능만 유지
    // 🎯 제거: 캐시 체크 로직 - ProfileStatusService에서 자동 처리
  }

  void onPop() {
    // 로그 제거: 기능만 유지
    // 🎯 제거: 캐시 초기화 로직 - ProfileStatusService에서 자동 처리
  }
}
