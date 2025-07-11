import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

/// HomeScreen의 RouteAware 기능을 담당하는 Singleton Service
/// 
/// 기능:
/// - RouteObserver 관리
/// - 캐시 만료 체크 (30초 쿨다운)
/// - 화면 전환 감지 및 처리
class HomeRouteService {
  static final HomeRouteService _instance = HomeRouteService._internal();
  factory HomeRouteService() => _instance;
  HomeRouteService._internal();

  // RouteObserver 인스턴스 (정적)
  static final RouteObserver<PageRoute<dynamic>> routeObserver = 
      RouteObserver<PageRoute<dynamic>>();

  // 캐시 관리 변수들
  DateTime? _lastCacheCheckTime;
  static const Duration _cacheCheckCooldown = Duration(seconds: 30);

  // 🎯 RouteObserver 등록/해제 메서드들
  
  void registerRouteObserver(BuildContext context, RouteAware routeAware) {
    final route = ModalRoute.of(context);
    if (route != null && route is PageRoute) {
      try {
        routeObserver.subscribe(routeAware, route as PageRoute<dynamic>);
        debugPrint('✅ [HomeRouteService] RouteObserver 등록 성공');
      } catch (e) {
        debugPrint('⚠️ [HomeRouteService] RouteObserver 등록 실패: $e');
      }
    }
  }

  void unregisterRouteObserver(RouteAware routeAware) {
    try {
      routeObserver.unsubscribe(routeAware);
      debugPrint('✅ [HomeRouteService] RouteObserver 구독 해제 완료');
    } catch (e) {
      debugPrint('⚠️ [HomeRouteService] RouteObserver 구독 해제 실패: $e');
    }
  }

  // 🎯 RouteAware 이벤트 처리 메서드들

  void onPush() {
    debugPrint('🏠 [HomeRouteService] 화면 진입 (didPush)');
  }

  void onPushNext() {
    debugPrint('🚪 [HomeRouteService] 다른 화면으로 이동 (didPushNext)');
  }

  void onPopNext(BuildContext context) {
    debugPrint('🔄 [HomeRouteService] 다른 화면에서 돌아옴 감지 (didPopNext)');
    
    // 🎯 실제로 홈화면으로 돌아왔을 때만 캐시 체크
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.isAuthenticated) {
      checkCacheExpiryWithCooldown(authProvider, '홈화면 재진입');
    }
  }

  void onPop() {
    debugPrint('🚪 [HomeRouteService] 화면 종료 (didPop)');
    // 로그아웃 시 캐시 체크 시간 초기화
    _lastCacheCheckTime = null;
  }

  // 🎯 캐시 만료 체크 (30초 쿨다운 적용)
  void checkCacheExpiryWithCooldown(AuthProvider authProvider, String reason) {
    if (!authProvider.isAuthenticated) return;
    
    // 🔧 쿨다운 체크: 30초 이내 중복 체크 방지
    final now = DateTime.now();
    if (_lastCacheCheckTime != null && 
        now.difference(_lastCacheCheckTime!) < _cacheCheckCooldown) {
      final remaining = _cacheCheckCooldown - now.difference(_lastCacheCheckTime!);
      debugPrint('⏰ [HomeRouteService] 캐시 체크 쿨다운 중 - 남은 시간: ${remaining.inSeconds}초 ($reason)');
      return;
    }
    
    // TODO: 실제 캐시 체크 로직은 나중에 ProfileStatusService와 연동
    debugPrint('🔍 [HomeRouteService - $reason] 캐시 체크 실행 (쿨다운 통과)');
    
    // 🔧 쿨다운 시간 업데이트
    _lastCacheCheckTime = now;
    
    // 여기에 실제 캐시 만료 체크 로직이 들어갈 예정
  }

  // 🎯 로그아웃 시 캐시 초기화
  void resetCacheCheckTime() {
    _lastCacheCheckTime = null;
    debugPrint('🔄 [HomeRouteService] 캐시 체크 시간 초기화');
  }
}
