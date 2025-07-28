import 'package:flutter/material.dart';
import '../../../../core/theme.dart';
import '../../../../models/meeting/meeting_detail_staff_model.dart';

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
            helperText: selectedDiscussionTime == null || isDiscussionTimeCleared
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('날짜/시간 선택 중 오류가 발생했습니다: $e')),
        );
      }
    }
  }
}
