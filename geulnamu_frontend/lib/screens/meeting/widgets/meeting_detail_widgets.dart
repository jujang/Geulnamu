import 'package:flutter/material.dart';
import '../../../core/theme.dart';
import '../../../models/meeting/meeting_detail_model.dart';
import '../../../models/meeting/group_member_model.dart';
import '../../../widgets/common/loading_widgets.dart';

/// 모임 상세 화면 UI 위젯들 (Static Methods)
///
/// 모임 상세 정보 표시를 위한 UI 컴포넌트들
class MeetingDetailWidgets {
  /// 로딩 위젯
  static Widget buildLoading(BuildContext context) {
    return LoadingWidgets.buildFullScreenLoading(
      context,
      message: '모임 정보를 불러오는 중...',
    );
  }

  /// 에러 위젯
  static Widget buildError(
    BuildContext context, {
    required String message,
    required VoidCallback onRetry,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: context.colors.error),
            const SizedBox(height: 16),
            Text(
              '모임 정보를 불러올 수 없습니다',
              style: context.textStyles.headlineSmall?.copyWith(fontSize: 20),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message.replaceAll('[모임 상세 조회]', '').trim(),
              style: context.textStyles.bodyLarge?.copyWith(
                color: context.colors.onSurfaceVariant,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('다시 시도', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }

  /// 메인 콘텐츠 위젯
  static Widget buildMainContent(
    BuildContext context,
    MeetingDetailInfo meeting, {
    required bool isEditing,
    required VoidCallback onEditToggle,
    required Function(String) onNoteSave,
    required VoidCallback onEditCancel,
    VoidCallback? onToggleDiscussion, // 🆕 토론 상태 토글 콜백 추가
    bool canToggleDiscussion = false, // 🆕 토론 상태 변경 가능 여부
    String? discussionTimeRemaining, // 🆕 토론 변경 마감까지 남은 시간
    VoidCallback? onQrDisplayTap, // 🆕 QR 표시 콜백 (운영진용)
    VoidCallback? onQrScanTap, // 🆕 QR 스캔 콜백 (일반 사용자용)
    bool isStaffOrAbove = false, // 🆕 운영진 이상 권한 여부
  }) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 모임 기본 정보
          _buildMeetingInfoCard(context, meeting),
          const SizedBox(height: 16),

          // 출석 정보
          _buildAttendanceCard(
            context,
            meeting,
            isEditing: isEditing,
            onEditToggle: onEditToggle,
            onNoteSave: onNoteSave,
            onEditCancel: onEditCancel,
          ),
          const SizedBox(height: 16),

          // QR 출석 기능 (조건부 표시 - '진행 전' 상태일 때만)
          // 참석, 지각, 불참 상태에서는 QR 출석 섹션 숨김
          if (meeting.attendanceStatus == 'NOT_STARTED') ...[
            _buildQrAttendanceCard(
              context,
              meeting,
              onQrDisplayTap: onQrDisplayTap,
              onQrScanTap: onQrScanTap,
              isStaffOrAbove: isStaffOrAbove,
            ),
            const SizedBox(height: 16),
          ],

          // 토론 정보
          _buildDiscussionCard(
            context,
            meeting,
            onToggleDiscussion: onToggleDiscussion, // 🆕 토글 콜백 전달
            canToggle: canToggleDiscussion, // 🆕 토글 가능 여부 전달
            timeRemaining: discussionTimeRemaining, // 🆕 남은 시간 정보 전달
          ),
          const SizedBox(height: 80), // FAB 공간 확보
        ],
      ),
    );
  }

  /// 모임 기본 정보 카드
  static Widget _buildMeetingInfoCard(
    BuildContext context,
    MeetingDetailInfo meeting,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 제목
            Row(
              children: [
                Icon(
                  Icons.event,
                  color: context.colors.primary,
                  size: 24, // 아이콘 크기 증가
                ),
                const SizedBox(width: 8),
                Text(
                  '모임 정보',
                  style: context.textStyles.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 20, // 폰트 크기 증가
                    color: context.colors.primary, // 다크모드에서 명확한 색상
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 모임 정보들
            _buildInfoRow(context, '모임 제목', meeting.meetingName),
            _buildInfoRow(context, '모임 유형', meeting.meetingTypeDisplayName),
            _buildInfoRow(context, '개설자', meeting.meetingCreatorName),
            _buildInfoRow(context, '개최일시', meeting.displayMeetingDateTime),
            _buildInfoRow(context, '지각 기준시간', meeting.displayLateThresholdTime),
            _buildInfoRow(context, '장소', meeting.meetingPlace),
            _buildInfoRow(context, '개설일', meeting.displayCreatedAt),

            // 모임 설명
            if (meeting.description.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                '모임 상세 내용',
                style: context.textStyles.labelLarge?.copyWith(
                  color: context.colors.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  meeting.description,
                  style: context.textStyles.bodyLarge?.copyWith(fontSize: 16),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// 출석 정보 카드
  static Widget _buildAttendanceCard(
    BuildContext context,
    MeetingDetailInfo meeting, {
    required bool isEditing,
    required VoidCallback onEditToggle,
    required Function(String) onNoteSave,
    required VoidCallback onEditCancel,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 제목
            Row(
              children: [
                Icon(
                  Icons.check_circle_outline,
                  color: context.colors.primary,
                  size: 24, // 아이콘 크기 증가
                ),
                const SizedBox(width: 8),
                Text(
                  '출석 정보',
                  style: context.textStyles.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 20, // 폰트 크기 증가
                    color: context.colors.primary, // 다크모드에서 명확한 색상
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 출석 상태
            Row(
              children: [
                Text(
                  '출석 상태',
                  style: context.textStyles.labelLarge?.copyWith(
                    color: context.colors.onSurfaceVariant,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(width: 16),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6, // 패딩 증가
                  ),
                  decoration: BoxDecoration(
                    color: _getAttendanceStatusColor(
                      context,
                      meeting.attendanceStatusColorName,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    meeting.attendanceStatusDisplayName,
                    style: context.textStyles.labelMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),

            // 비고 (편집 가능 - 출석 ID가 있을 때만)
            const SizedBox(height: 16),
            if (meeting.attendanceId != null)
              _buildNoteSection(
                context,
                meeting.note ?? '',
                isEditing: isEditing,
                onEditToggle: onEditToggle,
                onNoteSave: onNoteSave,
                onEditCancel: onEditCancel,
              )
            else
              _buildReadOnlyNote(context, meeting.note ?? ''),
          ],
        ),
      ),
    );
  }

  /// 토론 정보 카드
  static Widget _buildDiscussionCard(
    BuildContext context,
    MeetingDetailInfo meeting, {
    Function()? onToggleDiscussion,
    bool canToggle = false,
    String? timeRemaining, // 🆕 남은 시간 정보 추가
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 제목
            Row(
              children: [
                Icon(
                  Icons.forum_outlined,
                  color: context.colors.primary,
                  size: 24, // 아이콘 크기 증가
                ),
                const SizedBox(width: 8),
                Text(
                  '토론 정보',
                  style: context.textStyles.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 20, // 폰트 크기 증가
                    color: context.colors.primary, // 다크모드에서 명확한 색상
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 토론 정보들
            _buildInfoRow(context, '토론 시간', meeting.displayDiscussionTime),

            // 토론 참여 희망 상태 (토글 버튼 포함)
            _buildDiscussionParticipationRow(
              context,
              meeting,
              onToggleDiscussion: onToggleDiscussion,
              canToggle: canToggle,
              timeRemaining: timeRemaining, // 🆕 남은 시간 정보 전달
            ),

            // 알림 메시지
            if (meeting.alarmMessage != null &&
                meeting.alarmMessage!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                '토론 알림 메시지',
                style: context.textStyles.labelLarge?.copyWith(
                  color: context.colors.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  meeting.alarmMessage!,
                  style: context.textStyles.bodyLarge?.copyWith(fontSize: 16),
                ),
              ),
            ],

            // 토론 조 구성원 (🆕 알림 메시지 다음으로 이동)
            if (meeting.groupMemberList != null &&
                meeting.groupMemberList!.isNotEmpty) ...[
              const SizedBox(height: 12),
              _buildGroupMembersSection(context, meeting.groupMemberList!),
            ],
          ],
        ),
      ),
    );
  }

  /// 정보 행 위젯
  static Widget _buildInfoRow(
    BuildContext context,
    String label,
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10), // 패딩 증가
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100, // 라벨 영역 확장
            child: Text(
              label,
              style: context.textStyles.labelLarge?.copyWith(
                color: context.colors.onSurfaceVariant,
                fontSize: 16, // 폰트 크기 증가
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              style: context.textStyles.bodyLarge?.copyWith(
                fontSize: 16,
              ), // 폰트 크기 증가
            ),
          ),
        ],
      ),
    );
  }

  /// 읽기 전용 비고 섹션 (출석 ID가 없을 때)
  static Widget _buildReadOnlyNote(BuildContext context, String note) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '비고',
          style: context.textStyles.labelLarge?.copyWith(
            color: context.colors.onSurfaceVariant,
            fontSize: 16, // 폰트 크기 증가
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14), // 패딩 증가
          decoration: BoxDecoration(
            color: Theme.of(
              context,
            ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            note.isEmpty ? '비고가 없습니다.' : note,
            style: context.textStyles.bodyLarge?.copyWith(
              // bodyMedium에서 bodyLarge로 변경
              color: note.isEmpty
                  ? context.colors.onSurfaceVariant
                  : context.colors.onSurface,
              fontStyle: note.isEmpty ? FontStyle.italic : null,
              fontSize: 16, // 폰트 크기 증가
            ),
          ),
        ),
      ],
    );
  }

  /// 비고 섹션 위젯
  static Widget _buildNoteSection(
    BuildContext context,
    String currentNote, {
    required bool isEditing,
    required VoidCallback onEditToggle,
    required Function(String) onNoteSave,
    required VoidCallback onEditCancel,
  }) {
    final TextEditingController noteController = TextEditingController(
      text: currentNote,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              '비고',
              style: context.textStyles.labelLarge?.copyWith(
                color: context.colors.onSurfaceVariant,
                fontSize: 16, // 폰트 크기 증가
              ),
            ),
            const Spacer(),
            if (!isEditing)
              TextButton.icon(
                onPressed: onEditToggle,
                icon: const Icon(Icons.edit, size: 18), // 아이콘 크기 증가
                label: const Text(
                  '편집',
                  style: TextStyle(fontSize: 16),
                ), // 폰트 크기 증가
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),

        // 편집 모드
        if (isEditing) ...[
          TextField(
            controller: noteController,
            maxLines: 3,
            style: const TextStyle(fontSize: 16), // 입력 텍스트 크기 증가
            decoration: InputDecoration(
              hintText: '비고를 입력하세요...',
              hintStyle: const TextStyle(fontSize: 16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Spacer(),
              TextButton(
                onPressed: onEditCancel,
                child: const Text('취소', style: TextStyle(fontSize: 16)),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () => onNoteSave(noteController.text),
                child: const Text('저장', style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ]
        // 표시 모드
        else ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14), // 패딩 증가
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              currentNote.isEmpty ? '비고가 없습니다.' : currentNote,
              style: context.textStyles.bodyLarge?.copyWith(
                color: currentNote.isEmpty
                    ? context.colors.onSurfaceVariant
                    : context.colors.onSurface,
                fontStyle: currentNote.isEmpty ? FontStyle.italic : null,
                fontSize: 16, // 폰트 크기 증가
              ),
            ),
          ),
        ],
      ],
    );
  }

  /// 토론 조 구성원 섹션
  static Widget _buildGroupMembersSection(
    BuildContext context,
    List<GroupMember> groupMembers,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '나의 토론 조 구성원', // 🆕 제목 변경
          style: context.textStyles.labelLarge?.copyWith(
            color: context.colors.onSurfaceVariant,
            fontWeight: FontWeight.w500,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8.0, // Chip 간 가로 간격
          runSpacing: 6.0, // Chip 간 세로 간격
          children: groupMembers
              .map((member) => _buildMemberChip(context, member))
              .toList(),
        ),
      ],
    );
  }

  /// 토론 참여 상태 행 (토글 버튼 포함)
  static Widget _buildDiscussionParticipationRow(
    BuildContext context,
    MeetingDetailInfo meeting, {
    Function()? onToggleDiscussion,
    bool canToggle = false,
    String? timeRemaining, // 🆕 남은 시간 정보 추가
  }) {
    // 토론 시간이 설정되지 않았으면 하이픈 표시
    final hasDiscussionTime = meeting.discussionTime != null;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: 100,
                child: Text(
                  '토론 참석 여부',
                  style: context.textStyles.labelLarge?.copyWith(
                    color: context.colors.onSurfaceVariant,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // 현재 상태 표시 (토론 시간이 없으면 하이픈)
              Expanded(
                child: Text(
                  hasDiscussionTime ? meeting.displayWantDiscussion : '-',
                  style: context.textStyles.bodyLarge?.copyWith(
                    fontSize: 16,
                    color: hasDiscussionTime
                        ? context.colors.onSurface
                        : context.colors.onSurfaceVariant, // 토론 시간 없을 때 회색
                  ),
                ),
              ),

              // 토글 스위치 (토론 시간이 있고 출석한 모임에서만 활성화)
              if (hasDiscussionTime && canToggle && onToggleDiscussion != null)
                Switch(
                  value: meeting.wantDiscussion ?? false,
                  onChanged: (_) => onToggleDiscussion(),
                  activeColor: context.colors.primary,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                )
              else if (hasDiscussionTime && meeting.attendanceId != null)
                // 토론 시간은 있지만 토글 불가능한 경우 (로딩 중, 시간 만료 등)
                Switch(
                  value: meeting.wantDiscussion ?? false,
                  onChanged: null, // 비활성화
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                )
              else if (hasDiscussionTime)
                // 토론 시간은 있지만 출석하지 않은 모임인 경우 비활성화 스위치
                Switch(
                  value: false,
                  onChanged: null,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              // 토론 시간이 없으면 스위치 자체를 표시하지 않음
            ],
          ),

          // 남은 시간 안내 텍스트 (🆕 추가)
          if (timeRemaining != null &&
              hasDiscussionTime &&
              meeting.attendanceId != null) ...[
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.only(left: 116), // 라벨 너비 + 간격만큼 들여쓰기
              child: Text(
                timeRemaining,
                style: context.textStyles.bodySmall?.copyWith(
                  color: context.colors.onSurfaceVariant,
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// 운영진용 모임 수정 FAB
  static Widget buildEditFab(
    BuildContext context, {
    required VoidCallback onPressed,
  }) {
    return Positioned(
      bottom: 16,
      right: 16,
      child: FloatingActionButton(
        onPressed: onPressed,
        backgroundColor: context.colors.primary,
        foregroundColor: context.colors.onPrimary,
        heroTag: "meeting_edit_fab",
        tooltip: '모임 정보 수정',
        child: const Icon(Icons.edit),
      ),
    );
  }

  /// QR 출석 카드
  static Widget _buildQrAttendanceCard(
    BuildContext context,
    MeetingDetailInfo meeting, {
    VoidCallback? onQrDisplayTap,
    VoidCallback? onQrScanTap,
    bool isStaffOrAbove = false,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 제목
            Row(
              children: [
                Icon(Icons.qr_code, color: context.colors.primary, size: 24),
                const SizedBox(width: 8),
                Text(
                  'QR 출석',
                  style: context.textStyles.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: context.colors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 버튼들 - 🆕 모든 사용자가 출석 가능하도록 수정
            // 운영진도 일반 모임 상세에서는 출석만 가능 (QR 관리는 운영진용 페이지에서)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onQrScanTap,
                icon: const Icon(Icons.qr_code_scanner),
                label: const Text('QR로 출석하기'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: context.colors.primary,
                  foregroundColor: context.colors.onPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 개별 조 구성원 Chip
  static Widget _buildMemberChip(BuildContext context, GroupMember member) {
    return Chip(
      label: Text(
        member.memberName,
        style: context.textStyles.labelMedium?.copyWith(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: context.colors.primary, // 텍스트 색상을 직접 지정
        ),
      ),
      backgroundColor: context.colors.primary.withValues(alpha: 0.1),
      side: BorderSide(
        color: context.colors.primary.withValues(alpha: 0.3),
        width: 1,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  /// 출석 상태 색상 가져오기
  static Color _getAttendanceStatusColor(
    BuildContext context,
    String colorName,
  ) {
    switch (colorName) {
      case 'green':
        return Colors.green;
      case 'orange':
        return Colors.orange;
      case 'blue':
        return Colors.blue;
      case 'grey':
      default:
        return Colors.grey;
    }
  }
}
