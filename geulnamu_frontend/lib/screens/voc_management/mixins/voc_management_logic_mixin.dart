import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../services/voc/voc_service.dart';
import '../../../models/voc/voc_model.dart';
import '../../../models/voc/voc_filter_model.dart';
import '../../../core/config/app_config.dart';
import '../../../core/responsive.dart'; // 🆕 반응형 헬퍼 import

/// 문의함 관리 화면 로직 Mixin
mixin VoCManagementLogicMixin<T extends StatefulWidget> on State<T> {
  final VoCService _vocService = VoCService();

  // 상태 변수들
  bool isLoading = true;
  String? errorMessage;
  VoCListResponse? currentResponse;
  int currentPage = 1;
  VoCFilter currentFilter = VoCFilter();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // 🆕 반응형 페이지 크기 설정
      final defaultPageSize = ResponsiveHelper.getVoCDefaultPageSize(context);
      currentFilter = currentFilter.copyWith(size: defaultPageSize);
      loadIssueList();
    });
  }

  /// 이슈 목록 로드
  Future<void> loadIssueList({int? page}) async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final accessToken = await _getAccessToken();
      if (accessToken == null) {
        throw Exception('인증 토큰이 없습니다');
      }

      final targetPage = page ?? currentPage;

      final response = await _vocService.getIssueList(
        accessToken: accessToken,
        page: targetPage,
        filter: currentFilter,
      );

      if (mounted) {
        setState(() {
          currentResponse = response;
          currentPage = targetPage;
          isLoading = false;
        });
      }
    } catch (e) {
      if (AppConfig.debugMode) {
        print('❌ [이슈 목록 로드] 오류: $e');
      }

      if (mounted) {
        setState(() {
          errorMessage = _getErrorMessage(e);
          isLoading = false;
        });
      }
    }
  }

  /// 이슈 상태 업데이트
  Future<void> updateIssueStatus({
    required int vocId,
    required IssueStatus newStatus,
    String? adminComment,
  }) async {
    try {
      final accessToken = await _getAccessToken();
      if (accessToken == null) {
        throw Exception('인증 토큰이 없습니다');
      }

      // 로딩 스낵바
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
                const SizedBox(width: 12),
                const Text('이슈를 업데이트하고 있습니다...'), // 🔥 로딩 메시지도 통일
              ],
            ),
            duration: const Duration(seconds: 10),
          ),
        );
      }

      await _vocService.updateIssueStatus(
        accessToken: accessToken,
        vocId: vocId,
        newStatus: newStatus,
        adminComment: adminComment,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Text('이슈가 업데이트되었습니다.'), // 🔥 간단한 통합 메시지
              ],
            ),
            backgroundColor: Colors.green,
          ),
        );

        // 목록 새로고침
        await loadIssueList();
      }
    } catch (e) {
      if (AppConfig.debugMode) {
        print('❌ [이슈 상태 업데이트] 오류: $e');
      }

      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.error, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text('이슈 상태 변경에 실패했습니다: ${_getErrorMessage(e)}'),
                ),
              ],
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  /// 필터 변경
  void handleFilterChanged(VoCFilter newFilter) {
    setState(() {
      currentFilter = newFilter;
      currentPage = 1; // 필터 변경 시 첫 페이지로
    });
    loadIssueList(page: 1);
  }

  /// 페이지 변경
  void handlePageChanged(int newPage) {
    loadIssueList(page: newPage);
  }

  /// 재시도
  void handleRetry() {
    loadIssueList();
  }

  /// 액세스 토큰 가져오기
  Future<String?> _getAccessToken() async {
    try {
      // AuthProvider에서 토큰 가져오기
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      return await authProvider.accessToken;
    } catch (e) {
      if (AppConfig.debugMode) {
        print('❌ [토큰 가져오기] 오류: $e');
      }
      return null;
    }
  }

  /// 에러 메시지 생성
  String _getErrorMessage(dynamic error) {
    final errorString = error.toString().toLowerCase();

    if (errorString.contains('401') || errorString.contains('unauthorized')) {
      return '인증이 만료되었습니다. 다시 로그인해주세요.';
    } else if (errorString.contains('403') || errorString.contains('forbidden')) {
      return '접근 권한이 없습니다.';
    } else if (errorString.contains('404') || errorString.contains('not found')) {
      return '요청한 리소스를 찾을 수 없습니다.';
    } else if (errorString.contains('network') || errorString.contains('connection')) {
      return '네트워크 오류가 발생했습니다. 인터넷 연결을 확인해주세요.';
    } else if (errorString.contains('timeout')) {
      return '연결 시간이 초과되었습니다. 다시 시도해주세요.';
    } else {
      return '오류가 발생했습니다. 잠시 후 다시 시도해주세요.';
    }
  }
}
