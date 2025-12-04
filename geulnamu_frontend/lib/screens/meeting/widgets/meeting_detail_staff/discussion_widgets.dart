import 'package:flutter/material.dart';
import '../../../../core/theme.dart';
import '../../../../models/meeting/meeting_detail_staff_model.dart';
import '../../../../models/discussion/attendance_id_and_name_model.dart';
import '../../../../models/discussion/discussion_group_model.dart';
import '../../../../models/attendance/attendance_status_model.dart';
import 'discussion_group_edit_widgets.dart';

/// 운영진용 모임 상세 - 토론 정보 섹션 위젯들
class DiscussionWidgets {
  /// 💬 토론 정보 섹션
  static Widget buildDiscussionSection(
    BuildContext context,
    MeetingDetailStaffInfo meetingDetail, {
    required bool isEditing,
    required bool isSaving,
    required VoidCallback onToggleEdit,
    required VoidCallback onSave,
    required TextEditingController alarmMessageController,
    required DateTime? selectedDiscussionTime,
    required bool isDiscussionTimeCleared,
    required ValueChanged<DateTime?> onDiscussionTimeChanged,
    required VoidCallback onClearDiscussionTime,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 섹션 헤더
            _buildSectionHeader(
              context,
              '💬 토론 정보',
              isEditing: isEditing,
              isSaving: isSaving,
              onToggleEdit: onToggleEdit,
              onSave: onSave,
            ),

            const SizedBox(height: 16),

            // 내용 (조회 모드 vs 편집 모드)
            if (isEditing)
              _buildDiscussionEditForm(
                context,
                alarmMessageController: alarmMessageController,
                selectedDiscussionTime: selectedDiscussionTime,
                isDiscussionTimeCleared: isDiscussionTimeCleared,
                onDiscussionTimeChanged: onDiscussionTimeChanged,
                onClearDiscussionTime: onClearDiscussionTime,
              )
            else
              _buildDiscussionDisplay(context, meetingDetail),
          ],
        ),
      ),
    );
  }

  /// 👥 토론 조 정보 섹션
  static Widget buildDiscussionGroupSection(
    BuildContext context,
    MeetingDetailStaffInfo meetingDetail, {
    required bool isLoading,
    required List<AttendanceIdAndNameModel>? wantDiscussionList,
    required DiscussionGroupListResponse? discussionGroupList,
    required String? errorMessage,
    required VoidCallback onRefresh,
    // 🆕 토론 그룹 편집 관련 매개변수들
    required bool isEditingDiscussionGroups,
    required bool isSaving,
    required Map<int, List<AttendanceIdAndNameModel>> editingGroups,
    required List<AttendanceIdAndNameModel> editingUnassignedMembers,
    required VoidCallback onToggleDiscussionGroupEdit,
    required VoidCallback onSaveDiscussionGroupChanges,
    required void Function(
      AttendanceIdAndNameModel member,
      int targetGroupNumber,
    )
    onMoveMemberToGroup,
    required void Function(AttendanceIdAndNameModel member)
    onRemoveMemberFromGroup,
    required VoidCallback onCreateNewGroup,
    required VoidCallback onClearAllGroups,
    // 🆕 인원 추가 기능 관련 매개변수들
    required bool canAddMembers,
    required List<AttendanceStatus> availableMembersToAdd,
    required void Function(AttendanceStatus) onAddMember,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 섹션 헤더 (편집 상태에 따라 다르게 표시)
            _buildDiscussionGroupHeader(
              context,
              onRefresh,
              isEditingDiscussionGroups: isEditingDiscussionGroups,
              isSaving: isSaving,
              onToggleEdit: onToggleDiscussionGroupEdit,
              onSave: onSaveDiscussionGroupChanges,
            ),

            const SizedBox(height: 16),

            // 내용 (로딩/에러/정상 데이터)
            if (isLoading)
              _buildDiscussionGroupLoading(context)
            else if (errorMessage != null)
              _buildDiscussionGroupError(context, errorMessage, onRefresh)
            else if (isEditingDiscussionGroups)
              // 🆕 편집 모드 UI
              DiscussionGroupEditWidgets.buildDiscussionGroupEditingContent(
                context,
                editingGroups: editingGroups,
                editingUnassignedMembers: editingUnassignedMembers,
                onMoveMemberToGroup: onMoveMemberToGroup,
                onRemoveMemberFromGroup: onRemoveMemberFromGroup,
                onCreateNewGroup: onCreateNewGroup,
                onClearAllGroups: onClearAllGroups,
                // 🆕 인원 추가 기능 매개변수 전달
                canAddMembers: canAddMembers,
                availableMembersToAdd: availableMembersToAdd,
                onAddMember: onAddMember,
              )
            else
              // 일반 조회 모드 UI
              _buildDiscussionGroupContent(
                context,
                wantDiscussionList: wantDiscussionList,
                discussionGroupList: discussionGroupList,
              ),
          ],
        ),
      ),
    );
  }

  /// 섹션 헤더 (제목 + 편집 버튼)
  static Widget _buildSectionHeader(
    BuildContext context,
    String title, {
    required bool isEditing,
    required bool isSaving,
    required VoidCallback onToggleEdit,
    required VoidCallback onSave,
  }) {
    return Row(
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const Spacer(),
        if (isEditing)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 취소 버튼 (크기 축소)
              TextButton(
                onPressed: isSaving ? null : onToggleEdit,
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text('취소', style: TextStyle(fontSize: 13)),
              ),
              const SizedBox(width: 4),
              // 저장 버튼 (크기 축소)
              SizedBox(
                height: 32,
                child: ElevatedButton.icon(
                  onPressed: isSaving ? null : onSave,
                  icon: isSaving
                      ? const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.save, size: 16),
                  label: Text(
                    isSaving ? '저장중' : '저장',
                    style: const TextStyle(fontSize: 13),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              ),
            ],
          )
        else
          // 편집 버튼
          IconButton(
            onPressed: onToggleEdit,
            icon: const Icon(Icons.edit),
            tooltip: '편집',
          ),
      ],
    );
  }

  /// 토론 정보 표시 (조회 모드)
  static Widget _buildDiscussionDisplay(
    BuildContext context,
    MeetingDetailStaffInfo meetingDetail,
  ) {
    return Column(
      children: [
        _buildInfoRow(
          context,
          '토론 시간',
          meetingDetail.discussionTime != null
              ? _formatDateTime(meetingDetail.discussionTime!)
              : '토론 시간 미설정',
        ),
        _buildInfoRow(
          context,
          '알림 메시지',
          meetingDetail.alarmMessage ?? '알림 메시지 없음',
          isMultiline: true,
        ),
      ],
    );
  }

  /// 토론 정보 편집 폼
  static Widget _buildDiscussionEditForm(
    BuildContext context, {
    required TextEditingController alarmMessageController,
    required DateTime? selectedDiscussionTime,
    required bool isDiscussionTimeCleared,
    required ValueChanged<DateTime?> onDiscussionTimeChanged,
    required VoidCallback onClearDiscussionTime,
  }) {
    return Column(
      children: [
        // 토론 시간 (실제 시간 선택기)
        Row(
          children: [
            Expanded(
              child: TextFormField(
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: '토론 시간',
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.access_time),
                ),
                controller: TextEditingController(
                  text: selectedDiscussionTime != null
                      ? _formatDateTime(selectedDiscussionTime)
                      : '',
                ),
                onTap: () => _selectDateTime(
                  context,
                  selectedDiscussionTime,
                  onDiscussionTimeChanged,
                ),
              ),
            ),
            const SizedBox(width: 8),
            // 토론 시간 제거 버튼
            if (selectedDiscussionTime != null || isDiscussionTimeCleared)
              IconButton(
                onPressed: onClearDiscussionTime,
                icon: const Icon(Icons.clear),
                tooltip: '토론 시간 및 알림 메시지를 모두 초기화합니다',
                color: Theme.of(context).colorScheme.error,
              ),
          ],
        ),
        const SizedBox(height: 8),
        // 토론 시간 안내 텍스트 (개선됨)
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            '토론 시간은 선택사항입니다. 설정하지 않으면 토론 없이 진행됩니다.\n'
            '🕓 조건: 모임 당일 내에 모임 시간 이후로만 설정 가능\n'
            '📝 X 버튼 클릭 시 토론 시간만 초기화 (알림 메시지는 유지)',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
        const SizedBox(height: 16),

        // 알림 메시지
        TextFormField(
          controller: alarmMessageController,
          decoration: InputDecoration(
            labelText: '알림 메시지',
            border: const OutlineInputBorder(),
            helperText:
                selectedDiscussionTime == null || isDiscussionTimeCleared
                ? '⚠️ 토론 시간이 설정되지 않아 현재 알림 메시지는 사용되지 않습니다.'
                : '토론 시작 전에 참여자들에게 전송될 메시지입니다.',
            helperStyle: TextStyle(
              color: selectedDiscussionTime == null || isDiscussionTimeCleared
                  ? Theme.of(context).colorScheme.error
                  : Theme.of(context).colorScheme.onSurfaceVariant,
              fontSize: 12,
            ),
          ),
          maxLines: 3,
          enabled: true,
        ),
      ],
    );
  }

  /// 정보 행 빌더
  static Widget _buildInfoRow(
    BuildContext context,
    String label,
    String value, {
    bool isMultiline = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: isMultiline
            ? CrossAxisAlignment.start
            : CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: context.colors.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(value, style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }

  /// 날짜/시간 포맷터
  static String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}.${dateTime.month.toString().padLeft(2, '0')}.${dateTime.day.toString().padLeft(2, '0')} '
        '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  // ====================
  // 토론 조 정보 섹션 헬퍼 메서드들
  // ====================

  /// 토론 조 정보 섹션 헤더 (🆕 편집 기능 포함)
  static Widget _buildDiscussionGroupHeader(
    BuildContext context,
    VoidCallback onRefresh, {
    required bool isEditingDiscussionGroups,
    required bool isSaving,
    required VoidCallback onToggleEdit,
    required VoidCallback onSave,
  }) {
    return Row(
      children: [
        // 🆕 편집 중에도 제목은 동일하게 표시 ('편집 중' 텍스트 제거)
        Text(
          '👥 토론 조 정보',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const Spacer(),

        if (isEditingDiscussionGroups) ...[
          // 편집 모드: 취소 + 저장 버튼 (크기 축소)
          TextButton(
            onPressed: isSaving ? null : onToggleEdit,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text('취소', style: TextStyle(fontSize: 13)),
          ),
          const SizedBox(width: 4),
          // 🆕 저장 버튼 크기 축소
          SizedBox(
            height: 32,
            child: ElevatedButton.icon(
              onPressed: isSaving ? null : onSave,
              icon: isSaving
                  ? const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save, size: 16),
              label: Text(
                isSaving ? '저장중' : '저장',
                style: const TextStyle(fontSize: 13),
              ),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ),
        ] else ...[
          // 조회 모드: 새로고침 + 편집 버튼
          IconButton(
            onPressed: onRefresh,
            icon: const Icon(Icons.refresh),
            tooltip: '토론 조 데이터 새로고침',
          ),
          IconButton(
            onPressed: onToggleEdit,
            icon: const Icon(Icons.edit),
            tooltip: '토론 그룹 편집',
          ),
        ],
      ],
    );
  }

  /// 토론 조 정보 로딩 상태
  static Widget _buildDiscussionGroupLoading(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('토론 조 정보를 불러오는 중...'),
          ],
        ),
      ),
    );
  }

  /// 토론 조 정보 에러 상태
  static Widget _buildDiscussionGroupError(
    BuildContext context,
    String errorMessage,
    VoidCallback onRetry,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              errorMessage,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('다시 시도'),
            ),
          ],
        ),
      ),
    );
  }

  /// 토론 조 정보 메인 콘텐츠
  static Widget _buildDiscussionGroupContent(
    BuildContext context, {
    required List<AttendanceIdAndNameModel>? wantDiscussionList,
    required DiscussionGroupListResponse? discussionGroupList,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. 토론 참여 희망 명단
        _buildWantDiscussionSection(context, wantDiscussionList),

        const SizedBox(height: 24),

        // 2. 모임별 전체 토론 그룹 명단
        _buildAllDiscussionGroupsSection(context, discussionGroupList),
      ],
    );
  }

  /// 토론 참여 희망 명단 섹션
  static Widget _buildWantDiscussionSection(
    BuildContext context,
    List<AttendanceIdAndNameModel>? wantList,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 소제목
        Row(
          children: [
            Icon(
              Icons.volunteer_activism,
              size: 20,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Text(
              '토론 참여 희망 명단',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // 내용
        if (wantList == null)
          _buildNoDataMessage(context, '토론 참여 희망 명단 정보를 불러올 수 없습니다.')
        else if (wantList.isEmpty)
          _buildNoDataMessage(context, '토론 참여를 희망하는 모임원이 없습니다.')
        else
          _buildMemberList(context, wantList),
      ],
    );
  }

  /// 모임별 전체 토론 그룹 명단 섹션
  static Widget _buildAllDiscussionGroupsSection(
    BuildContext context,
    DiscussionGroupListResponse? groupList,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 소제목
        Row(
          children: [
            Icon(
              Icons.groups,
              size: 20,
              color: Theme.of(
                context,
              ).colorScheme.primary, // 🔧 secondary → primary
            ),
            const SizedBox(width: 8),
            Text(
              '토론 그룹 구성 현황',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold, // 🔧 w600 → bold
                color: Theme.of(
                  context,
                ).colorScheme.onSurface, // 🔧 secondary → onSurface
                fontSize: 16, // 🔧 크기 증가
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // 내용
        if (groupList == null)
          _buildNoDataMessage(context, '토론 그룹 정보를 불러올 수 없습니다.')
        else if (groupList.groups.isEmpty)
          _buildNoDataMessage(context, '구성된 토론 그룹이 없습니다.')
        else
          _buildDiscussionGroups(context, groupList),
      ],
    );
  }

  /// 데이터 없음 메시지
  static Widget _buildNoDataMessage(BuildContext context, String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(
          context,
        ).colorScheme.surfaceContainerHighest.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            size: 20,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 멤버 목록 표시
  static Widget _buildMemberList(
    BuildContext context,
    List<AttendanceIdAndNameModel> memberList,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 총 인원 표시
          Text(
            '총 ${memberList.length}명',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),

          const SizedBox(height: 8),

          // 멤버 이름들
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: memberList.map((member) {
              return Chip(
                label: Text(
                  member.memberName,
                  style: const TextStyle(fontSize: 12),
                ),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity.compact,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  /// 토론 그룹들 표시
  static Widget _buildDiscussionGroups(
    BuildContext context,
    DiscussionGroupListResponse groupList,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
          width: 1.5, // 🔧 두께 증가
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 총 그룹 수 및 참여자 수 표시
          Text(
            '총 ${groupList.groupCount}개 그룹, ${groupList.totalMemberCount}명 참여',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.bold, // 🔧 w600 → bold
              color: Theme.of(
                context,
              ).colorScheme.onSurface, // 🔧 secondary → onSurface
              fontSize: 14, // 🔧 크기 증가
            ),
          ),

          const SizedBox(height: 12),

          // 각 그룹별 표시
          ...groupList.groups.asMap().entries.map((entry) {
            final groupIndex = entry.key;
            final group = entry.value;

            return Padding(
              padding: EdgeInsets.only(
                bottom: groupIndex < groupList.groups.length - 1 ? 12 : 0,
              ),
              child: _buildSingleDiscussionGroup(
                context,
                groupIndex + 1, // 1부터 시작
                group,
              ),
            );
          }),
        ],
      ),
    );
  }

  /// 개별 토론 그룹 표시
  static Widget _buildSingleDiscussionGroup(
    BuildContext context,
    int groupNumber,
    DiscussionGroupModel group,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
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
                size: 16,
                color: Theme.of(context).colorScheme.primary, // 🔧 더 진한 색상
              ),
              const SizedBox(width: 6),
              Text(
                '$groupNumber조',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold, // 🔧 더 굵게
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface, // 🔧 표준 텍스트 색상
                  fontSize: 15, // 🔧 약간 크게
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '(${group.memberCount}명)',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.7), // 🔧 약간 연하게
                  fontWeight: FontWeight.w500, // 🔧 약간 굵게
                ),
              ),
            ],
          ),

          if (group.members.isNotEmpty) ...[
            const SizedBox(height: 8),

            // 그룹 멤버들
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: group.members.map((member) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10, // 🔧 패딩 증가
                    vertical: 6, // 🔧 패딩 증가
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.primaryContainer, // 🔧 더 진한 배경
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      // 🔧 테두리 추가
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    member.memberName,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontSize: 12, // 🔧 약간 크게
                      fontWeight: FontWeight.w600, // 🔧 더 굵게
                      color: Theme.of(
                        context,
                      ).colorScheme.onPrimaryContainer, // 🔧 대비되는 색상
                    ),
                  ),
                );
              }).toList(),
            ),
          ] else ...[
            const SizedBox(height: 4),
            Text(
              '참여자 없음',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontStyle: FontStyle.italic,
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withOpacity(0.6), // 🔧 더 진한 회색
                fontWeight: FontWeight.w500, // 🔧 약간 굵게
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// 날짜/시간 선택 다이얼로그
  static Future<void> _selectDateTime(
    BuildContext context,
    DateTime? currentDateTime,
    ValueChanged<DateTime?> onChanged,
  ) async {
    try {
      // 1단계: 날짜 선택
      final selectedDate = await showDatePicker(
        context: context,
        initialDate: currentDateTime ?? DateTime.now(),
        firstDate: DateTime(2020),
        lastDate: DateTime(2030),
        locale: const Locale('ko', 'KR'),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: Theme.of(context).colorScheme.copyWith(
                primary: Theme.of(context).colorScheme.primary,
                onPrimary: Theme.of(context).colorScheme.onPrimary,
                surface: Theme.of(context).colorScheme.surface,
                onSurface: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            child: child!,
          );
        },
      );

      if (selectedDate == null) return;

      // 2단계: 시간 선택
      final selectedTime = await showTimePicker(
        context: context,
        initialTime: currentDateTime != null
            ? TimeOfDay.fromDateTime(currentDateTime)
            : const TimeOfDay(hour: 9, minute: 0),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: Theme.of(context).colorScheme.copyWith(
                primary: Theme.of(context).colorScheme.primary,
                onPrimary: Theme.of(context).colorScheme.onPrimary,
                surface: Theme.of(context).colorScheme.surface,
                onSurface: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            child: child!,
          );
        },
      );

      if (selectedTime == null) return;

      // 3단계: 날짜와 시간 결합
      final combinedDateTime = DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
        selectedTime.hour,
        selectedTime.minute,
      );

      // 4단계: 콜백 호출
      onChanged(combinedDateTime);
    } catch (e) {
      // 에러가 발생하면 스낵바로 알림
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('날짜/시간 선택 중 오류가 발생했습니다: $e')));
      }
    }
  }
}
