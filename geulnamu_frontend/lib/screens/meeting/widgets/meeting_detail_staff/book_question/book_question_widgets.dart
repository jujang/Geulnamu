import 'package:flutter/material.dart';
import '../../../../../models/book_question/book_question_model.dart';
import '../../../../../core/config/app_config.dart';
import 'post_it_book_question_widget.dart';

/// 발제문 섹션 위젯들
///
/// 운영진용 모임 상세 화면에서 사용되는 발제문 관련 UI 위젯들
class BookQuestionWidgets {
  /// 발제문 섹션 메인 위젯
  static Widget buildBookQuestionSection(
    BuildContext context, {
    required bool isLoading,
    required String? errorMessage,
    required List<BookQuestionModel>? bookQuestionList,
    required int currentUserId,
    required bool hasDiscussionTime,
    required VoidCallback onRefresh,
    Function(BookQuestionModel)? onQuestionTap,
  }) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 섹션 헤더
            _buildSectionHeader(context, onRefresh),
            const SizedBox(height: 16),

            // 내용
            if (!hasDiscussionTime)
              _buildNoDiscussionTimeMessage(context)
            else if (isLoading)
              _buildLoadingState(context)
            else if (errorMessage != null)
              _buildErrorState(context, errorMessage, onRefresh)
            else
              _buildBookQuestionContent(
                context,
                bookQuestionList: bookQuestionList ?? [],
                currentUserId: currentUserId,
                onQuestionTap: onQuestionTap,
              ),
          ],
        ),
      ),
    );
  }

  /// 섹션 헤더
  static Widget _buildSectionHeader(
    BuildContext context,
    VoidCallback onRefresh,
  ) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Icon(Icons.sticky_note_2, color: theme.colorScheme.primary, size: 24),
        const SizedBox(width: 8),
        Text(
          '발제문',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const Spacer(),
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: onRefresh,
          tooltip: '발제문 새로고침',
        ),
      ],
    );
  }

  /// 토론 시간 미설정 안내 메시지
  static Widget _buildNoDiscussionTimeMessage(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            color: theme.colorScheme.onSurfaceVariant,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '토론 시간이 설정되어야 발제문을 확인할 수 있습니다.\n토론 정보 섹션에서 토론 시간을 먼저 설정해주세요.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 로딩 상태
  static Widget _buildLoadingState(BuildContext context) {
    return Container(
      height: 150,
      alignment: Alignment.center,
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('발제문을 불러오는 중...'),
        ],
      ),
    );
  }

  /// 에러 상태
  static Widget _buildErrorState(
    BuildContext context,
    String errorMessage,
    VoidCallback onRetry,
  ) {
    final theme = Theme.of(context);

    return Container(
      height: 150,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.colorScheme.error.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, color: theme.colorScheme.error, size: 32),
          const SizedBox(height: 12),
          Text(
            '발제문을 불러오는 중 오류가 발생했습니다',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.error,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            errorMessage,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.error.withOpacity(0.8),
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh, size: 18),
            label: const Text('다시 시도'),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.error,
              foregroundColor: theme.colorScheme.onError,
            ),
          ),
        ],
      ),
    );
  }

  /// 발제문 내용 표시
  static Widget _buildBookQuestionContent(
    BuildContext context, {
    required List<BookQuestionModel> bookQuestionList,
    required int currentUserId,
    Function(BookQuestionModel)? onQuestionTap,
  }) {
    if (bookQuestionList.isEmpty) {
      return _buildEmptyState(context);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 통계 정보
        _buildStatistics(context, bookQuestionList, currentUserId),
        const SizedBox(height: 16),

        // 포스트잇 발제문 컬렉션 (🆕 정확한 드롭 기능!)
        PostItCollectionWidget(
          bookQuestions: bookQuestionList,
          currentUserId: currentUserId,
          onQuestionTap: onQuestionTap,
        ),

        const SizedBox(height: 12),

        // 도움말
        _buildHelpText(context),
      ],
    );
  }

  /// 통계 정보
  static Widget _buildStatistics(
    BuildContext context,
    List<BookQuestionModel> bookQuestionList,
    int currentUserId,
  ) {
    final theme = Theme.of(context);
    final totalCount = bookQuestionList.length;
    final myCount = bookQuestionList
        .where((q) => q.writerMemberId == currentUserId)
        .length;
    final othersCount = totalCount - myCount;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withOpacity(0.3),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.analytics_outlined,
            size: 16,
            color: theme.colorScheme.onPrimaryContainer,
          ),
          const SizedBox(width: 6),
          Text(
            '총 $totalCount개',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.w500,
            ),
          ),
          // 🔥 본인 발제문 개수 표시 제거 (모두 동일하게 표시)
        ],
      ),
    );
  }

  /// 빈 상태
  static Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: 180,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.3),
          style: BorderStyle.solid,
        ),
        color: theme.colorScheme.surface.withOpacity(0.3),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.sticky_note_2_outlined,
              size: 64,
              color: theme.colorScheme.outline.withOpacity(0.4),
            ),
            const SizedBox(height: 16),
            Text(
              '아직 작성된 발제문이 없습니다',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.outline,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '토론 참여자들이 발제문을 작성하면\n포스트잇 형태로 여기에 표시됩니다',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.outline.withOpacity(0.7),
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// 도움말 텍스트
  static Widget _buildHelpText(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            Icons.touch_app_outlined, // 🆕 터치 아이콘으로 변경
            size: 16,
            color: theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '✨ 포스트잇을 드래그해서 정확한 위치에 드롭할 수 있습니다. 드래그 중에는 드롭존이 표시됩니다.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant.withOpacity(0.8),
                fontSize: 11,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
