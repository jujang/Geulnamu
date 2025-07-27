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
    // 변경 콜백들
    required ValueChanged<String?> onMeetingTypeChanged,
    required ValueChanged<DateTime?> onMeetingDateTimeChanged,
    required ValueChanged<DateTime?> onLateThresholdTimeChanged,
    required ValueChanged<DateTime?> onDiscussionTimeChanged,
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
            onDiscussionTimeChanged: onDiscussionTimeChanged,
          ),

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
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
            
            const SizedBox(height: 16),

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
    required ValueChanged<DateTime?> onDiscussionTimeChanged,
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
                onDiscussionTimeChanged: onDiscussionTimeChanged,
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
                Icon(
                  Icons.settings,
                  color: context.colors.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  '🔧 관리 기능',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
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
                    icon: Icon(meetingDetail.isPrivateMeeting ? Icons.public : Icons.lock),
                    label: Text(meetingDetail.isPrivateMeeting ? '공개로 변경' : '비공개로 변경'),
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
        _buildInfoRow(context, '모임 유형', meetingDetail.meetingType),
        _buildInfoRow(context, '개최 일시', _formatDateTime(meetingDetail.meetingDateTime)),
        _buildInfoRow(context, '지각 기준', _formatDateTime(meetingDetail.lateThresholdTime)),
        _buildInfoRow(context, '장소', meetingDetail.meetingPlace),
        _buildInfoRow(context, '설명', meetingDetail.description, isMultiline: true),
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
        _buildInfoRow(context, '토론 시간', _formatDateTime(meetingDetail.discussionTime)),
        _buildInfoRow(context, '알림 메시지', meetingDetail.alarmMessage, isMultiline: true),
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

        // 모임 유형
        DropdownButtonFormField<String>(
          value: selectedMeetingType,
          decoration: const InputDecoration(
            labelText: '모임 유형',
            border: OutlineInputBorder(),
          ),
          items: const [
            DropdownMenuItem(value: 'REGULAR', child: Text('정기 모임')),
            DropdownMenuItem(value: 'SPECIAL', child: Text('특별 모임')),
            DropdownMenuItem(value: 'LIGHTNING', child: Text('번개 모임')),
          ],
          onChanged: onMeetingTypeChanged,
        ),
        const SizedBox(height: 16),

        // 모임 일시 (TODO: 실제 날짜 선택기 구현)
        TextFormField(
          readOnly: true,
          decoration: const InputDecoration(
            labelText: '모임 일시',
            border: OutlineInputBorder(),
            suffixIcon: Icon(Icons.calendar_today),
          ),
          controller: TextEditingController(
            text: selectedMeetingDateTime != null 
              ? _formatDateTime(selectedMeetingDateTime!) 
              : '',
          ),
          onTap: () {
            // TODO: 날짜/시간 선택 다이얼로그 구현
          },
        ),
        const SizedBox(height: 16),

        // 지각 기준 시간 (TODO: 실제 시간 선택기 구현)
        TextFormField(
          readOnly: true,
          decoration: const InputDecoration(
            labelText: '지각 기준 시간',
            border: OutlineInputBorder(),
            suffixIcon: Icon(Icons.access_time),
          ),
          controller: TextEditingController(
            text: selectedLateThresholdTime != null 
              ? _formatDateTime(selectedLateThresholdTime!) 
              : '',
          ),
          onTap: () {
            // TODO: 시간 선택 다이얼로그 구현
          },
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
    required ValueChanged<DateTime?> onDiscussionTimeChanged,
  }) {
    return Column(
      children: [
        // 토론 시간 (TODO: 실제 시간 선택기 구현)
        TextFormField(
          readOnly: true,
          decoration: const InputDecoration(
            labelText: '토론 시간',
            border: OutlineInputBorder(),
            suffixIcon: Icon(Icons.access_time),
          ),
          controller: TextEditingController(
            text: selectedDiscussionTime != null 
              ? _formatDateTime(selectedDiscussionTime!) 
              : '',
          ),
          onTap: () {
            // TODO: 시간 선택 다이얼로그 구현
          },
        ),
        const SizedBox(height: 16),

        // 알림 메시지
        TextFormField(
          controller: alarmMessageController,
          decoration: const InputDecoration(
            labelText: '알림 메시지',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
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
        crossAxisAlignment: isMultiline ? CrossAxisAlignment.start : CrossAxisAlignment.center,
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
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
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
}
