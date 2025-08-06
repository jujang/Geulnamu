import 'package:flutter/material.dart';
import '../../../../core/theme.dart';
import '../../../../models/discussion/attendance_id_and_name_model.dart';

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
        // 1. 미할당 인원 섹션 (드롭 존)
        if (editingUnassignedMembers.isNotEmpty) ...[
          _buildUnassignedDropZone(
            context,
            editingUnassignedMembers: editingUnassignedMembers,
            onRemoveMemberFromGroup: onRemoveMemberFromGroup,
          ),
          const SizedBox(height: 24),
        ],

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
                  Text(
                    '📥 미할당 인원 (${editingUnassignedMembers.length}명)',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isHighlighted 
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.error,
                    ),
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
                  Text(
                    '🎯 ${groupNumber}조 (${members.length}명)',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                      fontSize: 16,
                    ),
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
            color: Theme.of(context).colorScheme.secondaryContainer.withOpacity(
              isHighlighted ? 0.2 : 0.1,
            ),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isHighlighted 
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.secondary.withOpacity(0.5),
              width: isHighlighted ? 2.0 : 1.0,
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
                    : Theme.of(context).colorScheme.secondary,
              ),
              const SizedBox(width: 8),
              Text(
                isHighlighted 
                    ? '➕ 새 그룹을 만들고 여기에 추가하세요!'
                    : '➕ 멤버를 여기로 드래그하면 새 그룹이 생성됩니다',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: isHighlighted ? FontWeight.bold : FontWeight.w500,
                  color: isHighlighted 
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.secondary,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// 🎯 드래그 가능한 멤버 카드
  static Widget _buildDraggableMemberCard(
    BuildContext context, {
    required AttendanceIdAndNameModel member,
  }) {
    return Draggable<AttendanceIdAndNameModel>(
      data: member,
      dragAnchorStrategy: pointerDragAnchorStrategy,
      feedback: Material(
        elevation: 6,
        borderRadius: BorderRadius.circular(8),
        child: Transform.scale(
          scale: 1.1, // 드래그 중 살짝 크게
          child: Opacity(
            opacity: 0.8, // 드래그 중 반투명
            child: _buildMemberCard(
              context, 
              member: member,
              isDragging: true,
            ),
          ),
        ),
      ),
      childWhenDragging: Opacity(
        opacity: 0.3, // 원본은 흐리게
        child: _buildMemberCard(context, member: member),
      ),
      child: _buildMemberCard(context, member: member),
    );
  }

  /// 🎯 멤버 카드 (공통 디자인)
  static Widget _buildMemberCard(
    BuildContext context, {
    required AttendanceIdAndNameModel member,
    bool isDragging = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isDragging 
            ? Theme.of(context).colorScheme.primaryContainer
            : Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDragging 
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.outline.withOpacity(0.2),
          width: isDragging ? 2.0 : 1.0,
        ),
        boxShadow: isDragging ? [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(2, 4),
          ),
        ] : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.drag_indicator,
            size: 16,
            color: Theme.of(context).colorScheme.primary.withOpacity(0.7),
          ),
          const SizedBox(width: 6),
          Icon(
            Icons.person,
            size: 16,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 6),
          Text(
            member.memberName,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: isDragging 
                  ? Theme.of(context).colorScheme.onPrimaryContainer
                  : Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
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
