import 'package:flutter/material.dart';
import '../../../models/meeting/meeting_detail_staff_model.dart';
import '../../../widgets/common/loading_widgets.dart';
import 'meeting_detail_staff/basic_info_widgets.dart';
import 'meeting_detail_staff/discussion_widgets.dart';
import 'meeting_detail_staff/management_widgets.dart';
import '../../../models/discussion/attendance_id_and_name_model.dart';
import '../../../models/discussion/discussion_group_model.dart';
import '../../../models/attendance/attendance_status_model.dart';

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
    // 🆕 편집 가능 여부 체크 (=날짜 기반 제한)
    required bool canEditMeetingInfo,
    required bool canEditDiscussionGroups,
    required VoidCallback onToggleBasicEdit,
    required VoidCallback onToggleDiscussionEdit,
    required VoidCallback onSaveBasicInfo,
    required VoidCallback onSaveDiscussionInfo,
    required VoidCallback onDeleteMeeting,
    required VoidCallback onTogglePrivacy,
    // 🆕 출석 관리 콜백들
    required VoidCallback onQrDisplayTap,
    required VoidCallback onViewAsUserTap,
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
    // 🆕 토론 조 관련 콜백들
    required bool Function() onGetDiscussionGroupLoading,
    required List<AttendanceIdAndNameModel>? Function() onGetWantDiscussionList,
    required DiscussionGroupListResponse? Function() onGetDiscussionGroupList,
    required String? Function() onGetDiscussionGroupErrorMessage,
    required VoidCallback onRefreshDiscussionGroupData,
    // 🆕 토론 그룹 편집 콜백들
    required bool isEditingDiscussionGroups,
    required Map<int, List<AttendanceIdAndNameModel>> editingGroups,
    required List<AttendanceIdAndNameModel> editingUnassignedMembers,
    required VoidCallback onToggleDiscussionGroupEdit,
    required VoidCallback onSaveDiscussionGroupChanges,
    required void Function(AttendanceIdAndNameModel member, int targetGroupNumber) onMoveMemberToGroup,
    required void Function(AttendanceIdAndNameModel member) onRemoveMemberFromGroup,
    required VoidCallback onCreateNewGroup,
    required VoidCallback onClearAllGroups,
    // 🆕 인원 추가 기능 관련 콜백들
    required bool canAddMembers,
    required List<AttendanceStatus> availableMembersToAdd,
    required void Function(AttendanceStatus) onAddMember,
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

          // 🆕 토론 조 정보 섹션 (토론 시간이 설정된 경우에만 표시)
          if (meetingDetail.discussionTime != null) ...[
            const SizedBox(height: 16),
            DiscussionWidgets.buildDiscussionGroupSection(
              context,
              meetingDetail,
              isLoading: onGetDiscussionGroupLoading(),
              wantDiscussionList: onGetWantDiscussionList(),
              discussionGroupList: onGetDiscussionGroupList(),
              errorMessage: onGetDiscussionGroupErrorMessage(),
              onRefresh: onRefreshDiscussionGroupData,
              // 🆕 편집 관련 매개변수들 추가
              isEditingDiscussionGroups: isEditingDiscussionGroups,
              isSaving: isSaving,
              editingGroups: editingGroups,
              editingUnassignedMembers: editingUnassignedMembers,
              onToggleDiscussionGroupEdit: onToggleDiscussionGroupEdit,
              onSaveDiscussionGroupChanges: onSaveDiscussionGroupChanges,
              onMoveMemberToGroup: onMoveMemberToGroup,
              onRemoveMemberFromGroup: onRemoveMemberFromGroup,
              onCreateNewGroup: onCreateNewGroup,
              onClearAllGroups: onClearAllGroups,
              // 🆕 인원 추가 기능 매개변수 전달
              canAddMembers: canAddMembers,
              availableMembersToAdd: availableMembersToAdd,
              onAddMember: onAddMember,
            ),
          ],

          const SizedBox(height: 16),

          // 📱 출석 관리 섹션
          ManagementWidgets.buildAttendanceManagementSection(
            context,
            meetingDetail,
            onQrDisplayTap: onQrDisplayTap,
            onViewAsUserTap: onViewAsUserTap,
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
