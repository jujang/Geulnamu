import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/auth_provider.dart';
import '../../core/theme.dart';
import '../meeting/meeting_detail_screen.dart';

/// HomeScreen의 비즈니스 로직과 RouteAware를 담당하는 mixin
/// 
/// 포함하는 기능들:
/// - RouteAware 화면 전환 감지
/// - 캐시 만료 체크 (30초 쿨다운)
/// - 이벤트 핸들러들
/// - 로그아웃 처리
mixin HomeScreenLogic<T extends StatefulWidget> on State<T>, RouteAware {
  
  // 🔧 RouteAware 제어 변수들
  bool _isCurrentScreen = true; // 현재 화면이 홈화면인지 추적
  DateTime? _lastCacheCheckTime; // 마지막 캐시 체크 시간
  static const Duration _cacheCheckCooldown = Duration(seconds: 30); // 캐시 체크 쿨다운

  // RouteObserver 인스턴스 (정적)
  static final RouteObserver<PageRoute<dynamic>> routeObserver = 
      RouteObserver<PageRoute<dynamic>>();

  // 🎯 RouteAware 라이프사이클 메서드들
  
  @override
  void didPush() {
    super.didPush();
    _isCurrentScreen = true;
    
    debugPrint('🏠 [홈화면] 화면 진입 (didPush)');
  }

  @override
  void didPushNext() {
    super.didPushNext();
    _isCurrentScreen = false;
    
    debugPrint('🚪 [홈화면] 다른 화면으로 이동 (didPushNext)');
  }

  @override
  void didPopNext() {
    super.didPopNext();
    _isCurrentScreen = true;
    
    debugPrint('🔄 [홈화면] 다른 화면에서 돌아옴 감지 (didPopNext)');
    
    // 🎯 실제로 홈화면으로 돌아왔을 때만 캐시 체크
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.isAuthenticated) {
      _checkCacheExpiryWithCooldown(authProvider, '홈화면 재진입');
    }
  }

  @override
  void didPop() {
    super.didPop();
    _isCurrentScreen = false;
    
    debugPrint('🚪 [홈화면] 화면 종료 (didPop)');
  }

  // 🔧 RouteObserver 등록/해제 헬퍼 메서드들
  
  void registerRouteObserver() {
    final route = ModalRoute.of(context);
    if (route != null && route is PageRoute) {
      try {
        routeObserver.subscribe(this, route as PageRoute<dynamic>);
        debugPrint('✅ [홈화면] RouteObserver 등록 성공');
      } catch (e) {
        debugPrint('⚠️ [홈화면] RouteObserver 등록 실패: $e');
      }
    }
  }

  void unregisterRouteObserver() {
    try {
      routeObserver.unsubscribe(this);
      debugPrint('✅ [홈화면] RouteObserver 구독 해제 완료');
    } catch (e) {
      debugPrint('⚠️ [홈화면] RouteObserver 구독 해제 실패: $e');
    }
  }

  // 🔍 캐시 만료 체크 (30초 쿨다운 적용)
  void _checkCacheExpiryWithCooldown(AuthProvider authProvider, String reason) {
    if (!authProvider.isAuthenticated) return;
    
    // 🔧 쿨다운 체크: 30초 이내 중복 체크 방지
    final now = DateTime.now();
    if (_lastCacheCheckTime != null && 
        now.difference(_lastCacheCheckTime!) < _cacheCheckCooldown) {
      final remaining = _cacheCheckCooldown - now.difference(_lastCacheCheckTime!);
      debugPrint('⏰ [홈화면] 캐시 체크 쿨다운 중 - 남은 시간: ${remaining.inSeconds}초 ($reason)');
      return;
    }
    
    // TODO: 실제 캐시 체크 로직은 나중에 ProfileStatusService와 연동
    debugPrint('🔍 [홈화면 - $reason] 캐시 체크 실행 (쿨다운 통과)');
    
    // 🔧 쿨다운 시간 업데이트
    _lastCacheCheckTime = now;
    
    // 여기에 실제 캐시 만료 체크 로직이 들어갈 예정
  }

  // 🎯 이벤트 핸들러들

  void navigateToLogin() {
    Navigator.pushNamed(context, '/login');
  }

  void handleMenuTap(String menuTitle, AuthProvider authProvider) {
    if (menuTitle == '모임 소개') {
      // 🎯 모임 소개 페이지로 이동
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const MeetingDetailScreen(),
        ),
      );
    } else if (authProvider.isAuthenticated) {
      // 로그인 후: 실제 기능 사용 (현재는 개발 중 메시지)
      _showSnackBar('$menuTitle 기능은 개발 중입니다.');
    } else {
      // 로그인 전: 로그인 유도
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$menuTitle 기능은 로그인 후 이용할 수 있습니다'),
          duration: const Duration(seconds: 2),
          backgroundColor: context.colors.primary,
          action: SnackBarAction(
            label: '로그인',
            textColor: context.colors.onPrimary,
            onPressed: navigateToLogin,
          ),
        ),
      );
    }
  }

  Future<void> handleProfileMenuSelection(
    String value,
    AuthProvider authProvider,
  ) async {
    switch (value) {
      case 'profile':
        _showSnackBar('프로필 기능은 개발 중입니다.');
        break;
      case 'settings':
        _showSnackBar('설정 기능은 개발 중입니다.');
        break;
      case 'logout':
        await _handleLogout(authProvider);
        break;
    }
  }

  void showCreateMeetingDialog() {
    _showSnackBar('모임 만들기 기능은 개발 중입니다.');
  }

  // 🚨 로그아웃 처리
  Future<void> _handleLogout(AuthProvider authProvider) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          '로그아웃',
          style: GoogleFonts.notoSans(fontWeight: FontWeight.w600),
        ),
        content: Text('정말 로그아웃하시겠습니까?', style: GoogleFonts.notoSans()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              '취소',
              style: GoogleFonts.notoSans(
                color: context.colors.onSurfaceVariant,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              '로그아웃',
              style: GoogleFonts.notoSans(color: context.colors.error),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await authProvider.logout();
      _showSnackBar('로그아웃되었습니다.');
      
      // 🔧 로그아웃 시 캐시 체크 시간 초기화
      _lastCacheCheckTime = null;
    }
  }

  // 🎯 공통 스낵바 메서드
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.notoSans(color: Colors.white),
        ),
        backgroundColor: context.colors.inverseSurface,
      ),
    );
  }
}
