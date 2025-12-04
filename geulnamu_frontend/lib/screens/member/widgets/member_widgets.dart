import 'package:flutter/material.dart';
import '../../../core/theme.dart';
import '../../../models/member/member_list_model.dart';

/// 모임원 목록 화면 UI 위젯들
/// 
/// Static Methods로 구현하여 재사용성 극대화
class MemberWidgets {
  
  /// 모임원 카드 위젯
  /// 
  /// [member] 모임원 정보
  /// [onTap] 카드 탭 콜백 (향후 상세보기 기능)
  static Widget buildMemberCard(
    BuildContext context,
    MemberListItem member, {
    VoidCallback? onTap,
  }) {
    final isActive = member.isActive;
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      elevation: isActive ? null : 0,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: isActive 
                ? null 
                : context.colors.surfaceVariant.withOpacity(0.3),
            border: isActive
                ? null
                : Border.all(
                    color: context.colors.outline.withOpacity(0.3),
                    width: 1,
                  ),
          ),
          child: Row(
            children: [
              // 🎯 첫 번째 열: 이름, 닉네임, 성별, 생년월일
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 이름 + 닉네임
                    Row(
                      children: [
                        Text(
                          member.displayName,
                          style: context.textStyles.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: isActive 
                                ? context.colors.onSurface
                                : context.colors.onSurface.withOpacity(0.5),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Flexible(  // 🎯 추가: 닉네임을 Flexible로 감싸기
                          child: Text(
                            '(${member.nickname})',
                            overflow: TextOverflow.ellipsis,  // 🎯 추가: 넘치면 ...
                            style: context.textStyles.bodySmall?.copyWith(
                              color: isActive
                                  ? context.colors.onSurfaceVariant
                                  : context.colors.onSurfaceVariant.withOpacity(0.5),
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 6),
                    
                    // 성별 + 생년월일
                    Row(
                      children: [
                        Icon(
                          member.gender == 'MALE' 
                              ? Icons.male 
                              : member.gender == 'FEMALE'
                                  ? Icons.female
                                  : Icons.help_outline,
                          size: 14,
                          color: isActive
                              ? context.colors.onSurfaceVariant
                              : context.colors.onSurfaceVariant.withOpacity(0.5),
                        ),
                        const SizedBox(width: 3),
                        Text(
                          member.genderDisplayName,
                          style: context.textStyles.bodySmall?.copyWith(
                            color: isActive
                                ? context.colors.onSurfaceVariant
                                : context.colors.onSurfaceVariant.withOpacity(0.5),
                          ),
                        ),
                        
                        const SizedBox(width: 12),
                        
                        Icon(
                          Icons.cake_outlined,
                          size: 14,
                          color: isActive
                              ? context.colors.onSurfaceVariant
                              : context.colors.onSurfaceVariant.withOpacity(0.5),
                        ),
                        const SizedBox(width: 3),
                        Expanded(
                          child: Text(
                            member.displayBirthDate,
                            style: context.textStyles.bodySmall?.copyWith(
                              color: isActive
                                  ? context.colors.onSurfaceVariant
                                  : context.colors.onSurfaceVariant.withOpacity(0.5),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              const SizedBox(width: 12),
              
              // 🎯 두 번째 열: 권한 배지 + 모임원 ID (정밀한 정렬)
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.only(right: 3), // 🎯 우측 여백 4 → 3으로 수정
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // 🎯 권한 배지 (이름/닉네임과 정확히 같은 높이)
                      SizedBox(
                        height: 26, // 🎯 높이 증가: 20 → 26 (배지가 짤리지 않도록)
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: _buildRoleBadge(context, member.roleDisplayName, isActive),
                        ),
                      ),
                      
                      const SizedBox(height: 10), // 🎯 간격 증가: 6 → 10
                      
                      // 🎯 모임원 ID (성별/생년월일과 같은 높이, 추가 패딩)
                      Padding(
                        padding: const EdgeInsets.only(right: 3), // 🎯 ID만 추가 패딩 3
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            '#${member.memberId}',
                            style: context.textStyles.bodySmall?.copyWith(
                              color: isActive
                                  ? context.colors.outline
                                  : context.colors.outline.withOpacity(0.5),
                              fontFamily: 'monospace',
                              fontSize: 11,
                              height: 1.0, // 라인 높이 조정
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 권한 배지 위젯
  static Widget _buildRoleBadge(BuildContext context, String role, bool isActive) {
    Color badgeColor;
    
    // 권한별 색상 설정
    switch (role) {
      case '모임장':
        badgeColor = Colors.purple;
        break;
      case '부모임장':
        badgeColor = Colors.indigo;
        break;
      case '관리자':
        badgeColor = Colors.red;
        break;
      case '운영진':
        badgeColor = Colors.orange;
        break;
      case '준운영진':
        badgeColor = Colors.blue;
        break;
      default:
        badgeColor = Colors.grey;
    }

    if (!isActive) {
      badgeColor = badgeColor.withOpacity(0.3);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4), // 🎯 패딩 조정: 원래 6,3에서 살짝만 증가
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(11), // 🎯 둥근 모서리 조정: 10에서 살짝만 증가
        border: Border.all(
          color: badgeColor.withOpacity(isActive ? 0.3 : 0.2),
          width: 1,
        ),
      ),
      child: Text(
        role,
        style: context.textStyles.labelSmall?.copyWith(
          color: badgeColor,
          fontWeight: FontWeight.w600,
          fontSize: 10,
        ),
      ),
    );
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
    required MemberListFilter currentFilter,
    required Function(MemberListFilter) onFilterChanged,
    required bool canShowDeletedFilter,
  }) {
    return _FilterBottomSheetContent(
      currentFilter: currentFilter,
      onFilterChanged: onFilterChanged,
      canShowDeletedFilter: canShowDeletedFilter,
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
            '모임원 목록을 불러오는 중...',
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
              Icons.people_outline,
              size: 64,
              color: context.colors.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              '조건에 맞는 모임원이 없습니다',
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
    required MemberListFilter currentFilter,
    VoidCallback? onFilterTap,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '총 ${totalElements}명',
            style: context.textStyles.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              // 🎯 다크모드 대비 강화: 더 밝은 텍스트 색상 사용
              color: context.colors.onBackground,
            ),
          ),
          // 🎯 필터 텍스트를 탭 가능하게 변경
          InkWell(
            onTap: onFilterTap,
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _getFilterSummary(currentFilter),
                    style: context.textStyles.bodySmall?.copyWith(
                      // 🎯 다크모드 대비 강화: onSurfaceVariant 대신 onBackground 사용
                      color: context.colors.onBackground.withOpacity(0.7),
                    ),
                  ),
                  if (onFilterTap != null) ...[
                    const SizedBox(width: 4),
                    Icon(
                      Icons.tune,
                      size: 14,
                      color: context.colors.onBackground.withOpacity(0.7),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 필터 요약 텍스트 생성
  static String _getFilterSummary(MemberListFilter filter) {
    final List<String> filterParts = [];

    // 성별 필터
    final gender = GenderOption.fromValue(filter.gender);
    if (gender != GenderOption.all) {
      filterParts.add(gender.displayName);
    }

    // 권한 필터
    final role = RoleOption.fromValue(filter.role);
    if (role != RoleOption.all) {
      filterParts.add(role.displayName);
    }

    // 상태 필터
    if (filter.isDeleted == true) {
      filterParts.add('비활성');
    } else if (filter.isDeleted == false) {
      filterParts.add('활성');
    }

    // 정렬 정보
    final sort = SortOption.fromValue(filter.sortBy);
    final order = filter.isAsc ? '↑' : '↓';
    filterParts.add('${sort.displayName}$order');

    return filterParts.join(' · ');
  }
}

/// 🎯 필터 바텀시트 콘텐츠 위젯 (StatefulWidget으로 분리)
class _FilterBottomSheetContent extends StatefulWidget {
  final MemberListFilter currentFilter;
  final Function(MemberListFilter) onFilterChanged;
  final bool canShowDeletedFilter;

  const _FilterBottomSheetContent({
    required this.currentFilter,
    required this.onFilterChanged,
    required this.canShowDeletedFilter,
  });

  @override
  State<_FilterBottomSheetContent> createState() => _FilterBottomSheetContentState();
}

class _FilterBottomSheetContentState extends State<_FilterBottomSheetContent> {
  late GenderOption selectedGender;
  late RoleOption selectedRole;
  late bool? selectedDeleted;
  late SortOption selectedSort;
  late bool isAscending;

  @override
  void initState() {
    super.initState();
    // 🎯 초기값 설정 - ID순, 내림차순으로 변경
    selectedGender = GenderOption.fromValue(widget.currentFilter.gender);
    selectedRole = RoleOption.fromValue(widget.currentFilter.role);
    selectedDeleted = widget.currentFilter.isDeleted;
    selectedSort = SortOption.fromValue(widget.currentFilter.sortBy);
    isAscending = widget.currentFilter.isAsc;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        child: SingleChildScrollView(
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
                  // 필터 초기화 - ID순, 내림차순으로 설정
                  setState(() {
                    selectedGender = GenderOption.all;
                    selectedRole = RoleOption.all;
                    selectedDeleted = null;
                    selectedSort = SortOption.id; // ID순으로 초기화
                    isAscending = false; // 내림차순으로 초기화
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
          
          // 성별 필터
          MemberWidgets._buildFilterSection(
            context,
            title: '성별',
            child: Wrap(
              spacing: 8,
              children: GenderOption.values.map((option) {
                final isSelected = selectedGender == option;
                return FilterChip(
                  label: Text(option.displayName),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      selectedGender = selected ? option : GenderOption.all;
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
          
          // 권한 필터
          MemberWidgets._buildFilterSection(
            context,
            title: '권한',
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: RoleOption.values.map((option) {
                final isSelected = selectedRole == option;
                return FilterChip(
                  label: Text(option.displayName),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      selectedRole = selected ? option : RoleOption.all;
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
          
          // 활성/비활성 필터 (조건부 표시) - 🎯 운영진·준운영진은 표시하지 않음
          if (widget.canShowDeletedFilter) ...[
            MemberWidgets._buildFilterSection(
              context,
              title: '계정 상태',
              child: Wrap(
                spacing: 8,
                children: [
                  FilterChip(
                    label: const Text('전체'),
                    selected: selectedDeleted == null,
                    onSelected: (selected) {
                      setState(() {
                        selectedDeleted = selected ? null : false;
                      });
                    },
                    selectedColor: context.colors.primary.withOpacity(0.2),
                    checkmarkColor: context.colors.primary,
                    backgroundColor: context.colors.surfaceVariant,
                  ),
                  FilterChip(
                    label: const Text('활성만'),
                    selected: selectedDeleted == false,
                    onSelected: (selected) {
                      setState(() {
                        selectedDeleted = selected ? false : null;
                      });
                    },
                    selectedColor: context.colors.primary.withOpacity(0.2),
                    checkmarkColor: context.colors.primary,
                    backgroundColor: context.colors.surfaceVariant,
                  ),
                  FilterChip(
                    label: const Text('비활성만'),
                    selected: selectedDeleted == true,
                    onSelected: (selected) {
                      setState(() {
                        selectedDeleted = selected ? true : null;
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
          ],
          
          // 정렬
          MemberWidgets._buildFilterSection(
            context,
            title: '정렬',
            child: Column(
              children: [
                // 정렬 기준
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: SortOption.values.map((option) {
                    final isSelected = selectedSort == option;
                    return FilterChip(
                      label: Text(option.displayName),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                        selectedSort = selected ? option : SortOption.id; // 기본값을 ID순으로
                        });
                      },
                      selectedColor: context.colors.primary.withOpacity(0.2),
                      checkmarkColor: context.colors.primary,
                      backgroundColor: context.colors.surfaceVariant,
                    );
                  }).toList(),
                ),
                
                const SizedBox(height: 8),
                
                // 정렬 순서 (ChoiceChip 유지 - 단일 선택)
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
                final newFilter = MemberListFilter(
                  gender: selectedGender.value,
                  role: selectedRole.value,
                  isDeleted: selectedDeleted,
                  sortBy: selectedSort.value,
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
        ),
      ),
    );
  }
}
