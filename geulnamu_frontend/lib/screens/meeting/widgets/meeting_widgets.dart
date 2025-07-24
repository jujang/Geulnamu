import 'package:flutter/material.dart';
import '../../../core/theme.dart';
import '../../../models/meeting/meeting_model.dart';
import '../../../models/meeting/meeting_filter_model.dart';

/// 모임 목록 화면 UI 위젯들
/// 
/// Static Methods로 구현하여 재사용성 극대화
class MeetingWidgets {
  
  /// 모임 카드 위젯
  /// 
  /// [meeting] 모임 정보
  /// [onTap] 카드 탭 콜백 (향후 상세보기 기능)
  /// [onAttendanceCheck] 출석현황 확인 버튼 콜백
  static Widget buildMeetingCard(
    BuildContext context,
    MeetingInfo meeting, {
    VoidCallback? onTap,
    VoidCallback? onAttendanceCheck,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      elevation: 4, // 그림자 강화 (2 -> 4)
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Theme.of(context).brightness == Brightness.light
              ? context.colors.outline.withOpacity(0.2) // 라이트 모드: 미세한 테두리
              : Colors.transparent, // 다크 모드: 테두리 없음
          width: 0.5,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🎯 상단: 모임 제목 + 모임 유형 배지
              Row(
                children: [
                  Expanded(
                    child: Text(
                      meeting.meetingName,
                      style: context.textStyles.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: context.colors.onSurface,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _buildMeetingTypeBadge(context, meeting.meetingType),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // 🎯 정보 행들
              Column(
                children: [
                  // 모임 개최일시 + 모임 장소
                  _buildInfoRow(
                    context,
                    icon: Icons.schedule,
                    label: '개최일시',
                    value: meeting.displayMeetingDateTime,
                    secondIcon: Icons.location_on_outlined,
                    secondLabel: '장소',
                    secondValue: meeting.meetingPlace,
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // 토론 시간 + 모임 개설자
                  _buildInfoRow(
                    context,
                    icon: Icons.chat_bubble_outline,
                    label: '토론시간',
                    value: meeting.displayDiscussionTime,
                    secondIcon: Icons.person_outline,
                    secondLabel: '개설자',
                    secondValue: meeting.meetingCreatorName,
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // 출석 상태 + 모임 번호
                  _buildInfoRow(
                    context,
                    icon: Icons.check_circle_outline,
                    label: '출석상태',
                    value: meeting.attendanceStatusDisplayName,
                    valueColor: _getAttendanceStatusColor(context, meeting.attendanceStatus),
                    secondIcon: Icons.tag,
                    secondLabel: '모임번호',
                    secondValue: '#${meeting.meetingId}',
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // 🎯 하단: 출석현황 확인 버튼
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: onAttendanceCheck,
                  icon: Icon(
                    Icons.people_outline,
                    size: 18,
                    color: context.colors.primary,
                  ),
                  label: Text(
                    '출석현황 확인',
                    style: TextStyle(
                      color: context.colors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: context.colors.primary),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 모임 유형 배지 위젯
  static Widget _buildMeetingTypeBadge(BuildContext context, MeetingType meetingType) {
    Color badgeColor;
    
    switch (meetingType) {
      case MeetingType.regular:
        badgeColor = Colors.blue;
        break;
      case MeetingType.flash:
        badgeColor = Colors.orange;
        break;
      case MeetingType.special:
        badgeColor = Colors.purple;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: badgeColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Text(
        meetingType.displayName,
        style: context.textStyles.labelSmall?.copyWith(
          color: badgeColor,
          fontWeight: FontWeight.w600,
          fontSize: 11,
        ),
      ),
    );
  }

  /// 정보 행 위젯 (2개 정보를 한 행에 표시)
  static Widget _buildInfoRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
    IconData? secondIcon,
    String? secondLabel,
    String? secondValue,
    Color? secondValueColor,
  }) {
    return Row(
      children: [
        // 첫 번째 정보
        Expanded(
          child: Row(
            children: [
              Icon(
                icon,
                size: 18, // 16 -> 18
                color: context.colors.onSurface.withOpacity(0.65), // 0.85 -> 0.65 (더 연하게)
              ),
              const SizedBox(width: 6),
              Text(
                '$label: ',
                style: context.textStyles.bodySmall?.copyWith(
                  color: context.colors.onSurface.withOpacity(0.55), // 0.75 -> 0.55 (더 연하게)
                  fontSize: 14, // 12 -> 14
                  fontWeight: Theme.of(context).brightness == Brightness.light
                      ? FontWeight.w600 // 라이트 모드: 더 진하게
                      : FontWeight.w500, // 다크 모드: 자연스럽게
                ),
              ),
              Expanded(
                child: Text(
                  value,
                  style: context.textStyles.bodySmall?.copyWith(
                    color: valueColor ?? context.colors.onSurface,
                    fontWeight: Theme.of(context).brightness == Brightness.light
                        ? FontWeight.w600 // 라이트 모드: 더 진하게
                        : FontWeight.w500, // 다크 모드: 자연스럽게
                    fontSize: 14, // 12 -> 14
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        
        // 두 번째 정보 (있는 경우)
        if (secondIcon != null && secondLabel != null && secondValue != null) ...[
          const SizedBox(width: 16),
          Expanded(
            child: Row(
              children: [
                Icon(
                  secondIcon,
                  size: 18, // 16 -> 18
                  color: context.colors.onSurface.withOpacity(0.65), // 0.85 -> 0.65 (더 연하게)
                ),
                const SizedBox(width: 6),
                Text(
                  '$secondLabel: ',
                  style: context.textStyles.bodySmall?.copyWith(
                    color: context.colors.onSurface.withOpacity(0.55), // 0.75 -> 0.55 (더 연하게)
                    fontSize: 14, // 12 -> 14
                    fontWeight: Theme.of(context).brightness == Brightness.light
                        ? FontWeight.w600 // 라이트 모드: 더 진하게
                        : FontWeight.w500, // 다크 모드: 자연스럽게
                  ),
                ),
                Expanded(
                  child: Text(
                    secondValue,
                    style: context.textStyles.bodySmall?.copyWith(
                      color: secondValueColor ?? context.colors.onSurface,
                      fontWeight: Theme.of(context).brightness == Brightness.light
                          ? FontWeight.w600 // 라이트 모드: 더 진하게
                          : FontWeight.w500, // 다크 모드: 자연스럽게
                      fontSize: 14, // 12 -> 14
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  /// 출석 상태별 색상 가져오기
  static Color _getAttendanceStatusColor(BuildContext context, AttendanceStatus status) {
    switch (status) {
      case AttendanceStatus.attend:
        return Colors.green;
      case AttendanceStatus.attendLate:
        return Colors.orange;
      case AttendanceStatus.notAttend:
        return Colors.grey; // red -> grey로 변경
      case AttendanceStatus.notStarted: // 새로운 상태 추가
        return Colors.blue;
    }
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

  /// 필터 바텀시트
  static Widget buildFilterBottomSheet(
    BuildContext context, {
    required MeetingListFilter currentFilter,
    required Function(MeetingListFilter) onFilterChanged,
  }) {
    return _FilterBottomSheetContent(
      currentFilter: currentFilter,
      onFilterChanged: onFilterChanged,
    );
  }

  /// 필터 섹션 빌더
  static Widget _buildFilterSection(
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

  /// 페이지네이션 위젯
  static Widget buildPagination(
    BuildContext context, {
    required int currentPage,
    required int totalPages,
    required Function(int) onPageChanged,
  }) {
    if (totalPages <= 1) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 첫 페이지
          IconButton(
            onPressed: currentPage > 1 
                ? () => onPageChanged(1)
                : null,
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
      ),
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
              onTap: i != currentPage 
                  ? () => onPageChanged(i)
                  : null,
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
          CircularProgressIndicator(
            color: context.colors.primary,
          ),
          const SizedBox(height: 16),
          Text(
            '모임 목록을 불러오는 중...',
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
            Icon(
              Icons.error_outline,
              size: 64,
              color: context.colors.error,
            ),
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
              Icons.event_note_outlined,
              size: 64,
              color: context.colors.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              '조건에 맞는 모임이 없습니다',
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
    required MeetingListFilter currentFilter,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '총 ${totalElements}개',
            style: context.textStyles.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: context.colors.onBackground,
            ),
          ),
          Text(
            _getFilterSummary(currentFilter),
            style: context.textStyles.bodySmall?.copyWith(
              color: context.colors.onBackground.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  /// 필터 요약 텍스트 생성
  static String _getFilterSummary(MeetingListFilter filter) {
    final List<String> filterParts = [];

    // 모임 유형 필터
    if (filter.meetingType != MeetingTypeOption.all) {
      filterParts.add(filter.meetingType.displayName);
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
}

/// 🎯 필터 바텀시트 콘텐츠 위젯 (StatefulWidget으로 분리)
class _FilterBottomSheetContent extends StatefulWidget {
  final MeetingListFilter currentFilter;
  final Function(MeetingListFilter) onFilterChanged;

  const _FilterBottomSheetContent({
    required this.currentFilter,
    required this.onFilterChanged,
  });

  @override
  State<_FilterBottomSheetContent> createState() => _FilterBottomSheetContentState();
}

class _FilterBottomSheetContentState extends State<_FilterBottomSheetContent> {
  late MeetingTypeOption selectedMeetingType;
  late bool selectedTodayMeeting; // 🎯 null 제거
  late AttendanceStatusOption selectedAttendanceStatus;
  late SortByOption selectedSort;
  late bool isAscending;

  @override
  void initState() {
    super.initState();
    selectedMeetingType = widget.currentFilter.meetingType;
    selectedTodayMeeting = widget.currentFilter.isTodayMeeting;
    selectedAttendanceStatus = widget.currentFilter.attendanceStatus;
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
              selectedTodayMeeting = false; // 🎯 초기화 시 false
              selectedAttendanceStatus = AttendanceStatusOption.all;
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
          MeetingWidgets._buildFilterSection(
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
                      selectedMeetingType = selected ? option : MeetingTypeOption.all;
                    });
                  },
                  selectedColor: context.colors.primary.withOpacity(0.2),
                  checkmarkColor: context.colors.primary,
                  backgroundColor: context.colors.surfaceVariant,
                );
              }).toList(),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // 오늘 모임 필터
          MeetingWidgets._buildFilterSection(
            context,
            title: '오늘 개최 모임',
            child: Wrap(
              spacing: 8,
              children: [
                FilterChip(
                  label: const Text('전체'),
                  selected: selectedTodayMeeting == false, // 🎯 false = 전체
                  onSelected: (selected) {
                    setState(() {
                      selectedTodayMeeting = false; // 🎯 전체 = false
                    });
                  },
                  selectedColor: context.colors.primary.withOpacity(0.2),
                  checkmarkColor: context.colors.primary,
                  backgroundColor: context.colors.surfaceVariant,
                ),
                FilterChip(
                  label: const Text('오늘 모임만'),
                  selected: selectedTodayMeeting == true,
                  onSelected: (selected) {
                    setState(() {
                      selectedTodayMeeting = true; // 🎯 오늘 모임만 = true
                    });
                  },
                  selectedColor: context.colors.primary.withOpacity(0.2),
                  checkmarkColor: context.colors.primary,
                  backgroundColor: context.colors.surfaceVariant,
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // 참석 상태 필터
          MeetingWidgets._buildFilterSection(
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
                      selectedAttendanceStatus = selected ? option : AttendanceStatusOption.all;
                    });
                  },
                  selectedColor: context.colors.primary.withOpacity(0.2),
                  checkmarkColor: context.colors.primary,
                  backgroundColor: context.colors.surfaceVariant,
                );
              }).toList(),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // 정렬
          MeetingWidgets._buildFilterSection(
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
                          selectedSort = selected ? option : SortByOption.meetingDate;
                        });
                      },
                      selectedColor: context.colors.primary.withOpacity(0.2),
                      checkmarkColor: context.colors.primary,
                      backgroundColor: context.colors.surfaceVariant,
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
                      backgroundColor: context.colors.surfaceVariant,
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
                      backgroundColor: context.colors.surfaceVariant,
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
