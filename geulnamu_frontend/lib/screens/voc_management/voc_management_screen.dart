import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/home/home_service.dart';
import '../../widgets/common/main_layout.dart';
import 'mixins/voc_management_logic_mixin.dart';
import 'widgets/voc_management_widgets.dart';
import 'widgets/voc_filter_widgets.dart';
import 'widgets/voc_detail_widgets.dart';

/// 문의 목록 화면 (관리자 전용)
///
/// 기능:
/// - 이슈 목록 조회 (페이징)
/// - 이슈 상태별/유형별 필터링
/// - 이슈 상세 보기 및 상태 변경
/// - 관리자 코멘트 작성
class VoCManagementScreen extends StatefulWidget {
  const VoCManagementScreen({super.key});

  @override
  State<VoCManagementScreen> createState() => _VoCManagementScreenState();
}

class _VoCManagementScreenState extends State<VoCManagementScreen>
    with VoCManagementLogicMixin {
  final HomeService _homeService = HomeService();

  @override
  Widget build(BuildContext context) {
    return Consumer2<AuthProvider, HomeService>(
      builder: (context, authProvider, homeService, child) {
        return MainLayout(
          showDrawerButton: true, // 🍔 햄버거 버튼 표시
          // isRootPage: false (기본값) - 시스템 뒤로가기 허용
          title: '문의 목록',
          actions: [
            // 새로고침 버튼
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: isLoading ? null : () => loadIssueList(),
              tooltip: '새로고침',
            ),
          ],
          onMenuTap: (menu) =>
              _homeService.handleMenuTap(context, menu), // 🔥 메뉴 탭 처리 추가
          onLogoutTap: authProvider.isAuthenticated
              ? () => homeService.handleLogout(context, authProvider)
              : null,
          body: RefreshIndicator(
            onRefresh: () async {
              await loadIssueList();
            },
            child: Stack(
              children: [
                // 메인 콘텐츠
                _buildBody(context),

                // 필터 FAB (좌측 하단)
                Positioned(
                  bottom: 16,
                  left: 16,
                  child: _buildFilterFab(context),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// 바디 빌드
  Widget _buildBody(BuildContext context) {
    if (isLoading) {
      return VoCManagementWidgets.buildLoading(context);
    }

    if (errorMessage != null) {
      return VoCManagementWidgets.buildError(
        context,
        message: errorMessage!,
        onRetry: handleRetry,
      );
    }

    if (currentResponse == null || currentResponse!.issues.isEmpty) {
      return VoCManagementWidgets.buildEmptyList(context);
    }

    return Column(
      children: [
        // 목록 헤더
        VoCManagementWidgets.buildListHeader(
          context,
          totalElements: currentResponse!.totalElements,
          currentFilter: currentFilter,
          onFilterTap: _showFilterBottomSheet,
        ),

        // 이슈 목록
        Expanded(
          child: VoCManagementWidgets.buildIssueList(
            context,
            currentResponse!.issues,
            _handleIssueTap,
          ),
        ),

        // 페이지네이션
        VoCManagementWidgets.buildPagination(
          context,
          currentPage: currentResponse!.pageNumber,
          totalPages: currentResponse!.totalPages,
          onPageChanged: handlePageChanged,
        ),
      ],
    );
  }

  /// 필터 FAB
  Widget _buildFilterFab(BuildContext context) {
    return FloatingActionButton(
      onPressed: _showFilterBottomSheet,
      backgroundColor: Theme.of(context).colorScheme.primary,
      foregroundColor: Theme.of(context).colorScheme.onPrimary,
      child: const Icon(Icons.tune),
    );
  }

  /// 필터 바텀시트 표시
  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => VoCFilterWidgets.buildFilterBottomSheet(
        context,
        currentFilter: currentFilter,
        onFilterChanged: handleFilterChanged,
      ),
    );
  }

  /// 이슈 탭 처리
  void _handleIssueTap(issue) {
    VoCDetailWidgets.showIssueDetail(
      context,
      issue: issue,
      onSave: (newStatus, adminComment) {
        updateIssueStatus(
          vocId: issue.vocId,
          newStatus: newStatus,
          adminComment: adminComment,
        );
      },
    );
  }
}
