import 'package:flutter/material.dart';
import '../../../core/theme.dart';
import '../../../models/meeting/meeting_detail_model.dart';
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
            Icon(
              Icons.error_outline,
              size: 64,
              color: context.colors.error,
            ),
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
          
          // 토론 정보
          _buildDiscussionCard(context, meeting),
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
                  color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.5),
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
                    color: _getAttendanceStatusColor(context, meeting.attendanceStatusColorName),
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
            _buildInfoRow(context, '참석 희망', meeting.displayWantDiscussion),
            
            // 알림 메시지
            if (meeting.alarmMessage != null && meeting.alarmMessage!.isNotEmpty) ...[
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
                  color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  meeting.alarmMessage!,
                  style: context.textStyles.bodyLarge?.copyWith(fontSize: 16),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// 정보 행 위젯
  static Widget _buildInfoRow(BuildContext context, String label, String value) {
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
              style: context.textStyles.bodyLarge?.copyWith(fontSize: 16), // 폰트 크기 증가
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
            color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.5),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            note.isEmpty ? '비고가 없습니다.' : note,
            style: context.textStyles.bodyLarge?.copyWith( // bodyMedium에서 bodyLarge로 변경
              color: note.isEmpty 
                ? context.colors.onSurfaceVariant
                : context.colors.onSurface,
              fontStyle: note.isEmpty 
                ? FontStyle.italic 
                : null,
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
    final TextEditingController noteController = TextEditingController(text: currentNote);

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
                label: const Text('편집', style: TextStyle(fontSize: 16)), // 폰트 크기 증가
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
              color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              currentNote.isEmpty ? '비고가 없습니다.' : currentNote,
              style: context.textStyles.bodyLarge?.copyWith(
                color: currentNote.isEmpty 
                  ? context.colors.onSurfaceVariant
                  : context.colors.onSurface,
                fontStyle: currentNote.isEmpty 
                  ? FontStyle.italic 
                  : null,
                fontSize: 16, // 폰트 크기 증가
              ),
            ),
          ),
        ],
      ],
    );
  }

  /// 운영진용 편집 FAB
  static Widget buildEditFab(
    BuildContext context, {
    required VoidCallback onPressed,
  }) {
    return Positioned(
      bottom: 16,
      left: 16,
      child: FloatingActionButton.extended(
        onPressed: onPressed,
        icon: const Icon(Icons.edit),
        label: const Text('모임 정보 수정', style: TextStyle(fontSize: 16)),
        backgroundColor: context.colors.secondary,
        foregroundColor: context.colors.onSecondary,
      ),
    );
  }

  /// 출석 상태 색상 가져오기
  static Color _getAttendanceStatusColor(BuildContext context, String colorName) {
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
