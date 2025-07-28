import 'package:flutter/material.dart';
import '../../../core/theme.dart';
import '../../../models/meeting/meeting_detail_staff_model.dart';
import '../../../widgets/common/loading_widgets.dart';

/// 운영진용 모임 상세 화면 UI 위젯들
///
/// Static Methods로 구현하여 상태 관리와 분리
class MeetingDetailStaffWidgets {
  /// 로딩 화면
  static Widget buildLoading(BuildContext context) {
    return LoadingWidgets.buildFullScreenLoading(
      context,
      message: '모임 정보를 불러오는 중...',
    );
  }

  /// 🔥 권한 안내 섹션
  static Widget _buildPermissionGuide(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  '📝 권한 안내',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.surfaceContainerHighest.withOpacity(0.5),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                ),
              ),
              child: Text(
                '• 모임 삭제: 모임 생성자 또는 관리자급 권한(모임장, 부모임장, 관지라)만 가능\n'
                '• 삭제 시간 제한: 모임 개최 6시간 전까지만 삭제 가능\n'
                '• 비공개/공개 처리: 관리자급 권한(모임장, 부모임장, 관리자)만 가능',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 에러 화면
  static Widget buildError(
    BuildContext context, {
    required String message,
    required VoidCallback onRetry,
  }) {
    return LoadingWidgets.buildRefreshableLoading(
      context,
      message: message,
      onRefresh: onRetry,
    );
  }

  /// 메인 콘텐츠
  static Widget buildMainContent(
    BuildContext context,
    MeetingDetailStaffInfo meetingDetail, {
    required bool isEditingBasicInfo,
    required bool isEditingDiscussion,
    required bool isSaving,
    required bool canDeleteMeeting,
    required bool canManagePrivacy,
    required VoidCallback onToggleBasicEdit,
    required VoidCallback onToggleDiscussionEdit,
    required VoidCallback onSaveBasicInfo,
    required VoidCallback onSaveDiscussionInfo,
    required VoidCallback onDeleteMeeting,
    required VoidCallback onTogglePrivacy,
    // 폼 컨트롤러들
    required TextEditingController meetingNameController,
    required TextEditingController meetingPlaceController,
    required TextEditingController descriptionController,
    required TextEditingController alarmMessageController,
    // 선택된 값들
    required String? selectedMeetingType,
    required DateTime? selectedMeetingDateTime,
    required DateTime? selectedLateThresholdTime,
    required DateTime? selectedDiscussionTime,
    required bool isDiscussionTimeCleared, // 🆕 X 버튼 상태 추가
    // 변경 콜백들
    required ValueChanged<String?> onMeetingTypeChanged,
    required ValueChanged<DateTime?> onMeetingDateTimeChanged,
    required ValueChanged<DateTime?> onLateThresholdTimeChanged,
    required ValueChanged<DateTime?> onDiscussionTimeChanged,
    required VoidCallback onClearDiscussionTime, // 🆕 X 버튼 콜백 추가
  }) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🆕 운영진용 헤더 (비공개 여부 표시)
          _buildStaffHeader(context, meetingDetail),

          const SizedBox(height: 16),

          // 📋 모임 기본 정보 섹션
          _buildBasicInfoSection(
            context,
            meetingDetail,
            isEditing: isEditingBasicInfo,
            isSaving: isSaving,
            onToggleEdit: onToggleBasicEdit,
            onSave: onSaveBasicInfo,
            meetingNameController: meetingNameController,
            meetingPlaceController: meetingPlaceController,
            descriptionController: descriptionController,
            selectedMeetingType: selectedMeetingType,
            selectedMeetingDateTime: selectedMeetingDateTime,
            selectedLateThresholdTime: selectedLateThresholdTime,
            onMeetingTypeChanged: onMeetingTypeChanged,
            onMeetingDateTimeChanged: onMeetingDateTimeChanged,
            onLateThresholdTimeChanged: onLateThresholdTimeChanged,
          ),

          const SizedBox(height: 16),

          // 💬 토론 정보 섹션
          _buildDiscussionSection(
            context,
            meetingDetail,
            isEditing: isEditingDiscussion,
            isSaving: isSaving,
            onToggleEdit: onToggleDiscussionEdit,
            onSave: onSaveDiscussionInfo,
            alarmMessageController: alarmMessageController,
            selectedDiscussionTime: selectedDiscussionTime,
            isDiscussionTimeCleared: isDiscussionTimeCleared, // 🆕 X 버튼 상태 전달
            onDiscussionTimeChanged: onDiscussionTimeChanged,
            onClearDiscussionTime: onClearDiscussionTime, // 🆕 X 버튼 콜백 전달
          ),

          const SizedBox(height: 16),

          // 🔥 권한 안내를 토론 정보 하단으로 이동
          _buildPermissionGuide(context),

          const SizedBox(height: 16),

          // 🔧 관리 기능 섹션
          _buildManagementSection(
            context,
            meetingDetail,
            canDeleteMeeting: canDeleteMeeting,
            canManagePrivacy: canManagePrivacy,
            isSaving: isSaving,
            onDeleteMeeting: onDeleteMeeting,
            onTogglePrivacy: onTogglePrivacy,
          ),
        ],
      ),
    );
  }

  /// 🆕 운영진용 헤더 (비공개 여부 표시)
  static Widget _buildStaffHeader(
    BuildContext context,
    MeetingDetailStaffInfo meetingDetail,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.admin_panel_settings,
                  color: context.colors.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  '운영진용 모임 관리',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: context.colors.primary,
                  ),
                ),
                const Spacer(),
                // 비공개 여부 표시
                if (meetingDetail.isPrivateMeeting)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.orange),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.lock, size: 16, color: Colors.orange[700]),
                        const SizedBox(width: 4),
                        Text(
                          '비공개',
                          style: TextStyle(
                            color: Colors.orange[700],
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.green),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.public, size: 16, color: Colors.green[700]),
                        const SizedBox(width: 4),
                        Text(
                          '공개',
                          style: TextStyle(
                            color: Colors.green[700],
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '생성자: ${meetingDetail.meetingCreatorName}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
            ),
            Text(
              '모임번호: ${meetingDetail.meetingId}', // 🔥 모임번호 추가
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
            ),
            Text(
              '생성일: ${_formatDateTime(meetingDetail.createdAt)}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 📋 모임 기본 정보 섹션
  static Widget _buildBasicInfoSection(
    BuildContext context,
    MeetingDetailStaffInfo meetingDetail, {
    required bool isEditing,
    required bool isSaving,
    required VoidCallback onToggleEdit,
    required VoidCallback onSave,
    required TextEditingController meetingNameController,
    required TextEditingController meetingPlaceController,
    required TextEditingController descriptionController,
    required String? selectedMeetingType,
    required DateTime? selectedMeetingDateTime,
    required DateTime? selectedLateThresholdTime,
    required ValueChanged<String?> onMeetingTypeChanged,
    required ValueChanged<DateTime?> onMeetingDateTimeChanged,
    required ValueChanged<DateTime?> onLateThresholdTimeChanged,
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
              '📋 모임 기본 정보',
              isEditing: isEditing,
              isSaving: isSaving,
              onToggleEdit: onToggleEdit,
              onSave: onSave,
            ),

            // 내용 (조회 모드 vs 편집 모드)
            if (isEditing)
              _buildBasicInfoEditForm(
                context,
                meetingNameController: meetingNameController,
                meetingPlaceController: meetingPlaceController,
                descriptionController: descriptionController,
                selectedMeetingType: selectedMeetingType,
                selectedMeetingDateTime: selectedMeetingDateTime,
                selectedLateThresholdTime: selectedLateThresholdTime,
                onMeetingTypeChanged: onMeetingTypeChanged,
                onMeetingDateTimeChanged: onMeetingDateTimeChanged,
                onLateThresholdTimeChanged: onLateThresholdTimeChanged,
              )
            else
              _buildBasicInfoDisplay(context, meetingDetail),
          ],
        ),
      ),
    );
  }

  /// 💬 토론 정보 섹션
  static Widget _buildDiscussionSection(
    BuildContext context,
    MeetingDetailStaffInfo meetingDetail, {
    required bool isEditing,
    required bool isSaving,
    required VoidCallback onToggleEdit,
    required VoidCallback onSave,
    required TextEditingController alarmMessageController,
    required DateTime? selectedDiscussionTime,
    required bool isDiscussionTimeCleared, // 🆕 X 버튼 상태 추가
    required ValueChanged<DateTime?> onDiscussionTimeChanged,
    required VoidCallback onClearDiscussionTime, // 🆕 X 버튼 콜백 추가
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
                isDiscussionTimeCleared:
                    isDiscussionTimeCleared, // 🆕 X 버튼 상태 전달
                onDiscussionTimeChanged: onDiscussionTimeChanged,
                onClearDiscussionTime: onClearDiscussionTime, // 🆕 X 버튼 콜백 전달
              )
            else
              _buildDiscussionDisplay(context, meetingDetail),
          ],
        ),
      ),
    );
  }

  /// 🔧 관리 기능 섹션
  static Widget _buildManagementSection(
    BuildContext context,
    MeetingDetailStaffInfo meetingDetail, {
    required bool canDeleteMeeting,
    required bool canManagePrivacy,
    required bool isSaving,
    required VoidCallback onDeleteMeeting,
    required VoidCallback onTogglePrivacy,
  }) {
    // 권한이 없으면 표시하지 않음
    if (!canDeleteMeeting && !canManagePrivacy) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.settings, color: context.colors.primary, size: 20),
                const SizedBox(width: 8),
                Text(
                  '🔧 관리 기능',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: context.colors.primary, // 다크 모드에서 명확한 색상
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // 버튼들
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                // 비공개/공개 토글 버튼 (관리자만)
                if (canManagePrivacy)
                  ElevatedButton.icon(
                    onPressed: isSaving ? null : onTogglePrivacy,
                    icon: Icon(
                      meetingDetail.isPrivateMeeting
                          ? Icons.public
                          : Icons.lock,
                    ),
                    label: Text(
                      meetingDetail.isPrivateMeeting ? '공개로 변경' : '비공개로 변경',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: meetingDetail.isPrivateMeeting
                          ? Colors.green
                          : Colors.orange,
                      foregroundColor: Colors.white,
                    ),
                  ),

                // 삭제 버튼 (생성자 또는 관리자)
                if (canDeleteMeeting)
                  ElevatedButton.icon(
                    onPressed: isSaving ? null : onDeleteMeeting,
                    icon: const Icon(Icons.delete),
                    label: const Text('모임 삭제'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                  ),
              ],
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
            color: Theme.of(context).colorScheme.primary, // 다크 모드에서 명확한 색상
          ),
        ),
        const Spacer(),
        if (isEditing)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 취소 버튼
              TextButton(
                onPressed: isSaving ? null : onToggleEdit,
                child: const Text('취소'),
              ),
              const SizedBox(width: 8),
              // 저장 버튼
              ElevatedButton.icon(
                onPressed: isSaving ? null : onSave,
                icon: isSaving
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save),
                label: Text(isSaving ? '저장 중...' : '저장'),
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

  /// 모임 기본 정보 표시 (조회 모드)
  static Widget _buildBasicInfoDisplay(
    BuildContext context,
    MeetingDetailStaffInfo meetingDetail,
  ) {
    return Column(
      children: [
        _buildInfoRow(context, '모임 이름', meetingDetail.meetingName),
        _buildInfoRow(
          context,
          '모임 유형',
          _getMeetingTypeDisplayName(meetingDetail.meetingType),
        ),
        _buildInfoRow(
          context,
          '개최 일시',
          _formatDateTime(meetingDetail.meetingDateTime),
        ),
        _buildInfoRow(
          context,
          '지각 기준',
          _formatDateTime(meetingDetail.lateThresholdTime),
        ),
        _buildInfoRow(context, '장소', meetingDetail.meetingPlace),
        _buildInfoRow(
          context,
          '설명',
          meetingDetail.description ?? '설명 없음',
          isMultiline: true,
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

  /// 모임 기본 정보 편집 폼
  static Widget _buildBasicInfoEditForm(
    BuildContext context, {
    required TextEditingController meetingNameController,
    required TextEditingController meetingPlaceController,
    required TextEditingController descriptionController,
    required String? selectedMeetingType,
    required DateTime? selectedMeetingDateTime,
    required DateTime? selectedLateThresholdTime,
    required ValueChanged<String?> onMeetingTypeChanged,
    required ValueChanged<DateTime?> onMeetingDateTimeChanged,
    required ValueChanged<DateTime?> onLateThresholdTimeChanged,
  }) {
    return Column(
      children: [
        // 모임 이름
        TextFormField(
          controller: meetingNameController,
          decoration: const InputDecoration(
            labelText: '모임 이름',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),

        // 모임 유형 (다크 모드 색상 개선)
        DropdownButtonFormField<String>(
          value: selectedMeetingType,
          decoration: const InputDecoration(
            labelText: '모임 유형',
            border: OutlineInputBorder(),
          ),
          dropdownColor: Theme.of(context).colorScheme.surface, // 다크 모드 배경색 적용
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: Theme.of(context).colorScheme.onSurface, // 다크 모드 텍스트 색상
          ),
          items: [
            DropdownMenuItem(
              value: 'REGULAR',
              child: Text(
                '정기',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
            DropdownMenuItem(
              value: 'SPECIAL',
              child: Text(
                '특수',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
            DropdownMenuItem(
              value: 'FLASH',
              child: Text(
                '번개',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
          ],
          onChanged: onMeetingTypeChanged,
        ),
        const SizedBox(height: 16),

        // 모임 일시 (실제 날짜/시간 선택기)
        TextFormField(
          readOnly: true,
          decoration: const InputDecoration(
            labelText: '모임 일시',
            border: OutlineInputBorder(),
            suffixIcon: Icon(Icons.calendar_today),
          ),
          controller: TextEditingController(
            text: selectedMeetingDateTime != null
                ? _formatDateTime(selectedMeetingDateTime)
                : '',
          ),
          onTap: () => _selectDateTime(
            context,
            selectedMeetingDateTime,
            onMeetingDateTimeChanged,
          ),
        ),
        const SizedBox(height: 16),

        // 지각 기준 시간 (실제 시간 선택기)
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              readOnly: true,
              decoration: const InputDecoration(
                labelText: '지각 기준 시간',
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.access_time),
              ),
              controller: TextEditingController(
                text: selectedLateThresholdTime != null
                    ? _formatDateTime(selectedLateThresholdTime)
                    : '',
              ),
              onTap: () => _selectDateTime(
                context,
                selectedLateThresholdTime,
                onLateThresholdTimeChanged,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '📅 모임 당일에 개최 일시 이상으로 설정 가능합니다. (같은 시간 포함)',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // 장소
        TextFormField(
          controller: meetingPlaceController,
          decoration: const InputDecoration(
            labelText: '모임 장소',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),

        // 설명
        TextFormField(
          controller: descriptionController,
          decoration: const InputDecoration(
            labelText: '모임 설명',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
      ],
    );
  }

  /// 토론 정보 편집 폼
  static Widget _buildDiscussionEditForm(
    BuildContext context, {
    required TextEditingController alarmMessageController,
    required DateTime? selectedDiscussionTime,
    required bool isDiscussionTimeCleared, // 🆕 X 버튼 상태 추가
    required ValueChanged<DateTime?> onDiscussionTimeChanged,
    required VoidCallback onClearDiscussionTime, // 🆕 X 버튼 콜백 추가
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
            if (selectedDiscussionTime != null ||
                isDiscussionTimeCleared) // 🆕 조건 수정
              IconButton(
                onPressed: onClearDiscussionTime, // 🆕 X 버튼 콜백 사용
                icon: const Icon(Icons.clear),
                tooltip: '토론 시간 및 알림 메시지를 모두 초기화합니다', // 🆕 툴팁 메시지 변경
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
            // 🆕 토론 시간이 설정되지 않은 경우 비활성화 안내
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
          // 🆕 토론 시간이 없어도 입력은 가능 (내용 보존을 위해)
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

  /// 모임 유형 한글 변환
  static String _getMeetingTypeDisplayName(String meetingType) {
    switch (meetingType) {
      case 'REGULAR':
        return '정기';
      case 'SPECIAL':
        return '특수';
      case 'FLASH':
      case 'LIGHTNING': // 기존 데이터 호환성
        return '번개';
      default:
        return meetingType; // 알 수 없는 값은 그대로 표시
    }
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
