import 'package:flutter/material.dart';
import '../../../core/theme.dart';
import '../../../core/responsive.dart';
import '../../../models/voc/voc_model.dart';

/// VoC 상세 화면 위젯들
class VoCDetailWidgets {
  /// 반응형 상세 보기 (모바일: 바텀시트, 데스크톱: 다이얼로그)
  static void showIssueDetail(
    BuildContext context, {
    required VoCIssue issue,
    required Function(IssueStatus, String?) onSave,
  }) {
    final isMobile = ResponsiveHelper.isMobile(context);

    if (isMobile) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (context) => _IssueDetailContent(
          issue: issue,
          onSave: onSave,
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (context) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: _IssueDetailContent(
              issue: issue,
              onSave: onSave,
            ),
          ),
        ),
      );
    }
  }
}

/// 이슈 상세 콘텐츠
class _IssueDetailContent extends StatefulWidget {
  final VoCIssue issue;
  final Function(IssueStatus, String?) onSave;

  const _IssueDetailContent({
    required this.issue,
    required this.onSave,
  });

  @override
  State<_IssueDetailContent> createState() => _IssueDetailContentState();
}

class _IssueDetailContentState extends State<_IssueDetailContent> {
  late IssueStatus selectedStatus;
  late TextEditingController commentController;

  @override
  void initState() {
    super.initState();
    selectedStatus = widget.issue.issueStatus;
    commentController = TextEditingController(
      text: widget.issue.adminComment ?? '',
    );
  }

  @override
  void dispose() {
    commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 헤더
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _getTypeColor(widget.issue.voCType)
                          .withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      widget.issue.voCType.icon,
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.issue.voCType.displayName,
                          style: context.textStyles.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: context.colors.onSurface, // 🔥 다크모드 대응
                          ),
                        ),
                        Text(
                          '이슈 #${widget.issue.vocId}',
                          style: context.textStyles.bodySmall?.copyWith(
                            color: context.colors.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // 작성자 정보
              _buildInfoRow(
                context,
                Icons.person_outline,
                '작성자',
                '#${widget.issue.memberId}',
              ),

              const SizedBox(height: 12),

              // 작성일
              _buildInfoRow(
                context,
                Icons.access_time,
                '작성일',
                _formatDateTime(widget.issue.createdAt),
              ),

              const SizedBox(height: 12),

              const Divider(),
              const SizedBox(height: 12),

              // 이슈 내용
              Text(
                '이슈 내용',
                style: context.textStyles.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: context.colors.onSurface, // 🔥 다크모드 대응
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.only(
                  left: 12,
                  right: 12,
                  bottom: 12,
                  top: 8,
                ),
                decoration: BoxDecoration(
                  color: context.colors.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  widget.issue.content,
                  style: context.textStyles.bodyMedium,
                ),
              ),

              const SizedBox(height: 24),

              // 관리자 코멘트
              Text(
                '관리자 코멘트',
                style: context.textStyles.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: context.colors.onSurface, // 🔥 다크모드 대응
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: commentController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: '이슈에 대한 관리자 코멘트를 입력하세요',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: context.colors.surfaceContainerHighest,
                ),
              ),

              const SizedBox(height: 24),

              // 상태 변경
              Text(
                '이슈 상태',
                style: context.textStyles.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: context.colors.onSurface, // 🔥 다크모드 대응
                ),
              ),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: context.colors.outline.withValues(alpha: 0.3),
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: DropdownButton<IssueStatus>(
                  value: selectedStatus,
                  isExpanded: true,
                  underline: const SizedBox(),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  borderRadius: BorderRadius.circular(12),
                  items: IssueStatus.values.map((status) {
                    return DropdownMenuItem(
                      value: status,
                      child: Row(
                        children: [
                          Text(status.icon, style: const TextStyle(fontSize: 18)),
                          const SizedBox(width: 8),
                          Text(
                            status.displayName,
                            style: TextStyle(
                              color: Color(status.colorValue),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (status) {
                    if (status != null) {
                      setState(() {
                        selectedStatus = status;
                      });
                    }
                  },
                ),
              ),

              const SizedBox(height: 24),

              // 버튼들
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('취소'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        final comment = commentController.text.trim();
                        Navigator.pop(context);
                        widget.onSave(
                          selectedStatus,
                          comment.isEmpty ? null : comment,
                        );
                      },
                      child: const Text('저장'),
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

  Widget _buildInfoRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: context.colors.onSurface.withValues(alpha: 0.6),
        ),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: context.textStyles.bodyMedium?.copyWith(
            color: context.colors.onSurface.withValues(alpha: 0.7),
          ),
        ),
        Text(
          value,
          style: context.textStyles.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: context.colors.onSurface, // 🔥 다크모드 대응
          ),
        ),
      ],
    );
  }

  Color _getTypeColor(VoCType type) {
    switch (type) {
      case VoCType.errorReport:
        return Colors.red;
      case VoCType.featureRequest:
        return Colors.amber;
    }
  }

  String _formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return '수정 이력 없음';
    return '${dateTime.year}.${dateTime.month.toString().padLeft(2, '0')}.${dateTime.day.toString().padLeft(2, '0')} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
