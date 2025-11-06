import 'package:flutter/material.dart';
import '../../../core/theme.dart';
import '../../../core/colors.dart';
import '../../../models/meeting/meeting_model.dart';
import '../../../models/meeting/meeting_filter_model.dart';
import 'meeting_list_widgets.dart';
import 'meeting_filter_widgets.dart';
import 'meeting_staff_widgets.dart';

/// 모임 관련 핵심 UI 위젯들
///
/// Static Methods로 구현하여 재사용성 극대화
/// 분할된 위젯들을 통합하여 제공하는 메인 클래스
class MeetingWidgets {
  // ==================== 모임 카드 위젯들 ====================

  /// 모임 카드 위젯 (일반 사용자용)
  ///
  /// [meeting] 모임 정보
  /// [onTap] 카드 탭 콜백 (향후 상세보기 기능)
  /// [onAttendance] 🆕 QR 출석 버튼 콜백
  /// [onAttendanceCheck] 출석현황 확인 버튼 콜백
  static Widget buildMeetingCard(
    BuildContext context,
    MeetingInfo meeting, {
    VoidCallback? onTap,
    VoidCallback? onAttendance,
    VoidCallback? onAttendanceCheck,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Theme.of(context).brightness == Brightness.light
              ? context.colors.outline.withOpacity(0.2)
              : Colors.transparent,
          width: 0.5,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🎯 상단: 모임 제목 + 모임 유형 배지
              Row(
                children: [
                  Expanded(
                    child: Text(
                      meeting.meetingName,
                      style: context.textStyles.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: context.colors.onSurface,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _buildMeetingTypeBadge(context, meeting.meetingType),
                ],
              ),

              const SizedBox(height: 12),

              // 🎯 정보 행들
              Column(
                children: [
                  // 모임 개최일시 + 모임 장소
                  _buildInfoRow(
                    context,
                    icon: Icons.schedule,
                    label: '개최일시',
                    value: meeting.displayMeetingDateTime,
                    secondIcon: Icons.location_on_outlined,
                    secondLabel: '장소',
                    secondValue: meeting.meetingPlace,
                  ),

                  const SizedBox(height: 8),

                  // 토론 시간 + 모임 개설자
                  _buildInfoRow(
                    context,
                    icon: Icons.chat_bubble_outline,
                    label: '토론시간',
                    value: meeting.displayDiscussionTime,
                    secondIcon: Icons.person_outline,
                    secondLabel: '개설자',
                    secondValue: meeting.meetingCreatorName,
                  ),

                  const SizedBox(height: 8),

                  // 출석 상태 + 모임 번호
                  _buildInfoRow(
                    context,
                    icon: Icons.check_circle_outline,
                    label: '출석상태',
                    value: meeting.attendanceStatusDisplayName,
                    valueColor: _getAttendanceStatusColor(
                      context,
                      meeting.attendanceStatus,
                    ),
                    secondIcon: Icons.tag,
                    secondLabel: '모임번호',
                    secondValue: '${meeting.meetingId}', // # 기호 제거
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // 🎯 하단: 출석 버튼들 (5:5 비율)
              Row(
                children: [
                  // 왼쪽: 출석 버튼 (QR 출석) - 출석 상태에 따라 비활성화
                  Expanded(
                    child: ElevatedButton.icon(
                      // 출석, 지각, 불참 상태일 때 비활성화
                      onPressed:
                          _isAttendanceButtonDisabled(meeting.attendanceStatus?.value)
                          ? null
                          : onAttendance,
                      icon: Icon(
                        Icons.qr_code_scanner,
                        size: 18,
                        color:
                            _isAttendanceButtonDisabled(
                              meeting.attendanceStatus?.value,
                            )
                            ? context.colors.onSurface.withOpacity(0.38)
                            : context.colors.onPrimary,
                      ),
                      label: Text(
                        '출석',
                        style: TextStyle(
                          color:
                              _isAttendanceButtonDisabled(
                                meeting.attendanceStatus?.toString(),
                              )
                              ? context.colors.onSurface.withOpacity(0.38)
                              : context.colors.onPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            _isAttendanceButtonDisabled(
                              meeting.attendanceStatus?.value,
                            )
                            ? context.colors.onSurface.withOpacity(0.12)
                            : context.colors.primary,
                        foregroundColor:
                            _isAttendanceButtonDisabled(
                              meeting.attendanceStatus?.value,
                            )
                            ? context.colors.onSurface.withOpacity(0.38)
                            : context.colors.onPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        // Material 3 스타일의 비활성화된 버튼 색상
                        disabledBackgroundColor: context.colors.onSurface
                            .withOpacity(0.12),
                        disabledForegroundColor: context.colors.onSurface
                            .withOpacity(0.38),
                      ),
                    ),
                  ),

                  const SizedBox(width: 8),

                  // 오른쪽: 출석 현황 버튼
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onAttendanceCheck,
                      icon: Icon(
                        Icons.people_outline,
                        size: 18,
                        color: context.colors.primary,
                      ),
                      label: Text(
                        '출석 현황',
                        style: TextStyle(
                          color: context.colors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: context.colors.primary),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==================== 공통 헬퍼 메서드들 ====================

  /// 출석 버튼 비활성화 여부 확인
  /// 출석, 지각, 불참 상태일 때 비활성화
  static bool _isAttendanceButtonDisabled(String? attendanceStatus) {
    if (attendanceStatus == null || attendanceStatus.isEmpty) return false;
    
    // 출석 상태가 '출석', '지각', '불참'일 때 비활성화
    const disabledStatuses = ['ATTEND', 'ATTEND_LATE', 'NOT_ATTEND'];
    return disabledStatuses.contains(attendanceStatus);
  }

  /// 출석 상태 색상 가져오기
  /// AttendanceStatus enum의 colorName을 활용하여 colors.dart의 정의된 색상과 매핑
  static Color _getAttendanceStatusColor(
    BuildContext context,
    AttendanceStatus? attendanceStatus,
  ) {
    if (attendanceStatus == null) {
      return context.colors.onSurfaceVariant;
    }

    switch (attendanceStatus.colorName) {
      case 'green':
        return GeulnamuColors.success;  // 출석 - 초록색
      case 'orange':
        return GeulnamuColors.warning;  // 지각 - 주황색
      case 'grey':
        return context.colors.onSurfaceVariant;  // 불참 - 회색
      case 'blue':
        return GeulnamuColors.info;  // 진행 전 - 파란색
      default:
        return context.colors.onSurfaceVariant;
    }
  }

  /// 모임 유형 배지 위젯
  static Widget _buildMeetingTypeBadge(
    BuildContext context,
    MeetingType meetingType,
  ) {
    Color badgeColor;

    switch (meetingType) {
      case MeetingType.regular:
        badgeColor = Colors.blue;
        break;
      case MeetingType.flash:
        badgeColor = Colors.orange;
        break;
      case MeetingType.special:
        badgeColor = Colors.purple;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: badgeColor.withOpacity(0.3), width: 1),
      ),
      child: Text(
        meetingType.displayName,
        style: context.textStyles.labelSmall?.copyWith(
          color: badgeColor,
          fontWeight: FontWeight.w600,
          fontSize: 11,
        ),
      ),
    );
  }

  /// 정보 행 위젯 (2개 정보를 한 행에 표시)
  static Widget _buildInfoRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
    IconData? secondIcon,
    String? secondLabel,
    String? secondValue,
    Color? secondValueColor,
  }) {
    return Row(
      children: [
        // 첫 번째 정보
        Expanded(
          child: Row(
            children: [
              Icon(
                icon,
                size: 18,
                color: context.colors.onSurface.withOpacity(0.65),
              ),
              const SizedBox(width: 6),
              Text(
                '$label: ',
                style: context.textStyles.bodySmall?.copyWith(
                  color: context.colors.onSurface.withOpacity(0.55),
                  fontSize: 14,
                  fontWeight: Theme.of(context).brightness == Brightness.light
                      ? FontWeight.w600
                      : FontWeight.w500,
                ),
              ),
              Expanded(
                child: Text(
                  value,
                  style: context.textStyles.bodySmall?.copyWith(
                    color: valueColor ?? context.colors.onSurface,
                    fontWeight: Theme.of(context).brightness == Brightness.light
                        ? FontWeight.w600
                        : FontWeight.w500,
                    fontSize: 14,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),

        // 두 번째 정보 (있는 경우)
        if (secondIcon != null &&
            secondLabel != null &&
            secondValue != null) ...[
          const SizedBox(width: 16),
          Expanded(
            child: Row(
              children: [
                Icon(
                  secondIcon,
                  size: 18,
                  color: context.colors.onSurface.withOpacity(0.65),
                ),
                const SizedBox(width: 6),
                Text(
                  '$secondLabel: ',
                  style: context.textStyles.bodySmall?.copyWith(
                    color: context.colors.onSurface.withOpacity(0.55),
                    fontSize: 14,
                    fontWeight: Theme.of(context).brightness == Brightness.light
                        ? FontWeight.w600
                        : FontWeight.w500,
                  ),
                ),
                Expanded(
                  child: Text(
                    secondValue,
                    style: context.textStyles.bodySmall?.copyWith(
                      color: secondValueColor ?? context.colors.onSurface,
                      fontWeight:
                          Theme.of(context).brightness == Brightness.light
                          ? FontWeight.w600
                          : FontWeight.w500,
                      fontSize: 14,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  // ==================== 분할된 위젯들에 대한 위임 메서드들 ====================

  // 목록 관련 위젯들 (MeetingListWidgets에 위임)
  static Widget buildPagination(
    BuildContext context, {
    required int currentPage,
    required int totalPages,
    required Function(int) onPageChanged,
  }) => MeetingListWidgets.buildPagination(
    context,
    currentPage: currentPage,
    totalPages: totalPages,
    onPageChanged: onPageChanged,
  );

  static Widget buildLoading(BuildContext context) =>
      MeetingListWidgets.buildLoading(context);

  static Widget buildError(
    BuildContext context, {
    required String message,
    VoidCallback? onRetry,
  }) => MeetingListWidgets.buildError(
    context,
    message: message,
    onRetry: onRetry,
  );

  static Widget buildEmptyList(BuildContext context) =>
      MeetingListWidgets.buildEmptyList(context);

  static Widget buildListHeader(
    BuildContext context, {
    required int totalElements,
    required MeetingListFilter currentFilter,
  }) => MeetingListWidgets.buildListHeader(
    context,
    totalElements: totalElements,
    currentFilter: currentFilter,
  );

  static Widget buildFilterFab(BuildContext context, VoidCallback onPressed) =>
      MeetingListWidgets.buildFilterFab(context, onPressed);

  // 필터 관련 위젯들 (MeetingFilterWidgets에 위임)
  static Widget buildFilterBottomSheet(
    BuildContext context, {
    required MeetingListFilter currentFilter,
    required Function(MeetingListFilter) onFilterChanged,
  }) => MeetingFilterWidgets.buildFilterBottomSheet(
    context,
    currentFilter: currentFilter,
    onFilterChanged: onFilterChanged,
  );

  // 🆕 운영진용 위젯들 (MeetingStaffWidgets에 위임)
  static Widget buildStaffMeetingCard(
    BuildContext context,
    MeetingInfo meeting, {
    VoidCallback? onTap,
  }) =>
      MeetingStaffWidgets.buildStaffMeetingCard(context, meeting, onTap: onTap);

  static Widget buildStaffListHeader(
    BuildContext context, {
    required int totalElements,
    required MeetingListFilter currentFilter,
  }) => MeetingStaffWidgets.buildStaffListHeader(
    context,
    totalElements: totalElements,
    currentFilter: currentFilter,
  );

  static Widget buildStaffFilterBottomSheet(
    BuildContext context, {
    required MeetingListFilter currentFilter,
    required Function(MeetingListFilter) onFilterChanged,
  }) => MeetingStaffWidgets.buildStaffFilterBottomSheet(
    context,
    currentFilter: currentFilter,
    onFilterChanged: onFilterChanged,
  );

  // 🆕 추가: 기존 코드와의 호환성을 위한 별칭 메서드들
  static Widget buildAdminMeetingCard(
    BuildContext context,
    MeetingInfo meeting, {
    VoidCallback? onTap,
  }) => buildStaffMeetingCard(context, meeting, onTap: onTap);

  static Widget buildAdminListHeader(
    BuildContext context, {
    required int totalElements,
    required MeetingListFilter currentFilter,
  }) => buildStaffListHeader(
    context,
    totalElements: totalElements,
    currentFilter: currentFilter,
  );

  static Widget buildAdminFilterBottomSheet(
    BuildContext context, {
    required MeetingListFilter currentFilter,
    required Function(MeetingListFilter) onFilterChanged,
  }) => buildStaffFilterBottomSheet(
    context,
    currentFilter: currentFilter,
    onFilterChanged: onFilterChanged,
  );
}
