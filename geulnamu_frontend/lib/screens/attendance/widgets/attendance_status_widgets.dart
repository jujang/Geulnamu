import 'package:flutter/material.dart';
import '../../../core/theme.dart';
import '../../../models/attendance/attendance_status_model.dart';

/// 출석 현황 화면 UI 위젯들
///
/// Static Methods로 구현하여 재사용성 극대화
class AttendanceStatusWidgets {
  // ==================== 로딩 및 에러 상태 ====================

  /// 로딩 위젯
  static Widget buildLoading(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }

  /// 에러 위젯
  static Widget buildError(
    BuildContext context, {
    required String message,
    required VoidCallback onRetry,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: context.colors.error),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: context.colors.onSurface.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('다시 시도'),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== 출석 요약 카드 ====================

  /// 출석 요약 정보 카드
  static Widget buildSummaryCard(
    BuildContext context,
    AttendanceSummary summary,
  ) {
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Theme.of(context).brightness == Brightness.light
              ? context.colors.outline.withValues(alpha: 0.2)
              : Colors.transparent,
          width: 0.5,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 헤더
            Row(
              children: [
                Icon(
                  Icons.analytics_outlined,
                  color: context.colors.primary,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  '출석 요약',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: context.colors.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 출석 통계
            _buildAttendanceStats(context, summary),

            const SizedBox(height: 16),
            Divider(color: context.colors.outline.withValues(alpha: 0.3)),
            const SizedBox(height: 16),

            // 모임 정보
            _buildMeetingInfo(context, summary),
          ],
        ),
      ),
    );
  }

  /// 출석 통계 위젯
  static Widget _buildAttendanceStats(
    BuildContext context,
    AttendanceSummary summary,
  ) {
    return Row(
      children: [
        Expanded(
          child: _buildStatItem(
            context,
            '전체',
            '${summary.totalAttendCount}명',
            context.colors.onSurface,
          ),
        ),
        Container(
          width: 1,
          height: 40,
          color: context.colors.outline.withValues(alpha: 0.3),
        ),
        Expanded(
          child: _buildStatItem(
            context,
            '출석',
            '${summary.attendCount}명',
            Colors.green,
          ),
        ),
        Container(
          width: 1,
          height: 40,
          color: context.colors.outline.withValues(alpha: 0.3),
        ),
        Expanded(
          child: _buildStatItem(
            context,
            '지각',
            '${summary.lateAttendCount}명',
            Colors.orange,
          ),
        ),
      ],
    );
  }

  /// 개별 통계 항목
  static Widget _buildStatItem(
    BuildContext context,
    String label,
    String value,
    Color color,
  ) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: context.colors.onSurface.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }

  /// 모임 정보 위젯
  static Widget _buildMeetingInfo(
    BuildContext context,
    AttendanceSummary summary,
  ) {
    return Column(
      children: [
        _buildInfoRow(
          context,
          '모임 시간',
          _formatDateTime(summary.meetingDate),
          Icons.schedule,
        ),
        const SizedBox(height: 8),
        _buildInfoRow(
          context,
          '지각 기준',
          _formatDateTime(summary.lateThresholdTime),
          Icons.access_time,
        ),
      ],
    );
  }

  /// 정보 행 위젯
  static Widget _buildInfoRow(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: context.colors.onSurface.withValues(alpha: 0.6),
        ),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: context.colors.onSurface.withValues(alpha: 0.7),
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: context.colors.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  // ==================== 출석자 목록 ====================

  /// 출석자 목록 헤더
  static Widget buildAttendanceListHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Icon(Icons.people_outline, color: context.colors.primary, size: 24),
          const SizedBox(width: 8),
          Text(
            '출석자 목록',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: context.colors.onSurface,
            ),
          ),
          const Spacer(),
          Text(
            '(늦게 온 순)',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: context.colors.onSurface.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }

  /// 출석자 목록 빌드
  static Widget buildAttendanceList(
    BuildContext context,
    List<AttendanceStatus> attendanceList,
    VoidCallback onRefresh,
  ) {
    if (attendanceList.isEmpty) {
      return buildEmptyList(context);
    }

    return RefreshIndicator(
      onRefresh: () async => onRefresh(),
      child: ListView.builder(
        padding: const EdgeInsets.only(bottom: 16),
        itemCount: attendanceList.length,
        itemBuilder: (context, index) {
          final attendance = attendanceList[index];
          return buildAttendanceItem(context, attendance);
        },
      ),
    );
  }

  /// 개별 출석 항목
  static Widget buildAttendanceItem(
    BuildContext context,
    AttendanceStatus attendance,
  ) {
    final timeColor = attendance.isLate ? Colors.orange : Colors.green;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(
            color: Theme.of(context).brightness == Brightness.light
                ? context.colors.outline.withValues(alpha: 0.1)
                : Colors.transparent,
            width: 0.5,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // 프로필 아이콘
              CircleAvatar(
                backgroundColor: context.colors.primary.withValues(alpha: 0.1),
                child: Icon(
                  Icons.person,
                  color: context.colors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),

              // 이름
              Expanded(
                child: Text(
                  attendance.name,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: context.colors.onSurface,
                  ),
                ),
              ),

              // 출석 시간 (색상으로 지각 여부 표시)
              Text(
                _formatDateTime(attendance.attendanceTime),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: timeColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 빈 목록 위젯
  static Widget buildEmptyList(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_outline,
              size: 64,
              color: context.colors.onSurface.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            Text(
              '아직 출석한 사람이 없습니다',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: context.colors.onSurface.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '새로고침하여 최신 정보를 확인해보세요',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: context.colors.onSurface.withValues(alpha: 0.4),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== Helper Methods ====================

  /// DateTime을 "yyyy.MM.dd HH:mm" 형식으로 포맷
  static String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}.${dateTime.month.toString().padLeft(2, '0')}.${dateTime.day.toString().padLeft(2, '0')} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
