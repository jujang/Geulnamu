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
    print('🎨 [PostIt 빌드] 위젯 빌드 시작: ${widget.bookQuestion.bookQuestionId}');
    
    return AnimatedBuilder(
      animation: _hoverController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Draggable<BookQuestionModel>(
            // 🔧 기본 Draggable 사용 (웹 호환성 개선)
            data: widget.bookQuestion,
            // 드래그 중일 때의 피드백 (웹 최적화)
            feedback: Material(
              elevation: 16.0,
              shadowColor: Colors.black.withOpacity(0.5),
              borderRadius: BorderRadius.circular(8.0),
              child: SizedBox(
                width: 180, // 고정 크기
                height: 120,
                child: _buildPostItCard(
                  context,
                  isDragging: true,
                  elevation: 0, // Material이 elevation 처리
                  opacity: 0.95,
                  isFloating: true,
                ),
              ),
            ),
            // 드래그 중인 원본은 더 투명하게
            childWhenDragging: _buildPostItCard(
              context,
              isDragging: true,
              elevation: 1.0,
              opacity: 0.2,
            ),
            // 드래그 시작/종료 애니메이션 + 로그 추가
            onDragStarted: () {
              print('🚀 [드래그 시작] PostIt: ${widget.bookQuestion.bookQuestionId}');
              setState(() => _isDragging = true);
              widget.onDragStarted?.call(widget.bookQuestion);
            },
            onDragEnd: (details) {
              print('🏁 [드래그 종료] PostIt: ${widget.bookQuestion.bookQuestionId}');
              print('   - 종료 위치: ${details.offset}');
              print('   - 드롭 성공: ${details.wasAccepted}');
              setState(() => _isDragging = false);
              widget.onDragEnd?.call(widget.bookQuestion);
            },
            onDragUpdate: (details) {
              // 너무 많은 로그 방지: 가끔씩만 출력
              if (details.globalPosition.dx % 50 < 10) {
                print('📍 [드래그 업데이트] 위치: ${details.globalPosition}');
              }
            },
            child: MouseRegion(
              cursor: SystemMouseCursors.grab,
              onEnter: (_) {
                print('🐁 [마우스 진입] PostIt: ${widget.bookQuestion.bookQuestionId}');
                _onHover(true);
              },
              onExit: (_) {
                print('🐁 [마우스 이탈] PostIt: ${widget.bookQuestion.bookQuestionId}');
                _onHover(false);
              },
              child: GestureDetector(
                onTap: () {
                  print('👆 [탭] PostIt: ${widget.bookQuestion.bookQuestionId}');
                  widget.onTap?.call();
                },
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

/// 🚀 정확한 위치 기반 + 빈 공간 드롭 지원 시스템
/// GlobalKey를 사용해 포스트잇의 실제 크기와 위치를 정확히 계산
/// 포스트잇 사이의 빈 공간에도 드롭 가능
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
  
  // 🆕 포스트잇 위치 추적을 위한 GlobalKey들
  final Map<int, GlobalKey> _postItKeys = {}; // questionId -> GlobalKey
  final List<GlobalKey> _dropZoneKeys = []; // 빈 공간 드롭존 키들
  
  // 🆕 드롭 표시를 위한 상태 변수들
  int? _hoveredPostItIndex; // 호버 중인 포스트잇 인덱스
  int? _hoveredDropZoneIndex; // 호버 중인 빈 공간 드롭존 인덱스
  bool _isLeftSide = false; // 마우스가 포스트잇의 왼쪽에 있는지
  
  // 애니메이션 관련
  late AnimationController _reorderController;
  late Animation<double> _reorderAnimation;
  
  @override
  void initState() {
    super.initState();
    print('🏗️ [컬렉션 초기화] 발제문 ${widget.bookQuestions.length}개');
    _orderedQuestions = List.from(widget.bookQuestions);
    _initializeKeys();
    
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
    if (oldWidget.bookQuestions != widget.bookQuestions) {
      print('📝 [컬렉션 업데이트] 발제문 목록 변경됨');
      setState(() {
        _orderedQuestions = List.from(widget.bookQuestions);
        _initializeKeys(); // 키들도 재초기화
      });
    }
  }
  
  /// GlobalKey들을 초기화/업데이트
  void _initializeKeys() {
    // 기존 키들 중 여전히 사용되는 것들만 유지
    final currentQuestionIds = _orderedQuestions.map((q) => q.bookQuestionId).toSet();
    _postItKeys.removeWhere((questionId, key) => !currentQuestionIds.contains(questionId));
    
    // 새로운 발제문들에 대한 키 생성
    for (final question in _orderedQuestions) {
      if (!_postItKeys.containsKey(question.bookQuestionId)) {
        _postItKeys[question.bookQuestionId] = GlobalKey();
      }
    }
    
    // 드롭존 키들 재생성 (발제문 수 + 1개)
    _dropZoneKeys.clear();
    for (int i = 0; i <= _orderedQuestions.length; i++) {
      _dropZoneKeys.add(GlobalKey());
    }
    
    print('🔑 [키 초기화] 포스트잇 키: ${_postItKeys.length}개, 드롭존 키: ${_dropZoneKeys.length}개');
  }

  @override
  Widget build(BuildContext context) {
    print('🏗️ [컬렉션 빌드] 발제문 ${_orderedQuestions.length}개 렌더링');
    
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
          return _buildPostItGrid(context);
        },
      ),
    );
  }
  
  /// 🚀 정확한 위치 계산 기반 드래그 타겟 그리드 + 빈 공간 드롭존
  Widget _buildPostItGrid(BuildContext context) {
    final theme = Theme.of(context);
    final children = <Widget>[];
    
    // 첫 번째 드롭존 (맨 앞)
    children.add(_buildDropZone(context, 0));
    
    for (int i = 0; i < _orderedQuestions.length; i++) {
      final question = _orderedQuestions[i];
      final isDragging = _draggingQuestion?.bookQuestionId == question.bookQuestionId;
      final isHovered = _hoveredPostItIndex == i;
      
      // 포스트잇 위젯
      children.add(
        Container(
          key: _postItKeys[question.bookQuestionId], // GlobalKey 적용
          margin: const EdgeInsets.all(8),
          child: Stack(
            children: [
              // 🎯 정확한 크기 기반 드래그 타겟
              DragTarget<BookQuestionModel>(
                onWillAccept: (data) {
                  if (data == null || _draggingQuestion == null) {
                    print('❌ [포스트잇 드롭 체크] 데이터 없음');
                    return false;
                  }
                  
                  // 자기 자신에게는 드롭 불가
                  final isSelf = data.bookQuestionId == question.bookQuestionId;
                  if (isSelf) {
                    print('❌ [포스트잇 드롭 체크] 자기 자신에게 드롭 불가: ${data.bookQuestionId}');
                    return false;
                  }
                  
                  print('✅ [포스트잇 드롭 체크] 드롭 허용: ${data.bookQuestionId} → 포스트잇 $i');
                  return true;
                },
                onAccept: (data) {
                  print('🎉 [포스트잇 드롭 성공] ${data.bookQuestionId} → 포스트잇 $i (왼쪽: $_isLeftSide)');
                  _handlePostItDrop(data, i, _isLeftSide);
                },
                onMove: (details) {
                  // 🎯 핵심 로직: 실제 포스트잇 크기 기반 정확한 위치 계산
                  final isLeftSide = _calculateIsLeftSide(question.bookQuestionId, details.offset);
                  
                  if (_hoveredPostItIndex != i || _isLeftSide != isLeftSide || _hoveredDropZoneIndex != null) {
                    setState(() {
                      _hoveredPostItIndex = i;
                      _hoveredDropZoneIndex = null; // 포스트잇 호버 시 드롭존 해제
                      _isLeftSide = isLeftSide;
                    });
                    print('🎯 [포스트잇 호버] 포스트잇 $i, 왼쪽: $isLeftSide');
                  }
                },
                onLeave: (data) {
                  if (_hoveredPostItIndex == i) {
                    setState(() {
                      _hoveredPostItIndex = null;
                      _isLeftSide = false;
                    });
                    print('🚪 [포스트잇 호버 종료] 포스트잇 $i');
                  }
                },
                builder: (context, candidateData, rejectedData) {
                  return Stack(
                    children: [
                      // 📍 드롭 위치 표시기 (왼쪽)
                      if (isHovered && _isLeftSide)
                        Positioned(
                          left: -20,
                          top: 0,
                          bottom: 0,
                          child: _buildDropIndicator(context),
                        ),
                      
                      // 📍 드롭 위치 표시기 (오른쪽)
                      if (isHovered && !_isLeftSide)
                        Positioned(
                          right: -20,
                          top: 0,
                          bottom: 0,
                          child: _buildDropIndicator(context),
                        ),
                      
                      // 🎨 실제 포스트잇 위젯
                      AnimatedOpacity(
                        duration: const Duration(milliseconds: 200),
                        opacity: isDragging ? 0.3 : (isHovered ? 0.8 : 1.0),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          transform: Matrix4.identity()
                            ..scale(isHovered && !isDragging ? 1.05 : 1.0),
                          child: PostItBookQuestionWidget(
                            bookQuestion: question,
                            isMyQuestion: question.writerMemberId == widget.currentUserId,
                            onTap: () => widget.onQuestionTap?.call(question),
                            onDragStarted: (draggingQuestion) {
                              print('🎯 [컬렉션] 드래그 시작 감지: ${draggingQuestion.bookQuestionId}');
                              setState(() {
                                _draggingQuestion = draggingQuestion;
                                _clearHoverStates();
                              });
                            },
                            onDragEnd: (draggingQuestion) {
                              print('🎯 [컬렉션] 드래그 종료 감지: ${draggingQuestion.bookQuestionId}');
                              setState(() {
                                _draggingQuestion = null;
                                _clearHoverStates();
                              });
                            },
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      );
      
      // 포스트잇 뒤에 드롭존 추가 (마지막 포스트잇 뒤까지)
      children.add(_buildDropZone(context, i + 1));
    }
    
    return Wrap(
      spacing: 20,
      runSpacing: 20,
      alignment: WrapAlignment.center,
      children: children,
    );
  }
  
  /// 🎯 실제 포스트잇 크기 기반으로 왼쪽/오른쪽 판단
  bool _calculateIsLeftSide(int questionId, Offset localPosition) {
    final key = _postItKeys[questionId];
    if (key?.currentContext == null) {
      print('⚠️ [위치 계산] GlobalKey가 준비되지 않음, 기본값 사용');
      return localPosition.dx < 100; // 기본값
    }
    
    try {
      final RenderBox renderBox = key!.currentContext!.findRenderObject() as RenderBox;
      final size = renderBox.size;
      final centerX = size.width / 2;
      
      final isLeftSide = localPosition.dx < centerX;
      print('📐 [위치 계산] 포스트잇 너비: ${size.width}, 중심: $centerX, 마우스X: ${localPosition.dx}, 왼쪽: $isLeftSide');
      
      return isLeftSide;
    } catch (e) {
      print('❌ [위치 계산] 오류: $e, 기본값 사용');
      return localPosition.dx < 100; // 오류 시 기본값
    }
  }
  
  /// 🌟 빈 공간 드롭존 위젯
  Widget _buildDropZone(BuildContext context, int insertIndex) {
    if (insertIndex >= _dropZoneKeys.length) {
      print('❌ [드롭존] 인덱스 초과: $insertIndex >= ${_dropZoneKeys.length}');
      return const SizedBox.shrink();
    }
    
    final theme = Theme.of(context);
    final isHovered = _hoveredDropZoneIndex == insertIndex;
    final isActive = _draggingQuestion != null;
    
    return DragTarget<BookQuestionModel>(
      key: _dropZoneKeys[insertIndex],
      onWillAccept: (data) {
        if (data == null || _draggingQuestion == null) {
          return false;
        }
        print('✅ [드롭존 체크] 드롭 허용: ${data.bookQuestionId} → 드롭존 $insertIndex');
        return true;
      },
      onAccept: (data) {
        print('🎉 [드롭존 드롭 성공] ${data.bookQuestionId} → 인덱스 $insertIndex');
        _handleDropZoneDrop(data, insertIndex);
      },
      onMove: (details) {
        if (_hoveredDropZoneIndex != insertIndex || _hoveredPostItIndex != null) {
          setState(() {
            _hoveredDropZoneIndex = insertIndex;
            _hoveredPostItIndex = null; // 드롭존 호버 시 포스트잇 해제
            _isLeftSide = false;
          });
          print('🎯 [드롭존 호버] 드롭존 $insertIndex');
        }
      },
      onLeave: (data) {
        if (_hoveredDropZoneIndex == insertIndex) {
          setState(() {
            _hoveredDropZoneIndex = null;
          });
          print('🚪 [드롭존 호버 종료] 드롭존 $insertIndex');
        }
      },
      builder: (context, candidateData, rejectedData) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: isActive ? (isHovered ? 80 : 40) : 20,
          height: isActive ? (isHovered ? 120 : 80) : 40,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: isHovered 
                ? theme.colorScheme.primary.withOpacity(0.3)
                : (isActive 
                    ? theme.colorScheme.primary.withOpacity(0.1)
                    : Colors.transparent),
            borderRadius: BorderRadius.circular(8),
            border: isActive ? Border.all(
              color: isHovered 
                  ? theme.colorScheme.primary
                  : theme.colorScheme.primary.withOpacity(0.3),
              width: isHovered ? 2 : 1,
            ) : null,
          ),
          child: isHovered ? Center(
            child: Icon(
              Icons.add_circle,
              color: theme.colorScheme.primary,
              size: 24,
            ),
          ) : (isActive ? Center(
            child: Container(
              width: 3,
              height: 40,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.5),
                borderRadius: BorderRadius.circular(1.5),
              ),
            ),
          ) : null),
        );
      },
    );
  }
  
  /// 드롭 위치 표시기 위젯
  Widget _buildDropIndicator(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: 4,
      decoration: BoxDecoration(
        color: theme.colorScheme.primary,
        borderRadius: BorderRadius.circular(2),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withOpacity(0.5),
            blurRadius: 8,
            offset: const Offset(0, 0),
          ),
        ],
      ),
    );
  }
  
  /// 모든 호버 상태 클리어
  void _clearHoverStates() {
    _hoveredPostItIndex = null;
    _hoveredDropZoneIndex = null;
    _isLeftSide = false;
  }

  /// 🎯 포스트잇 드롭 처리 (정확한 크기 기반)
  void _handlePostItDrop(BookQuestionModel draggedQuestion, int targetPostItIndex, bool isLeftSide) {
    print('🚀 [포스트잇 드롭] 시작');
    print('   - 드래그된 질문: ${draggedQuestion.bookQuestionId}');
    print('   - 타겟 포스트잇 인덱스: $targetPostItIndex');
    print('   - 왼쪽에 삽입: $isLeftSide');
    
    if (!mounted) {
      print('❌ [포스트잇 드롭] mounted = false, 중단');
      return;
    }

    final currentIndex = _orderedQuestions.indexWhere(
        (q) => q.bookQuestionId == draggedQuestion.bookQuestionId);
    
    if (currentIndex == -1) {
      print('❌ [포스트잇 드롭] 현재 인덱스를 찾을 수 없음');
      return;
    }

    // 🎯 핵심 로직: 정확한 마우스 위치에 따라 삽입 위치 결정
    int insertIndex;
    if (isLeftSide) {
      // 왼쪽에 드롭 = 해당 포스트잇 앞에 삽입
      insertIndex = targetPostItIndex;
    } else {
      // 오른쪽에 드롭 = 해당 포스트잇 뒤에 삽입
      insertIndex = targetPostItIndex + 1;
    }
    
    _performReorder(draggedQuestion, currentIndex, insertIndex, '포스트잇 ${isLeftSide ? "앞" : "뒤"}쪽');
  }
  
  /// 🌟 드롭존 드롭 처리 (빈 공간에 정확히 삽입)
  void _handleDropZoneDrop(BookQuestionModel draggedQuestion, int insertIndex) {
    print('🚀 [드롭존 드롭] 시작');
    print('   - 드래그된 질문: ${draggedQuestion.bookQuestionId}');
    print('   - 삽입 인덱스: $insertIndex');
    
    if (!mounted) {
      print('❌ [드롭존 드롭] mounted = false, 중단');
      return;
    }

    final currentIndex = _orderedQuestions.indexWhere(
        (q) => q.bookQuestionId == draggedQuestion.bookQuestionId);
    
    if (currentIndex == -1) {
      print('❌ [드롭존 드롭] 현재 인덱스를 찾을 수 없음');
      return;
    }
    
    _performReorder(draggedQuestion, currentIndex, insertIndex, '${insertIndex + 1}번째 위치');
  }
  
  /// 🔄 실제 순서 변경 수행 (공통 로직)
  void _performReorder(BookQuestionModel draggedQuestion, int currentIndex, int insertIndex, String positionDescription) {
    // 드래그한 항목이 삽입 위치보다 앞에 있으면 인덱스 조정
    if (currentIndex < insertIndex) {
      insertIndex--;
    }
    
    // 경계 검사
    insertIndex = insertIndex.clamp(0, _orderedQuestions.length);
    
    // 같은 위치면 아무것도 하지 않음
    if (currentIndex == insertIndex) {
      print('ℹ️ [순서 변경] 같은 위치로 이동, 변경 없음');
      return;
    }
    
    print('🎯 [순서 변경] 최종 삽입 인덱스: $insertIndex');
    print('📊 [순서 변경] 변경 전 리스트: ${_orderedQuestions.map((q) => q.bookQuestionId).toList()}');

    // 애니메이션 시작
    _reorderController.forward().then((_) {
      _reorderController.reset();
    });

    setState(() {
      // 기존 위치에서 제거
      _orderedQuestions.removeAt(currentIndex);
      
      // 새 위치에 삽입
      _orderedQuestions.insert(insertIndex, draggedQuestion);
      
      // 상태 클리어
      _clearHoverStates();
      
      // 키들도 재초기화 (순서 변경으로 인한 동기화)
      _initializeKeys();
    });
    
    print('📊 [순서 변경] 변경 후 리스트: ${_orderedQuestions.map((q) => q.bookQuestionId).toList()}');

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
              Flexible(
                child: Text('포스트잇을 $positionDescription로 이동했습니다'),
              ),
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
