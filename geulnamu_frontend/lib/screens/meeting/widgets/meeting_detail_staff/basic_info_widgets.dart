import 'package:flutter/material.dart';
import '../../../../core/theme.dart';
import '../../../../models/meeting/meeting_detail_staff_model.dart';

/// 운영진용 모임 상세 - 기본 정보 섹션 위젯들
class BasicInfoWidgets {
  /// 📋 모임 기본 정보 섹션
  static Widget buildBasicInfoSection(
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

            const SizedBox(height: 16), // 헤더와 콘텐츠 사이 여백

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
          dropdownColor: Theme.of(context).colorScheme.surface,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
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
      case 'LIGHTNING':
        return '번개';
      default:
        return meetingType;
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('날짜/시간 선택 중 오류가 발생했습니다: $e')),
        );
      }
    }
  }
}
