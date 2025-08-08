import 'package:flutter/material.dart';
import '../../../../../models/book_question/book_question_model.dart';
import '../../../../../core/config/app_config.dart';

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
  State<PostItBookQuestionWidget> createState() =>
      _PostItBookQuestionWidgetState();
}

class _PostItBookQuestionWidgetState extends State<PostItBookQuestionWidget> {
  bool _isDragging = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: widget.onTap,
      child: Draggable<BookQuestionModel>(
        data: widget.bookQuestion,
        feedback: _buildPostItCard(context, theme, isDragging: true),
        childWhenDragging: _buildPostItCard(context, theme, isGhost: true),
        onDragStarted: () {
          setState(() {
            _isDragging = true;
          });
          widget.onDragStarted?.call(widget.bookQuestion);
        },
        onDragEnd: (details) {
          setState(() {
            _isDragging = false;
          });
          widget.onDragEnd?.call(widget.bookQuestion);
        },
        child: _buildPostItCard(context, theme),
      ),
    );
  }

  /// 포스트잇 카드 위젯 빌드 (🌙 다크모드에서도 라이트모드와 동일한 노란색 유지)
  Widget _buildPostItCard(
    BuildContext context,
    ThemeData theme, {
    bool isDragging = false,
    bool isGhost = false,
  }) {
    final bool isDarkMode = theme.brightness == Brightness.dark;
    
    // 🎨 다크모드에서도 라이트모드와 동일한 노란색 포스트잇 유지!
    final Color postItColor = isGhost 
        ? const Color(0xFFFFF59D).withOpacity(0.3)  // 고스트: 노란색 30% 투명도
        : const Color(0xFFFFF59D);                   // 일반: 밝은 노란색 (다크/라이트 동일)
            
    final Color shadowColor = isDarkMode
        ? Colors.black.withOpacity(0.4)  // 다크모드: 더 진한 그림자
        : Colors.black.withOpacity(0.15); // 라이트모드: 기존 그림자

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 200,
      height: 120,
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: postItColor,
        borderRadius: BorderRadius.circular(8),
        boxShadow: isGhost 
            ? [] 
            : [
                BoxShadow(
                  color: shadowColor,
                  blurRadius: isDragging ? 12 : 6,
                  offset: Offset(0, isDragging ? 6 : 3),
                ),
              ],
        // 🎨 경계선 제거 (노란색 포스트잇이므로 불필요)
        border: Border.all(color: Colors.transparent, width: 0),
      ),
      child: Container(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 발제문 내용 (🎨 다크모드에서도 노란색 배경에 최적화된 텍스트)
            Expanded(
              child: Text(
                widget.bookQuestion.content ?? '내용 없음',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontSize: 13,
                  height: 1.3,
                  // 🎨 노란색 배경에 잘 보이는 진한 색상 (다크/라이트 동일)
                  color: const Color(0xFF2E2E2E),  // 진한 회색 (노란색과 대비 좋음)
                  fontWeight: FontWeight.w500,      // 약간 굵게 해서 가독성 향상
                ),
                maxLines: 6,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 🚀 단순한 드래그앤드롭 시스템
/// 포스트잇을 드래그해서 가장 가까운 위치에 간단히 삽입
/// 복잡한 로직 없이 직관적인 사용자 경험 제공
class PostItCollectionWidget extends StatefulWidget {
  final List<BookQuestionModel> bookQuestions;
  final int currentUserId;
  final Function(BookQuestionModel)? onQuestionTap;
  final Function(List<BookQuestionModel>)? onQuestionsReordered;

  const PostItCollectionWidget({
    super.key,
    required this.bookQuestions,
    required this.currentUserId,
    this.onQuestionTap,
    this.onQuestionsReordered,
  });

  @override
  State<PostItCollectionWidget> createState() =>
      _PostItCollectionWidgetState();
}

class _PostItCollectionWidgetState extends State<PostItCollectionWidget>
    with TickerProviderStateMixin {
  BookQuestionModel? _draggingQuestion;
  List<BookQuestionModel> _orderedQuestions = []; // 순서가 변경된 발제문 리스트

  // 🎯 단순한 드래그앤드롭을 위한 상태 변수들
  final Map<int, GlobalKey> _postItKeys = {}; // questionId -> GlobalKey (위치 계산용)
  final GlobalKey _containerKey = GlobalKey(); // 🆕 전체 컨테이너 키 추가
  int? _hoveredIndex; // 현재 호버 중인 포스트잇 인덱스
  bool _isLeftSide = false; // 왼쪽/오른쪽 삽입 구분
  
  // 🆕 전체 영역 드롭을 위한 상태 변수들
  int? _predictedInsertIndex; // 예상 삽입 인덱스 (전체 영역 기준)
  
  // 원위치 드롭 감지
  int? _draggingOriginalIndex; // 드래그 중인 포스트잇의 원래 인덱스

  // 애니메이션 관련
  late AnimationController _reorderController;
  late Animation<double> _reorderAnimation;

  @override
  void initState() {
    super.initState();
    if (AppConfig.debugMode) {
      print('🏠 [컬렉션 초기화] 발제문 ${widget.bookQuestions.length}개');
    }
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
  void didUpdateWidget(PostItCollectionWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.bookQuestions != widget.bookQuestions) {
      _orderedQuestions = List.from(widget.bookQuestions);
      _initializeKeys();
    }
  }

  @override
  void dispose() {
    _reorderController.dispose();
    super.dispose();
  }

  /// GlobalKey들을 초기화/업데이트
  void _initializeKeys() {
    // 기존 키들 중 여전히 사용되는 것들만 유지
    final currentQuestionIds = _orderedQuestions
        .map((q) => q.bookQuestionId)
        .toSet();
    _postItKeys.removeWhere(
      (questionId, key) => !currentQuestionIds.contains(questionId),
    );

    // 새로운 발제문들에 대한 키 생성
    for (final question in _orderedQuestions) {
      if (!_postItKeys.containsKey(question.bookQuestionId)) {
        _postItKeys[question.bookQuestionId] = GlobalKey();
      }
    }

    if (AppConfig.debugMode) {
      print('🔑 [단순 드롭] 포스트잇 키: ${_postItKeys.length}개');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_orderedQuestions.isEmpty) {
      return _buildEmptyState(context);
    }

    return Container(
      key: _containerKey, // 🆕 전체 컨테이너 키 추가
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _draggingQuestion != null
              ? Theme.of(context).colorScheme.primary.withOpacity(0.4) // 🎨 글나무 민트색 드롭 가이드
              : Colors.transparent,
          width: 2, // 조금 더 두껍게
        ),
        color: _draggingQuestion != null
            ? Theme.of(context).colorScheme.primary.withOpacity(0.05) // 🎨 매우 연한 민트색 배경
            : null,
      ),
      padding: const EdgeInsets.all(16),
      child: AnimatedBuilder(
        animation: _reorderAnimation,
        builder: (context, child) {
          return Stack(
            children: [
              // 메인 포스트잇 그리드
              _buildSimplePostItGrid(context),
              
              // 🆕 전체 영역 드롭 오버레이 (빈 공간 포함)
              if (_draggingQuestion != null)
                _buildFullAreaDropOverlay(context),
              
              // 🆕 예상 삽입 인덱스 표시기 (세로 선)
              if (_predictedInsertIndex != null && _draggingQuestion != null)
                _buildInsertIndexIndicator(context),
            ],
          );
        },
      ),
    );
  }

  /// 🎯 단순한 포스트잇 그리드 (간단한 드래그앤드롭)
  Widget _buildSimplePostItGrid(BuildContext context) {
    final theme = Theme.of(context);
    final children = <Widget>[];

    for (int i = 0; i < _orderedQuestions.length; i++) {
      final question = _orderedQuestions[i];
      final isDragging =
          _draggingQuestion?.bookQuestionId == question.bookQuestionId;
      final isHovered = _hoveredIndex == i;

      // 🎯 단순한 포스트잇 위젯 (간단한 드래그앤드롭)
      children.add(
        Container(
          key: _postItKeys[question.bookQuestionId], // 위치 계산용 키
          margin: const EdgeInsets.all(8),
          child: DragTarget<BookQuestionModel>(
            onWillAccept: (data) {
              if (data == null || _draggingQuestion == null) {
                if (AppConfig.debugMode) {
                  print('❌ [드롭 거부] 데이터 또는 드래그 질문이 null');
                }
                return false;
              }
              
              // 자기 자신에게는 드롭 불가
              final isSelf = data.bookQuestionId == question.bookQuestionId;
              if (isSelf) {
                if (AppConfig.debugMode) {
                  print('❌ [드롭 거부] 자기 자신에게 드롭 시도');
                }
                return false;
              }
              
              if (AppConfig.debugMode) {
                print('✅ [드롭 허용] 포스트잇 $i에 드롭 가능');
              }
              return true;
            },
            onAccept: (data) {
              if (AppConfig.debugMode) {
                print('🎯 [단순 드롭] ${data.bookQuestionId} → 포스트잇 $i (${_isLeftSide ? "왼쪽" : "오른쪽"})');
              }
              _handleSimpleDrop(data, i, _isLeftSide);
            },
            onMove: (details) {
              // 드래그 중이 아니면 무시
              if (_draggingQuestion == null) return;
              
              // 🆕 민감도 조정: 1/4 지점에서 인식 (200px 포스트잇 기준)
              final isLeftSide = details.offset.dx < 50; // 1/4 지점 (200px * 0.25 = 50px)
              
              if (AppConfig.debugMode) {
                print('🎯 [드롭 호버] 포스트잇 $i에 마우스 위치: ${details.offset.dx.toInt()}, 왼쪽: $isLeftSide (임계값: 50px)');
              }
              
              if (_hoveredIndex != i || _isLeftSide != isLeftSide) {
                setState(() {
                  _hoveredIndex = i;
                  _isLeftSide = isLeftSide;
                });
                
                if (AppConfig.debugMode) {
                  print('📍 [드롭 표시기] 표시: 포스트잇 $i ${isLeftSide ? "왼쪽" : "오른쪽"}');
                }
              }
            },
            onLeave: (data) {
              if (_hoveredIndex == i) {
                setState(() {
                  _hoveredIndex = null;
                  _isLeftSide = false;
                });
              }
            },
            builder: (context, candidateData, rejectedData) {
              // 🎯 드래그 중일 때만 표시기 보이도록 단순화
              final shouldShowLeftIndicator = _draggingQuestion != null && 
                                             _hoveredIndex == i && 
                                             _isLeftSide &&
                                             !isDragging; // 드래그되는 포스트잇 자체는 제외
              
              final shouldShowRightIndicator = _draggingQuestion != null && 
                                              _hoveredIndex == i && 
                                              !_isLeftSide &&
                                              !isDragging; // 드래그되는 포스트잇 자체는 제외
              
              if (AppConfig.debugMode && (shouldShowLeftIndicator || shouldShowRightIndicator)) {
                print('📍 [표시기 표시] 포스트잇 $i: ${shouldShowLeftIndicator ? "왼쪽" : shouldShowRightIndicator ? "오른쪽" : ""} 표시기 활성');
              }
              
              return Stack(
                children: [
                  // 🎯 왼쪽 표시기 (더 강력한 조건)
                  if (shouldShowLeftIndicator)
                    Positioned(
                      left: -15,
                      top: 0,
                      bottom: 0,
                      child: _buildSimpleDropIndicator(context),
                    ),

                  // 🎯 오른쪽 표시기 (더 강력한 조건)
                  if (shouldShowRightIndicator)
                    Positioned(
                      right: -15,
                      top: 0,
                      bottom: 0,
                      child: _buildSimpleDropIndicator(context),
                    ),

                  // 실제 포스트잇 위젯
                  AnimatedOpacity(
                    duration: const Duration(milliseconds: 200),
                    opacity: isDragging ? 0.3 : 1.0,
                    child: PostItBookQuestionWidget(
                      bookQuestion: question,
                      isMyQuestion: question.writerMemberId == widget.currentUserId,
                      onTap: () => widget.onQuestionTap?.call(question),
                      onDragStarted: (draggingQuestion) {
                        if (AppConfig.debugMode) {
                          print('🚀 [단순 드래그] 시작: ${draggingQuestion.bookQuestionId}');
                        }
                        setState(() {
                          _draggingQuestion = draggingQuestion;
                          _draggingOriginalIndex = i; // 원래 위치 기록
                          // 드래그 시작 시 상태 초기화
                          _hoveredIndex = null;
                          _isLeftSide = false;
                        });
                        
                        if (AppConfig.debugMode) {
                          print('🎯 [드롭 준비] 드래그 시작, 드롭 표시기 준비 완료');
                        }
                      },
                      onDragEnd: (draggingQuestion) {
                        if (AppConfig.debugMode) {
                          print('🏁 [단순 드래그] 종료: ${draggingQuestion.bookQuestionId}');
                        }
                        setState(() {
                          _draggingQuestion = null;
                          _draggingOriginalIndex = null;
                          _clearStates();
                        });
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      );
    }

    return Wrap(
      spacing: 20,
      runSpacing: 20,
      alignment: WrapAlignment.center,
      children: children,
    );
  }

  /// 🎯 드롭 표시기 위젯 (🎨 글나무 테마 색상으로 변경)
  Widget _buildSimpleDropIndicator(BuildContext context) {
    final theme = Theme.of(context);
    final Color dropIndicatorColor = theme.colorScheme.primary; // 🎨 글나무 민트색 사용
    
    return Container(
      width: 6, // 더 두껍게
      decoration: BoxDecoration(
        color: dropIndicatorColor,
        borderRadius: BorderRadius.circular(3),
        boxShadow: [
          BoxShadow(
            color: dropIndicatorColor.withOpacity(0.8), // 🎨 민트색 그림자
            blurRadius: 8, // 더 강한 그림자
            offset: const Offset(0, 0),
          ),
          // 🎯 추가 그림자로 더 눈에 잘 띠게
          BoxShadow(
            color: Colors.white.withOpacity(0.8),
            blurRadius: 2,
            offset: const Offset(0, 0),
          ),
        ],
      ),
    );
  }

  /// 🎯 모든 상태 클리어 (단순화)
  void _clearStates() {
    _hoveredIndex = null;
    _isLeftSide = false;
    _predictedInsertIndex = null; // 🆕 예상 삽입 인덱스도 클리어
    
    if (AppConfig.debugMode) {
      print('🧺 [상태 클리어] 모든 드롭 표시기 숨김');
    }
  }

  /// 🎯 단순한 드롭 처리
  void _handleSimpleDrop(
    BookQuestionModel draggedQuestion,
    int targetIndex,
    bool isLeftSide,
  ) {
    if (!mounted) return;

    final currentIndex = _orderedQuestions.indexWhere(
      (q) => q.bookQuestionId == draggedQuestion.bookQuestionId,
    );

    if (currentIndex == -1) {
      if (AppConfig.debugMode) {
        print('❌ [단순 드롭] 현재 인덱스를 찾을 수 없음');
      }
      return;
    }

    // 🎯 간단한 삽입 위치 계산
    int insertIndex;
    if (isLeftSide) {
      insertIndex = targetIndex; // 타겟 앞에 삽입
    } else {
      insertIndex = targetIndex + 1; // 타겟 뒤에 삽입
    }

    _performSimpleReorder(
      draggedQuestion,
      currentIndex,
      insertIndex,
      isLeftSide ? "앞" : "뒤",
    );
  }

  /// 🎯 단순한 순서 변경 수행
  void _performSimpleReorder(
    BookQuestionModel draggedQuestion,
    int currentIndex,
    int insertIndex,
    String direction,
  ) {
    // 🎯 원위치 드롭 기준 완화: 오직 자기 자신에게만 드롭할 때만 차단
    if (currentIndex == insertIndex) {
      if (AppConfig.debugMode) {
        print('🚫 [원위치 드롭] 자기 자신에게 드롭, 변경 안 함');
      }
      return;
    }
    
    // 드래그한 항목이 삽입 위치보다 앞에 있으면 인덱스 조정
    if (currentIndex < insertIndex) {
      insertIndex--;
    }

    // 경계 검사
    insertIndex = insertIndex.clamp(0, _orderedQuestions.length);

    // 조정 후에도 같은 위치인지 체크
    if (currentIndex == insertIndex) {
      if (AppConfig.debugMode) {
        print('🚫 [원위치 드롭] 조정 후에도 동일 위치, 변경 안 함');
      }
      return;
    }

    if (AppConfig.debugMode) {
      print('🎯 [단순 순서 변경] $currentIndex → $insertIndex ($direction)');
    }

    // 애니메이션 시작
    _reorderController.forward().then((_) {
      _reorderController.reset();
    });

    setState(() {
      // 기존 위치에서 제거
      final question = _orderedQuestions.removeAt(currentIndex);
      
      // 새 위치에 삽입
      _orderedQuestions.insert(insertIndex, question);

      // 상태 클리어
      _clearStates();
    });

    // 간단한 성공 피드백
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('포스트잇을 ${direction}쪽으로 이동했습니다'),
          duration: const Duration(seconds: 1),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  /// 🆕 전체 영역 드롭 오버레이 (빈 공간 포함)
  Widget _buildFullAreaDropOverlay(BuildContext context) {
    return Positioned.fill(
      child: DragTarget<BookQuestionModel>(
        onWillAcceptWithDetails: (data) {
          if (data.data == null || _draggingQuestion == null) {
            return false;
          }
          return true; // 빈 공간에서도 드롭 가능
        },
        onAcceptWithDetails: (data) {
          if (_predictedInsertIndex != null) {
            if (AppConfig.debugMode) {
              print('🎆 [전체 영역 드롭] ${data.data.bookQuestionId} → 인덱스 $_predictedInsertIndex');
            }
            _handleFullAreaDrop(data.data, _predictedInsertIndex!);
          }
        },
        onMove: (details) {
          if (_draggingQuestion == null) return;
          
          // 마우스 위치에 따라 예상 삽입 인덱스 계산
          final insertIndex = _calculateInsertIndex(details.offset);
          
          if (_predictedInsertIndex != insertIndex) {
            setState(() {
              _predictedInsertIndex = insertIndex;
            });
            
            if (AppConfig.debugMode) {
              print('🎯 [삽입 인덱스 예측] $insertIndex번째 위치');
            }
          }
        },
        onLeave: (data) {
          setState(() {
            _predictedInsertIndex = null;
          });
          
          if (AppConfig.debugMode) {
            print('🚻 [전체 영역] 드래그 어웨이, 예측 인덱스 제거');
          }
        },
        builder: (context, candidateData, rejectedData) {
          return Container(
            color: Colors.transparent, // 투명한 오버레이
          );
        },
      ),
    );
  }

  /// 🆕 마우스 위치에 따른 삽입 인덱스 계산 (Y축 고려 개선)
  int _calculateInsertIndex(Offset mousePosition) {
    if (_orderedQuestions.isEmpty) return 0;
    
    // 🎯 1단계: 마우스 Y 좌표와 비슷한 높이의 포스트잇들만 필터링
    final List<int> candidateIndices = [];
    final double mouseY = mousePosition.dy;
    
    for (int i = 0; i < _orderedQuestions.length; i++) {
      final question = _orderedQuestions[i];
      final key = _postItKeys[question.bookQuestionId];
      
      if (key?.currentContext != null) {
        try {
          final RenderBox renderBox = key!.currentContext!.findRenderObject() as RenderBox;
          final globalPos = renderBox.localToGlobal(Offset.zero);
          
          // 컨테이너 기준 로컬 좌표로 변환
          final containerRenderBox = _containerKey.currentContext?.findRenderObject() as RenderBox?;
          if (containerRenderBox != null) {
            final localPos = containerRenderBox.globalToLocal(globalPos);
            final postItY = localPos.dy;
            final postItHeight = renderBox.size.height;
            
            // 🎯 Y축 범위 체크: 마우스가 포스트잇과 비슷한 높이에 있는지 확인
            // 포스트잇 높이의 50% 여유를 둠 (같은 행으로 간주)
            final tolerance = postItHeight * 0.5;
            if (mouseY >= postItY - tolerance && mouseY <= postItY + postItHeight + tolerance) {
              candidateIndices.add(i);
              
              if (AppConfig.debugMode) {
                print('🎯 [후보 선정] 포스트잇 $i: Y범위 ${postItY.toInt()}~${(postItY + postItHeight).toInt()}, 마우스Y: ${mouseY.toInt()}');
              }
            }
          }
        } catch (e) {
          if (AppConfig.debugMode) {
            print('⚠️ [후보 선정] 포스트잇 $i 오류: $e');
          }
        }
      }
    }
    
    // 🎯 2단계: 후보가 없으면 전체에서 가장 가까운 것 선택
    if (candidateIndices.isEmpty) {
      if (AppConfig.debugMode) {
        print('⚠️ [삽입 인덱스] 같은 행 후보 없음, 전체에서 계산');
      }
      return _calculateInsertIndexFallback(mousePosition);
    }
    
    // 🎯 3단계: 후보들 중에서 가장 적절한 삽입 위치 계산
    double minDistance = double.infinity;
    int bestIndex = 0;
    
    for (final candidateIndex in candidateIndices) {
      final question = _orderedQuestions[candidateIndex];
      final key = _postItKeys[question.bookQuestionId];
      
      if (key?.currentContext != null) {
        try {
          final RenderBox renderBox = key!.currentContext!.findRenderObject() as RenderBox;
          final globalPos = renderBox.localToGlobal(Offset.zero);
          
          final containerRenderBox = _containerKey.currentContext?.findRenderObject() as RenderBox?;
          if (containerRenderBox != null) {
            final localPos = containerRenderBox.globalToLocal(globalPos);
            final postItCenter = Offset(
              localPos.dx + renderBox.size.width / 2,
              localPos.dy + renderBox.size.height / 2,
            );
            
            // 🎯 X축 거리만 계산 (같은 행이므로 Y축은 고려하지 않음)
            final xDistance = (mousePosition.dx - postItCenter.dx).abs();
            
            if (xDistance < minDistance) {
              minDistance = xDistance;
              
              // 🆕 1/4 지점 기준으로 앞/뒤 결정
              final postItLeftQuarter = localPos.dx + (renderBox.size.width * 0.25);
              bestIndex = mousePosition.dx < postItLeftQuarter ? candidateIndex : candidateIndex + 1;
              
              if (AppConfig.debugMode) {
                print('🎯 [최적 위치] 포스트잇 $candidateIndex: X거리=${xDistance.toInt()}, 1/4지점=${postItLeftQuarter.toInt()}, 삽입인덱스=$bestIndex');
              }
            }
          }
        } catch (e) {
          if (AppConfig.debugMode) {
            print('⚠️ [최적 위치 계산] 포스트잇 $candidateIndex 오류: $e');
          }
        }
      }
    }
    
    // 경계 검사
    bestIndex = bestIndex.clamp(0, _orderedQuestions.length);
    
    if (AppConfig.debugMode) {
      print('🎯 [최종 삽입 인덱스] $bestIndex (후보: ${candidateIndices.length}개)');
    }
    
    return bestIndex;
  }
  
  /// 🆕 폴백 계산 (후보가 없을 때 전체에서 계산)
  int _calculateInsertIndexFallback(Offset mousePosition) {
    double minDistance = double.infinity;
    int bestIndex = 0;
    
    for (int i = 0; i < _orderedQuestions.length; i++) {
      final question = _orderedQuestions[i];
      final key = _postItKeys[question.bookQuestionId];
      
      if (key?.currentContext != null) {
        try {
          final RenderBox renderBox = key!.currentContext!.findRenderObject() as RenderBox;
          final globalPos = renderBox.localToGlobal(Offset.zero);
          
          final containerRenderBox = _containerKey.currentContext?.findRenderObject() as RenderBox?;
          if (containerRenderBox != null) {
            final localPos = containerRenderBox.globalToLocal(globalPos);
            final postItCenter = Offset(
              localPos.dx + renderBox.size.width / 2,
              localPos.dy + renderBox.size.height / 2,
            );
            
            final distance = (mousePosition - postItCenter).distance;
            
            if (distance < minDistance) {
              minDistance = distance;
              final postItLeftQuarter = postItCenter.dx - (renderBox.size.width * 0.25);
              bestIndex = mousePosition.dx < postItLeftQuarter ? i : i + 1;
            }
          }
        } catch (e) {
          if (AppConfig.debugMode) {
            print('⚠️ [폴백 계산] 포스트잇 $i 오류: $e');
          }
        }
      }
    }
    
    return bestIndex.clamp(0, _orderedQuestions.length);
  }

  /// 🆕 예상 삽입 인덱스 표시기 (세로 선)
  Widget _buildInsertIndexIndicator(BuildContext context) {
    if (_predictedInsertIndex == null) return const SizedBox.shrink();
    
    final theme = Theme.of(context);
    
    // 삽입 위치에 따른 선 위치 계산
    if (_predictedInsertIndex == 0) {
      // 맨 앞에 삽입
      return Positioned(
        left: 0,
        top: 0,
        bottom: 0,
        child: _buildVerticalInsertLine(context, theme),
      );
    } else if (_predictedInsertIndex == _orderedQuestions.length) {
      // 맨 뒤에 삽입
      return Positioned(
        right: 0,
        top: 0,
        bottom: 0,
        child: _buildVerticalInsertLine(context, theme),
      );
    } else {
      // 중간에 삽입 - 해당 인덱스 포스트잇 앞에 표시
      final targetQuestion = _orderedQuestions[_predictedInsertIndex!];
      final key = _postItKeys[targetQuestion.bookQuestionId];
      
      if (key?.currentContext != null) {
        try {
          final RenderBox renderBox = key!.currentContext!.findRenderObject() as RenderBox;
          final globalPos = renderBox.localToGlobal(Offset.zero);
          final containerRenderBox = _containerKey.currentContext?.findRenderObject() as RenderBox?;
          
          if (containerRenderBox != null) {
            final localPos = containerRenderBox.globalToLocal(globalPos);
            
            return Positioned(
              left: localPos.dx - 25, // 포스트잇 앞쪽에
              top: localPos.dy,
              child: SizedBox(
                height: renderBox.size.height,
                child: _buildVerticalInsertLine(context, theme),
              ),
            );
          }
        } catch (e) {
          if (AppConfig.debugMode) {
            print('⚠️ [삽입 표시기] 위치 계산 오류: $e');
          }
        }
      }
    }
    
    return const SizedBox.shrink();
  }
  
  /// 세로 삽입 선 위젯 (🎨 글나무 테마 색상)
  Widget _buildVerticalInsertLine(BuildContext context, ThemeData theme) {
    final Color insertLineColor = theme.colorScheme.primary; // 🎨 글나무 민트색 사용
    
    return Container(
      width: 4,
      decoration: BoxDecoration(
        color: insertLineColor,
        borderRadius: BorderRadius.circular(2),
        boxShadow: [
          BoxShadow(
            color: insertLineColor.withOpacity(0.8), // 🎨 민트색 그림자
            blurRadius: 8,
            offset: const Offset(0, 0),
          ),
          // 추가 그림자로 더 눈에 잘 띠게
          BoxShadow(
            color: Colors.white.withOpacity(0.9),
            blurRadius: 2,
            offset: const Offset(0, 0),
          ),
        ],
      ),
    );
  }

  /// 🆕 전체 영역 드롭 처리
  void _handleFullAreaDrop(BookQuestionModel draggedQuestion, int insertIndex) {
    if (!mounted) return;

    final currentIndex = _orderedQuestions.indexWhere(
      (q) => q.bookQuestionId == draggedQuestion.bookQuestionId,
    );

    if (currentIndex == -1) {
      if (AppConfig.debugMode) {
        print('❌ [전체 영역 드롭] 현재 인덱스를 찾을 수 없음');
      }
      return;
    }

    _performSimpleReorder(
      draggedQuestion,
      currentIndex,
      insertIndex,
      '${insertIndex + 1}번째 위치',
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
