import 'package:flutter/material.dart';
import '../../../services/contact/contact_service.dart';
import '../../../core/config/app_config.dart';

/// 문의하기 화면의 로직을 담당하는 Mixin
///
/// 기능:
/// - 에러 보고 BottomSheet 표시 및 전송
/// - 기능 요청 BottomSheet 표시 및 전송
/// - 로딩 상태 관리
/// - 입력 유효성 검증
/// - 성공/실패 메시지 표시
/// - 🆕 로컬 저장 기능 (실수 닫힘 방지)
/// - 🚀 안전한 메모리 관리 (FocusNode 에러 해결)
mixin ContactLogicMixin<T extends StatefulWidget> on State<T> {
  final ContactService _contactService = ContactService();

  // 💾 로컬 저장 변수들
  String _savedErrorReportContent = '';
  String _savedFeatureRequestContent = '';

  // 🚀 안전한 컨트롤러 관리
  final Set<TextEditingController> _activeControllers = {};
  final Set<FocusNode> _activeFocusNodes = {};

  // 🚀 dispose 상태 추적
  final Set<TextEditingController> _disposedControllers = {};
  final Set<FocusNode> _disposedFocusNodes = {};

  // 🔄 로딩 상태 관리
  bool _isSubmitting = false;
  String? _currentSubmissionType;

  /// 현재 제출 중인지 여부
  bool get isSubmitting => _isSubmitting;

  /// 현재 제출 중인 타입 (에러 보고/기능 요청)
  String? get currentSubmissionType => _currentSubmissionType;

  /// 에러 보고 BottomSheet 표시
  void showErrorReportBottomSheet() {
    _showContactBottomSheet(
      type: 'error',
      title: '🐛 에러 보고',
      subtitle: '앱에서 발생한 문제를 알려주세요',
      hintText: '어떤 문제가 발생했나요?\n\n예시:\n- 로그인이 안 돼요\n- 화면이 느려요\n- 버튼이 작동하지 않아요',
      initialContent: _savedErrorReportContent,
      onSubmit: _handleErrorReportSubmit,
      onContentChanged: (content) => _savedErrorReportContent = content,
    );
  }

  /// 기능 요청 BottomSheet 표시
  void showFeatureRequestBottomSheet() {
    _showContactBottomSheet(
      type: 'feature',
      title: '💡 기능 요청',
      subtitle: '새로운 아이디어를 제안해주세요',
      hintText:
          '어떤 기능이 있으면 좋을까요?\n\n예시:\n- 독서 진도 알림 기능\n- 모임 캘린더 연동\n- 발제문 템플릿 제공',
      initialContent: _savedFeatureRequestContent,
      onSubmit: _handleFeatureRequestSubmit,
      onContentChanged: (content) => _savedFeatureRequestContent = content,
    );
  }

  /// 🚀 안전한 공통 BottomSheet 표시 메서드 (완전 개선)
  void _showContactBottomSheet({
    required String type,
    required String title,
    required String subtitle,
    required String hintText,
    required Future<void> Function(String content) onSubmit,
    String initialContent = '',
    Function(String content)? onContentChanged,
  }) {
    // 🚀 안전한 컨트롤러 생성
    TextEditingController? contentController;
    FocusNode? contentFocusNode;

    try {
      contentController = TextEditingController(text: initialContent);
      contentFocusNode = FocusNode();

      // 활성 컨트롤러 등록
      _activeControllers.add(contentController);
      _activeFocusNodes.add(contentFocusNode);
    } catch (e) {
      return;
    }

    // 🚀 dispose 상태 추적
    bool isDisposed = false;
    bool localSubmitting = false;

    // 🚀 안전한 포커스 설정 함수
    void safeSetFocus() {
      if (isDisposed || contentController == null || contentFocusNode == null)
        return;

      try {
        if (initialContent.isNotEmpty && contentController.text.isNotEmpty) {
          contentController.selection = TextSelection.fromPosition(
            TextPosition(offset: contentController.text.length),
          );
        }
        if (!contentFocusNode.hasFocus && contentFocusNode.canRequestFocus) {
          contentFocusNode.requestFocus();
        }
      } catch (e) {
        // 포커스 설정 실패 무시
      }
    }

    // 프레임 완료 후 포커스 설정
    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetFocus());

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      enableDrag: true,
      isDismissible: true,
      useSafeArea: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          // 🚀 안전성 체크
          if (isDisposed ||
              contentController == null ||
              contentFocusNode == null) {
            return const SizedBox.shrink();
          }

          return Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
            // 🔧 고정 패딩 사용 (BottomSheet가 키보드를 자동으로 피함)
            padding: const EdgeInsets.all(20),
            // 🚀 최대 높이 제한으로 오버플로우 방지
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.8,
              minHeight: 200,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 상단 핸들
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurfaceVariant.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 제목 및 부제목
                  Text(
                    title,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 입력 필드
                  TextFormField(
                    controller: contentController,
                    focusNode: contentFocusNode,
                    maxLines: 6,
                    maxLength: 1000,
                    onChanged: (value) {
                      if (isDisposed) return;
                      onContentChanged?.call(value);
                    },
                    decoration: InputDecoration(
                      hintText: hintText,
                      hintStyle: TextStyle(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurfaceVariant.withOpacity(0.6),
                        height: 1.4,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Theme.of(
                        context,
                      ).colorScheme.surfaceContainerHighest.withOpacity(0.3),
                    ),
                    style: const TextStyle(height: 1.4),
                  ),
                  const SizedBox(height: 16),

                  // 버튼들
                  Row(
                    children: [
                      // 취소 버튼
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _isSubmitting
                              ? null
                              : () {
                                  try {
                                    Navigator.of(context).pop();
                                  } catch (e) {
                                    // 닫기 실패 무시
                                  }
                                },
                          child: const Text('취소'),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // 전송 버튼
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          onPressed:
                              (_isSubmitting || localSubmitting || isDisposed)
                              ? null
                              : () async {
                                  final content = contentController!.text
                                      .trim();

                                  // 빈 내용 방지 로직
                                  if (content.isEmpty) {
                                    _showSnackBar('내용을 입력해주세요.');
                                    return;
                                  }

                                  if (content.length < 5) {
                                    _showSnackBar('최소 5자 이상 입력해주세요.');
                                    return;
                                  }

                                  final validation = _contactService
                                      .validateContent(content);

                                  if (!validation['isValid']) {
                                    _showSnackBar(validation['message']);
                                    return;
                                  }

                                  // 🚀 안전한 로딩 상태 설정
                                  if (!isDisposed) {
                                    setModalState(() {
                                      localSubmitting = true;
                                      _isSubmitting = true;
                                      _currentSubmissionType = type;
                                    });
                                  }

                                  try {
                                    await onSubmit(content);
                                    // 🚀 성공 시 안전한 닫기
                                    if (!isDisposed && context.mounted) {
                                      Navigator.of(context).pop();
                                    }
                                  } catch (e) {
                                    // 에러는 onSubmit 내부에서 처리됨
                                  } finally {
                                    // 🚀 안전한 로딩 상태 해제
                                    if (!isDisposed) {
                                      try {
                                        setModalState(() {
                                          localSubmitting = false;
                                          _isSubmitting = false;
                                          _currentSubmissionType = null;
                                        });
                                      } catch (e) {
                                        // 상태 업데이트 실패 무시
                                      }
                                    }
                                  }
                                },
                          child:
                              (_isSubmitting || localSubmitting) &&
                                  _currentSubmissionType == type
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text('전송'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    ).whenComplete(() {
      // 🚀 안전한 정리
      _safeCleanupControllers(
        contentController,
        contentFocusNode,
        () => isDisposed = true,
      );
    });
  }

  /// 에러 보고 제출 처리
  Future<void> _handleErrorReportSubmit(String content) async {
    try {
      final success = await _contactService.reportError(
        content,
        context,
      ); // context 전달

      if (success) {
        _savedErrorReportContent = '';
        Future.delayed(const Duration(milliseconds: 200), () {
          if (mounted) {
            _showSnackBar('에러 보고가 전송되었습니다. 빠른 시일 내에 확인하겠습니다.');
          }
        });
      }
    } catch (e) {
      _showSnackBar('전송 중 오류가 발생했습니다: ${e.toString()}');
    }
  }

  /// 기능 요청 제출 처리
  Future<void> _handleFeatureRequestSubmit(String content) async {
    try {
      final success = await _contactService.requestFeature(
        content,
        context,
      ); // context 전달

      if (success) {
        _savedFeatureRequestContent = '';
        Future.delayed(const Duration(milliseconds: 200), () {
          if (mounted) {
            _showSnackBar('기능 요청이 전송되었습니다. 검토해 보겠습니다.');
          }
        });
      }
    } catch (e) {
      _showSnackBar('전송 중 오류가 발생했습니다: ${e.toString()}');
    }
  }

  /// SnackBar 표시 헬퍼
  void _showSnackBar(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.primary,
        duration: const Duration(milliseconds: 3000),
      ),
    );
  }

  /// 🚀 안전한 컨트롤러 정리 (개선된 방식)
  void _safeCleanupControllers(
    TextEditingController? controller,
    FocusNode? focusNode,
    VoidCallback? onDispose,
  ) {
    // 🚀 dispose 상태 설정
    onDispose?.call();

    // 🚀 비동기로 안전한 정리
    Future.microtask(() {
      try {
        if (controller != null && !_disposedControllers.contains(controller)) {
          _activeControllers.remove(controller);
          _disposedControllers.add(controller);
          controller.dispose();
        }
      } catch (e) {
        // Controller dispose 에러 무시
      }

      try {
        if (focusNode != null && !_disposedFocusNodes.contains(focusNode)) {
          _activeFocusNodes.remove(focusNode);
          if (focusNode.hasFocus && focusNode.canRequestFocus) {
            focusNode.unfocus();
          }
          _disposedFocusNodes.add(focusNode);
          focusNode.dispose();
        }
      } catch (e) {
        // FocusNode dispose 에러 무시
      }

      // 🚀 상태 정리 (안전하게)
      if (mounted) {
        try {
          setState(() {
            _isSubmitting = false;
            _currentSubmissionType = null;
          });
        } catch (e) {
          // 상태 정리 에러 무시
        }
      }
    });
  }

  @override
  void dispose() {
    final controllersToDispose = _activeControllers.toList();
    _activeControllers.clear();

    for (final controller in controllersToDispose) {
      try {
        if (!_disposedControllers.contains(controller)) {
          _disposedControllers.add(controller);
          controller.dispose();
        }
      } catch (e) {
        // Controller dispose 에러 무시
      }
    }

    // 🚀 안전한 포커스노드 정리
    final focusNodesToDispose = _activeFocusNodes.toList();
    _activeFocusNodes.clear();

    for (final focusNode in focusNodesToDispose) {
      try {
        if (!_disposedFocusNodes.contains(focusNode)) {
          if (focusNode.hasFocus && focusNode.canRequestFocus) {
            focusNode.unfocus();
          }
          _disposedFocusNodes.add(focusNode);
          focusNode.dispose();
        }
      } catch (e) {
        // FocusNode dispose 에러 무시
      }
    }

    _disposedControllers.clear();
    _disposedFocusNodes.clear();

    super.dispose();
  }
}
