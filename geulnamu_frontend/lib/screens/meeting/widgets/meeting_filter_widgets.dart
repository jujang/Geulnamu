import 'package:flutter/material.dart';
import '../../../core/theme.dart';
import '../../../models/meeting/meeting_filter_model.dart';

/// 모임 필터 관련 UI 위젯들
///
/// Static Methods로 구현하여 재사용성 극대화
class MeetingFilterWidgets {
  /// 필터 바텀시트 (일반 사용자용)
  static Widget buildFilterBottomSheet(
    BuildContext context, {
    required MeetingListFilter currentFilter,
    required Function(MeetingListFilter) onFilterChanged,
  }) {
    return _FilterBottomSheetContent(
      currentFilter: currentFilter,
      onFilterChanged: onFilterChanged,
      isAdminMode: false, // 일반 모드
    );
  }

  /// 필터 바텀시트 (운영진용)
  static Widget buildAdminFilterBottomSheet(
    BuildContext context, {
    required MeetingListFilter currentFilter,
    required Function(MeetingListFilter) onFilterChanged,
  }) {
    return _FilterBottomSheetContent(
      currentFilter: currentFilter,
      onFilterChanged: onFilterChanged,
      isAdminMode: true, // 운영진 모드
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
  final MeetingListFilter currentFilter;
  final Function(MeetingListFilter) onFilterChanged;
  final bool isAdminMode; // 운영진 모드 여부

  const _FilterBottomSheetContent({
    required this.currentFilter,
    required this.onFilterChanged,
    this.isAdminMode = false, // 기본값: 일반 모드
  });

  @override
  State<_FilterBottomSheetContent> createState() =>
      _FilterBottomSheetContentState();
}

class _FilterBottomSheetContentState extends State<_FilterBottomSheetContent> {
  late MeetingTypeOption selectedMeetingType;
  late bool selectedTodayMeeting;
  late AttendanceStatusOption selectedAttendanceStatus;
  late PrivacyStatusOption selectedPrivacyStatus; // 운영진용
  late SortByOption selectedSort;
  late bool isAscending;

  @override
  void initState() {
    super.initState();
    selectedMeetingType = widget.currentFilter.meetingType;
    selectedTodayMeeting = widget.currentFilter.isTodayMeeting;
    selectedAttendanceStatus = widget.currentFilter.attendanceStatus;
    selectedPrivacyStatus = widget.currentFilter.privacyStatus;
    selectedSort = widget.currentFilter.sortBy;
    isAscending = widget.currentFilter.isAsc;
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
                    selectedMeetingType = MeetingTypeOption.all;
                    selectedTodayMeeting = false;
                    selectedAttendanceStatus = AttendanceStatusOption.all;
                    selectedPrivacyStatus = PrivacyStatusOption.all;
                    selectedSort = SortByOption.meetingDate;
                    isAscending = false;
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
          MeetingFilterWidgets.buildFilterSection(
            context,
            title: '모임 유형',
            child: Wrap(
              spacing: 8,
              children: MeetingTypeOption.values.map((option) {
                final isSelected = selectedMeetingType == option;
                return FilterChip(
                  label: Text(option.displayName),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      selectedMeetingType = selected
                          ? option
                          : MeetingTypeOption.all;
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

          // 오늘 모임 필터
          MeetingFilterWidgets.buildFilterSection(
            context,
            title: '오늘 개최 모임',
            child: Wrap(
              spacing: 8,
              children: [
                FilterChip(
                  label: const Text('전체'),
                  selected: selectedTodayMeeting == false,
                  onSelected: (selected) {
                    setState(() {
                      selectedTodayMeeting = false;
                    });
                  },
                  selectedColor: context.colors.primary.withOpacity(0.2),
                  checkmarkColor: context.colors.primary,
                  backgroundColor: context.colors.surfaceContainerHighest,
                ),
                FilterChip(
                  label: const Text('오늘 모임만'),
                  selected: selectedTodayMeeting == true,
                  onSelected: (selected) {
                    setState(() {
                      selectedTodayMeeting = true;
                    });
                  },
                  selectedColor: context.colors.primary.withOpacity(0.2),
                  checkmarkColor: context.colors.primary,
                  backgroundColor: context.colors.surfaceContainerHighest,
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // 운영진 모드에서만 비공개 여부 필터 표시
          if (widget.isAdminMode) ...[
            // 비공개 여부 필터
            MeetingFilterWidgets.buildFilterSection(
              context,
              title: '공개 상태',
              child: Wrap(
                spacing: 8,
                children: PrivacyStatusOption.values.map((option) {
                  final isSelected = selectedPrivacyStatus == option;
                  return FilterChip(
                    label: Text(option.displayName),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        selectedPrivacyStatus = selected
                            ? option
                            : PrivacyStatusOption.all;
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
          ],

          // 일반 모드에서만 참석 상태 필터 표시
          if (!widget.isAdminMode) ...[
            // 참석 상태 필터
            MeetingFilterWidgets.buildFilterSection(
              context,
              title: '참석 상태',
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: AttendanceStatusOption.values.map((option) {
                  final isSelected = selectedAttendanceStatus == option;
                  return FilterChip(
                    label: Text(option.displayName),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        selectedAttendanceStatus = selected
                            ? option
                            : AttendanceStatusOption.all;
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
          ],

          // 정렬 (모든 모드에서 공통)
          MeetingFilterWidgets.buildFilterSection(
            context,
            title: '정렬',
            child: Column(
              children: [
                // 정렬 기준
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: SortByOption.values.map((option) {
                    final isSelected = selectedSort == option;
                    return FilterChip(
                      label: Text(option.displayName),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          selectedSort = selected
                              ? option
                              : SortByOption.meetingDate;
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

          const SizedBox(height: 24),

          // 적용 버튼
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                final newFilter = MeetingListFilter(
                  meetingType: selectedMeetingType,
                  isTodayMeeting: selectedTodayMeeting,
                  attendanceStatus: selectedAttendanceStatus,
                  privacyStatus: selectedPrivacyStatus,
                  sortBy: selectedSort,
                  isAsc: isAscending,
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
