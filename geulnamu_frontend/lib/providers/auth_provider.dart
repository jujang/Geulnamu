import 'package:flutter/material.dart';
import '../core/services/auth_service.dart';
import '../core/services/profile_status_service.dart';

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
  
  // 개인정보 상태 접근자
  bool? get profileCompleted => _profileCompleted;
  bool get hasProfile => _profileCompleted == true;
  bool get needsProfile => _profileCompleted == false;
  bool get profileStatusUnknown => _profileCompleted == null;

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
  Future<bool> loginWithKakao() async {
    try {
      print('🥕 카카오 로그인 시작...');
      _setStatus(AuthStatus.loading);
      _clearError();

      final authResponse = await _authService.loginWithKakao();
      
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
  Future<void> logout() async {
    try {
      print('👋 로그아웃 중...');
      _setStatus(AuthStatus.loading);
      
      await _authService.logout();
      
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

  /// 사용자 정보 업데이트
  Future<void> updateUserInfo() async {
    try {
      final userInfo = await _authService.getUserInfo();
      if (userInfo != null) {
        _userInfo = userInfo;
        notifyListeners();
        print('✅ 사용자 정보 업데이트 완료');
      }
    } catch (e) {
      print('❌ 사용자 정보 업데이트 실패: $e');
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
    
    if (errorString.contains('kakaoauthexception')) {
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

  /// 디버그용 - 강제 로그아웃
  void forceLogout() {
    _userInfo = null;
    _profileCompleted = null; // 개인정보 상태 초기화
    _setStatus(AuthStatus.unauthenticated);
    print('🔧 강제 로그아웃 완료');
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
      
      final profileStatus = await _profileStatusService.checkProfileStatus(
        accessToken: accessToken,
        forceRefresh: forceRefresh,
        onAutoLogout: () async {
          print('🚨 [개인정보 상태 확인] 자동 로그아웃 처리');
          await logout(); // AuthProvider의 로그아웃 메서드 호출
        },
      );

      if (profileStatus != null) {
        _profileCompleted = profileStatus;
        notifyListeners();
        
        print('✅ [개인정보 상태 확인] 성공: ${profileStatus ? '완료' : '미입력'}');
      } else {
        print('⚠️ [개인정보 상태 확인] 자동 로그아웃 처리됨');
      }
    } catch (e) {
      print('❌ [개인정보 상태 확인] 오류: $e');
      // 오류 시에도 상태를 업데이트하지 않음 (기존 캠시 유지)
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