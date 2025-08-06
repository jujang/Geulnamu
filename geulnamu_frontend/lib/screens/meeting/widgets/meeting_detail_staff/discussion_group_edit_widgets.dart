import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme.dart';
import '../../../../models/discussion/attendance_id_and_name_model.dart';
import '../../../../core/config/app_config.dart';

/// 🎯 토론 그룹 편집 모드 전용 위젯들 (드래그&드롭 방식)
class DiscussionGroupEditWidgets {
  
  /// 토론 그룹 편집 모드 전체 컨텐츠
  static Widget buildDiscussionGroupEditingContent(
    BuildContext context, {
    required Map<int, List<AttendanceIdAndNameModel>> editingGroups,
    required List<AttendanceIdAndNameModel> editingUnassignedMembers,
    required void Function(AttendanceIdAndNameModel member, int targetGroupNumber) onMoveMemberToGroup,
    required void Function(AttendanceIdAndNameModel member) onRemoveMemberFromGroup,
    required VoidCallback onCreateNewGroup,
    required VoidCallback onClearAllGroups,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. 미할당 인원 섹션 (항상 표시)
        _buildUnassignedDropZone(
          context,
          editingUnassignedMembers: editingUnassignedMembers,
          onRemoveMemberFromGroup: onRemoveMemberFromGroup,
        ),
        const SizedBox(height: 24),

        // 2. 토론 그룹들 (드래그&드롭 가능)
        _buildDraggableDiscussionGroups(
          context,
          editingGroups: editingGroups,
          onMoveMemberToGroup: onMoveMemberToGroup,
          onRemoveMemberFromGroup: onRemoveMemberFromGroup,
        ),

        const SizedBox(height: 16),

        // 3. 새 그룹 생성 드롭 존
        _buildNewGroupDropZone(
          context,
          onMoveMemberToGroup: onMoveMemberToGroup,
          onCreateNewGroup: onCreateNewGroup,
          editingGroups: editingGroups,
        ),

        const SizedBox(height: 16),

        // 4. 하단 액션 버튼들
        buildEditingActionButtons(
          context,
          onCreateNewGroup: onCreateNewGroup,
          onClearAllGroups: onClearAllGroups,
        ),
      ],
    );
  }

  /// 🎯 미할당 인원 드롭 존
  static Widget _buildUnassignedDropZone(
    BuildContext context, {
    required List<AttendanceIdAndNameModel> editingUnassignedMembers,
    required void Function(AttendanceIdAndNameModel member) onRemoveMemberFromGroup,
  }) {
    return DragTarget<AttendanceIdAndNameModel>(
      onAcceptWithDetails: (details) {
        onRemoveMemberFromGroup(details.data);
      },
      builder: (context, candidateData, rejectedData) {
        final isHighlighted = candidateData.isNotEmpty;
        
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.errorContainer.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isHighlighted 
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.error.withOpacity(0.3),
              width: isHighlighted ? 2.0 : 1.0,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 제목
              Row(
                children: [
                  Icon(
                    Icons.person_off,
                    size: 20,
                    color: isHighlighted 
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.error,
                  ),
                  const SizedBox(width: 8),
                  // 🎯 미할당 인원 수 애니메이션
                  _buildAnimatedUnassignedTitle(
                    context,
                    memberCount: editingUnassignedMembers.length,
                    isHighlighted: isHighlighted,
                  ),
                  if (isHighlighted) ...[
                    const SizedBox(width: 8),
                    Text(
                      '← 여기로 드롭하세요',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ],
              ),

              if (editingUnassignedMembers.isNotEmpty) ...[
                const SizedBox(height: 12),
                
                // 미할당 멤버들 (가로 배치)
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: editingUnassignedMembers.map((member) {
                    return _buildDraggableMemberCard(context, member: member);
                  }).toList(),
                ),
              ] else ...[
                const SizedBox(height: 8),
                Text(
                  '💭 모든 멤버가 그룹에 배정되었습니다.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontStyle: FontStyle.italic,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  /// 🎯 드래그 가능한 토론 그룹들
  static Widget _buildDraggableDiscussionGroups(
    BuildContext context, {
    required Map<int, List<AttendanceIdAndNameModel>> editingGroups,
    required void Function(AttendanceIdAndNameModel member, int targetGroupNumber) onMoveMemberToGroup,
    required void Function(AttendanceIdAndNameModel member) onRemoveMemberFromGroup,
  }) {
    if (editingGroups.isEmpty) {
      return _buildNoGroupsMessage(context);
    }

    // 그룹 번호 순으로 정렬
    final sortedGroupNumbers = editingGroups.keys.toList()..sort();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 소제목
        Row(
          children: [
            Icon(
              Icons.groups,
              size: 20,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Text(
              '토론 그룹 구성 현황 (드래그&드롭 편집)',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 16,
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // 각 그룹별 드롭 존
        ...sortedGroupNumbers.map((groupNumber) {
          final members = editingGroups[groupNumber]!;
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _buildGroupDropZone(
              context,
              groupNumber: groupNumber,
              members: members,
              onMoveMemberToGroup: onMoveMemberToGroup,
            ),
          );
        }),
      ],
    );
  }

  /// 🎯 개별 그룹 드롭 존
  static Widget _buildGroupDropZone(
    BuildContext context, {
    required int groupNumber,
    required List<AttendanceIdAndNameModel> members,
    required void Function(AttendanceIdAndNameModel member, int targetGroupNumber) onMoveMemberToGroup,
  }) {
    return DragTarget<AttendanceIdAndNameModel>(
      onAcceptWithDetails: (details) {
        onMoveMemberToGroup(details.data, groupNumber);
      },
      builder: (context, candidateData, rejectedData) {
        final isHighlighted = candidateData.isNotEmpty;
        
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer.withOpacity(
              isHighlighted ? 0.2 : 0.1,
            ),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isHighlighted 
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.primary.withOpacity(0.3),
              width: isHighlighted ? 2.0 : 1.5,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 그룹 제목
              Row(
                children: [
                  Icon(
                    Icons.group,
                    size: 18,
                    color: isHighlighted 
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  // 🎯 그룹 제목 + 인원 수 애니메이션
                  _buildAnimatedGroupTitle(
                    context,
                    groupNumber: groupNumber,
                    memberCount: members.length,
                  ),
                  if (isHighlighted) ...[
                    const SizedBox(width: 8),
                    Text(
                      '← 여기로 드롭하세요',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                  if (members.isEmpty) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.error.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '빈 그룹',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.error,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ],
              ),

              if (members.isNotEmpty) ...[
                const SizedBox(height: 12),

                // 그룹 멤버들 (가로 배치, 드래그 가능)
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: members.map((member) {
                    return _buildDraggableMemberCard(context, member: member);
                  }).toList(),
                ),
              ] else if (!isHighlighted) ...[
                const SizedBox(height: 8),
                Text(
                  '💭 이 그룹에는 아직 배정된 멤버가 없습니다.\n멤버를 드래그해서 여기로 옮겨보세요.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontStyle: FontStyle.italic,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  /// 🎯 새 그룹 생성 드롭 존
  static Widget _buildNewGroupDropZone(
    BuildContext context, {
    required void Function(AttendanceIdAndNameModel member, int targetGroupNumber) onMoveMemberToGroup,
    required VoidCallback onCreateNewGroup,
    required Map<int, List<AttendanceIdAndNameModel>> editingGroups,
  }) {
    return DragTarget<AttendanceIdAndNameModel>(
      onAcceptWithDetails: (details) {
        // 새 그룹 생성
        onCreateNewGroup();
        
        // 새로 생성된 그룹 번호 계산
        final newGroupNumber = editingGroups.isEmpty 
            ? 1 
            : editingGroups.keys.reduce((a, b) => a > b ? a : b) + 1;
        
        // 드래그된 멤버를 새 그룹으로 이동
        onMoveMemberToGroup(details.data, newGroupNumber);
      },
      builder: (context, candidateData, rejectedData) {
        final isHighlighted = candidateData.isNotEmpty;
        
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            // 🎨 색상 강화: 라이트/다크 모드 모두에서 잘 보이도록
            color: isHighlighted 
                ? Theme.of(context).colorScheme.primary.withOpacity(0.15)
                : Theme.of(context).colorScheme.tertiary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isHighlighted 
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.tertiary,
              width: isHighlighted ? 2.0 : 2.0, // 항상 두께 2.0으로 고정
              style: BorderStyle.solid,
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.add_circle_outline,
                size: 20,
                color: isHighlighted 
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.tertiary,
              ),
              const SizedBox(width: 8),
              Text(
                isHighlighted 
                    ? '➕ 새 그룹을 만들고 여기에 추가하세요!'
                    : '➕ 멤버를 여기로 드래그하면 새 그룹이 생성됩니다',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: isHighlighted ? FontWeight.bold : FontWeight.w600,
                  color: isHighlighted 
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.tertiary,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// 🎯 드래그 가능한 멤버 카드 (고급 애니메이션)
  static Widget _buildDraggableMemberCard(
    BuildContext context, {
    required AttendanceIdAndNameModel member,
  }) {
    return Draggable<AttendanceIdAndNameModel>(
      data: member,
      dragAnchorStrategy: pointerDragAnchorStrategy,
      
      // 🎯 드래그 시작 시 핸틱 피드백
      onDragStarted: () {
        HapticFeedback.lightImpact();
        if (AppConfig.debugMode) {
          print('🚀 [드래그 시작] ${member.memberName} 드래그 시작');
        }
      },
      
      // 🎯 드래그 종료 시 로깅 및 핸틱 피드백
      onDragEnd: (details) {
        if (AppConfig.debugMode) {
          print('📍 [드래그 종료] ${member.memberName} 드래그 종료: ${{"wasAccepted": details.wasAccepted, "offset": details.offset}}');
        }
        
        // 드롭 성공 시 성공 피드백, 실패 시 실패 피드백
        if (details.wasAccepted) {
          HapticFeedback.mediumImpact(); // 성공: 중간 진동
        } else {
          HapticFeedback.lightImpact(); // 실패: 가벼운 진동
        }
      },
      
      // 🎯 드래그 중 피드백 (회전 효과 제거)
      feedback: Material(
        elevation: 8, // 좌더 깊은 그림자
        borderRadius: BorderRadius.circular(8),
        child: Transform.scale(
          scale: 1.15, // 더 크게 확대
          child: Opacity(
            opacity: 0.9, // 덜 투명하게
            child: _buildMemberCard(
              context, 
              member: member,
              isDragging: true,
            ),
          ),
        ),
      ),
      
      // 🎯 드래그 중 원본 카드 상태
      childWhenDragging: AnimatedScale(
        scale: 0.95, // 살짝 작아지게
        duration: const Duration(milliseconds: 150),
        child: AnimatedOpacity(
          opacity: 0.4, // 좌더 흐리게
          duration: const Duration(milliseconds: 150),
          child: _buildMemberCard(context, member: member, isDimmed: true),
        ),
      ),
      
      child: _buildMemberCard(context, member: member),
    );
  }

  /// 🎯 멤버 카드 (고급 디자인 + 애니메이션)
  static Widget _buildMemberCard(
    BuildContext context, {
    required AttendanceIdAndNameModel member,
    bool isDragging = false,
    bool isDimmed = false,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: _getMemberCardColor(context, isDragging: isDragging, isDimmed: isDimmed),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: _getMemberCardBorderColor(context, isDragging: isDragging, isDimmed: isDimmed),
          width: isDragging ? 2.0 : 1.0,
        ),
        boxShadow: _getMemberCardShadow(context, isDragging: isDragging),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 🎯 드래그 인디케이터 (회전 효과 제거)
          Icon(
            Icons.drag_indicator,
            size: 16,
            color: Theme.of(context).colorScheme.primary.withOpacity(
              isDimmed ? 0.4 : 0.7,
            ),
          ),
          const SizedBox(width: 6),
          
          // 🎯 사용자 아이콘 (애니메이션)
          AnimatedScale(
            scale: isDragging ? 1.1 : 1.0,
            duration: const Duration(milliseconds: 200),
            child: Icon(
              Icons.person,
              size: 16,
              color: Theme.of(context).colorScheme.primary.withOpacity(
                isDimmed ? 0.5 : 1.0,
              ),
            ),
          ),
          const SizedBox(width: 6),
          
          // 🎯 멤버 이름 (애니메이션)
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 200),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: isDragging ? FontWeight.bold : FontWeight.w600,
              color: _getMemberCardTextColor(context, isDragging: isDragging, isDimmed: isDimmed),
            ) ?? const TextStyle(),
            child: Text(member.memberName),
          ),
        ],
      ),
    );
  }
  
  /// 🎨 멤버 카드 색상 결정
  static Color _getMemberCardColor(BuildContext context, {bool isDragging = false, bool isDimmed = false}) {
    if (isDragging) return Theme.of(context).colorScheme.primaryContainer;
    if (isDimmed) return Theme.of(context).colorScheme.surface.withOpacity(0.7);
    return Theme.of(context).colorScheme.surface;
  }
  
  /// 🎨 멤버 카드 테두리 색상 결정
  static Color _getMemberCardBorderColor(BuildContext context, {bool isDragging = false, bool isDimmed = false}) {
    if (isDragging) return Theme.of(context).colorScheme.primary;
    if (isDimmed) return Theme.of(context).colorScheme.outline.withOpacity(0.1);
    return Theme.of(context).colorScheme.outline.withOpacity(0.2);
  }
  
  /// 🎨 멤버 카드 텍스트 색상 결정
  static Color _getMemberCardTextColor(BuildContext context, {bool isDragging = false, bool isDimmed = false}) {
    if (isDragging) return Theme.of(context).colorScheme.onPrimaryContainer;
    if (isDimmed) return Theme.of(context).colorScheme.onSurface.withOpacity(0.5);
    return Theme.of(context).colorScheme.onSurface;
  }
  
  /// 🎨 멤버 카드 그림자 결정
  static List<BoxShadow>? _getMemberCardShadow(BuildContext context, {bool isDragging = false}) {
    if (isDragging) {
      return [
        BoxShadow(
          color: Colors.black.withOpacity(0.3),
          blurRadius: 12,
          offset: const Offset(3, 6),
        ),
        BoxShadow(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ];
    }
    return null;
  }

  /// 편집 모드 하단 액션 버튼들 (기존 유지)
  static Widget buildEditingActionButtons(
    BuildContext context, {
    required VoidCallback onCreateNewGroup,
    required VoidCallback onClearAllGroups,
  }) {
    return Row(
      children: [
        // 새 그룹 추가 버튼
        Expanded(
          child: OutlinedButton.icon(
            onPressed: onCreateNewGroup,
            icon: const Icon(Icons.add),
            label: const Text('새 그룹 추가'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.primary,
              side: BorderSide(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
        ),

        const SizedBox(width: 12),

        // 모든 그룹 해제 버튼
        Expanded(
          child: OutlinedButton.icon(
            onPressed: onClearAllGroups,
            icon: const Icon(Icons.clear_all),
            label: const Text('모든 그룹 해제'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
              side: BorderSide(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// 🎯 애니메이션 미할당 인원 제목
  static Widget _buildAnimatedUnassignedTitle(
    BuildContext context, {
    required int memberCount,
    required bool isHighlighted,
  }) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (child, animation) {
        return ScaleTransition(
          scale: Tween<double>(
            begin: 0.7,
            end: 1.0,
          ).animate(
            CurvedAnimation(
              parent: animation,
              curve: Curves.bounceOut,
            ),
          ),
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
      },
      child: Text(
        '📥 미할당 인원 (${memberCount}명)',
        key: ValueKey<String>('unassigned_count_${memberCount}'),
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.bold,
          color: isHighlighted 
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.error,
        ),
      ),
    );
  }
  
  /// 🎯 애니메이션 그룹 제목 (인원 수 변화 시 애니메이션)
  static Widget _buildAnimatedGroupTitle(
    BuildContext context, {
    required int groupNumber,
    required int memberCount,
  }) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (child, animation) {
        // 🎯 세련된 결합 애니메이션: 스케일 + 페이드
        return ScaleTransition(
          scale: Tween<double>(
            begin: 0.8,
            end: 1.0,
          ).animate(
            CurvedAnimation(
              parent: animation,
              curve: Curves.elasticOut,
            ),
          ),
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
      },
      child: Text(
        '🎯 ${groupNumber}조 (${memberCount}명)',
        key: ValueKey<String>('group_${groupNumber}_count_${memberCount}'), // 고유한 키로 애니메이션 트리거
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.onSurface,
          fontSize: 16,
        ),
      ),
    );
  }
  
  /// 그룹이 없을 때 메시지 (기존 유지)
  static Widget _buildNoGroupsMessage(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.group_off,
            size: 48,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          Text(
            '구성된 토론 그룹이 없습니다.',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '멤버를 "새 그룹 생성 영역"으로 드래그하거나\n"새 그룹 추가" 버튼을 클릭하여 첫 번째 그룹을 만들어보세요.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}
