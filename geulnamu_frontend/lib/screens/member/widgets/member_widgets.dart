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
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4), // 세로 간격 줄임
      elevation: isActive ? null : 0, // 비활성 계정은 그림자 제거
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12), // 패딩 줄임 (16 → 12)
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            // 🎯 비활성 계정 강화된 시각적 구분
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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 🎯 이름 + 닉네임 (한 줄로 슬림화)
                    Row(
                      children: [
                        // 이름 (메인)
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
                        // 🎯 닉네임 (소괄호로 이름 옆에)
                        Text(
                          '(${member.nickname})',
                          style: context.textStyles.bodySmall?.copyWith(
                            color: isActive
                                ? context.colors.onSurfaceVariant
                                : context.colors.onSurfaceVariant.withOpacity(0.5),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 6), // 간격 줄임 (12 → 6)
                    
                    // 🎯 성별 + 생년월일 + ID (한 줄로 압축)
                    Row(
                      children: [
                        // 성별 아이콘
                        Icon(
                          member.gender == 'MALE' 
                              ? Icons.male 
                              : member.gender == 'FEMALE'
                                  ? Icons.female
                                  : Icons.help_outline,
                          size: 14, // 아이콘 크기 줄임
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
                        
                        // 생년월일 아이콘
                        Icon(
                          Icons.cake_outlined,
                          size: 14, // 아이콘 크기 줄임
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
                        
                        // ID 표시 (우측 끝)
                        Text(
                          '#${member.memberId}',
                          style: context.textStyles.bodySmall?.copyWith(
                            color: isActive
                                ? context.colors.outline
                                : context.colors.outline.withOpacity(0.5),
                            fontFamily: 'monospace',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              const SizedBox(width: 8),
              
              // 🎯 권한 배지 (우측)
              _buildRoleBadge(context, member.roleDisplayName, isActive),
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

    // 🎯 비활성 계정 색상 강화된 대비
    if (!isActive) {
      badgeColor = badgeColor.withOpacity(0.3); // 더 연한 색상
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3), // 크기 아주 조금 줄임
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10), // 더 작은 보던
        border: Border.all(
          color: badgeColor.withOpacity(isActive ? 0.3 : 0.2), // 비활성 시 더 연한 테두리
          width: 1,
        ),
      ),
      child: Text(
        role,
        style: context.textStyles.labelSmall?.copyWith(
          color: badgeColor,
          fontWeight: FontWeight.w600,
          fontSize: 10, // 택스트 크기 조금 줄임
        ),
      ),
    );
  }

  /// 플로팅 필터 버튼
  /// 
  /// [onPressed] 필터 버튼 탭 콜백
  static Widget buildFilterFab(BuildContext context, VoidCallback onPressed) {
    return FloatingActionButton(
      onPressed: onPressed,
      backgroundColor: context.colors.primary,
      foregroundColor: context.colors.onPrimary,
      child: const Icon(Icons.tune),
    );
  }

  /// 필터 바텀시트
  /// 
  /// [currentFilter] 현재 필터 설정
  /// [onFilterChanged] 필터 변경 콜백
  /// [canShowDeletedFilter] 비활성 계정 필터 표시 여부
  static Widget buildFilterBottomSheet(
    BuildContext context, {
    required MemberListFilter currentFilter,
    required Function(MemberListFilter) onFilterChanged,
    required bool canShowDeletedFilter,
  }) {
    return StatefulBuilder(
      builder: (context, setModalState) {
        // 지역 상태 변수들
        GenderOption selectedGender = GenderOption.fromValue(currentFilter.gender);
        RoleOption selectedRole = RoleOption.fromValue(currentFilter.role);
        bool? selectedDeleted = currentFilter.isDeleted;
        SortOption selectedSort = SortOption.fromValue(currentFilter.sortBy);
        bool isAscending = currentFilter.isAsc;

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
                      // 필터 초기화
                      setModalState(() {
                        selectedGender = GenderOption.all;
                        selectedRole = RoleOption.all;
                        selectedDeleted = null;
                        selectedSort = SortOption.role;
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
              
              // 성별 필터
              _buildFilterSection(
                context,
                title: '성별',
                child: Wrap(
                  spacing: 8,
                  children: GenderOption.values.map((option) {
                    final isSelected = selectedGender == option;
                    return ChoiceChip( // FilterChip 대신 ChoiceChip 사용
                      label: Text(option.displayName),
                      selected: isSelected,
                      onSelected: (selected) {
                        if (selected) {
                          setModalState(() {
                            selectedGender = option;
                          });
                        }
                      },
                    );
                  }).toList(),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // 권한 필터
              _buildFilterSection(
                context,
                title: '권한',
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: RoleOption.values.map((option) {
                    final isSelected = selectedRole == option;
                    return ChoiceChip( // FilterChip 대신 ChoiceChip 사용
                      label: Text(option.displayName),
                      selected: isSelected,
                      onSelected: (selected) {
                        if (selected) {
                          setModalState(() {
                            selectedRole = option;
                            // 권한 변경 시 비활성 필터 옵션 확인
                            if (option.forceActiveOnly) {
                              selectedDeleted = false;
                            }
                          });
                        }
                      },
                    );
                  }).toList(),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // 활성/비활성 필터 (조건부 표시)
              if (canShowDeletedFilter && !selectedRole.forceActiveOnly) ...[
                _buildFilterSection(
                  context,
                  title: '계정 상태',
                  child: Wrap(
                    spacing: 8,
                    children: [
                      ChoiceChip( // FilterChip 대신 ChoiceChip 사용
                        label: const Text('전체'),
                        selected: selectedDeleted == null,
                        onSelected: (selected) {
                          if (selected) {
                            setModalState(() {
                              selectedDeleted = null;
                            });
                          }
                        },
                      ),
                      ChoiceChip(
                        label: const Text('활성만'),
                        selected: selectedDeleted == false,
                        onSelected: (selected) {
                          if (selected) {
                            setModalState(() {
                              selectedDeleted = false;
                            });
                          }
                        },
                      ),
                      ChoiceChip(
                        label: const Text('비활성만'),
                        selected: selectedDeleted == true,
                        onSelected: (selected) {
                          if (selected) {
                            setModalState(() {
                              selectedDeleted = true;
                            });
                          }
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
              
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
                      children: SortOption.values.map((option) {
                        final isSelected = selectedSort == option;
                        return ChoiceChip( // FilterChip 대신 ChoiceChip 사용
                          label: Text(option.displayName),
                          selected: isSelected,
                          onSelected: (selected) {
                            if (selected) {
                              setModalState(() {
                                selectedSort = option;
                              });
                            }
                          },
                        );
                      }).toList(),
                    ),
                    
                    const SizedBox(height: 8),
                    
                    // 정렬 순서
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ChoiceChip( // FilterChip 대신 ChoiceChip 사용
                          label: const Text('오름차순'),
                          selected: isAscending,
                          onSelected: (selected) {
                            if (selected) {
                              setModalState(() {
                                isAscending = true;
                              });
                            }
                          },
                        ),
                        const SizedBox(width: 8),
                        ChoiceChip(
                          label: const Text('내림차순'),
                          selected: !isAscending,
                          onSelected: (selected) {
                            if (selected) {
                              setModalState(() {
                                isAscending = false;
                              });
                            }
                          },
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
                    onFilterChanged(newFilter);
                  },
                  child: const Text('적용'),
                ),
              ),
              
              // 하단 여백 (키보드 대응)
              SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
            ],
          ),
        );
      },
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
  /// 
  /// [currentPage] 현재 페이지
  /// [totalPages] 전체 페이지 수
  /// [onPageChanged] 페이지 변경 콜백
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
  /// 
  /// [message] 에러 메시지
  /// [onRetry] 재시도 콜백
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
  /// 
  /// [totalElements] 전체 요소 수
  /// [currentFilter] 현재 필터
  static Widget buildListHeader(
    BuildContext context, {
    required int totalElements,
    required MemberListFilter currentFilter,
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
            ),
          ),
          Text(
            _getFilterSummary(currentFilter),
            style: context.textStyles.bodySmall?.copyWith(
              color: context.colors.onSurfaceVariant,
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
