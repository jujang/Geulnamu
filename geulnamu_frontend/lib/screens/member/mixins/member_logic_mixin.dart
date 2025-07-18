import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/config/app_config.dart';
import '../../../providers/auth_provider.dart';
import '../../../services/member/member_service.dart';
import '../../../models/member/member_list_model.dart';

/// 모임원 목록 화면 로직 Mixin
/// 
/// 모임원 목록 조회, 필터링, 정렬, 페이지네이션 등의 비즈니스 로직 담당
mixin MemberLogicMixin<T extends StatefulWidget> on State<T> {
  final MemberService _memberService = MemberService();

  // 상태 변수들
  bool _isLoading = false;
  bool _isLoadingMore = false;
  String? _errorMessage;
  MemberListResponse? _memberListResponse;
  MemberListFilter _currentFilter = const MemberListFilter();

  // Getters
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  String? get errorMessage => _errorMessage;
  List<MemberListItem> get memberList => _memberListResponse?.memberList ?? [];
  PagingResponse? get pagingInfo => _memberListResponse?.pagingResponse;
  MemberListFilter get currentFilter => _currentFilter;

  // 페이지네이션 정보
  bool get hasNextPage {
    final paging = pagingInfo;
    if (paging == null) return false;
    return paging.pageNumber < paging.totalPages;
  }

  bool get hasPreviousPage {
    final paging = pagingInfo;
    if (paging == null) return false;
    return paging.pageNumber > 1;
  }

  int get currentPage => pagingInfo?.pageNumber ?? 1;
  int get totalPages => pagingInfo?.totalPages ?? 1;
  int get totalElements => pagingInfo?.totalElements ?? 0;

  /// 초기 데이터 로드
  Future<void> initializeMemberList() async {
    if (AppConfig.debugMode) {
      print('🚀 [MemberLogicMixin] 모임원 목록 초기화 시작');
    }

    // 🎯 MemberService 초기화
    _memberService.initialize();

    // 🎯 사용자 권한에 따른 필터 표시 가능 여부 설정
    await _updateDeletedFilterPermission();

    // 🎯 초기 필터 설정 (비관리자급은 활성 계정만)
    await _setInitialFilter();

    await loadMemberList(isInitial: true);
  }

  /// 비활성 계정 필터 표시 권한 업데이트
  Future<void> _updateDeletedFilterPermission() async {
    final userRole = await _getUserRole();
    _canShowDeletedFilterSync = MemberService.canUseDeletedFilter(userRole);
    
    if (AppConfig.debugMode) {
      print('🔍 [MemberLogicMixin] 사용자 권한: $userRole');
      print('🔍 [MemberLogicMixin] 비활성 계정 필터 사용 가능: $_canShowDeletedFilterSync');
    }
  }

  /// 🎯 초기 필터 설정 (비관리자급은 활성 계정만)
  Future<void> _setInitialFilter() async {
    final userRole = await _getUserRole();
    final isAdminLevel = userRole != null && ['ADMIN', 'LEADER', 'VICE_LEADER'].contains(userRole);
    
    if (!isAdminLevel) {
      // 비관리자급은 초기 필터에 활성 계정만 조회로 설정
      _currentFilter = _currentFilter.copyWith(isDeleted: false);
      
      if (AppConfig.debugMode) {
        print('🎨 [MemberLogicMixin] 초기 필터 설정: 비관리자급($userRole) - 활성 계정만 조회');
      }
    } else {
      if (AppConfig.debugMode) {
        print('🎨 [MemberLogicMixin] 초기 필터 설정: 관리자급($userRole) - 모든 계정 조회 가능');
      }
    }
  }

  /// 모임원 목록 조회
  /// 
  /// [isInitial] 초기 로드 여부 (true면 첫 페이지부터)
  /// [showLoading] 로딩 표시 여부
  Future<void> loadMemberList({
    bool isInitial = false,
    bool showLoading = true,
  }) async {
    try {
      if (showLoading) {
        _setLoading(true);
      }
      _clearError();

      // 초기 로드 시 첫 페이지로 설정
      var filter = isInitial 
          ? _currentFilter.copyWith(page: 1)
          : _currentFilter;

      // 🎯 사용자 권한 정보 가져오기
      final userRole = await _getUserRole();
      
      // 🎯 관리자급이 아닌 경우 활성 계정만 조회하도록 필터 강제 설정
      final isAdminLevel = userRole != null && ['ADMIN', 'LEADER', 'VICE_LEADER'].contains(userRole);
      if (!isAdminLevel) {
        // 비관리자급은 활성 계정만 볼 수 있음
        filter = filter.copyWith(isDeleted: false);
        
        if (AppConfig.debugMode) {
          print('🚫 [MemberLogicMixin] 비관리자급 ($userRole) - 활성 계정만 조회로 제한');
        }
      } else {
        if (AppConfig.debugMode) {
          print('✅ [MemberLogicMixin] 관리자급 ($userRole) - 모든 계정 조회 가능');
        }
      }

      final accessToken = await _getAccessToken();
      if (accessToken == null) {
        throw Exception('인증 토큰을 가져올 수 없습니다.');
      }
      
      final response = await _memberService.getMemberList(
        filter: filter,
        accessToken: accessToken,
        userRole: userRole,
      );

      _memberListResponse = response;
      _currentFilter = filter;

      if (AppConfig.debugMode) {
        print('✅ [MemberLogicMixin] 모임원 목록 조회 성공: ${response.memberList.length}명');
      }
    } catch (e) {
      if (AppConfig.debugMode) {
        print('❌ [MemberLogicMixin] 모임원 목록 조회 실패: $e');
      }
      _setError(_getErrorMessage(e));
    } finally {
      if (showLoading) {
        _setLoading(false);
      }
    }
  }

  /// 필터 적용
  /// 
  /// [newFilter] 새로운 필터 설정
  Future<void> applyFilter(MemberListFilter newFilter) async {
    if (AppConfig.debugMode) {
      print('🔍 [MemberLogicMixin] 필터 적용: $newFilter');
    }

    // 필터 변경 시 첫 페이지로 이동
    final filterWithFirstPage = newFilter.copyWith(page: 1);
    _currentFilter = filterWithFirstPage;

    await loadMemberList();
  }

  /// 특정 페이지로 이동
  /// 
  /// [page] 이동할 페이지 번호
  Future<void> goToPage(int page) async {
    if (page < 1 || page > totalPages) {
      if (AppConfig.debugMode) {
        print('⚠️ [MemberLogicMixin] 잘못된 페이지: $page (총 ${totalPages}페이지)');
      }
      return;
    }

    if (AppConfig.debugMode) {
      print('📄 [MemberLogicMixin] 페이지 이동: $page');
    }

    _currentFilter = _currentFilter.copyWith(page: page);
    await loadMemberList();
  }

  /// 다음 페이지로 이동
  Future<void> goToNextPage() async {
    if (hasNextPage) {
      await goToPage(currentPage + 1);
    }
  }

  /// 이전 페이지로 이동
  Future<void> goToPreviousPage() async {
    if (hasPreviousPage) {
      await goToPage(currentPage - 1);
    }
  }

  /// 첫 페이지로 이동
  Future<void> goToFirstPage() async {
    if (currentPage != 1) {
      await goToPage(1);
    }
  }

  /// 마지막 페이지로 이동
  Future<void> goToLastPage() async {
    if (currentPage != totalPages) {
      await goToPage(totalPages);
    }
  }

  /// 새로고침
  Future<void> refreshMemberList() async {
    if (AppConfig.debugMode) {
      print('🔄 [MemberLogicMixin] 모임원 목록 새로고침');
    }

    await loadMemberList();
  }

  /// 필터 초기화
  Future<void> resetFilter() async {
    if (AppConfig.debugMode) {
      print('🔄 [MemberLogicMixin] 필터 초기화');
    }

    final resetFilter = _currentFilter.reset();
    await applyFilter(resetFilter);
  }

  /// 현재 사용자가 비활성 계정 필터를 사용할 수 있는지 확인
  /// 
  /// 운영진·준운영진은 비활성 계정 필터 사용 불가
  Future<bool> get canShowDeletedFilter async {
    final userRole = await _getUserRole();
    return MemberService.canUseDeletedFilter(userRole);
  }

  /// 현재 필터에 비활성 계정 필터가 적용 가능한지 확인 (동기 버전)
  bool get canShowCurrentDeletedFilter {
    // 🎯 이 메서드는 UI에서 즉시 사용되므로 임시로 true 반환
    // 실제 확인은 _canShowDeletedFilterSync에서 수행
    return _canShowDeletedFilterSync;
  }
  
  /// 동기적으로 비활성 계정 필터 표시 가능 여부 저장
  bool _canShowDeletedFilterSync = true;

  // Private methods

  /// 액세스 토큰 가져오기
  Future<String?> _getAccessToken() async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      return await authProvider.accessToken;
    } catch (e) {
      if (AppConfig.debugMode) {
        print('❌ [MemberLogicMixin] 액세스 토큰 가져오기 실패: $e');
      }
      return null;
    }
  }

  /// 사용자 권한 가져오기
  Future<String?> _getUserRole() async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      return authProvider.userRole;
    } catch (e) {
      if (AppConfig.debugMode) {
        print('❌ [MemberLogicMixin] 사용자 권한 가져오기 실패: $e');
      }
      return null;
    }
  }

  /// 로딩 상태 설정
  void _setLoading(bool loading) {
    if (_isLoading != loading) {
      _isLoading = loading;
      if (mounted) {
        setState(() {});
      }
    }
  }

  /// 에러 메시지 설정
  void _setError(String message) {
    _errorMessage = message;
    if (mounted) {
      setState(() {});
    }
  }

  /// 에러 메시지 초기화
  void _clearError() {
    if (_errorMessage != null) {
      _errorMessage = null;
      if (mounted) {
        setState(() {});
      }
    }
  }

  /// 에러 메시지 변환
  String _getErrorMessage(dynamic error) {
    final errorString = error.toString().toLowerCase();

    if (errorString.contains('network') || errorString.contains('connection')) {
      return '네트워크 오류가 발생했습니다. 인터넷 연결을 확인해주세요.';
    } else if (errorString.contains('timeout')) {
      return '연결 시간이 초과되었습니다. 다시 시도해주세요.';
    } else if (errorString.contains('401') || errorString.contains('unauthorized')) {
      return '인증이 필요합니다. 다시 로그인해주세요.';
    } else if (errorString.contains('403') || errorString.contains('forbidden')) {
      return '권한이 없습니다. 임원진 이상 권한이 필요합니다.';
    } else {
      return '모임원 목록을 불러오는 중 오류가 발생했습니다. 잠시 후 다시 시도해주세요.';
    }
  }

  /// 디버그용 - 현재 상태 출력
  void printCurrentState() {
    if (AppConfig.debugMode) {
      print('📊 === MemberLogicMixin 상태 ===');
      print('로딩: $_isLoading');
      print('에러: $_errorMessage');
      print('필터: $_currentFilter');
      print('페이징: $pagingInfo');
      print('멤버 수: ${memberList.length}');
      print('==============================');
    }
  }
}
