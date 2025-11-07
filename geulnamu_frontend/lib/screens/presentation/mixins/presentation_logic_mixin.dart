import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../services/presentation/presentation_service.dart';
import '../../../models/presentation/presentation_model.dart';
import '../../../models/presentation/presentation_filter_model.dart';
import '../../../core/config/app_config.dart';
import '../../../core/responsive.dart'; // 🆕 반응형 헬퍼 import

/// 발제문 목록 화면 로직 Mixin
///
/// 발제문 목록 조회, 필터링, 정렬, 페이지네이션 등의 비즈니스 로직 담당
mixin PresentationLogicMixin<T extends StatefulWidget> on State<T> {
  final PresentationService _presentationService = PresentationService();

  // 상태 변수들
  bool _isLoading = false;
  String? _errorMessage;
  PresentationListResponse? _presentationListResponse;
  PresentationListFilter _currentFilter = const PresentationListFilter();

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<PresentationInfo> get presentationList => _presentationListResponse?.presentationList ?? [];
  PagingResponse? get pagingInfo => _presentationListResponse?.pagingResponse;
  PresentationListFilter get currentFilter => _currentFilter;

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
  ///
  /// [initialFilter] 초기 필터 설정 (옵션)
  Future<void> initializePresentationList({PresentationListFilter? initialFilter}) async {
    // 🎯 PresentationService는 Singleton이므로 이미 초기화됨

    // 🆕 반응형 기본 페이지 크기 설정 (발제문 전용)
    final defaultPageSize = ResponsiveHelper.getPresentationDefaultPageSize(context);

    // 🎯 초기 필터 설정 (제공된 경우)
    if (initialFilter != null) {
      // 🆕 페이지 크기를 반응형 기본값으로 설정
      _currentFilter = initialFilter.copyWith(size: defaultPageSize);
    } else {
      // 🆕 기본 필터에 반응형 크기 적용
      _currentFilter = PresentationListFilter(size: defaultPageSize);
    }

    await loadPresentationList(isInitial: true);
  }

  /// 발제문 목록 조회
  ///
  /// [isInitial] 초기 로드 여부 (true면 첫 페이지부터)
  /// [showLoading] 로딩 표시 여부
  Future<void> loadPresentationList({
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

      final accessToken = await _getAccessToken();
      if (accessToken == null) {
        throw Exception('인증 토큰을 가져올 수 없습니다.');
      }

      final response = await _presentationService.getPresentationList(
        filter: filter,
        accessToken: accessToken,
      );

      _presentationListResponse = response;
      _currentFilter = filter;
    } catch (e) {
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
  Future<void> applyFilter(PresentationListFilter newFilter) async {
    // 필터 변경 시 첫 페이지로 이동
    final filterWithFirstPage = newFilter.copyWith(page: 1);
    _currentFilter = filterWithFirstPage;

    await loadPresentationList();
  }

  /// 특정 페이지로 이동
  ///
  /// [page] 이동할 페이지 번호
  Future<void> goToPage(int page) async {
    if (page < 1 || page > totalPages) {
      return;
    }

    _currentFilter = _currentFilter.copyWith(page: page);
    await loadPresentationList();
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

  /// 새로고침 (강제 캐시 무효화)
  Future<void> refreshPresentationList() async {
    if (AppConfig.debugMode) {
      print('🔄 [발제문 목록 새로고침] 다른 화면에서 돌아와서 새로고침 시작...');
    }

    // 로딩 표시와 함께 강제 새로고침
    await loadPresentationList(showLoading: true);

    if (AppConfig.debugMode) {
      print('✅ [발제문 목록 새로고침] 완료 - 총 $totalElements개 발제문');
    }
  }

  /// 필터 초기화
  Future<void> resetFilter() async {
    final resetFilter = _currentFilter.reset();
    await applyFilter(resetFilter);
  }

  /// 발제문 상세 페이지 이동
  void handlePresentationTap(PresentationInfo presentation) {
    if (AppConfig.debugMode) {
      print('🎯 [PresentationLogicMixin] 발제문 탭: ${presentation.bookTitle} (ID: ${presentation.meetingId})');
    }

    // TODO: 향후 발제문 상세 페이지 구현 시 아래 코드 활성화
    // Navigator.pushNamed(context, '/presentation/${presentation.meetingId}');
    
    // 임시: 모임 상세 페이지로 이동
    Navigator.pushNamed(context, '/meeting/${presentation.meetingId}');
  }

  // Private methods

  /// 액세스 토큰 가져오기
  Future<String?> _getAccessToken() async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      return await authProvider.accessToken;
    } catch (e) {
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
    } else if (errorString.contains('401') ||
        errorString.contains('unauthorized')) {
      return '인증이 필요합니다. 다시 로그인해주세요.';
    } else if (errorString.contains('403') ||
        errorString.contains('forbidden')) {
      return '권한이 없습니다.';
    } else {
      return '발제문 목록을 불러오는 중 오류가 발생했습니다. 잠시 후 다시 시도해주세요.';
    }
  }
}
