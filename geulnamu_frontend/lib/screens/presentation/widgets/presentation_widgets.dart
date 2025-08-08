import 'package:flutter/material.dart';
import '../../../core/theme.dart';
import '../../../models/presentation/presentation_model.dart';
import '../../../models/presentation/presentation_filter_model.dart';

/// 발제문 관련 UI 위젯들 (실제 책 모양 디자인)
///
/// Static Methods로 구현하여 재사용성 극대화
class PresentationWidgets {
  /// 📖 실제 책 모양 발제문 카드
  static Widget buildBookCard(
    BuildContext context,
    PresentationInfo presentation, {
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 160, // 책 너비 확대 (140 → 160)
        height: 200, // 책 높이 확대 (180 → 200)
        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        child: Stack(
          children: [
            // 📖 책 본체 (입체감)
            Positioned(
              left: 8,
              top: 0,
              right: 0,
              bottom: 8,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  color: _getBookColor(context, presentation.presentationType), // 단색으로 변경
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.25),
                      blurRadius: 8,
                      offset: const Offset(3, 3),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    // 📚 책 표지 효과
                    _buildBookCover(context),
                    
                    // 📄 책 내용
                    _buildBookContent(context, presentation),
                  ],
                ),
              ),
            ),
            
            // 📖 책 옆면/등 (진짜 책처럼)
            Positioned(
              left: 0,
              top: 4,
              bottom: 12,
              width: 12,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(4),
                    bottomLeft: Radius.circular(4),
                  ),
                  gradient: LinearGradient(
                    colors: [
                      _getDarkerBookColor(context, presentation.presentationType),
                      _getDarkerBookColor(context, presentation.presentationType).withValues(alpha: 0.8),
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 4,
                      offset: const Offset(2, 2),
                    ),
                  ],
                ),
                // 📄 책 등 선들
                child: Column(
                  children: [
                    const SizedBox(height: 8),
                    Container(
                      height: 1,
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      color: Colors.black.withValues(alpha: 0.2),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      height: 1,
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      color: Colors.black.withValues(alpha: 0.2),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 📚 책 표지 효과
  static Widget _buildBookCover(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        gradient: LinearGradient(
          colors: [
            Colors.white.withValues(alpha: 0.15),
            Colors.transparent,
            Colors.black.withValues(alpha: 0.08),
          ],
          stops: const [0.0, 0.3, 1.0],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      // 📄 책 표지 선들
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            height: 1,
            margin: const EdgeInsets.symmetric(horizontal: 12),
            color: Colors.white.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 6),
          Container(
            height: 1,
            margin: const EdgeInsets.symmetric(horizontal: 12),
            color: Colors.white.withValues(alpha: 0.2),
          ),
        ],
      ),
    );
  }

  /// 📄 책 내용 (제목, 정보들)
  static Widget _buildBookContent(BuildContext context, PresentationInfo presentation) {
    return Padding(
      padding: const EdgeInsets.all(12), // 패딩 증가 (10 → 12)
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16), // 상단 여백 줄임 (20 → 16)
          
          // 📖 발제문 제목 (실제 책 제목처럼)
          Expanded(
            flex: 3, // 제목 영역 비율 증가
            child: Center(
              child: Text(
                presentation.bookTitle,
                style: context.textStyles.titleSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  height: 1.3, // 줄간격 증가 (1.2 → 1.3)
                  fontSize: 14, // 폰트 크기 증가 (13 → 14)
                ),
                maxLines: 5, // 최대 줄 수 증가 (4 → 5)
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),
          ),
          
          const SizedBox(height: 8), // 간격 조정
          
          // 📅 모임 종류 & 모임일자 (첫 번째 줄)
          Text(
            '${presentation.presentationTypeDisplayName} · ${presentation.displayMeetingDate}',
            style: context.textStyles.bodySmall?.copyWith(
              color: Colors.white.withValues(alpha: 0.9),
              fontWeight: FontWeight.w500,
              fontSize: 11, // 폰트 크기 증가 (10 → 11)
            ),
          ),
          
          const SizedBox(height: 4), // 간격 증가 (2 → 4)
          
          // 🏷️ #모임번호 & 모임 생성자 (두 번째 줄)
          Row(
            children: [
              Icon(
                Icons.tag,
                size: 12, // 아이콘 크기 증가 (10 → 12)
                color: Colors.white.withValues(alpha: 0.8),
              ),
              const SizedBox(width: 4), // 간격 증가 (2 → 4)
              Expanded(
                child: Text(
                  '${presentation.meetingId} · ${presentation.meetingCreatorName}',
                  style: context.textStyles.bodySmall?.copyWith(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 11, // 폰트 크기 증가 (9 → 11)
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

  /// 📚 발제문 유형별 어두운 책 색상 (책등용)
  static Color _getDarkerBookColor(BuildContext context, PresentationType type) {
    switch (type) {
      case PresentationType.regular:
        return const Color(0xFF5AB59F); // 어두운 민트색
      case PresentationType.flash:
        return const Color(0xFFB8935D); // 어두운 베이지
      case PresentationType.special:
        return const Color(0xFF8FA373); // 어두운 초록
    }
  }

  /// 📚 발제문 유형별 책 그라디언트 (민트+베이지 조합)
  static LinearGradient _getBookGradient(BuildContext context, PresentationType type) {
    final baseColor = _getBookColor(context, type);
    
    // 실제 책처럼 자연스러운 그라디언트
    return LinearGradient(
      colors: [
        baseColor,
        baseColor.withValues(alpha: 0.95),
        const Color(0xFFF5F1E8).withValues(alpha: 0.1), // 베이지 특색 살짝
        baseColor.withValues(alpha: 0.9),
      ],
      stops: const [0.0, 0.3, 0.7, 1.0],
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
              color: context.colors.surfaceVariant.withValues(alpha: 0.5),
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
                  '발제문 유형, 날짜별 필터링',
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
