import 'package:flutter/material.dart';
import '../../../core/theme.dart';
import '../../../models/voc/voc_model.dart';
import '../../../models/voc/voc_filter_model.dart';

/// VoC 필터 관련 UI 위젯들
class VoCFilterWidgets {
  /// 필터 바텀시트
  static Widget buildFilterBottomSheet(
    BuildContext context, {
    required VoCFilter currentFilter,
    required Function(VoCFilter) onFilterChanged,
  }) {
    return _FilterBottomSheetContent(
      currentFilter: currentFilter,
      onFilterChanged: onFilterChanged,
    );
  }
}

/// 필터 바텀시트 콘텐츠
class _FilterBottomSheetContent extends StatefulWidget {
  final VoCFilter currentFilter;
  final Function(VoCFilter) onFilterChanged;

  const _FilterBottomSheetContent({
    required this.currentFilter,
    required this.onFilterChanged,
  });

  @override
  State<_FilterBottomSheetContent> createState() =>
      _FilterBottomSheetContentState();
}

class _FilterBottomSheetContentState extends State<_FilterBottomSheetContent> {
  late IssueStatus? selectedIssueStatus;
  late VoCType? selectedVoCType;
  late VoCSortBy selectedSortBy;
  late bool isAscending;
  late int pageSize;

  @override
  void initState() {
    super.initState();
    selectedIssueStatus = widget.currentFilter.issueStatus;
    selectedVoCType = widget.currentFilter.voCType;
    selectedSortBy = widget.currentFilter.sortBy;
    isAscending = widget.currentFilter.isAsc;
    pageSize = widget.currentFilter.size;
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
                  // 🆕 반응형 기본값 사용
                  final defaultSize = widget.currentFilter.size; // 현재 반응형 크기 유지
                  setState(() {
                    selectedIssueStatus = null;
                    selectedVoCType = null;
                    selectedSortBy = VoCSortBy.id;
                    isAscending = false;
                    pageSize = defaultSize;
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

          // 이슈 유형 필터
          _buildFilterSection(
            context,
            title: '이슈 유형',
            child: Wrap(
              spacing: 8,
              children: [
                FilterChip(
                  label: const Text('전체'),
                  selected: selectedVoCType == null,
                  onSelected: (selected) {
                    setState(() {
                      selectedVoCType = null;
                    });
                  },
                  selectedColor: context.colors.primary.withOpacity(0.2),
                  checkmarkColor: context.colors.primary,
                  backgroundColor: context.colors.surfaceContainerHighest,
                ),
                ...VoCType.values.map((type) {
                  final isSelected = selectedVoCType == type;
                  return FilterChip(
                    label: Text('${type.icon} ${type.displayName}'),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        selectedVoCType = selected ? type : null;
                      });
                    },
                    selectedColor: context.colors.primary.withOpacity(0.2),
                    checkmarkColor: context.colors.primary,
                    backgroundColor: context.colors.surfaceContainerHighest,
                  );
                }),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // 이슈 상태 필터
          _buildFilterSection(
            context,
            title: '이슈 상태',
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilterChip(
                  label: const Text('전체'),
                  selected: selectedIssueStatus == null,
                  onSelected: (selected) {
                    setState(() {
                      selectedIssueStatus = null;
                    });
                  },
                  selectedColor: context.colors.primary.withOpacity(0.2),
                  checkmarkColor: context.colors.primary,
                  backgroundColor: context.colors.surfaceContainerHighest,
                ),
                ...IssueStatus.values.map((status) {
                  final isSelected = selectedIssueStatus == status;
                  return FilterChip(
                    label: Text('${status.icon} ${status.displayName}'),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        selectedIssueStatus = selected ? status : null;
                      });
                    },
                    selectedColor: context.colors.primary.withOpacity(0.2),
                    checkmarkColor: context.colors.primary,
                    backgroundColor: context.colors.surfaceContainerHighest,
                  );
                }),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // 정렬
          _buildFilterSection(
            context,
            title: '정렬',
            child: Column(
              children: [
                // 정렬 기준
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: VoCSortBy.values.map((sortBy) {
                    final isSelected = selectedSortBy == sortBy;
                    return FilterChip(
                      label: Text(sortBy.displayName),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          selectedSortBy = selected ? sortBy : VoCSortBy.id;
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

          // 페이지 크기
          _buildFilterSection(
            context,
            title: '한 페이지에 보이는 이슈 개수',
            child: Wrap(
              spacing: 8,
              children: [8, 10].map((size) {
                final isSelected = pageSize == size;
                return ChoiceChip(
                  label: Text('$size개'),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        pageSize = size;
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
                final newFilter = VoCFilter(
                  issueStatus: selectedIssueStatus,
                  voCType: selectedVoCType,
                  sortBy: selectedSortBy,
                  isAsc: isAscending,
                  size: pageSize,
                );

                Navigator.pop(context);
                widget.onFilterChanged(newFilter);
              },
              child: const Text('적용'),
            ),
          ),

          // 하단 여백
          SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
        ],
      ),
    );
  }

  Widget _buildFilterSection(
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
