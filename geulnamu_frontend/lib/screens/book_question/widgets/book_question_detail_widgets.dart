import 'package:flutter/material.dart';
import '../../../core/theme.dart';
import '../../../models/book_question/book_question_model.dart';
import 'post_it_widgets.dart';

/// 발제문 상세 페이지 관련 위젯들
///
/// 기능:
/// - 탭바 및 탭뷰 구성
/// - 로딩/에러 상태 처리
/// - 그룹별 발제문 표시
/// - 헤더 정보 표시
class BookQuestionDetailWidgets {
  /// 📊 헤더 정보 카드 (모임 정보 + 전체 통계)
  static Widget buildHeaderInfo(
    BuildContext context, {
    required String meetingTitle,
    required int totalGroups,
    required int totalQuestions,
    required String currentGroupSummary,
  }) {
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 모임 제목
          Row(
            children: [
              Icon(
                Icons.library_books,
                color: context.colors.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  meetingTitle,
                  style: context.textStyles.titleMedium?.copyWith(
                    color: context.colors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // 통계 정보
          Row(
            children: [
              // 전체 그룹 수
              _buildStatItem(
                context,
                icon: Icons.groups,
                label: '전체 그룹',
                value: '$totalGroups개',
              ),

              const SizedBox(width: 24),

              // 전체 발제문 수
              _buildStatItem(
                context,
                icon: Icons.sticky_note_2,
                label: '전체 발제문',
                value: '$totalQuestions개',
              ),
            ],
          ),

          const SizedBox(height: 8),

          // 현재 선택된 그룹 정보
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: context.colors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              '현재 보기: $currentGroupSummary',
              style: context.textStyles.bodySmall?.copyWith(
                color: context.colors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 📈 통계 아이템 (아이콘 + 라벨 + 값)
  static Widget _buildStatItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: context.colors.onSurface.withOpacity(0.7)),
        const SizedBox(width: 4),
        Text(
          label,
          style: context.textStyles.bodySmall?.copyWith(
            color: context.colors.onSurface.withOpacity(0.7),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          value,
          style: context.textStyles.bodySmall?.copyWith(
            color: context.colors.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  /// 📂 동적 탭바 (그룹 수만큼 생성)
  static Widget buildTabBar(
    BuildContext context,
    TabController tabController,
    int groupCount,
    Function(int) getTabLabel,
  ) {
    if (groupCount == 0) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TabBar(
        controller: tabController,
        isScrollable: groupCount > 4, // 4개 이상이면 스크롤 가능
        tabAlignment: groupCount > 4 ? TabAlignment.start : TabAlignment.fill,
        indicator: BoxDecoration(
          color: context.colors.primary,
          borderRadius: BorderRadius.circular(8),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        indicatorPadding: const EdgeInsets.all(4),
        dividerColor: Colors.transparent,
        labelColor: context.colors.onPrimary,
        unselectedLabelColor: context.colors.onSurface.withOpacity(0.7),
        labelStyle: context.textStyles.titleSmall?.copyWith(
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: context.textStyles.titleSmall?.copyWith(
          fontWeight: FontWeight.normal,
        ),
        tabs: List.generate(
          groupCount,
          (index) => Tab(text: getTabLabel(index)),
        ),
      ),
    );
  }

  /// 📋 탭뷰 컨텐츠 (발제문 그리드)
  static Widget buildTabBarView(
    BuildContext context,
    TabController tabController,
    BookQuestionResponse bookQuestionResponse, {
    required bool canEdit,
    required Function(BookQuestionModel) onEdit,
    required Function(BookQuestionModel) onDelete,
  }) {
    if (bookQuestionResponse.groups.isEmpty) {
      return buildEmptyAllGroups(context);
    }

    return TabBarView(
      controller: tabController,
      children: bookQuestionResponse.groups.map((group) {
        return PostItWidgets.buildPostItGrid(
          context,
          group.bookQuestionList,
          canEdit: canEdit,
          onEdit: onEdit,
          onDelete: onDelete,
        );
      }).toList(),
    );
  }

  /// 🔄 로딩 위젯
  static Widget buildLoading(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: context.colors.primary),
          const SizedBox(height: 16),
          Text(
            '발제문을 불러오는 중...',
            style: context.textStyles.bodyMedium?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  /// ❌ 에러 위젯
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
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.colors.primary,
                  foregroundColor: context.colors.onPrimary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// 📭 모든 그룹이 비어있을 때
  static Widget buildEmptyAllGroups(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.sticky_note_2_outlined,
              size: 80,
              color: context.colors.onSurfaceVariant.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              '아직 발제문이 없습니다',
              textAlign: TextAlign.center,
              style: context.textStyles.titleMedium?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '토론 참여자들이 발제문을 작성하면\n여기에 그룹별로 표시됩니다',
              textAlign: TextAlign.center,
              style: context.textStyles.bodyMedium?.copyWith(
                color: context.colors.onSurfaceVariant.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 🔒 권한 없음 위젯
  static Widget buildNoPermission(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.lock_outline, size: 64, color: context.colors.outline),
            const SizedBox(height: 16),
            Text(
              '접근 권한이 없습니다',
              textAlign: TextAlign.center,
              style: context.textStyles.titleMedium?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '발제문을 보려면 해당 모임에\\n참여해야 합니다',
              textAlign: TextAlign.center,
              style: context.textStyles.bodyMedium?.copyWith(
                color: context.colors.onSurfaceVariant.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 🎯 플로팅 액션 버튼 (새로고침)
  static Widget buildFloatingActionButton(
    BuildContext context,
    VoidCallback onRefresh,
  ) {
    return FloatingActionButton(
      onPressed: onRefresh,
      backgroundColor: context.colors.primary,
      foregroundColor: context.colors.onPrimary,
      tooltip: '새로고침',
      child: const Icon(Icons.refresh),
    );
  }

  /// 📱 권한 안내 스낵바
  static void showPermissionSnackBar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.info_outline, color: context.colors.onPrimary, size: 20),
            const SizedBox(width: 8),
            const Expanded(child: Text('관리자급만 발제문을 수정/삭제할 수 있습니다.')),
          ],
        ),
        backgroundColor: context.colors.primary,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
