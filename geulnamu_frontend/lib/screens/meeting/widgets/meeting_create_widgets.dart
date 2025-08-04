import 'package:flutter/material.dart';
import '../../../models/meeting/request/meeting_create_request.dart';
import '../../../core/theme.dart';

/// 모임 만들기 화면 UI 위젯들
///
/// Static Methods로 구성하여 재사용성 극대화
class MeetingCreateWidgets {
  /// 📋 모임 타입 선택 위젯 (SegmentedButton)
  static Widget buildMeetingTypeSelector({
    required BuildContext context,
    required MeetingType selectedType,
    required Function(MeetingType) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '모임 타입',
          style: context.textStyles.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: context.colors.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: SegmentedButton<MeetingType>(
            segments: MeetingType.values
                .map(
                  (type) => ButtonSegment<MeetingType>(
                    value: type,
                    label: Text(type.displayName),
                    icon: Icon(_getMeetingTypeIcon(type)),
                  ),
                )
                .toList(),
            selected: {selectedType},
            onSelectionChanged: (Set<MeetingType> newSelection) {
              onChanged(newSelection.first);
            },
            style: SegmentedButton.styleFrom(
              backgroundColor: context.colors.surface,
              foregroundColor: context.colors.onSurface,
              selectedBackgroundColor: context.colors.primary,
              selectedForegroundColor: context.colors.onPrimary,
            ),
          ),
        ),
        // 설명 제거
      ],
    );
  }

  /// 📝 모임 제목 입력 필드
  static Widget buildMeetingNameField({
    required BuildContext context,
    required TextEditingController controller,
    required String? Function(String?) validator,
    VoidCallback? onChanged, // 실시간 유효성 검사용
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: '모임 제목 *',
        hintText: '예: 12월 정기 독서모임',
        prefixIcon: const Icon(Icons.title),
        border: _getSoftOutlineBorder(context),
        enabledBorder: _getSoftOutlineBorder(context),
        focusedBorder: _getSoftFocusedBorder(context),
        helperText: '한글, 영문, 숫자, 일부 특수문자 사용 가능 (최대 70자)',
        counterText: '',
        fillColor: context.inputFieldBackgroundColor, // 🎨 민트색 배경 적용
        filled: true,
      ),
      validator: validator,
      maxLength: 70,
      textInputAction: TextInputAction.next,
      onChanged: (value) {
        if (onChanged != null) onChanged();
      },
    );
  }

  /// 📅 날짜 선택 필드
  static Widget buildDateTimeSelector({
    required BuildContext context,
    required String label,
    required TextEditingController dateController,
    required TextEditingController timeController,
    required VoidCallback onDateTap,
    required VoidCallback onTimeTap,
    bool isRequired = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isRequired ? '$label *' : label,
          style: context.textStyles.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: context.colors.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            // 날짜 선택
            Expanded(
              flex: 3,
              child: TextFormField(
                controller: dateController,
                readOnly: true,
                enabled: label == '지각 기준 시간' ? false : true, // 지각 기준 날짜는 비활성화
                decoration: InputDecoration(
                  labelText: '날짜',
                  hintText: label == '지각 기준 시간' ? '모임 날짜와 동일' : '날짜 선택',
                  prefixIcon: const Icon(Icons.calendar_today),
                  border: _getSoftOutlineBorder(context),
                  enabledBorder: _getSoftOutlineBorder(context),
                  focusedBorder: _getSoftFocusedBorder(context),
                  suffixIcon: label == '지각 기준 시간'
                      ? null
                      : const Icon(Icons.arrow_drop_down),
                  fillColor: context.inputFieldBackgroundColor, // 🎨 민트색 배경 적용
                  filled: true,
                ),
                onTap: label == '지각 기준 시간' ? null : onDateTap,
                validator: isRequired
                    ? (value) {
                        if (value == null || value.isEmpty) {
                          return '날짜를 선택해주세요';
                        }
                        return null;
                      }
                    : null,
              ),
            ),
            const SizedBox(width: 12),
            // 시간 선택
            Expanded(
              flex: 2,
              child: TextFormField(
                controller: timeController,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: '시간',
                  hintText: '시간 선택',
                  prefixIcon: const Icon(Icons.access_time),
                  border: _getSoftOutlineBorder(context),
                  enabledBorder: _getSoftOutlineBorder(context),
                  focusedBorder: _getSoftFocusedBorder(context),
                  suffixIcon: const Icon(Icons.arrow_drop_down),
                  fillColor: context.inputFieldBackgroundColor, // 🎨 민트색 배경 적용
                  filled: true,
                ),
                onTap: onTimeTap,
                validator: isRequired
                    ? (value) {
                        if (value == null || value.isEmpty) {
                          return '시간을 선택해주세요';
                        }
                        return null;
                      }
                    : null,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// 📍 모임 장소 입력 필드
  static Widget buildMeetingPlaceField({
    required BuildContext context,
    required TextEditingController controller,
    required String? Function(String?) validator,
    VoidCallback? onChanged, // 실시간 유효성 검사용
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: '모임 장소 *',
        hintText: '예: 강남역 1번 출구 앞 카페',
        prefixIcon: const Icon(Icons.location_on),
        border: _getSoftOutlineBorder(context),
        enabledBorder: _getSoftOutlineBorder(context),
        focusedBorder: _getSoftFocusedBorder(context),
        helperText: '구체적인 위치를 입력해주세요 (최대 255자)',
        counterText: '',
        fillColor: context.inputFieldBackgroundColor, // 🎨 민트색 배경 적용
        filled: true,
      ),
      validator: validator,
      maxLength: 255,
      textInputAction: TextInputAction.next,
      onChanged: (value) {
        if (onChanged != null) onChanged();
      },
    );
  }

  /// 📄 상세 설명 입력 필드
  static Widget buildDescriptionField({
    required BuildContext context,
    required TextEditingController controller,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: '상세 설명 (선택)',
        hintText: '모임에 대한 추가 설명을 입력하세요',
        prefixIcon: const Icon(Icons.description),
        border: _getSoftOutlineBorder(context),
        enabledBorder: _getSoftOutlineBorder(context),
        focusedBorder: _getSoftFocusedBorder(context),
        alignLabelWithHint: true,
        fillColor: context.inputFieldBackgroundColor, // 🎨 민트색 배경 적용
        filled: true,
      ),
      maxLines: 4,
      textInputAction: TextInputAction.done,
    );
  }

  /// 🚀 생성 버튼
  static Widget buildCreateButton({
    required BuildContext context,
    required VoidCallback onPressed,
    required bool isLoading,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: isLoading ? null : onPressed,
        icon: isLoading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    context.colors.onPrimary,
                  ),
                ),
              )
            : const Icon(Icons.add_circle),
        label: Text(
          isLoading ? '모임 생성 중...' : '모임 만들기',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: context.colors.primary,
          foregroundColor: context.colors.onPrimary,
          disabledBackgroundColor: context.colors.onSurface.withValues(
            alpha: 0.12,
          ),
          disabledForegroundColor: context.colors.onSurface.withValues(
            alpha: 0.38,
          ),
          elevation: isLoading ? 0 : 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  /// 📋 안내 카드
  static Widget buildInfoCard(BuildContext context) {
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
                  color: context.colors.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  '모임 만들기 안내',
                  style: context.textStyles.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: context.colors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              '• 모든 필수 항목을 입력해야 모임을 생성할 수 있습니다.\n'
              '• 토론 관련 항목은 모임 생성 이후 입력 및 수정이 가능합니다.',
              style: context.textStyles.bodySmall?.copyWith(
                color: context.colors.onSurfaceVariant,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 모임 타입별 아이콘 반환
  static IconData _getMeetingTypeIcon(MeetingType type) {
    switch (type) {
      case MeetingType.regular:
        return Icons.event_repeat;
      case MeetingType.flash:
        return Icons.flash_on;
      case MeetingType.special:
        return Icons.star;
    }
  }

  /// 🌙 다크 모드에서 부드러운 테두리 색상 적용
  static OutlineInputBorder _getSoftOutlineBorder(BuildContext context) {
    // 다크 모드일 때만 부드러운 색상 적용
    final Color borderColor = context.isDarkMode
        ? const Color(0xFF404040) // 부드러운 회색 (기존보다 더 부드럽게)
        : context.colors.outline; // 라이트 모드는 기본 테마 색상 사용

    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(4.0),
      borderSide: BorderSide(color: borderColor, width: 1.0),
    );
  }

  /// 🌙 다크 모드에서 포커스 시 부드러운 테두리 색상 적용
  static OutlineInputBorder _getSoftFocusedBorder(BuildContext context) {
    // 다크 모드일 때만 부드러운 포커스 색상 적용
    final Color focusedBorderColor = context.isDarkMode
        ? context.colors.primary.withValues(alpha: 0.8) // 민트색을 약간 부드럽게
        : context.colors.primary; // 라이트 모드는 기본 primary 색상

    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(4.0),
      borderSide: BorderSide(color: focusedBorderColor, width: 2.0),
    );
  }
}
