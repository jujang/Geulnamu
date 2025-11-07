import 'package:flutter/material.dart';
import '../../../core/theme.dart';
import '../../../models/meeting/meeting_model.dart';
import '../../../models/meeting/meeting_filter_model.dart';
import 'meeting_filter_widgets.dart';

/// 🆕 운영진용 모임 관련 UI 위젯들
///
/// Static Methods로 구현하여 재사용성 극대화
class MeetingStaffWidgets {
  /// 🆕 운영진용 모임 카드 위젯
  ///
  /// 출석 상태 대신 비공개 여부를 표시하고, 출석현황 확인 버튼 제거
  ///
  /// [meeting] 모임 정보
  /// [onTap] 카드 탭 콜백 (향후 상세보기 기능)
  static Widget buildStaffMeetingCard(
    BuildContext context,
    MeetingInfo meeting, {
    VoidCallback? onTap,
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
              // 상단: 모임 제목 + 모임 유형 배지
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

              // 정보 행들
              Column(
                children: [
                  // 모임 개최일시 + 모임 장소
                  _buildInfoRow(
                    context,
                    icon: Icons.schedule,
                    label: '개최일시',
                    value: meeting.getResponsiveMeetingDateTime(
                      MediaQuery.of(context).size.width,
                    ),
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
                    value: meeting.getResponsiveDiscussionTime(
                      MediaQuery.of(context).size.width,
                    ),
                    secondIcon: Icons.person_outline,
                    secondLabel: '개설자',
                    secondValue: meeting.meetingCreatorName,
                  ),

                  const SizedBox(height: 8),

                  // 🆕 비공개 여부 + 모임 번호
                  _buildInfoRow(
                    context,
                    icon: Icons.visibility_outlined,
                    label: '공개상태',
                    value: _getPrivacyStatusDisplayName(meeting.isPrivate),
                    valueColor: _getPrivacyStatusColor(
                      context,
                      meeting.isPrivate,
                    ),
                    secondIcon: Icons.tag,
                    secondLabel: '모임번호',
                    secondValue: '${meeting.meetingId}', // # 기호 제거
                  ),
                ],
              ),

              // 🆕 출석현황 확인 버튼 제거 (운영진용에서는 불필요)
            ],
          ),
        ),
      ),
    );
  }

  /// 🆕 운영진용 목록 정보 헤더
  static Widget buildStaffListHeader(
    BuildContext context, {
    required int totalElements,
    required MeetingListFilter currentFilter,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                Icons.admin_panel_settings,
                size: 20,
                color: context.colors.primary,
              ),
              const SizedBox(width: 8),
              Text(
                '운영진용 - 총 $totalElements개',
                style: context.textStyles.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: context.colors.onSurface,
                ),
              ),
            ],
          ),
          Text(
            _getStaffFilterSummary(currentFilter),
            style: context.textStyles.bodySmall?.copyWith(
              color: context.colors.onSurface.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  /// 🆕 운영진용 필터 바텀시트
  static Widget buildStaffFilterBottomSheet(
    BuildContext context, {
    required MeetingListFilter currentFilter,
    required Function(MeetingListFilter) onFilterChanged,
  }) {
    return MeetingFilterWidgets.buildAdminFilterBottomSheet(
      context,
      currentFilter: currentFilter,
      onFilterChanged: onFilterChanged,
    );
  }

  /// 🆕 운영진용 필터 요약 텍스트 생성
  static String _getStaffFilterSummary(MeetingListFilter filter) {
    final List<String> filterParts = [];

    // 모임 유형 필터
    if (filter.meetingType != MeetingTypeOption.all) {
      filterParts.add(filter.meetingType.displayName);
    }

    // 오늘 모임 필터
    if (filter.isTodayMeeting == true) {
      filterParts.add('오늘 모임만');
    }

    // 비공개 여부 필터
    if (filter.privacyStatus != PrivacyStatusOption.all) {
      filterParts.add(filter.privacyStatus.displayName);
    }

    // 정렬 정보
    final order = filter.isAsc ? '↑' : '↓';
    filterParts.add('${filter.sortBy.displayName}$order');

    return filterParts.join(' · ');
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
  /// 
  /// 반응형: 모바일(~600px)에서는 레이블 숨김, 아이콘+데이터만 표시
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
    // 📱 반응형: 화면 크기 감지
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600; // 모바일 기준: 600px 미만

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
              // 📱 모바일에서는 레이블 숨김
              if (!isMobile)
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
                // 📱 모바일에서는 레이블 숨김
                if (!isMobile)
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

  /// 🆕 비공개 여부 표시명 가져오기
  static String _getPrivacyStatusDisplayName(bool isPrivate) {
    return isPrivate ? '비공개' : '공개';
  }

  /// 🆕 비공개 여부별 색상 가져오기
  static Color _getPrivacyStatusColor(BuildContext context, bool isPrivate) {
    return isPrivate ? Colors.orange : Colors.green;
  }
}
