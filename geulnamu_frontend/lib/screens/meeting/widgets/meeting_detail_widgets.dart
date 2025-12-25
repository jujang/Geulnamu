import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme.dart';
import '../../../models/meeting/meeting_detail_model.dart';
import '../../../models/meeting/group_member_model.dart';
import '../../../models/book_question/book_question_model.dart';
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
    // 인증 관련 에러 감지
    final isAuthError = _isAuthenticationError(message);
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isAuthError ? Icons.lock_outline : Icons.error_outline,
              size: 64,
              color: isAuthError ? context.colors.primary : context.colors.error,
            ),
            const SizedBox(height: 16),
            Text(
              isAuthError ? '로그인이 필요합니다' : '모임 정보를 불러올 수 없습니다',
              style: context.textStyles.headlineSmall?.copyWith(fontSize: 20),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              _cleanErrorMessage(message),
              style: context.textStyles.bodyLarge?.copyWith(
                color: context.colors.onSurfaceVariant,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            
            // 버튼들
            Wrap(
              spacing: 12,
              runSpacing: 12,
              alignment: WrapAlignment.center,
              children: [
                // 다시 시도 버튼
                ElevatedButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh),
                  label: const Text('다시 시도', style: TextStyle(fontSize: 16)),
                ),
                
                // 인증 에러: 로그인 버튼 / 일반 에러: 홈으로 버튼
                if (isAuthError)
                  OutlinedButton.icon(
                    onPressed: () => context.go('/login'),
                    icon: const Icon(Icons.login),
                    label: const Text('로그인하기', style: TextStyle(fontSize: 16)),
                  )
                else
                  OutlinedButton.icon(
                    onPressed: () => context.go('/home'),
                    icon: const Icon(Icons.home),
                    label: const Text('홈으로', style: TextStyle(fontSize: 16)),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  /// 인증 관련 에러인지 확인
  static bool _isAuthenticationError(String message) {
    final lowerMessage = message.toLowerCase();
    return lowerMessage.contains('401') ||
           lowerMessage.contains('로그인') ||
           lowerMessage.contains('토큰') ||
           lowerMessage.contains('인증') ||
           lowerMessage.contains('unauthorized') ||
           lowerMessage.contains('authentication');
  }
  
  /// QR 출석 섹션 표시 여부 확인
  /// - 운영진 이상: 항상 표시
  /// - 일반 사용자: 미출석/불참 상태이고 모임 당일까지만 표시
  static bool _canShowQrSection(MeetingDetailInfo meeting, bool isStaffOrAbove) {
    // 운영진 이상은 항상 표시
    if (isStaffOrAbove) return true;
    
    // 이미 출석/지각 상태면 표시 안 함
    if (meeting.attendanceStatus == 'ATTEND' || 
        meeting.attendanceStatus == 'ATTEND_LATE') {
      return false;
    }
    
    // 모임 당일까지만 표시 (미출석/불참 상태)
    return _isOnOrBeforeMeetingDay(meeting.meetingDateTime);
  }
  
  /// QR 출석 버튼 표시 여부 확인 (일반 사용자용)
  /// - 미출석/불참 상태이고 모임 당일까지만 표시
  static bool _canShowQrScanButton(MeetingDetailInfo meeting) {
    // 이미 출석/지각 상태면 표시 안 함
    if (meeting.attendanceStatus == 'ATTEND' || 
        meeting.attendanceStatus == 'ATTEND_LATE') {
      return false;
    }
    
    // 모임 당일까지만 표시
    return _isOnOrBeforeMeetingDay(meeting.meetingDateTime);
  }
  
  /// 모임 당일 또는 이전인지 확인
  static bool _isOnOrBeforeMeetingDay(DateTime meetingDateTime) {
    final now = DateTime.now();
    final meetingDate = DateTime(
      meetingDateTime.year,
      meetingDateTime.month,
      meetingDateTime.day,
    );
    final today = DateTime(now.year, now.month, now.day);
    
    // 오늘이 모임 날짜와 같거나 이전이면 true
    return !today.isAfter(meetingDate);
  }
  
  /// 에러 메시지 정리 (불필요한 접두사 제거)
  static String _cleanErrorMessage(String message) {
    return message
        .replaceAll('[모임 상세 조회]', '')
        .replaceAll('[운영진용 모임 상세 조회]', '')
        .replaceAll('Exception:', '')
        .trim();
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
    // 🆕 발제문 관련 매개변수 추가
    List<BookQuestionModel>? bookQuestions,
    bool isBookQuestionLoading = false,
    VoidCallback? onCreateBookQuestion,
    Function(BookQuestionModel)? onEditBookQuestion,
    Function(int)? onDeleteBookQuestion,
    bool canEditBookQuestions = false,
    String? bookQuestionEditTimeRemaining,
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

          // QR 출석 기능 (조건부 표시)
          // - 일반 사용자: 미출석/불참 상태이고 모임 당일까지만 표시
          // - 운영진 이상: 항상 표시 (출석용 QR 표시 버튼 접근 위해)
          if (_canShowQrSection(meeting, isStaffOrAbove)) ...[
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

          // 🆕 발제문 섹션 (토론 시간이 설정된 경우에만 표시)
          if (meeting.discussionTime != null) ...[
            const SizedBox(height: 16),
            _buildBookQuestionCard(
              context,
              meeting,
              bookQuestions: bookQuestions ?? [],
              isLoading: isBookQuestionLoading,
              onCreateBookQuestion: onCreateBookQuestion,
              onEditBookQuestion: onEditBookQuestion,
              onDeleteBookQuestion: onDeleteBookQuestion,
              canEdit: canEditBookQuestions,
              timeRemaining: bookQuestionEditTimeRemaining,
            ),
          ],

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
                  fontSize: 16, // 🆕 fontWeight 제거하여 다른 라벨과 통일
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

            // 알림 메시지 (🆕 별도 Card로 개선)
            if (meeting.alarmMessage != null &&
                meeting.alarmMessage!.isNotEmpty) ...[
              const SizedBox(height: 12),
              _buildAlarmMessageCard(context, meeting.alarmMessage!),
            ],

            // 토론 조 구성원 (🆕 별도 Card로 개선)
            if (meeting.groupMemberList != null &&
                meeting.groupMemberList!.isNotEmpty) ...[
              const SizedBox(height: 12),
              _buildGroupMembersCard(context, meeting.groupMemberList!),
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

  /// 토론 조 구성원 섹션 (🆕 Card로 감싸서 구분감 강화)
  static Widget _buildGroupMembersCard(
    BuildContext context,
    List<GroupMember> groupMembers,
  ) {
    return Card(
      margin: EdgeInsets.zero, // 상위 Card와의 여백 제거
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.people_outline,
                  color: context.colors.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  '나의 토론 조 구성원',
                  style: context.textStyles.labelLarge?.copyWith(
                    color: context.colors.onSurfaceVariant,
                    fontSize: 16, // 🆕 다른 라벨과 동일하게 수정
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8.0,
              runSpacing: 6.0,
              children: groupMembers
                  .map((member) => _buildMemberChip(context, member))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  /// 토론 알림 메시지 카드 (🆕 별도 Card로 구분감 강화)
  static Widget _buildAlarmMessageCard(
    BuildContext context,
    String alarmMessage,
  ) {
    return Card(
      margin: EdgeInsets.zero, // 상위 Card와의 여백 제거
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.notifications_outlined,
                  color: context.colors.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  '토론 알림 메시지',
                  style: context.textStyles.labelLarge?.copyWith(
                    color: context.colors.onSurfaceVariant,
                    fontSize: 16, // 🆕 다른 라벨과 동일하게 수정
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              alarmMessage,
              style: context.textStyles.bodyLarge?.copyWith(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  /// 토론 조 구성원 섹션 (기존 방식 - 호환성을 위해 유지)
  static Widget _buildGroupMembersSection(
    BuildContext context,
    List<GroupMember> groupMembers,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '나의 토론 조 구성원',
          style: context.textStyles.labelLarge?.copyWith(
            color: context.colors.onSurfaceVariant,
            fontSize: 16, // 🆕 fontWeight 제거하여 다른 라벨과 통일
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

            // 🆕 QR로 출석하기 버튼 - 미출석/불참 상태이고 모임 당일까지만 표시
            if (_canShowQrScanButton(meeting)) ...[
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
            
            // 🆕 운영진 이상일 때 QR 표시 버튼 (출석 여부와 무관하게 항상 표시)
            if (isStaffOrAbove && onQrDisplayTap != null) ...[
              // QR 출석 버튼이 있으면 간격 추가
              if (_canShowQrScanButton(meeting))
                const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: onQrDisplayTap,
                  icon: const Icon(Icons.qr_code_2),
                  label: const Text('출석용 QR 표시 (운영진용)'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: BorderSide(color: context.colors.primary),
                  ),
                ),
              ),
            ],
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

  /// 발제문 섹션 카드 (📝 포스트잇 스타일)
  static Widget _buildBookQuestionCard(
    BuildContext context,
    MeetingDetailInfo meeting, {
    required List<BookQuestionModel> bookQuestions,
    required bool isLoading,
    VoidCallback? onCreateBookQuestion,
    Function(BookQuestionModel)? onEditBookQuestion,
    Function(int)? onDeleteBookQuestion,
    bool canEdit = false,
    String? timeRemaining,
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
                  Icons.article_outlined,
                  color: context.colors.primary,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  '발제문',
                  style: context.textStyles.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: context.colors.primary,
                  ),
                ),
                const Spacer(),
                // 발제문 작성 버튼 (출석한 경우에만 표시)
                if (meeting.attendanceId != null &&
                    onCreateBookQuestion != null)
                  TextButton.icon(
                    onPressed: onCreateBookQuestion,
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('작성', style: TextStyle(fontSize: 14)),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),

            // 시간 제한 안내 (있을 경우에만)
            if (timeRemaining != null) ...[
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: context.colors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: context.colors.primary.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.schedule,
                      size: 16,
                      color: context.colors.primary,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        timeRemaining,
                        style: context.textStyles.bodySmall?.copyWith(
                          fontSize: 12,
                          color: context.colors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // 발제문 내용
            if (isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (bookQuestions.isEmpty)
              _buildEmptyBookQuestionsState(
                context,
                meeting.attendanceId != null,
              )
            else
              _buildBookQuestionGrid(
                context,
                bookQuestions,
                onEditBookQuestion,
                onDeleteBookQuestion,
                canEdit,
              ),

            // 📋 발제문 섹션 하단 안내 문구 (출석한 경우에만 표시)
            if (meeting.attendanceId != null) ...[
              const SizedBox(height: 16),
              _buildBookQuestionNotice(context),
            ],
          ],
        ),
      ),
    );
  }

  /// 발제문이 없을 때 상태
  static Widget _buildEmptyBookQuestionsState(
    BuildContext context,
    bool canCreate,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Icon(
            Icons.article_outlined,
            size: 48,
            color: context.colors.onSurfaceVariant.withOpacity(0.5),
          ),
          const SizedBox(height: 12),
          Text(
            canCreate ? '아직 작성한 발제문이 없습니다.' : '발제문을 보려면 출석이 필요합니다.',
            style: context.textStyles.bodyLarge?.copyWith(
              color: context.colors.onSurfaceVariant,
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
          if (canCreate) ...[
            const SizedBox(height: 8),
            Text(
              '위의 "작성" 버튼을 눌러 발제문을 작성해보세요!',
              style: context.textStyles.bodyMedium?.copyWith(
                color: context.colors.onSurfaceVariant.withOpacity(0.7),
                fontSize: 14,
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  /// 발제문 그리드 (포스트잇 스타일)
  static Widget _buildBookQuestionGrid(
    BuildContext context,
    List<BookQuestionModel> bookQuestions,
    Function(BookQuestionModel)? onEditBookQuestion,
    Function(int)? onDeleteBookQuestion,
    bool canEdit,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // 모바일 고려: 열 개수 결정
        final crossAxisCount = constraints.maxWidth > 600 ? 3 : 2;
        final childAspectRatio = constraints.maxWidth > 600 ? 1.2 : 1.0;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: childAspectRatio,
          ),
          itemCount: bookQuestions.length,
          itemBuilder: (context, index) {
            final question = bookQuestions[index];
            return _buildPostItNote(
              context,
              question,
              onEdit: onEditBookQuestion != null
                  ? () => onEditBookQuestion(question)
                  : null,
              onDelete: onDeleteBookQuestion != null
                  ? () => onDeleteBookQuestion(question.bookQuestionId)
                  : null,
              canEdit: canEdit,
            );
          },
        );
      },
    );
  }

  /// 포스트잇 노트 위젯 (📝 노란색 포스트잇 스타일)
  static Widget _buildPostItNote(
    BuildContext context,
    BookQuestionModel question, {
    VoidCallback? onEdit,
    VoidCallback? onDelete,
    bool canEdit = false,
  }) {
    // 포스트잇 노란색 (라이트/다크 모드 무관) - 더 부드럽게 개선
    const postItColor = Color(0xFFFFF59D); // 부드러운 파스텔 노란색
    const shadowColor = Color(0xFFE6CC3A); // 조화로운 그림자 색상

    return GestureDetector(
      onTap: canEdit && onEdit != null ? onEdit : null,
      child: Container(
        decoration: BoxDecoration(
          color: postItColor,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: shadowColor.withOpacity(0.3),
              offset: const Offset(2, 4),
              blurRadius: 6,
              spreadRadius: 0,
            ),
          ],
        ),
        child: Stack(
          children: [
            // 메인 콘텐츠
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 액션 버튼 공간 확보
                  if (canEdit && (onEdit != null || onDelete != null))
                    const SizedBox(height: 24),

                  // 발제문 내용
                  Expanded(
                    child: SingleChildScrollView(
                      child: Text(
                        question.content,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black87, // 포스트잇에는 검은색 텅스트
                          height: 1.4,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 액션 버튼들 (오른쪽 상단)
            if (canEdit && (onEdit != null || onDelete != null))
              Positioned(
                top: 4,
                right: 4,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (onEdit != null)
                      GestureDetector(
                        onTap: onEdit,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.edit,
                            size: 16,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    if (onEdit != null && onDelete != null)
                      const SizedBox(width: 4),
                    if (onDelete != null)
                      GestureDetector(
                        onTap: onDelete,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.delete,
                            size: 16,
                            color: Colors.red,
                          ),
                        ),
                      ),
                  ],
                ),
              ),

            // 포스트잇 접착 테이프 효과 (왼쪽 상단)
            Positioned(
              top: 0,
              left: 16,
              child: Container(
                width: 24,
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.7),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(4),
                    bottomRight: Radius.circular(4),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 발제문 작성/수정 다이얼로그 (🆕 포스트잇 스타일)
  static Future<void> showBookQuestionDialog(
    BuildContext context, {
    BookQuestionModel? existingQuestion, // null이면 작성, 있으면 수정
    required Function(String) onSave,
  }) async {
    final isEditing = existingQuestion != null;
    final TextEditingController controller = TextEditingController(
      text: existingQuestion?.content ?? '',
    );

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            height: MediaQuery.of(context).size.height * 0.6,
            decoration: BoxDecoration(
              color: const Color(0xFFFFF59D), // 포스트잇 노란색 - 부드러운 파스텔
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFE6CC3A).withOpacity(0.5), // 조화로운 그림자
                  offset: const Offset(4, 8),
                  blurRadius: 12,
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Stack(
              children: [
                // 메인 콘텐츠
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 제목
                      Row(
                        children: [
                          Icon(
                            isEditing ? Icons.edit : Icons.add,
                            color: Colors.black87,
                            size: 24,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            isEditing ? '발제문 수정' : '발제문 작성',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // 입력 필드
                      Expanded(
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.8),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Colors.black.withOpacity(0.1),
                              width: 1,
                            ),
                          ),
                          child: TextField(
                            controller: controller,
                            maxLines: null,
                            expands: true,
                            textAlignVertical: TextAlignVertical.top,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.black87,
                              height: 1.5,
                            ),
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              hintText:
                                  '발제문 내용을 입력하세요...\n\n토론하고 싶은 주제나 질문을 자유롭게 작성해보세요!',
                              hintStyle: TextStyle(
                                fontSize: 16,
                                color: Colors.black54,
                                height: 1.5,
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // 버튼들
                      Row(
                        children: [
                          const Spacer(),
                          TextButton(
                            onPressed: () => Navigator.of(dialogContext).pop(),
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.black87,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                            ),
                            child: const Text(
                              '취소',
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton(
                            onPressed: () {
                              final content = controller.text.trim();
                              if (content.isNotEmpty) {
                                onSave(content);
                                Navigator.of(dialogContext).pop();
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black87,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 10,
                              ),
                            ),
                            child: Text(
                              isEditing ? '수정' : '작성',
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // 포스트잇 접착 테이프 효과들
                Positioned(
                  top: 0,
                  left: 30,
                  child: Container(
                    width: 40,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.7),
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(6),
                        bottomRight: Radius.circular(6),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 0,
                  right: 50,
                  child: Container(
                    width: 30,
                    height: 10,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.6),
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(5),
                        bottomRight: Radius.circular(5),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// 발제문 섹션 하단 안내 문구 (📋 시간 제한 안내)
  static Widget _buildBookQuestionNotice(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: context.colors.surfaceContainerHighest.withOpacity(0.5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: context.colors.outline.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            size: 16,
            color: context.colors.onSurfaceVariant,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '토론 시작 2시간 이후에는 작성한 발제문 수정/삭제가 불가능합니다.',
              style: context.textStyles.bodySmall?.copyWith(
                fontSize: 13,
                color: context.colors.onSurfaceVariant,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
