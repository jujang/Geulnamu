import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/config/app_config.dart';
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

  void _checkProfileStatusOnScreenEnter() {
    // 비동기로 실행하여 UI 블록킹 방지
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        
        // 로그인 상태에서만 실행
        if (authProvider.isAuthenticated) {
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

  /// 🔍 인증 에러 여부 정확히 감지
  /// 
  /// 백엔드 응답 구조를 기반으로 인증 에러를 판단
  /// 예상 응답: {code: 401, message: '리프레시 토큰이 유효하지 않습니다...', data: null}
  bool _isAuthenticationError(dynamic error) {
    try {
      final errorString = error.toString();
      
      // 🎯 ApiUtils에서 던진 Exception 메시지 파싱
      // 예: "Exception: [개인정보 상태 확인] 백엔드 오류 (401): 리프레시 토큰이 유효하지 않습니다..."
      final backendErrorPattern = RegExp(r'백엔드 오류 \((\d+)\):');
      final match = backendErrorPattern.firstMatch(errorString);
      
      if (match != null) {
        final errorCode = int.tryParse(match.group(1) ?? '');
        if (errorCode == 401) {
          if (AppConfig.debugMode) {
            print('🔍 [RouteAwareMixin] 백엔드 인증 에러 감지: 코드 $errorCode');
          }
          return true;
        }
      }
      
      // 🔄 기존 방식: 문자열 검색 (폴백)
      final lowerError = errorString.toLowerCase();
      if (lowerError.contains('백엔드 오류 (401)') ||
          lowerError.contains('인증') ||
          lowerError.contains('토큰') ||
          lowerError.contains('만료') ||
          lowerError.contains('unauthorized') ||
          lowerError.contains('token')) {
        if (AppConfig.debugMode) {
          print('🔍 [RouteAwareMixin] 인증 관련 키워드 감지');
        }
        return true;
      }
      
      return false;
    } catch (e) {
      // 파싱 오류 시 안전하게 false 반환
      return false;
    }
  }
}
