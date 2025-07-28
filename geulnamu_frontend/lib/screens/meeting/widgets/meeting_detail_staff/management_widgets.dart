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
                ).colorScheme.surfaceContainerHighest.withOpacity(0.5),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
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

  /// 날짜/시간 포맷터
  static String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}.${dateTime.month.toString().padLeft(2, '0')}.${dateTime.day.toString().padLeft(2, '0')} '
        '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
