import 'package:flutter/material.dart';
import '../core/services/auth_service.dart';
import '../core/services/profile_status_service.dart';
import '../core/config/app_config.dart'; // 🎯 AppConfig import
import '../main.dart'; // 🎯 global navigatorKey import

enum AuthStatus {
  uninitialized,
  authenticated,
  unauthenticated,
  loading,
}

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  final ProfileStatusService _profileStatusService = ProfileStatusService();
  
  AuthStatus _status = AuthStatus.uninitialized;
  Map<String, dynamic>? _userInfo;
  String? _errorMessage;
  bool? _profileCompleted; // 개인정보 입력 완료 여부

  // Getters
  AuthStatus get status => _status;
  Map<String, dynamic>? get userInfo => _userInfo;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _status == AuthStatus.authenticated;
  bool get isLoading => _status == AuthStatus.loading;
  bool get isUninitialized => _status == AuthStatus.uninitialized;
  
  // AccessToken getter 추가
  Future<String?> get accessToken async {
    try {
      return await _authService.getAccessToken();
    } catch (e) {
      print('❌ AccessToken 가져오기 실패: $e');
      return null;
    }
  }
  
  // 개인정보 상태 접근자
  bool? get profileCompleted => _profileCompleted;

  /// 앱 시작 시 로그인 상태 확인
  Future<void> checkAuthStatus() async {
    try {
      print('🔍 로그인 상태 확인 중...');
      _setStatus(AuthStatus.loading);
      
      final isLoggedIn = await _authService.isLoggedIn();
      
      if (isLoggedIn) {
        final userInfo = await _authService.getUserInfo();
        if (userInfo != null) {
          _userInfo = userInfo;
          _setStatus(AuthStatus.authenticated);
          print('✅ 이미 로그인된 상태입니다.');
          
          // 개인정보 상태 확인
          await _checkProfileStatusSilent();
        } else {
          _setStatus(AuthStatus.unauthenticated);
          print('⚠️ 토큰은 있지만 사용자 정보를 가져올 수 없습니다.');
        }
      } else {
        _setStatus(AuthStatus.unauthenticated);
        print('📝 로그인이 필요합니다.');
      }
    } catch (e) {
      print('❌ 로그인 상태 확인 중 오류: $e');
      _setError('로그인 상태 확인 중 오류가 발생했습니다.');
      _setStatus(AuthStatus.unauthenticated);
    }
  }

  /// 카카오 로그인
  Future<bool> loginWithKakao({BuildContext? context}) async {
    try {
      print('🥕 카카오 로그인 시작...');
      _setStatus(AuthStatus.loading);
      _clearError();

      final authResponse = await _authService.loginWithKakao(context: context);
      
      // 사용자 정보 설정
      _userInfo = authResponse['userInfo'];
      _setStatus(AuthStatus.authenticated);
      
      print('✅ 카카오 로그인 성공!');
      print('👤 사용자: ${_userInfo?['memberName'] ?? '이름 미등록'}'); // null 처리
      
      // 개인정보 상태 확인
      await _checkProfileStatusSilent();
      
      return true;
    } catch (e) {
      print('❌ 카카오 로그인 실패: $e');
      _setError(_getErrorMessage(e));
      _setStatus(AuthStatus.unauthenticated);
      return false;
    }
  }

  /// 로그아웃
  Future<void> logout({BuildContext? context}) async {
    try {
      print('👋 로그아웃 중...');
      _setStatus(AuthStatus.loading);
      
      await _authService.logout(context: context);
      
      _userInfo = null;
      _setStatus(AuthStatus.unauthenticated);
      
      print('✅ 로그아웃 완료');
    } catch (e) {
      print('❌ 로그아웃 중 오류: $e');
      _setError('로그아웃 중 오류가 발생했습니다.');
      // 로그아웃은 실패하더라도 상태를 unauthenticated로 설정
      _userInfo = null;
      _profileCompleted = null; // 개인정보 상태 초기화
      _setStatus(AuthStatus.unauthenticated);
    }
  }

  /// 토큰 갱신
  Future<bool> refreshToken() async {
    try {
      print('🔄 토큰 갱신 중...');
      final result = await _authService.refreshToken();
      if (result != null) {
        _userInfo = result['userInfo'];
        print('✅ 토큰 갱신 성공');
        return true;
      }
      print('⚠️ 토큰 갱신 실패');
      return false;
    } catch (e) {
      print('❌ 토큰 갱신 중 오류: $e');
      return false;
    }
  }

  /// 사용자 정보 업데이트 (백엔드에서 최신 데이터 가져오기)
  Future<void> updateUserInfo() async {
    try {
      if (AppConfig.debugMode) {
        print('🔄 [AuthProvider] 사용자 정보 업데이트 시작...');
      }

      // 백엔드에서 최신 사용자 정보 가져오기
      final updatedUserInfo = await _authService.fetchAndUpdateUserInfo();
      
      if (updatedUserInfo != null) {
        // 🎯 핵심 수정: _userInfo 업데이트 + notifyListeners 호출
        _userInfo = updatedUserInfo;
        notifyListeners();
        
        if (AppConfig.debugMode) {
          print('✅ [AuthProvider] 사용자 정보 업데이트 완료: ${_userInfo?['memberName'] ?? 'null'}');
        }
      } else {
        if (AppConfig.debugMode) {
          print('⚠️ [AuthProvider] 사용자 정보 업데이트 실패: null 반환');
        }
      }
    } catch (e) {
      if (AppConfig.debugMode) {
        print('❌ [AuthProvider] 사용자 정보 업데이트 실패: $e');
      }
      // 에러가 발생해도 기존 상태 유지
    }
  }

  /// 사용자 닉네임 가져오기
  String get userNickname {
    final memberName = _userInfo?['memberName'];
    // memberName이 null이면 임시 텍스트 반환 (나중에 다른 텍스트로 변경 가능)
    return memberName ?? '사용자';
  }

  /// 사용자 이름 등록 여부 확인
  bool get hasUserName {
    final memberName = _userInfo?['memberName'];
    return memberName != null && memberName.toString().trim().isNotEmpty;
  }

  /// 사용자 이메일 가져오기
  String? get userEmail {
    return _userInfo?['email'];
  }

  /// 사용자 프로필 이미지 URL 가져오기
  String? get userProfileImageUrl {
    return _userInfo?['profileImageUrl'];
  }

  /// 사용자 권한 가져오기
  String? get userRole {
    return _userInfo?['role'];
  }

  /// 임원진 이상 권한 확인 (운영진, 준운영진, 관리자, 부모임장, 모임장)
  bool get isStaffLevel {
    if (userRole == null) return false;
    const staffRoles = ['STAFF', 'VICE_STAFF', 'ADMIN', 'VICE_LEADER', 'LEADER'];
    return staffRoles.contains(userRole);
  }

  /// 관리자급 이상 권한 확인 (관리자, 부모임장, 모임장)
  bool get isAdminLevel {
    if (userRole == null) return false;
    const adminRoles = ['ADMIN', 'VICE_LEADER', 'LEADER'];
    return adminRoles.contains(userRole);
  }

  /// 권한 레벨 표시명 가져오기
  String get roleDisplayName {
    if (userRole == null) return '알 수 없음';
    
    switch (userRole!) {
      case 'LEADER':
        return '모임장';
      case 'VICE_LEADER':
        return '부모임장';
      case 'ADMIN':
        return '관리자';
      case 'STAFF':
        return '운영진';
      case 'VICE_STAFF':
        return '준운영진';
      case 'MEMBER':
        return '일반 회원';
      default:
        return '알 수 없음';
    }
  }

  // Private methods
  void _setStatus(AuthStatus status) {
    _status = status;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }

  String _getErrorMessage(dynamic error) {
    final errorString = error.toString().toLowerCase();
    
    // 🚫 460 비활성화 계정 에러 체크 (다이얼로그는 ApiUtils에서 처리)
    if (errorString.contains('460') || errorString.contains('비활성화된 계정')) {
      return ''; // 빈 문자열 반환 (다이얼로그가 대신 표시됨)
    } else if (errorString.contains('kakaoauthexception')) {
      return '카카오 로그인에 실패했습니다. 다시 시도해주세요.';
    } else if (errorString.contains('network') || errorString.contains('connection')) {
      return '네트워크 오류가 발생했습니다. 인터넷 연결을 확인해주세요.';
    } else if (errorString.contains('timeout')) {
      return '연결 시간이 초과되었습니다. 다시 시도해주세요.';
    } else if (errorString.contains('invalid key hash')) {
      return '앱 설정 오류입니다. 개발자에게 문의해주세요.';
    } else {
      return '로그인 중 오류가 발생했습니다. 잠시 후 다시 시도해주세요.';
    }
  }

  /// 🚨 강제 로그아웃 (즉시 처리)
  /// 
  /// 토큰 만료 등으로 인한 자동 로그아웃 시 사용
  /// 백엔드 API 호출 없이 로컬 데이터만 즉시 삭제
  void _forceLogoutWithoutContext() {
    try {
      if (AppConfig.debugMode) {
        print('🚨 [AuthProvider] 강제 로그아웃 시작');
      }
      
      _setStatus(AuthStatus.loading);
      
      // 🎯 로컬 데이터 즉시 삭제
      _userInfo = null;
      _profileCompleted = null;
      _setStatus(AuthStatus.unauthenticated);
      _clearError();
      
      // 🔥 SharedPreferences 삭제는 백그라운드에서 처리 (Fire-and-Forget)
      _authService.clearLocalAuthData().catchError((e) {
        if (AppConfig.debugMode) {
          print('⚠️ [AuthProvider] 로컬 데이터 삭제 중 오류: $e');
        }
      });
      
      // 📢 사용자에게 로그아웃 알림 다이얼로그 표시 (비동기)
      _showLogoutNotificationDialog();
      
      if (AppConfig.debugMode) {
        print('✅ [AuthProvider] 강제 로그아웃 완료');
      }
    } catch (e) {
      if (AppConfig.debugMode) {
        print('❌ [AuthProvider] 강제 로그아웃 오류: $e');
      }
      // 오류가 발생해도 로컬 데이터는 반드시 삭제
      _userInfo = null;
      _profileCompleted = null;
      _setStatus(AuthStatus.unauthenticated);
    }
  }

  /// 📢 강제 로그아웃 알림 다이얼로그 표시
  /// 
  /// Global NavigatorKey를 사용하여 어디서나 다이얼로그 표시 가능
  void _showLogoutNotificationDialog() {
    // 비동기로 실행하여 강제 로그아웃 프로세스를 블록하지 않음
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        final context = navigatorKey.currentContext; // 🎯 Global Navigator Key 사용
        
        if (context != null) {
          showDialog(
            context: context,
            barrierDismissible: false, // 사용자가 배경 탭으로 닫을 수 없도록
            builder: (BuildContext dialogContext) {
              return AlertDialog(
                title: Row(
                  children: [
                    Icon(
                      Icons.logout,
                      color: Theme.of(dialogContext).colorScheme.error,
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '자동 로그아웃',
                      style: TextStyle(
                        color: Theme.of(dialogContext).colorScheme.error,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                content: const Text(
                  '로그인 세션이 만료되어 자동으로 로그아웃되었습니다.\n다시 로그인해 주세요.',
                  style: TextStyle(fontSize: 16),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(dialogContext).pop();
                    },
                    child: Text(
                      '확인',
                      style: TextStyle(
                        color: Theme.of(dialogContext).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        }
      } catch (e) {
        if (AppConfig.debugMode) {
          print('❌ [강제 로그아웃] 다이얼로그 표시 중 오류: $e');
        }
        // 다이얼로그 실패해도 로그아웃은 이미 완료된 상태이므로 무시
      }
    });
  }

  /// 🔧 디버그용 - 강제 로그아웃
  void forceLogout() {
    _userInfo = null;
    _profileCompleted = null; // 개인정보 상태 초기화
    _setStatus(AuthStatus.unauthenticated);
    print('🔧 디버그용 강제 로그아웃 완료');
  }

  /// 디버그용 - 개인정보 상태 강제 설정
  void debugSetProfileStatus(bool? status) {
    _profileCompleted = status;
    notifyListeners();
    print('🔧 개인정보 상태 강제 설정: $status');
  }

  /// 개인정보 상태 확인 (메인 화면 진입 시 호출)
  /// 
  /// 5분 스마트 캠싱 + 자동 로그아웃 처리
  Future<void> checkProfileStatus({bool forceRefresh = false}) async {
    if (!isAuthenticated) {
      print('⚠️ 로그인되지 않은 상태에서 개인정보 상태를 확인할 수 없습니다.');
      return;
    }

    try {
      final accessToken = await _authService.getAccessToken();
      if (accessToken == null) {
        print('⚠️ 액세스 토큰이 없습니다.');
        return;
      }

      print('🔍 [개인정보 상태 확인] API 호출 시작...');
      print('🔑 [개인정보 상태 확인] 액세스 토큰: ${accessToken.substring(0, 20)}...');
      
      final profileStatus = await _profileStatusService.checkProfileStatus(
        accessToken: accessToken,
        forceRefresh: forceRefresh,
        onAutoLogout: () {
          print('🚨 === [개인정보 상태 확인] 자동 로그아웃 콜백 호출 ===');
          print('🔍 [자동 로그아웃] 현재 AuthProvider 상태: $_status');
          print('🔍 [자동 로그아웃] 사용자 정보: ${_userInfo != null ? '있음' : '없음'}');
          _forceLogoutWithoutContext(); // 즉시 실행
          print('✅ [자동 로그아웃] 강제 로그아웃 콜백 완료');
        },
      );

      if (profileStatus != null) {
        final previousStatus = _profileCompleted;
        _profileCompleted = profileStatus;
        notifyListeners();
        
        print('✅ [개인정보 상태 확인] 성공: ${profileStatus ? '완료' : '미입력'}');
        if (AppConfig.debugMode && previousStatus != profileStatus) {
          print('🔍 [AuthProvider] 개인정보 상태 변경: $previousStatus -> $profileStatus');
        }
      } else {
        print('⚠️ [개인정보 상태 확인] 자동 로그아웃 처리됨');
      }
    } catch (e) {
      print('❌ [개인정보 상태 확인] 오류: $e');
      
      // 🎯 인증 관련 에러는 다시 throw 하여 상위에서 처리
      final errorString = e.toString().toLowerCase();
      if (errorString.contains('401') || 
          errorString.contains('인증') || 
          errorString.contains('만료') ||
          errorString.contains('unauthorized') ||
          errorString.contains('token')) {
        print('🚨 [개인정보 상태 확인] 인증 관련 에러 감지 - 다시 throw');
        rethrow; // RouteAwareMixin에서 처리하도록
      }
      
      // 다른 에러들은 조용히 처리
      // 오류 시에도 상태를 업데이트하지 않음 (기존 캐시 유지)
    }
  }

  /// 개인정보 상태 조용히 확인 (로그인 후 자동 호출용)
  /// 
  /// 오류가 발생해도 로그인 프로세스를 막지 않음
  Future<void> _checkProfileStatusSilent() async {
    try {
      await checkProfileStatus();
    } catch (e) {
      print('⚠️ [개인정보 상태 조용히 확인] 오류 (무시): $e');
    }
  }

  /// 개인정보 입력 완료 후 상태 업데이트
  /// 
  /// 개인정보 입력 화면에서 완료 후 호출
  void markProfileCompleted() {
    _profileCompleted = true;
    _profileStatusService.invalidateCache(); // 캠시 무효화
    notifyListeners();
    print('✅ 개인정보 입력 완료로 표시');
  }

  /// 개인정보 상태 강제 새로고침
  /// 
  /// 필요시 수동으로 호출 가능
  Future<void> refreshProfileStatus() async {
    await checkProfileStatus(forceRefresh: true);
  }

  /// 디버그용 - 상태 정보 출력
  void printStatus() {
    print('📊 === AuthProvider 상태 ===');
    print('상태: $_status');
    print('사용자 정보: ${_userInfo != null ? '있음' : '없음'}');
    print('오류 메시지: ${_errorMessage ?? '없음'}');
    print('개인정보 상태: ${_profileCompleted == null ? '미확인' : (_profileCompleted! ? '완료' : '미입력')}');
    
    // ProfileStatusService 캠시 정보도 출력
    final cacheInfo = _profileStatusService.getCacheInfo();
    print('캠시 상태: $cacheInfo');
    print('========================');
  }
}
