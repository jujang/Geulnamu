import 'package:flutter/material.dart';
import '../../../../core/theme.dart';
import '../../../../models/meeting/meeting_detail_staff_model.dart';

/// 운영진용 모임 상세 - 관리 기능 섹션 위젯들
class ManagementWidgets {
  /// 🆕 운영진용 헤더 (비공개 여부 표시)
  static Widget buildStaffHeader(
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
                      color: Colors.orange.withValues(alpha: 0.2),
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
                      color: Colors.green.withValues(alpha: 0.2),
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
              '모임번호: ${meetingDetail.meetingId}',
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

  /// 🔥 권한 안내 섹션
  static Widget buildPermissionGuide(BuildContext context) {
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
                ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Theme.of(
                    context,
                  ).colorScheme.outline.withValues(alpha: 0.3),
                ),
              ),
              child: Text(
                '• 모임 삭제: 모임 생성자 또는 관리자급 권한(모임장, 부모임장, 관리자)만 가능\n'
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

  /// 📱 운영진용 출석 관리 섹션
  static Widget buildAttendanceManagementSection(
    BuildContext context,
    MeetingDetailStaffInfo meetingDetail, {
    required VoidCallback onQrDisplayTap,
    required VoidCallback onViewAsUserTap,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.qr_code, color: context.colors.primary, size: 20),
                const SizedBox(width: 8),
                Text(
                  '📱 출석 관리',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: context.colors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              '모임 출석을 위한 QR 코드를 생성하거나, 일반 사용자 화면에서 본인의 출석 상태를 확인할 수 있습니다.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: context.colors.onSurfaceVariant,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                // QR 코드 생성 버튼
                ElevatedButton.icon(
                  onPressed: onQrDisplayTap,
                  icon: const Icon(Icons.qr_code),
                  label: const Text('출석용 QR 표시'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: context.colors.primary,
                    foregroundColor: context.colors.onPrimary,
                  ),
                ),
                // 일반 사용자 화면으로 이동
                OutlinedButton.icon(
                  onPressed: onViewAsUserTap,
                  icon: const Icon(Icons.visibility),
                  label: const Text('사용자 화면에서 보기'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: context.colors.primary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 🔧 관리 기능 섹션
  static Widget buildManagementSection(
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

    // 🔥 시간 제한 체크 (6시간 이내인 경우 추가 안내)
    final now = DateTime.now();
    final meetingTime = meetingDetail.meetingDateTime;
    final timeDifference = meetingTime.difference(now);
    final hoursLeft = timeDifference.inHours;
    final isWithinDeleteWindow = hoursLeft >= 6;

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
                    color: context.colors.primary,
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

                // 삭제 버튼 (생성자 또는 관리자, 시간 제한 고려)
                if (canDeleteMeeting)
                  ElevatedButton.icon(
                    onPressed: (isSaving || !isWithinDeleteWindow)
                        ? null
                        : onDeleteMeeting,
                    icon: const Icon(Icons.delete),
                    label: const Text('모임 삭제'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isWithinDeleteWindow
                          ? Colors.red
                          : Colors.grey,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: Colors.grey,
                      disabledForegroundColor: Colors.white70,
                    ),
                  ),
              ],
            ),

            // 🔥 시간 제한 안내 메시지 (삭제 불가능한 경우)
            if (canDeleteMeeting && !isWithinDeleteWindow) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.warning_amber,
                      color: Colors.orange[700],
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '모임 개최 6시간 전까지만 삭제가 가능합니다.\n현재 남은 시간: 약 ${hoursLeft + 1}시간',
                        style: TextStyle(
                          color: Colors.orange[700],
                          fontSize: 13,
                          height: 1.3,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// 날짜/시간 포맷터
  static String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}.${dateTime.month.toString().padLeft(2, '0')}.${dateTime.day.toString().padLeft(2, '0')} '
        '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
