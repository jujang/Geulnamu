import 'package:flutter/material.dart';
import '../../../../../models/book_question/book_question_model.dart';
import '../../../../../core/colors.dart';

/// 포스트잇 스타일의 발제문 위젯
/// 
/// 기능:
/// - 포스트잇 모양 디자인 (그림자, 둥근 모서리)
/// - 드래그 가능 (Draggable 위젯 사용)
/// - 발제문 내용 표시
/// - 작성자 구분 (본인/타인)
class PostItBookQuestionWidget extends StatefulWidget {
  final BookQuestionModel bookQuestion;
  final bool isMyQuestion;
  final VoidCallback? onTap;
  final Function(BookQuestionModel)? onDragStarted;
  final Function(BookQuestionModel)? onDragEnd;

  const PostItBookQuestionWidget({
    super.key,
    required this.bookQuestion,
    required this.isMyQuestion,
    this.onTap,
    this.onDragStarted,
    this.onDragEnd,
  });

  @override
  State<PostItBookQuestionWidget> createState() => _PostItBookQuestionWidgetState();
}

class _PostItBookQuestionWidgetState extends State<PostItBookQuestionWidget>
    with TickerProviderStateMixin {
  late AnimationController _hoverController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _elevationAnimation;
  
  bool _isHovered = false;
  bool _isDragging = false;

  @override
  void initState() {
    super.initState();
    
    _hoverController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _hoverController,
      curve: Curves.easeInOut,
    ));
    
    _elevationAnimation = Tween<double>(
      begin: 4.0,
      end: 8.0,
    ).animate(CurvedAnimation(
      parent: _hoverController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _hoverController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _hoverController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Draggable<BookQuestionModel>(
            data: widget.bookQuestion,
            feedback: _buildPostItCard(
              context,
              isDragging: true,
              elevation: 12.0,
              opacity: 0.8,
            ),
            childWhenDragging: _buildPostItCard(
              context,
              isDragging: true,
              elevation: 2.0,
              opacity: 0.3,
            ),
            onDragStarted: () {
              setState(() => _isDragging = true);
              widget.onDragStarted?.call(widget.bookQuestion);
            },
            onDragEnd: (details) {
              setState(() => _isDragging = false);
              widget.onDragEnd?.call(widget.bookQuestion);
            },
            child: MouseRegion(
              onEnter: (_) => _onHover(true),
              onExit: (_) => _onHover(false),
              child: GestureDetector(
                onTap: widget.onTap,
                child: _buildPostItCard(
                  context,
                  elevation: _elevationAnimation.value,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// 호버 상태 변경
  void _onHover(bool isHovered) {
    if (_isDragging) return;
    
    setState(() => _isHovered = isHovered);
    
    if (isHovered) {
      _hoverController.forward();
    } else {
      _hoverController.reverse();
    }
  }

  /// 포스트잇 카드 빌드
  Widget _buildPostItCard(
    BuildContext context, {
    bool isDragging = false,
    double? elevation,
    double opacity = 1.0,
  }) {
    final theme = Theme.of(context);
    final postItColor = _getPostItColor(context);
    final textColor = _getTextColor(context);
    
    return Opacity(
      opacity: opacity,
      child: Container(
        constraints: const BoxConstraints(
          minWidth: 120,
          maxWidth: 200,
          minHeight: 100,
          maxHeight: 150,
        ),
        child: Card(
          elevation: elevation ?? (_isHovered ? 8.0 : 4.0),
          color: postItColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Container(
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.0),
              // 포스트잇 특유의 미묘한 그라디언트
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  postItColor,
                  postItColor.withOpacity(0.9),
                ],
              ),
              // 포스트잇 상단의 약간 어두운 테이프 효과
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 6.0,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 포스트잇 상단 테이프 효과
                Container(
                  height: 2,
                  width: 30,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
                const SizedBox(height: 8),
                
                // 발제문 내용
                Expanded(
                  child: SingleChildScrollView(
                    child: Text(
                      widget.bookQuestion.content,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: textColor,
                        fontSize: 11,
                        height: 1.3,
                      ),
                      maxLines: null,
                    ),
                  ),
                ),
                
                const SizedBox(height: 8),
                
                // 본인 발제문 표시
                if (widget.isMyQuestion)
                  Container(
                    alignment: Alignment.bottomRight,
                    child: Icon(
                      Icons.edit,
                      size: 12,
                      color: textColor.withOpacity(0.6),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 포스트잇 색상 가져오기 (본인/타인 구분)
  Color _getPostItColor(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    if (widget.isMyQuestion) {
      // 본인 발제문: 민트색 포스트잇 (브랜드 컬러)
      return GeulnamuColors.primaryLight.withOpacity(0.8);
    } else {
      // 타인 발제문: 연한 노란색 포스트잇 (전통적인 포스트잇 색상)
      return const Color(0xFFFFF59D).withOpacity(0.9);
    }
  }

  /// 텍스트 색상 가져오기
  Color _getTextColor(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    if (widget.isMyQuestion) {
      // 본인 발제문: 어두운 텍스트 (민트색 배경에 대비)
      return Colors.black87;
    } else {
      // 타인 발제문: 어두운 텍스트 (노란색 배경에 대비)
      return Colors.black87;
    }
  }
}

/// 포스트잇들을 배치하는 컨테이너 위젯
class PostItCollectionWidget extends StatefulWidget {
  final List<BookQuestionModel> bookQuestions;
  final int currentUserId;
  final Function(BookQuestionModel)? onQuestionTap;
  final double? maxHeight;

  const PostItCollectionWidget({
    super.key,
    required this.bookQuestions,
    required this.currentUserId,
    this.onQuestionTap,
    this.maxHeight,
  });

  @override
  State<PostItCollectionWidget> createState() => _PostItCollectionWidgetState();
}

class _PostItCollectionWidgetState extends State<PostItCollectionWidget> {
  BookQuestionModel? _draggingQuestion;

  @override
  Widget build(BuildContext context) {
    if (widget.bookQuestions.isEmpty) {
      return _buildEmptyState(context);
    }

    return Container(
      constraints: BoxConstraints(
        maxHeight: widget.maxHeight ?? 300,
      ),
      child: DragTarget<BookQuestionModel>(
        onWillAccept: (data) => true,
        onAccept: (BookQuestionModel data) {
          // 드래그 완료 처리 (현재는 단순 표시용)
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('📝 "${data.content.length > 20 ? data.content.substring(0, 20) + "..." : data.content}" 위치 이동됨'),
                duration: const Duration(seconds: 2),
              ),
            );
          }
        },
        builder: (context, candidateData, rejectedData) {
          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: candidateData.isNotEmpty
                    ? Theme.of(context).colorScheme.primary.withOpacity(0.5)
                    : Colors.transparent,
                width: 2,
              ),
              color: candidateData.isNotEmpty
                  ? Theme.of(context).colorScheme.primary.withOpacity(0.05)
                  : null,
            ),
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              child: Wrap(
                spacing: 12,
                runSpacing: 12,
                children: widget.bookQuestions
                    .where((question) => question != _draggingQuestion)
                    .map((question) => PostItBookQuestionWidget(
                          bookQuestion: question,
                          isMyQuestion: question.writerMemberId == widget.currentUserId,
                          onTap: () => widget.onQuestionTap?.call(question),
                          onDragStarted: (draggingQuestion) {
                            setState(() => _draggingQuestion = draggingQuestion);
                          },
                          onDragEnd: (draggingQuestion) {
                            setState(() => _draggingQuestion = null);
                          },
                        ))
                    .toList(),
              ),
            ),
          );
        },
      ),
    );
  }

  /// 빈 상태 위젯
  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      height: 150,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.3),
          style: BorderStyle.solid,
        ),
        color: theme.colorScheme.surface.withOpacity(0.3),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.sticky_note_2_outlined,
              size: 48,
              color: theme.colorScheme.outline.withOpacity(0.5),
            ),
            const SizedBox(height: 12),
            Text(
              '아직 작성된 발제문이 없습니다',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '토론 참여자들이 발제문을 작성하면 여기에 표시됩니다',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.outline.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
