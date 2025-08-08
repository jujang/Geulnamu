import 'package:flutter/material.dart';
import '../../../core/theme.dart';
import '../../../models/presentation/presentation_model.dart';
import '../../../models/presentation/presentation_filter_model.dart';

/// 발제문 관련 UI 위젯들 (책 모양 디자인)
///
/// Static Methods로 구현하여 재사용성 극대화
class PresentationWidgets {
  /// 📖 책 모양 발제문 카드
  static Widget buildBookCard(
    BuildContext context,
    PresentationInfo presentation, {
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 160, // 책 너비 고정
        height: 220, // 책 높이 고정
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 8,
              offset: const Offset(2, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            // 📚 메인 책 표지
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                gradient: _getBookGradient(
                  context,
                  presentation.presentationType,
                ),
              ),
              child: Stack(
                children: [
                  // 📖 책 텍스처 효과
                  _buildBookTexture(context),

                  // 📄 책 내용
                  _buildBookContent(context, presentation),
                ],
              ),
            ),

            // 📖 책 옆면/등 효과 (3D 느낌)
            Positioned(
              right: 0,
              top: 4,
              bottom: 4,
              child: Container(
                width: 6,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(8),
                    bottomRight: Radius.circular(8),
                  ),
                  gradient: LinearGradient(
                    colors: [
                      _getBookColor(
                        context,
                        presentation.presentationType,
                      ).withValues(alpha: 0.7),
                      _getBookColor(
                        context,
                        presentation.presentationType,
                      ).withValues(alpha: 0.4),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 📚 책 텍스처 효과
  static Widget _buildBookTexture(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withValues(alpha: 0.1),
            Colors.transparent,
            Colors.black.withValues(alpha: 0.05),
          ],
          stops: const [0.0, 0.5, 1.0],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
    );
  }

  /// 📄 책 내용 (제목, 정보들)
  static Widget _buildBookContent(
    BuildContext context,
    PresentationInfo presentation,
  ) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 📖 책 제목 (세로 레이아웃에 맞게 조정)
          Row(
            children: [
              Icon(
                Icons.menu_book_rounded,
                size: 16,
                color: Colors.white.withValues(alpha: 0.9),
              ),
              const SizedBox(width: 4),
            ],
          ),

          const SizedBox(height: 8),

          // 📖 발제문 제목 (세로 레이아웃에 맞게)
          Expanded(
            child: Text(
              presentation.bookTitle,
              style: context.textStyles.titleSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                height: 1.3,
              ),
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          const Spacer(),

          // 📅 모임 날짜 (세로 레이아웃용)
          Text(
            presentation.displayMeetingDate,
            style: context.textStyles.bodySmall?.copyWith(
              color: Colors.white.withValues(alpha: 0.9),
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: 4),

          // 🏷️ 발제문 유형
          Row(
            children: [
              Icon(
                _getPresentationTypeIcon(presentation.presentationType),
                size: 12,
                color: Colors.white.withValues(alpha: 0.8),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  presentation.presentationTypeDisplayName,
                  style: context.textStyles.bodySmall?.copyWith(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 11,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),

          const SizedBox(height: 4),

          // 👤 작성자
          Row(
            children: [
              Icon(
                Icons.person,
                size: 12,
                color: Colors.white.withValues(alpha: 0.8),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  presentation.meetingCreatorName,
                  style: context.textStyles.bodySmall?.copyWith(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 11,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 📚 발제문 유형별 책 색상 (민트+베이지 조합)
  static Color _getBookColor(BuildContext context, PresentationType type) {
    switch (type) {
      case PresentationType.regular:
        return const Color(0xFF7DD3C0); // 민트색
      case PresentationType.flash:
        return const Color(0xFFD4A574); // 따뜻한 베이지
      case PresentationType.special:
        return const Color(0xFFA8C08A); // 연한 초록
    }
  }

  /// 📚 발제문 유형별 책 그라데이션
  static LinearGradient _getBookGradient(
    BuildContext context,
    PresentationType type,
  ) {
    final baseColor = _getBookColor(context, type);

    return LinearGradient(
      colors: [
        baseColor,
        baseColor.withValues(alpha: 0.8),
        baseColor.withValues(alpha: 0.9),
      ],
      stops: const [0.0, 0.6, 1.0],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  /// 🏷️ 발제문 유형별 아이콘
  static IconData _getPresentationTypeIcon(PresentationType type) {
    switch (type) {
      case PresentationType.regular:
        return Icons.schedule;
      case PresentationType.flash:
        return Icons.flash_on;
      case PresentationType.special:
        return Icons.star;
    }
  }

  /// 📖 필터 바텀시트
  static Widget buildFilterBottomSheet(
    BuildContext context, {
    required PresentationListFilter currentFilter,
    required Function(PresentationListFilter) onFilterChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 헤더
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '발제문 필터',
                style: context.textStyles.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // 임시 필터 UI (향후 구현)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: context.colors.surfaceContainerHighest.withOpacity(0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.tune,
                  size: 48,
                  color: context.colors.onSurfaceVariant,
                ),
                const SizedBox(height: 8),
                Text(
                  '필터 기능 구현 예정',
                  style: context.textStyles.bodyLarge?.copyWith(
                    color: context.colors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '발제문 유형, 날짜, 출석상태별 필터링',
                  style: context.textStyles.bodySmall?.copyWith(
                    color: context.colors.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // 확인 버튼
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('확인'),
            ),
          ),

          // 하단 안전 영역
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
