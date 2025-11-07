import 'package:flutter/material.dart';
import '../../../core/theme.dart';
import '../../../models/presentation/presentation_filter_model.dart';

/// 발제문 필터 관련 UI 위젯들
///
/// 모임 필터와 유사한 구조로 구현
/// Static Methods로 구현하여 재사용성 극대화
class PresentationFilterWidgets {
  /// 필터 바텀시트
  static Widget buildFilterBottomSheet(
    BuildContext context, {
    required PresentationListFilter currentFilter,
    required Function(PresentationListFilter) onFilterChanged,
  }) {
    return _FilterBottomSheetContent(
      currentFilter: currentFilter,
      onFilterChanged: onFilterChanged,
    );
  }

  /// 필터 섹션 빌더
  static Widget buildFilterSection(
    BuildContext context, {
    required String title,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: context.textStyles.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: context.colors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}

/// 🎯 필터 바텀시트 콘텐츠 위젯 (StatefulWidget으로 분리)
class _FilterBottomSheetContent extends StatefulWidget {
  final PresentationListFilter currentFilter;
  final Function(PresentationListFilter) onFilterChanged;

  const _FilterBottomSheetContent({
    required this.currentFilter,
    required this.onFilterChanged,
  });

  @override
  State<_FilterBottomSheetContent> createState() =>
      _FilterBottomSheetContentState();
}

class _FilterBottomSheetContentState extends State<_FilterBottomSheetContent> {
  late PresentationTypeOption selectedPresentationType;
  late PresentationSortBy selectedSort;
  late bool isAscending;
  late int selectedPageSize;

  @override
  void initState() {
    super.initState();
    selectedPresentationType = widget.currentFilter.presentationType;
    selectedSort = widget.currentFilter.sortBy;
    isAscending = widget.currentFilter.isAsc;
    selectedPageSize = widget.currentFilter.size;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 헤더
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '필터 및 정렬',
                style: context.textStyles.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    selectedPresentationType = PresentationTypeOption.all;
                    selectedSort = PresentationSortBy.meetingDate;
                    isAscending = false;
                    selectedPageSize = 12; // 🎯 기본값 12개
                  });
                },
                child: Text(
                  '초기화',
                  style: TextStyle(color: context.colors.primary),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // 모임 유형 필터
          PresentationFilterWidgets.buildFilterSection(
            context,
            title: '모임 유형',
            child: Wrap(
              spacing: 8,
              children: PresentationTypeOption.values.map((option) {
                final isSelected = selectedPresentationType == option;
                return FilterChip(
                  label: Text(option.displayName),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      selectedPresentationType = selected
                          ? option
                          : PresentationTypeOption.all;
                    });
                  },
                  selectedColor: context.colors.primary.withOpacity(0.2),
                  checkmarkColor: context.colors.primary,
                  backgroundColor: context.colors.surfaceContainerHighest,
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 16),

          // 정렬
          PresentationFilterWidgets.buildFilterSection(
            context,
            title: '정렬',
            child: Column(
              children: [
                // 정렬 기준
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: PresentationSortBy.values.map((option) {
                    final isSelected = selectedSort == option;
                    return FilterChip(
                      label: Text(option.displayName),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          selectedSort = selected
                              ? option
                              : PresentationSortBy.meetingDate;
                        });
                      },
                      selectedColor: context.colors.primary.withOpacity(0.2),
                      checkmarkColor: context.colors.primary,
                      backgroundColor: context.colors.surfaceContainerHighest,
                    );
                  }).toList(),
                ),

                const SizedBox(height: 8),

                // 정렬 순서
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ChoiceChip(
                      label: const Text('오름차순'),
                      selected: isAscending,
                      onSelected: (selected) {
                        if (selected) {
                          setState(() {
                            isAscending = true;
                          });
                        }
                      },
                      selectedColor: context.colors.primary.withOpacity(0.2),
                      backgroundColor: context.colors.surfaceContainerHighest,
                    ),
                    const SizedBox(width: 8),
                    ChoiceChip(
                      label: const Text('내림차순'),
                      selected: !isAscending,
                      onSelected: (selected) {
                        if (selected) {
                          setState(() {
                            isAscending = false;
                          });
                        }
                      },
                      selectedColor: context.colors.primary.withOpacity(0.2),
                      backgroundColor: context.colors.surfaceContainerHighest,
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // 페이지당 항목 수
          PresentationFilterWidgets.buildFilterSection(
            context,
            title: '한 페이지에 보이는 발제문 개수',
            child: Wrap(
              spacing: 8,
              children: [6, 12].map((size) {
                final isSelected = selectedPageSize == size;
                return ChoiceChip(
                  label: Text('${size}개'),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        selectedPageSize = size;
                      });
                    }
                  },
                  selectedColor: context.colors.primary.withOpacity(0.2),
                  backgroundColor: context.colors.surfaceContainerHighest,
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 24),

          // 적용 버튼
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                final newFilter = PresentationListFilter(
                  presentationType: selectedPresentationType,
                  sortBy: selectedSort,
                  isAsc: isAscending,
                  size: selectedPageSize,
                );

                Navigator.pop(context);
                widget.onFilterChanged(newFilter);
              },
              child: const Text('적용'),
            ),
          ),

          // 하단 여백 (키보드 대응)
          SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
        ],
      ),
    );
  }
}
