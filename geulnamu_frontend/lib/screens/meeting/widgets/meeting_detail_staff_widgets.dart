import 'package:flutter/material.dart';
import '../../../models/meeting/meeting_detail_staff_model.dart';
import '../../../widgets/common/loading_widgets.dart';
import 'meeting_detail_staff/basic_info_widgets.dart';
import 'meeting_detail_staff/discussion_widgets.dart';
import 'meeting_detail_staff/management_widgets.dart';

/// 운영진용 모임 상세 화면 메인 위젯들
///
/// 분할된 섹션들을 조합하여 완전한 화면을 구성
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

  /// 메인 콘텐츠 (분할된 섹션들 조합)
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
    required bool isDiscussionTimeCleared,
    // 변경 콜백들
    required ValueChanged<String?> onMeetingTypeChanged,
    required ValueChanged<DateTime?> onMeetingDateTimeChanged,
    required ValueChanged<DateTime?> onLateThresholdTimeChanged,
    required ValueChanged<DateTime?> onDiscussionTimeChanged,
    required VoidCallback onClearDiscussionTime,
  }) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🆕 운영진용 헤더 (비공개 여부 표시)
          ManagementWidgets.buildStaffHeader(context, meetingDetail),

          const SizedBox(height: 16),

          // 📋 모임 기본 정보 섹션
          BasicInfoWidgets.buildBasicInfoSection(
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
          DiscussionWidgets.buildDiscussionSection(
            context,
            meetingDetail,
            isEditing: isEditingDiscussion,
            isSaving: isSaving,
            onToggleEdit: onToggleDiscussionEdit,
            onSave: onSaveDiscussionInfo,
            alarmMessageController: alarmMessageController,
            selectedDiscussionTime: selectedDiscussionTime,
            isDiscussionTimeCleared: isDiscussionTimeCleared,
            onDiscussionTimeChanged: onDiscussionTimeChanged,
            onClearDiscussionTime: onClearDiscussionTime,
          ),

          const SizedBox(height: 16),

          // 🔥 권한 안내 섹션
          ManagementWidgets.buildPermissionGuide(context),

          const SizedBox(height: 16),

          // 🔧 관리 기능 섹션
          ManagementWidgets.buildManagementSection(
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
}
