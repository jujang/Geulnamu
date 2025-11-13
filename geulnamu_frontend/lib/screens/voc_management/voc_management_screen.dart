import 'package:flutter/material.dart';
import 'mixins/voc_management_logic_mixin.dart';
import 'widgets/voc_management_widgets.dart';
import 'widgets/voc_filter_widgets.dart';
import 'widgets/voc_detail_widgets.dart';

/// 문의함 관리 화면 (관리자 전용)
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('문의함 관리'),
        centerTitle: true,
      ),
      body: _buildBody(context),
      floatingActionButton: _buildFilterFab(context),
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
          currentPage: currentResponse!.pageNumber,
          totalPages: currentResponse!.totalPages,
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
