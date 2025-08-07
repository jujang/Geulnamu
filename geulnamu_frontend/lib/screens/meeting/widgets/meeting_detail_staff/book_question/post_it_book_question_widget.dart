import 'package:flutter/material.dart';
import '../../../../../models/book_question/book_question_model.dart';
import '../../../../../core/colors.dart';

/// 포스트잇 스타일의 발제문 위젯
/// 
/// 기능:
/// - 포스트잇 모양 디자인 (그림자, 둥근 모서리)
/// - 드래그 가능 (Draggable 위젯 사용)
/// - 발제문 내용 표시
/// - 🔥 모든 발제문을 노란색으로 통일 표시
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
            // 드래그 중일 때의 피드백 (회전 제거)
            feedback: _buildPostItCard(
              context,
              isDragging: true,
              elevation: 16.0, // 더 높은 그림자
              opacity: 0.95, // 더 선명하게
              isFloating: true, // 플로팅 상태 표시
            ),
            // 드래그 중인 원본은 더 투명하게
            childWhenDragging: _buildPostItCard(
              context,
              isDragging: true,
              elevation: 1.0,
              opacity: 0.2, // 더 투명하게
            ),
            // 드래그 시작/종료 애니메이션
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
    bool isFloating = false, // 🆕 플로팅 상태 (드래그 중 피드백용)
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
              // 🆕 플로팅 상태에서는 더 강한 그라디언트
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  postItColor,
                  postItColor.withOpacity(isFloating ? 0.95 : 0.9),
                ],
              ),
              // 🆕 플로팅 상태에서는 더 화려한 그림자
              boxShadow: isFloating ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 15.0,
                  offset: const Offset(0, 8),
                ),
                BoxShadow(
                  color: theme.colorScheme.primary.withOpacity(0.2),
                  blurRadius: 25.0,
                  offset: const Offset(0, 5),
                ),
              ] : [
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
                  child: Text(
                    widget.bookQuestion.content,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: textColor,
                      fontSize: isFloating ? 14 : 13, // 🆕 플로팅 시 더 크게!
                      height: 1.4,
                      fontWeight: isFloating ? FontWeight.w500 : FontWeight.w400, // 🆕 플로팅 시 더 굵게!
                    ),
                    maxLines: null,
                  ),
                ),
                
                const SizedBox(height: 8),
                
                // 🔥 본인 발제문 표시 아이콘 제거 (구분하지 않음)
                // 모든 발제문을 동일하게 표시
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 포스트잇 색상 가져오기 (모두 노란색으로 통일!)
  Color _getPostItColor(BuildContext context) {
    // 🔥 모든 발제문을 노란색 포스트잇으로 통일 표시!
    return const Color(0xFFFFF59D).withOpacity(0.9);
  }

  /// 텍스트 색상 가져오기 (모두 동일)
  Color _getTextColor(BuildContext context) {
    // 🔥 모든 발제문의 텍스트를 동일하게 (노란색 배경에 대비)
    return Colors.black87;
  }
}

/// 포스트잇들을 배치하는 컨테이너 위젯
/// 🔥 정확한 인덱스 기반 드롭과 부드러운 애니메이션 구현!
class PostItCollectionWidget extends StatefulWidget {
  final List<BookQuestionModel> bookQuestions;
  final int currentUserId;
  final Function(BookQuestionModel)? onQuestionTap;

  const PostItCollectionWidget({
    super.key,
    required this.bookQuestions,
    required this.currentUserId,
    this.onQuestionTap,
  });

  @override
  State<PostItCollectionWidget> createState() => _PostItCollectionWidgetState();
}

