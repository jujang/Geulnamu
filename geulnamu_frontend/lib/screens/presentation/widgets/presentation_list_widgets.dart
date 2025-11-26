import 'package:flutter/material.dart';
import '../../../core/theme.dart';
import '../../../models/presentation/presentation_filter_model.dart';

/// 발제문 목록 관련 UI 위젯들
///
/// Static Methods로 구현하여 재사용성 극대화
class PresentationListWidgets {
  /// 페이지네이션 위젯 (🆕 반응형 개선)
  static Widget buildPagination(
    BuildContext context, {
    required int currentPage,
    required int totalPages,
    required Function(int) onPageChanged,
  }) {
    if (totalPages <= 1) {
      return const SizedBox.shrink();
    }

    // 🆕 화면 크기에 따른 반응형 처리
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600; // 모바일 화면

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      child: isSmallScreen
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

  /// 📱 컴팩트 페이지네이션 (모바일용 - 3개 페이지 번호)
  static Widget _buildCompactPagination(
    BuildContext context,
    int currentPage,
    int totalPages,
    Function(int) onPageChanged,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // 첫 페이지 버튼
        IconButton(
          onPressed: currentPage > 1 ? () => onPageChanged(1) : null,
          icon: const Icon(Icons.first_page),
          iconSize: 20,
          padding: const EdgeInsets.all(8),
          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
        ),

        // 🆕 3개 페이지 번호 버튼
        ...buildCompactPageNumbers(
          context,
          currentPage,
          totalPages,
          onPageChanged,
        ),

        // 마지막 페이지 버튼
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

  /// 🆕 컴팩트 페이지 번호 버튼들 생성 (3개)
  static List<Widget> buildCompactPageNumbers(
    BuildContext context,
    int currentPage,
    int totalPages,
    Function(int) onPageChanged,
  ) {
    final List<Widget> pageButtons = [];

    // 🎯 현재 페이지를 중심으로 3개 표시 (currentPage - 1, currentPage, currentPage + 1)
    int startPage = (currentPage - 1).clamp(1, totalPages);
    int endPage = (startPage + 2).clamp(1, totalPages);

    // 🎯 경계 처리: endPage가 마지막에 도달했을 때 startPage 조정
    if (endPage == totalPages && totalPages >= 3) {
      startPage = (totalPages - 2).clamp(1, totalPages);
    }

    // 🎯 총 페이지가 3개 미만이면 모두 표시
    if (totalPages < 3) {
      startPage = 1;
      endPage = totalPages;
    }

    for (int i = startPage; i <= endPage; i++) {
      pageButtons.add(
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 2),
          child: Material(
            borderRadius: BorderRadius.circular(8),
            color: i == currentPage
                ? context.colors.primary
                : Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: i != currentPage ? () => onPageChanged(i) : null,
              child: Container(
                width: 36, // 모바일용 작은 크기
                height: 36,
                alignment: Alignment.center,
                child: Text(
                  '$i',
                  style: context.textStyles.bodyMedium?.copyWith(
                    color: i == currentPage
                        ? context.colors.onPrimary
                        : context.colors.onSurface,
                    fontWeight: i == currentPage
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    return pageButtons;
  }

  /// 🖥️ 풀 페이지네이션 (PC용)
  static Widget _buildFullPagination(
    BuildContext context,
    int currentPage,
    int totalPages,
    Function(int) onPageChanged,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // 첫 페이지
        IconButton(
          onPressed: currentPage > 1 ? () => onPageChanged(1) : null,
          icon: const Icon(Icons.first_page),
        ),

        // 이전 페이지
        IconButton(
          onPressed: currentPage > 1
              ? () => onPageChanged(currentPage - 1)
              : null,
          icon: const Icon(Icons.chevron_left),
        ),

        // 페이지 번호들
        ...buildPageNumbers(context, currentPage, totalPages, onPageChanged),

        // 다음 페이지
        IconButton(
          onPressed: currentPage < totalPages
              ? () => onPageChanged(currentPage + 1)
              : null,
          icon: const Icon(Icons.chevron_right),
        ),

        // 마지막 페이지
        IconButton(
          onPressed: currentPage < totalPages
              ? () => onPageChanged(totalPages)
              : null,
          icon: const Icon(Icons.last_page),
        ),
      ],
    );
  }

  /// 페이지 번호 버튼들 생성
  static List<Widget> buildPageNumbers(
    BuildContext context,
    int currentPage,
    int totalPages,
    Function(int) onPageChanged,
  ) {
    final List<Widget> pageButtons = [];

    // 표시할 페이지 범위 계산 (최대 5개)
    int startPage = (currentPage - 2).clamp(1, totalPages);
    int endPage = (startPage + 4).clamp(1, totalPages);

    // startPage 조정 (endPage가 마지막에 도달했을 때)
    if (endPage == totalPages) {
      startPage = (endPage - 4).clamp(1, totalPages);
    }

    for (int i = startPage; i <= endPage; i++) {
      pageButtons.add(
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 2),
          child: Material(
            borderRadius: BorderRadius.circular(8),
            color: i == currentPage
                ? context.colors.primary
                : Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: i != currentPage ? () => onPageChanged(i) : null,
              child: Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                child: Text(
                  '$i',
                  style: context.textStyles.bodyMedium?.copyWith(
                    color: i == currentPage
                        ? context.colors.onPrimary
                        : context.colors.onSurface,
                    fontWeight: i == currentPage
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    return pageButtons;
  }

  /// 로딩 위젯
  static Widget buildLoading(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: context.colors.primary),
          const SizedBox(height: 16),
          Text(
            '발제문 목록을 불러오는 중...',
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
    VoidCallback? onRetry,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: context.colors.error),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: context.textStyles.bodyLarge?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('다시 시도'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// 빈 목록 위젯
  static Widget buildEmptyList(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.library_books_outlined,
              size: 64,
              color: context.colors.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              '조건에 맞는 발제문이 없습니다',
              textAlign: TextAlign.center,
              style: context.textStyles.titleMedium?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '필터 조건을 변경해보세요',
              textAlign: TextAlign.center,
              style: context.textStyles.bodyMedium?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 목록 정보 헤더
  static Widget buildListHeader(
    BuildContext context, {
    required int totalElements,
    required PresentationListFilter currentFilter,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                Icons.library_books,
                size: 20,
                color: context.colors.primary,
              ),
              const SizedBox(width: 8),
              Text(
                '총 $totalElements개 모임',
                style: context.textStyles.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: context.colors.onSurface,
                ),
              ),
            ],
          ),
          Text(
            _getFilterSummary(currentFilter),
            style: context.textStyles.bodySmall?.copyWith(
              color: context.colors.onSurface.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  /// 필터 요약 텍스트 생성
  static String _getFilterSummary(PresentationListFilter filter) {
    final List<String> filterParts = [];

    // 발제문 유형 필터
    if (filter.presentationType != PresentationTypeOption.all) {
      filterParts.add(filter.presentationType.displayName);
    }

    // 오늘 모임 필터
    if (filter.isTodayMeeting == true) {
      filterParts.add('오늘 모임만');
    }

    // 출석 상태 필터
    if (filter.attendanceStatus != AttendanceStatusOption.all) {
      filterParts.add(filter.attendanceStatus.displayName);
    }

    // 정렬 정보
    final order = filter.isAsc ? '↑' : '↓';
    filterParts.add('${filter.sortBy.displayName}$order');

    return filterParts.join(' · ');
  }

  /// 플로팅 필터 버튼
  static Widget buildFilterFab(BuildContext context, VoidCallback onPressed) {
    return FloatingActionButton(
      onPressed: onPressed,
      backgroundColor: context.colors.primary,
      foregroundColor: context.colors.onPrimary,
      child: const Icon(Icons.tune),
    );
  }

  /// 📚 발제문 안내 메시지
  static Widget buildIntroduction(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colors.primaryContainer.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: context.colors.primary.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: context.colors.primary, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '발제문 목록',
                  style: context.textStyles.titleSmall?.copyWith(
                    color: context.colors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '모임별 발제문을 책 형태로 확인하세요',
                  style: context.textStyles.bodySmall?.copyWith(
                    color: context.colors.onSurface.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
