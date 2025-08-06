import 'package:flutter/material.dart';
import '../../../../core/theme.dart';
import '../../../../models/discussion/attendance_id_and_name_model.dart';

/// 토론 그룹 편집 모드 전용 위젯들
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
        // 1. 미할당 인원 섹션
        if (editingUnassignedMembers.isNotEmpty) ...[
          buildUnassignedMembersSection(
            context,
            editingUnassignedMembers: editingUnassignedMembers,
            editingGroups: editingGroups,
            onMoveMemberToGroup: onMoveMemberToGroup,
            onCreateNewGroup: onCreateNewGroup,
          ),
          const SizedBox(height: 24),
        ],

        // 2. 토론 그룹들 (편집 가능)
        buildEditableDiscussionGroups(
          context,
          editingGroups: editingGroups,
          editingUnassignedMembers: editingUnassignedMembers,
          onMoveMemberToGroup: onMoveMemberToGroup,
          onRemoveMemberFromGroup: onRemoveMemberFromGroup,
        ),

        const SizedBox(height: 16),

        // 3. 하단 액션 버튼들
        buildEditingActionButtons(
          context,
          onCreateNewGroup: onCreateNewGroup,
          onClearAllGroups: onClearAllGroups,
        ),
      ],
    );
  }

  /// 편집 가능한 토론 그룹들
  static Widget buildEditableDiscussionGroups(
    BuildContext context, {
    required Map<int, List<AttendanceIdAndNameModel>> editingGroups,
    required List<AttendanceIdAndNameModel> editingUnassignedMembers,
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
              '토론 그룹 구성 현황 (편집 모드)',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 16,
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // 각 그룹별 편집 가능한 UI
        ...sortedGroupNumbers.map((groupNumber) {
          final members = editingGroups[groupNumber]!;
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _buildEditableSingleDiscussionGroup(
              context,
              groupNumber: groupNumber,
              members: members,
              editingGroups: editingGroups,
              onMoveMemberToGroup: onMoveMemberToGroup,
              onRemoveMemberFromGroup: onRemoveMemberFromGroup,
            ),
          );
        }),
      ],
    );
  }

  /// 개별 편집 가능한 토론 그룹
  static Widget _buildEditableSingleDiscussionGroup(
    BuildContext context, {
    required int groupNumber,
    required List<AttendanceIdAndNameModel> members,
    required Map<int, List<AttendanceIdAndNameModel>> editingGroups,
    required void Function(AttendanceIdAndNameModel member, int targetGroupNumber) onMoveMemberToGroup,
    required void Function(AttendanceIdAndNameModel member) onRemoveMemberFromGroup,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
          width: 1.5,
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
                color: Theme.of(context).colorScheme.primary,
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

            // 그룹 멤버들 (편집 가능)
            ...members.map((member) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _buildEditableMemberCard(
                  context,
                  member: member,
                  currentGroupNumber: groupNumber,
                  editingGroups: editingGroups,
                  onMoveMemberToGroup: onMoveMemberToGroup,
                  onRemoveMemberFromGroup: onRemoveMemberFromGroup,
                  onCreateNewGroup: null, // 그룹 내에서는 새 그룹 생성 버튼 없음
                ),
              );
            }),
          ] else ...[
            const SizedBox(height: 8),
            Text(
              '💭 이 그룹에는 아직 배정된 멤버가 없습니다.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontStyle: FontStyle.italic,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// 미할당 인원 섹션
  static Widget buildUnassignedMembersSection(
    BuildContext context, {
    required List<AttendanceIdAndNameModel> editingUnassignedMembers,
    required Map<int, List<AttendanceIdAndNameModel>> editingGroups,
    required void Function(AttendanceIdAndNameModel member, int targetGroupNumber) onMoveMemberToGroup,
    required VoidCallback onCreateNewGroup,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.errorContainer.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).colorScheme.error.withOpacity(0.3),
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
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(width: 8),
              Text(
                '📥 미할당 인원 (${editingUnassignedMembers.length}명)',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // 미할당 멤버들
          ...editingUnassignedMembers.map((member) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _buildEditableMemberCard(
                context,
                member: member,
                currentGroupNumber: null, // 미할당
                editingGroups: editingGroups,
                onMoveMemberToGroup: onMoveMemberToGroup,
                onRemoveMemberFromGroup: null, // 미할당에서는 제거 불가
                onCreateNewGroup: onCreateNewGroup,
              ),
            );
          }),
        ],
      ),
    );
  }

  /// 편집 가능한 멤버 카드
  static Widget _buildEditableMemberCard(
    BuildContext context, {
    required AttendanceIdAndNameModel member,
    required int? currentGroupNumber, // null이면 미할당
    required Map<int, List<AttendanceIdAndNameModel>> editingGroups,
    required void Function(AttendanceIdAndNameModel member, int targetGroupNumber) onMoveMemberToGroup,
    required void Function(AttendanceIdAndNameModel member)? onRemoveMemberFromGroup,
    required VoidCallback? onCreateNewGroup,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 멤버 이름
          Row(
            children: [
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
                ),
              ),
              const Spacer(),
              if (currentGroupNumber != null)
                Text(
                  '현재: ${currentGroupNumber}조',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 8),

          // 이동 버튼들
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: [
              // 기존 그룹으로 이동 버튼들
              ...editingGroups.keys.where((groupNumber) => groupNumber != currentGroupNumber).map((groupNumber) {
                return _buildMoveButton(
                  context,
                  label: '→ ${groupNumber}조',
                  onTap: () => onMoveMemberToGroup(member, groupNumber),
                );
              }),

              // 새 그룹 생성 버튼 (미할당에서만 표시)
              if (onCreateNewGroup != null && currentGroupNumber == null)
                _buildMoveButton(
                  context,
                  label: '→ 새 그룹',
                  onTap: () {
                    onCreateNewGroup();
                    // 새로 생성된 그룹 번호 계산
                    final newGroupNumber = editingGroups.isEmpty 
                        ? 1 
                        : editingGroups.keys.reduce((a, b) => a > b ? a : b);
                    onMoveMemberToGroup(member, newGroupNumber);
                  },
                  isSpecial: true,
                ),

              // 그룹에서 제거 버튼 (할당된 멤버만)
              if (onRemoveMemberFromGroup != null && currentGroupNumber != null)
                _buildMoveButton(
                  context,
                  label: '그룹에서 제거',
                  onTap: () => onRemoveMemberFromGroup(member),
                  isRemove: true,
                ),
            ],
          ),
        ],
      ),
    );
  }

  /// 이동 버튼 위젯
  static Widget _buildMoveButton(
    BuildContext context, {
    required String label,
    required VoidCallback onTap,
    bool isSpecial = false,
    bool isRemove = false,
  }) {
    Color backgroundColor;
    Color textColor;
    Color borderColor;

    if (isRemove) {
      backgroundColor = Theme.of(context).colorScheme.errorContainer;
      textColor = Theme.of(context).colorScheme.onErrorContainer;
      borderColor = Theme.of(context).colorScheme.error;
    } else if (isSpecial) {
      backgroundColor = Theme.of(context).colorScheme.secondaryContainer;
      textColor = Theme.of(context).colorScheme.onSecondaryContainer;
      borderColor = Theme.of(context).colorScheme.secondary;
    } else {
      backgroundColor = Theme.of(context).colorScheme.primaryContainer;
      textColor = Theme.of(context).colorScheme.onPrimaryContainer;
      borderColor = Theme.of(context).colorScheme.primary;
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: borderColor.withOpacity(0.5),
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
      ),
    );
  }

  /// 편집 모드 하단 액션 버튼들
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

  /// 그룹이 없을 때 메시지
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
            '"새 그룹 추가" 버튼을 클릭하여 첫 번째 그룹을 만들어보세요.',
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