class _PostItCollectionWidgetState extends State<PostItCollectionWidget>
    with TickerProviderStateMixin {
  BookQuestionModel? _draggingQuestion;
  List<BookQuestionModel> _orderedQuestions = []; // 순서가 변경된 발제문 리스트
  
  // 🆕 애니메이션 관련
  late AnimationController _reorderController;
  late Animation<double> _reorderAnimation;
  int? _targetDropIndex; // 드롭 대상 인덱스
  
  @override
  void initState() {
    super.initState();
    // 초기 순서 설정
    _orderedQuestions = List.from(widget.bookQuestions);
    
    // 🆕 애니메이션 컨트롤러 초기화
    _reorderController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _reorderAnimation = CurvedAnimation(
      parent: _reorderController,
      curve: Curves.easeInOut,
    );
  }
  
  @override
  void dispose() {
    _reorderController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(PostItCollectionWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // widget.bookQuestions가 변경되면 _orderedQuestions도 업데이트
    if (oldWidget.bookQuestions != widget.bookQuestions) {
      setState(() {
        _orderedQuestions = List.from(widget.bookQuestions);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.bookQuestions.isEmpty) {
      return _buildEmptyState(context);
    }

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _draggingQuestion != null
              ? Theme.of(context).colorScheme.primary.withOpacity(0.3)
              : Colors.transparent,
          width: 1,
        ),
        color: _draggingQuestion != null
            ? Theme.of(context).colorScheme.primary.withOpacity(0.02)
            : null,
      ),
      padding: const EdgeInsets.all(16),
      child: AnimatedBuilder(
        animation: _reorderAnimation,
        builder: (context, child) {
          return _buildDragTargetGrid(context);
        },
      ),
    );
  }
  
  /// 🆕 드래그 타겟이 포함된 그리드 빌드
  Widget _buildDragTargetGrid(BuildContext context) {
    final children = <Widget>[];
    
    for (int i = 0; i <= _orderedQuestions.length; i++) {
      // 각 포스트잇 앞에 드롭존 추가
      children.add(_buildDropZone(context, i));
      
      // 마지막이 아니라면 포스트잇 추가
      if (i < _orderedQuestions.length) {
        final question = _orderedQuestions[i];
        
        // 드래그 중인 아이템은 반투명하게 표시
        final isDragging = _draggingQuestion?.bookQuestionId == question.bookQuestionId;
        
        children.add(
          AnimatedOpacity(
            duration: const Duration(milliseconds: 200),
            opacity: isDragging ? 0.3 : 1.0,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: PostItBookQuestionWidget(
                bookQuestion: question,
                isMyQuestion: question.writerMemberId == widget.currentUserId,
                onTap: () => widget.onQuestionTap?.call(question),
                onDragStarted: (draggingQuestion) {
                  setState(() {
                    _draggingQuestion = draggingQuestion;
                    _targetDropIndex = null;
                  });
                },
                onDragEnd: (draggingQuestion) {
                  setState(() {
                    _draggingQuestion = null;
                    _targetDropIndex = null;
                  });
                },
              ),
            ),
          ),
        );
      }
    }
    
    return Wrap(
      spacing: 8, // 드롭존을 위해 간격 줄임
      runSpacing: 12,
      children: children,
    );
  }
  
  /// 🆕 드롭존 위젯 생성
  Widget _buildDropZone(BuildContext context, int index) {
    final theme = Theme.of(context);
    
    return DragTarget<BookQuestionModel>(
      onWillAccept: (data) {
        if (data == null || _draggingQuestion == null) return false;
        
        // 현재 위치와 같으면 드롭 불허
        final currentIndex = _orderedQuestions.indexWhere(
            (q) => q.bookQuestionId == data.bookQuestionId);
        
        return currentIndex != index && currentIndex != index - 1;
      },
      onAccept: (data) {
        _reorderQuestions(data, index);
      },
      onMove: (details) {
        // 호버 시 대상 인덱스 업데이트
        if (_targetDropIndex != index) {
          setState(() => _targetDropIndex = index);
        }
      },
      onLeave: (data) {
        // 떠날 때 대상 인덱스 클리어
        if (_targetDropIndex == index) {
          setState(() => _targetDropIndex = null);
        }
      },
      builder: (context, candidateData, rejectedData) {
        final isActive = candidateData.isNotEmpty;
        final isTarget = _targetDropIndex == index;
        
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: isActive || isTarget ? 40 : 8,
          height: isActive || isTarget ? 120 : 8,
          margin: const EdgeInsets.symmetric(horizontal: 2),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: isActive
                ? theme.colorScheme.primary.withOpacity(0.3)
                : isTarget
                    ? theme.colorScheme.primary.withOpacity(0.1)
                    : Colors.transparent,
            border: isActive
                ? Border.all(
                    color: theme.colorScheme.primary.withOpacity(0.6),
                    width: 2,
                  )
                : isTarget
                    ? Border.all(
                        color: theme.colorScheme.primary.withOpacity(0.3),
                        width: 1,
                      )
                    : null,
          ),
          child: isActive
              ? Icon(
                  Icons.add_circle_outline,
                  color: theme.colorScheme.primary,
                  size: 24,
                )
              : null,
        );
      },
    );
  }

  /// 🆕 정확한 인덱스 기반 포스트잇 순서 변경 메서드 (adjustedIndex → finalIndex 변경)
  void _reorderQuestions(BookQuestionModel draggedQuestion, int targetIndex) {
    if (!mounted) return;

    final currentIndex = _orderedQuestions.indexWhere(
        (q) => q.bookQuestionId == draggedQuestion.bookQuestionId);
    
    if (currentIndex == -1) return; // 찾을 수 없으면 리턴
    
    // 애니메이션 시작
    _reorderController.forward().then((_) {
      _reorderController.reset();
    });

    // 🔧 finalIndex를 setState 밖에서 계산
    int finalIndex = targetIndex;
    if (currentIndex < targetIndex) {
      finalIndex = targetIndex - 1;
    }
    
    // 경계 검사
    finalIndex = finalIndex.clamp(0, _orderedQuestions.length);

    setState(() {
      // 1. 기존 위치에서 제거
      _orderedQuestions.removeAt(currentIndex);
      
      // 2. 새 위치에 삽입
      _orderedQuestions.insert(finalIndex, draggedQuestion);
      
      // 3. 타겟 인덱스 클리어
      _targetDropIndex = null;
    });

    // 사용자에게 피드백 제공
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.check_circle,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text('포스트잇이 ${finalIndex + 1}번째 위치로 이동했습니다'),
            ],
          ),
          duration: const Duration(seconds: 2),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
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
