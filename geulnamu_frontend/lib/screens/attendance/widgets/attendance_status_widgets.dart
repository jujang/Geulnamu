import 'package:flutter/material.dart';
import 'package:flutter/services.dart';  // 🆕 클립보드 복사용
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
  static Widget buildAttendanceListHeader(
    BuildContext context, {
    List<AttendanceStatus>? attendanceList,  // 🆕 복사 기능을 위해 추가
    bool showAdminActions = false,  // 🆕 관리자 액션 표시 여부
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 헤더 행
          Row(
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
          
          // 🆕 관리자용 복사 버튼들
          if (showAdminActions && attendanceList != null && attendanceList.isNotEmpty) ...[
            const SizedBox(height: 12),
            _buildCopyButtonsRow(context, attendanceList),
          ],
        ],
      ),
    );
  }

  /// 🆕 관리자용 복사 버튼 행
  static Widget _buildCopyButtonsRow(
    BuildContext context,
    List<AttendanceStatus> attendanceList,
  ) {
    // 토론 참여 희망자 수 계산
    final discussionWantCount = attendanceList
        .where((a) => a.wantDiscussion == true)
        .length;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        // 모임원 명단 복사 버튼
        _buildCopyButton(
          context,
          icon: Icons.content_copy,
          label: '모임원 명단 (${attendanceList.length}명)',
          onPressed: () => _copyAttendeeIds(context, attendanceList),
        ),
        
        // 토론 참여 모임원 명단 복사 버튼
        _buildCopyButton(
          context,
          icon: Icons.forum_outlined,
          label: '토론 참여 모임원 명단 ($discussionWantCount명)',
          onPressed: discussionWantCount > 0
              ? () => _copyDiscussionWantIds(context, attendanceList)
              : null,  // 0명이면 비활성화
        ),
      ],
    );
  }

  /// 🆕 복사 버튼 위젯
  static Widget _buildCopyButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback? onPressed,
  }) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 16),
      label: Text(label, style: const TextStyle(fontSize: 13)),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        side: BorderSide(
          color: onPressed != null
              ? context.colors.primary
              : context.colors.outline.withValues(alpha: 0.3),
        ),
        foregroundColor: onPressed != null
            ? context.colors.primary
            : context.colors.onSurface.withValues(alpha: 0.4),
      ),
    );
  }

  /// 🆕 출석자 전체 memberId 복사
  static Future<void> _copyAttendeeIds(
    BuildContext context,
    List<AttendanceStatus> attendanceList,
  ) async {
    final memberIds = attendanceList
        .map((a) => a.memberId.toString())
        .join(',');
    
    await Clipboard.setData(ClipboardData(text: memberIds));
    
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '모임원 ${attendanceList.length}명의 ID가 복사되었습니다.',
                ),
              ),
            ],
          ),
          backgroundColor: context.colors.primary,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  /// 🆕 토론 참여 희망자 memberId 복사
  static Future<void> _copyDiscussionWantIds(
    BuildContext context,
    List<AttendanceStatus> attendanceList,
  ) async {
    final discussionWantList = attendanceList
        .where((a) => a.wantDiscussion == true)
        .toList();
    
    final memberIds = discussionWantList
        .map((a) => a.memberId.toString())
        .join(',');
    
    await Clipboard.setData(ClipboardData(text: memberIds));
    
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '토론 참여 희망자 ${discussionWantList.length}명의 ID가 복사되었습니다.',
                ),
              ),
            ],
          ),
          backgroundColor: context.colors.primary,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  /// 출석자 목록 빌드
  static Widget buildAttendanceList(
    BuildContext context,
    List<AttendanceStatus> attendanceList,
    VoidCallback onRefresh, {
    Function(int, String)? onDeleteAttendance, // 삭제 콜백 추가
    bool showAdminActions = false, // 관리자 액션 표시 여부
  }) {
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
          return buildAttendanceItem(
            context,
            attendance,
            onDeleteAttendance: onDeleteAttendance,
            showAdminActions: showAdminActions,
          );
        },
      ),
    );
  }

  /// 개별 출석 항목
  static Widget buildAttendanceItem(
    BuildContext context,
    AttendanceStatus attendance, {
    Function(int, String)? onDeleteAttendance, // 삭제 콜백 추가
    bool showAdminActions = false, // 관리자 액션 표시 여부
  }) {
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

              // 🎯 이름 부분 (개선 - 남은 공간 모두 사용)
              Expanded(
                child: Text(
                  attendance.name,
                  maxLines: 2,  // 최대 2줄까지 표시
                  // 🎯 overflow 제거 - 자연스럽게 줄바꿈
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: context.colors.onSurface,
                  ),
                ),
              ),

              const SizedBox(width: 8),  // 🎯 12 → 8로 줄임

              // 🎯 출석 시간 부분 (고정 너비 - 필요한 만큼만 차지)
              SizedBox(
                width: 80,  // 🎯 고정 너비 ("2025.08.07" + "00:37" 표시 가능)
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _formatDate(attendance.attendanceTime),  // 날짜
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: context.colors.onSurface.withValues(alpha: 0.7),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      _formatTime(attendance.attendanceTime),  // 시간
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: context.colors.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),  // 🎯 12 → 8로 줄임

              // 출석/지각 상태 표시
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),  // 🎯 padding 축소
                decoration: BoxDecoration(
                  color: (attendance.isLate ? Colors.orange : Colors.green)
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  attendance.isLate ? '지각' : '출석',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: attendance.isLate ? Colors.orange : Colors.green,
                    fontWeight: FontWeight.w600,
                    fontSize: 11,  // 🎯 폰트 크기 약간 축소
                  ),
                ),
              ),

              const SizedBox(width: 4),  // 🎯 8 → 4로 줄임

              // 더보기 메뉴 버튼 (관리자급에게만 표시)
              if (showAdminActions)
                SizedBox(
                  width: 28,  // 🎯 버튼 영역 크기 제한
                  height: 28,
                  child: PopupMenuButton<String>(
                    padding: EdgeInsets.zero,  // 🎯 내부 패딩 제거
                    iconSize: 18,  // 🎯 아이콘 크기 축소
                    icon: Icon(
                      Icons.more_vert,
                      color: context.colors.onSurface.withValues(alpha: 0.6),
                      size: 18,  // 🎯 20 → 18로 축소
                    ),
                    onSelected: (value) {
                      _handleAttendanceMenuAction(
                        context,
                        attendance,
                        value,
                        onDeleteAttendance,
                      );
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem<String>(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(
                              Icons.delete_outline,
                              color: Colors.red,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '출석 삭제',
                              style: Theme.of(
                                context,
                              ).textTheme.bodyMedium?.copyWith(color: Colors.red),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// 출석 메뉴 액션 처리 (삭제 기능 완전 구현)
  static void _handleAttendanceMenuAction(
    BuildContext context,
    AttendanceStatus attendance,
    String action,
    Function(int, String)? onDeleteAttendance,
  ) {
    switch (action) {
      case 'delete':
        if (onDeleteAttendance != null) {
          _confirmAndDeleteAttendance(context, attendance, onDeleteAttendance);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('삭제 기능이 사용할 수 없습니다.'),
              backgroundColor: Colors.red,
            ),
          );
        }
        break;
    }
  }

  /// 확인 후 출석 삭제 실행
  static void _confirmAndDeleteAttendance(
    BuildContext context,
    AttendanceStatus attendance,
    Function(int, String) onDeleteAttendance,
  ) async {
    try {
      // 1. 확인 다이얼로그 표시
      final confirmed = await showDeleteConfirmDialog(context, attendance.name);

      if (!confirmed) {
        return; // 사용자가 취소
      }

      // 2. 로딩 스낵바 표시
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              const SizedBox(width: 12),
              Text('${attendance.name}님의 출석을 삭제하고 있습니다...'),
            ],
          ),
          backgroundColor: Colors.orange,
          duration: const Duration(seconds: 10), // 길게 표시 (삭제 시간 고려)
        ),
      );

      // 3. 실제 삭제 실행
      await onDeleteAttendance(attendance.attendanceId, attendance.name);

      // 4. 성공 메시지
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Text('${attendance.name}님의 출석이 삭제되었습니다.'),
            ],
          ),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      // 5. 오류 처리
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Expanded(child: Text('출석 삭제에 실패했습니다: ${e.toString()}')),
            ],
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
    }
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

  /// 출석 삭제 확인 다이얼로그
  static Future<bool> showDeleteConfirmDialog(
    BuildContext context,
    String attendeeName,
  ) async {
    return await showDialog<bool>(
          context: context,
          barrierDismissible: false, // 바깥 클릭으로 닫기 방지
          builder: (context) => AlertDialog(
            title: Row(
              children: [
                Icon(
                  Icons.warning_amber_outlined,
                  color: Colors.orange,
                  size: 28,
                ),
                const SizedBox(width: 8),
                Text(
                  '출석 삭제 확인',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: context.colors.onSurface, // 🎯 다크 모드 가독성 개선
                  ),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$attendeeName님의 출석 기록을 삭제하시겠습니까?',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.red.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline, color: Colors.red, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '이 작업은 되돌릴 수 없습니다.',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: Colors.red,
                                fontWeight: FontWeight.w500,
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(
                  '취소', // 🎯 오타 수정: '어죰' → '취소'
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: context.colors.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: Text(
                  '삭제',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ) ??
        false; // null인 경우 false 반환
  }

  /// DateTime을 "yyyy.MM.dd HH:mm" 형식으로 포맷
  static String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}.${dateTime.month.toString().padLeft(2, '0')}.${dateTime.day.toString().padLeft(2, '0')} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  /// 날짜만 포맷 (yyyy.MM.dd)
  static String _formatDate(DateTime dateTime) {
    return '${dateTime.year}.${dateTime.month.toString().padLeft(2, '0')}.${dateTime.day.toString().padLeft(2, '0')}';
  }

  /// 시간만 포맷 (HH:mm)
  static String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
