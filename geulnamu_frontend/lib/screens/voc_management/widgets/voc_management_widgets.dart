import 'package:flutter/material.dart';
import '../../../core/theme.dart';
import '../../../core/responsive.dart';
import '../../../models/voc/voc_model.dart';

/// 문의 목록 화면 UI 위젯들
///
/// Static Methods로 구현하여 재사용성 극대화
class VoCManagementWidgets {
  // ==================== 로딩 및 에러 상태 ====================

  /// 로딩 위젯
  static Widget buildLoading(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: context.colors.primary),
          const SizedBox(height: 16),
          Text(
            '이슈 목록을 불러오는 중...',
            style: context.textStyles.bodyMedium?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  /// 에러 위젯
  static Widget buildError(
    BuildContext context, {
    required String message,
    required VoidCallback onRetry,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: context.colors.error),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: context.textStyles.bodyLarge?.copyWith(
                color: context.colors.onSurface.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('다시 시도'),
            ),
          ],
        ),
      ),
    );
  }

  /// 빈 목록 위젯
  static Widget buildEmptyList(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 64,
              color: context.colors.onSurface.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            Text(
              '📭 아직 등록된 이슈가 없습니다',
              style: context.textStyles.titleMedium?.copyWith(
                color: context.colors.onSurface.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '문의 사항이 접수되면 여기에 표시됩니다',
              textAlign: TextAlign.center,
              style: context.textStyles.bodyMedium?.copyWith(
                color: context.colors.onSurface.withValues(alpha: 0.4),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== 목록 헤더 ====================

  /// 목록 정보 헤더
  static Widget buildListHeader(
    BuildContext context, {
    required int totalElements,
    required int currentPage,
    required int totalPages,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '총 $totalElements개',
            style: context.textStyles.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: context.colors.onSurface,
            ),
          ),
          Text(
            '$currentPage / $totalPages 페이지',
            style: context.textStyles.bodySmall?.copyWith(
              color: context.colors.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== 이슈 목록 ====================

  /// 이슈 목록 빌드
  static Widget buildIssueList(
    BuildContext context,
    List<VoCIssue> issues,
    Function(VoCIssue) onIssueTap,
  ) {
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 80), // FAB 공간 확보
      itemCount: issues.length,
      itemBuilder: (context, index) {
        final issue = issues[index];
        return buildIssueItem(context, issue, onIssueTap);
      },
    );
  }

  /// 개별 이슈 항목 (출석 현황 스타일)
  static Widget buildIssueItem(
    BuildContext context,
    VoCIssue issue,
    Function(VoCIssue) onTap,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(
            color: Theme.of(context).brightness == Brightness.light
                ? context.colors.outline.withValues(alpha: 0.1)
                : Colors.transparent,
            width: 0.5,
          ),
        ),
        child: InkWell(
          onTap: () => onTap(issue),
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // 이슈 ID
                SizedBox(
                  width: 40,
                  child: Text(
                    '#${issue.vocId}',
                    style: context.textStyles.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: context.colors.primary,
                    ),
                  ),
                ),

                const SizedBox(width: 8),

                // 유형 아이콘
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _getTypeColor(issue.voCType).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      issue.voCType.icon,
                      style: const TextStyle(fontSize: 20),
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // 작성자 ID
                SizedBox(
                  width: 45,
                  child: Text(
                    '👤${issue.memberId}',
                    style: context.textStyles.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: context.colors.onSurface,
                    ),
                  ),
                ),

                const SizedBox(width: 8),

                // 내용 (말줄임)
                Expanded(
                  child: Text(
                    issue.content,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.textStyles.bodyMedium?.copyWith(
                      color: context.colors.onSurface.withValues(alpha: 0.8),
                    ),
                  ),
                ),

                const SizedBox(width: 8),

                // 상태 칩
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Color(
                      issue.issueStatus.colorValue,
                    ).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        issue.issueStatus.icon,
                        style: const TextStyle(fontSize: 12),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        issue.issueStatus.displayName,
                        style: context.textStyles.bodySmall?.copyWith(
                          color: Color(issue.issueStatus.colorValue),
                          fontWeight: FontWeight.w600,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ==================== 페이지네이션 ====================

  /// 페이지네이션 위젯 (모임 목록 스타일)
  static Widget buildPagination(
    BuildContext context, {
    required int currentPage,
    required int totalPages,
    required Function(int) onPageChanged,
  }) {
    if (totalPages <= 1) {
      return const SizedBox.shrink();
    }

    final isMobile = ResponsiveHelper.isMobile(context);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      child: isMobile
          ? _buildCompactPagination(
              context,
              currentPage,
              totalPages,
              onPageChanged,
            )
          : _buildFullPagination(
              context,
              currentPage,
              totalPages,
              onPageChanged,
            ),
    );
  }

  /// 모바일용 컴팩트 페이지네이션
  static Widget _buildCompactPagination(
    BuildContext context,
    int currentPage,
    int totalPages,
    Function(int) onPageChanged,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          onPressed: currentPage > 1 ? () => onPageChanged(1) : null,
          icon: const Icon(Icons.first_page),
          iconSize: 20,
          padding: const EdgeInsets.all(8),
          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
        ),
        ..._buildCompactPageNumbers(
          context,
          currentPage,
          totalPages,
          onPageChanged,
        ),
        IconButton(
          onPressed: currentPage < totalPages
              ? () => onPageChanged(totalPages)
              : null,
          icon: const Icon(Icons.last_page),
          iconSize: 20,
          padding: const EdgeInsets.all(8),
          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
        ),
      ],
    );
  }

  /// 데스크톱용 풀 페이지네이션
  static Widget _buildFullPagination(
    BuildContext context,
    int currentPage,
    int totalPages,
    Function(int) onPageChanged,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          onPressed: currentPage > 1 ? () => onPageChanged(1) : null,
          icon: const Icon(Icons.first_page),
        ),
        IconButton(
          onPressed: currentPage > 1
              ? () => onPageChanged(currentPage - 1)
              : null,
          icon: const Icon(Icons.chevron_left),
        ),
        ..._buildPageNumbers(context, currentPage, totalPages, onPageChanged),
        IconButton(
          onPressed: currentPage < totalPages
              ? () => onPageChanged(currentPage + 1)
              : null,
          icon: const Icon(Icons.chevron_right),
        ),
        IconButton(
          onPressed: currentPage < totalPages
              ? () => onPageChanged(totalPages)
              : null,
          icon: const Icon(Icons.last_page),
        ),
      ],
    );
  }

  /// 컴팩트 페이지 번호들 (3개)
  static List<Widget> _buildCompactPageNumbers(
    BuildContext context,
    int currentPage,
    int totalPages,
    Function(int) onPageChanged,
  ) {
    final List<Widget> pageButtons = [];

    int startPage = (currentPage - 1).clamp(1, totalPages);
    int endPage = (startPage + 2).clamp(1, totalPages);

    if (endPage == totalPages && totalPages >= 3) {
      startPage = (totalPages - 2).clamp(1, totalPages);
    }

    if (totalPages < 3) {
      startPage = 1;
      endPage = totalPages;
    }

    for (int i = startPage; i <= endPage; i++) {
      pageButtons.add(
        _buildPageButton(context, i, currentPage, onPageChanged, true),
      );
    }

    return pageButtons;
  }

  /// 풀 페이지 번호들 (5개)
  static List<Widget> _buildPageNumbers(
    BuildContext context,
    int currentPage,
    int totalPages,
    Function(int) onPageChanged,
  ) {
    final List<Widget> pageButtons = [];

    int startPage = (currentPage - 2).clamp(1, totalPages);
    int endPage = (startPage + 4).clamp(1, totalPages);

    if (endPage == totalPages) {
      startPage = (endPage - 4).clamp(1, totalPages);
    }

    for (int i = startPage; i <= endPage; i++) {
      pageButtons.add(
        _buildPageButton(context, i, currentPage, onPageChanged, false),
      );
    }

    return pageButtons;
  }

  /// 페이지 버튼
  static Widget _buildPageButton(
    BuildContext context,
    int pageNumber,
    int currentPage,
    Function(int) onPageChanged,
    bool isCompact,
  ) {
    final isSelected = pageNumber == currentPage;
    final size = isCompact ? 36.0 : 40.0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      child: Material(
        borderRadius: BorderRadius.circular(8),
        color: isSelected ? context.colors.primary : Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: !isSelected ? () => onPageChanged(pageNumber) : null,
          child: Container(
            width: size,
            height: size,
            alignment: Alignment.center,
            child: Text(
              '$pageNumber',
              style: context.textStyles.bodyMedium?.copyWith(
                color: isSelected
                    ? context.colors.onPrimary
                    : context.colors.onSurface,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ==================== Helper Methods ====================

  /// 유형별 색상
  static Color _getTypeColor(VoCType type) {
    switch (type) {
      case VoCType.errorReport:
        return Colors.red;
      case VoCType.featureRequest:
        return Colors.amber;
    }
  }

  /// 날짜 포맷 (MM.dd)
  static String _formatDate(DateTime dateTime) {
    return '${dateTime.month.toString().padLeft(2, '0')}.${dateTime.day.toString().padLeft(2, '0')}';
  }

  /// 시간 포맷 (HH:mm)
  static String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
