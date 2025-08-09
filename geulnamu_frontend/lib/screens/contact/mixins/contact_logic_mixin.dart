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
mixin ContactLogicMixin<T extends StatefulWidget> on State<T> {
  final ContactService _contactService = ContactService();
  
  // 💾 로컬 저장 변수들
  String _savedErrorReportContent = '';
  String _savedFeatureRequestContent = '';
  
  // 🆕 안전한 컸트롤러 관리
  final Set<TextEditingController> _activeControllers = {};
  final Set<FocusNode> _activeFocusNodes = {};
  
  // 🔄 로딩 상태 관리
  bool _isSubmitting = false;
  String? _currentSubmissionType;

  /// 현재 제출 중인지 여부
  bool get isSubmitting => _isSubmitting;

  /// 현재 제출 중인 타입 (에러 보고/기능 요청)
  String? get currentSubmissionType => _currentSubmissionType;

  /// 에러 보고 BottomSheet 표시
  void showErrorReportBottomSheet() {
    if (AppConfig.debugMode) {
      print('🐛 [ContactLogicMixin] 에러 보고 BottomSheet 표시');
      print('💾 [ContactLogicMixin] 기존 저장된 내용: "${_savedErrorReportContent.isEmpty ? '없음' : '${_savedErrorReportContent.substring(0, _savedErrorReportContent.length > 20 ? 20 : _savedErrorReportContent.length)}...'}"');
    }

    _showContactBottomSheet(
      type: 'error',
      title: '🐛 에러 보고',
      subtitle: '앱에서 발생한 문제를 알려주세요',
      hintText: '어떤 문제가 발생했나요?\n\n예시:\n- 로그인이 안 돼요\n- 화면이 느려요\n- 버튼이 작동하지 않아요',
      initialContent: _savedErrorReportContent, // 🆕 저장된 내용 복원
      onSubmit: _handleErrorReportSubmit,
      onContentChanged: (content) => _savedErrorReportContent = content, // 🆕 실시간 저장
    );
  }

  /// 기능 요청 BottomSheet 표시
  void showFeatureRequestBottomSheet() {
    if (AppConfig.debugMode) {
      print('💡 [ContactLogicMixin] 기능 요청 BottomSheet 표시');
      print('💾 [ContactLogicMixin] 기존 저장된 내용: "${_savedFeatureRequestContent.isEmpty ? '없음' : '${_savedFeatureRequestContent.substring(0, _savedFeatureRequestContent.length > 20 ? 20 : _savedFeatureRequestContent.length)}...'}"');
    }

    _showContactBottomSheet(
      type: 'feature',
      title: '💡 기능 요청',
      subtitle: '새로운 아이디어를 제안해주세요',
      hintText: '어떤 기능이 있으면 좋을까요?\n\n예시:\n- 독서 진도 알림 기능\n- 모임 캘린더 연동\n- 발제문 템플릿 제공',
      initialContent: _savedFeatureRequestContent, // 🆕 저장된 내용 복원
      onSubmit: _handleFeatureRequestSubmit,
      onContentChanged: (content) => _savedFeatureRequestContent = content, // 🆕 실시간 저장
    );
  }

  /// 공통 BottomSheet 표시 메서드
  void _showContactBottomSheet({
    required String type,
    required String title,
    required String subtitle,
    required String hintText,
    required Future<void> Function(String content) onSubmit,
    String initialContent = '', // 🆕 초기 내용
    Function(String content)? onContentChanged, // 🆕 내용 변경 콜백
  }) {
    final TextEditingController contentController = TextEditingController(
      text: initialContent, // 🆕 저장된 내용으로 초기화
    );
    final FocusNode contentFocusNode = FocusNode();
    
    // 🆕 안전한 관리를 위한 등록
    _activeControllers.add(contentController);
    _activeFocusNodes.add(contentFocusNode);
    
    // 🆕 로컬 제출 상태 관리 (글로벌과 분리)
    bool localSubmitting = false;

    // 🆕 커서 위치를 끝으로 이동 (기존 내용이 있을 때)
    if (initialContent.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (contentController.text.isNotEmpty) {
          contentController.selection = TextSelection.fromPosition(
            TextPosition(offset: contentController.text.length),
          );
        }
        if (!contentFocusNode.hasFocus) {
          contentFocusNode.requestFocus();
        }
      });
    } else {
      // BottomSheet 표시 후 자동 포커스
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!contentFocusNode.hasFocus) {
          contentFocusNode.requestFocus();
        }
      });
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // 키보드에 맞춰 크기 조절
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: EdgeInsets.only(
            top: 20,
            left: 20,
            right: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20, // 키보드 높이 고려
          ),
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
                    color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.4),
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
                  // 🆕 실시간 로컬 저장
                  onContentChanged?.call(value);
                  if (AppConfig.debugMode) {
                    print('💾 [ContactLogicMixin] 내용 저장: "${value.length > 20 ? '${value.substring(0, 20)}...' : value}"');
                  }
                },
                decoration: InputDecoration(
                  hintText: hintText,
                  hintStyle: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.6),
                    height: 1.4,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
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
                      onPressed: _isSubmitting ? null : () => Navigator.pop(context),
                      child: const Text('취소'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  
                  // 전송 버튼
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: (_isSubmitting || localSubmitting)
                          ? null
                          : () async {
                              final content = contentController.text.trim();
                              
                              // 🔒 빈 내용 방지 로직
                              if (content.isEmpty) {
                                _showSnackBar('내용을 입력해주세요.');
                                return;
                              }
                              
                              if (content.length < 5) {
                                _showSnackBar('최소 5자 이상 입력해주세요.');
                                return;
                              }
                              
                              final validation = _contactService.validateContent(content);
                              
                              if (!validation['isValid']) {
                                _showSnackBar(validation['message']);
                                return;
                              }

                              // 🆕 로컬 로딩 상태 설정
                              setModalState(() {
                                localSubmitting = true;
                                _isSubmitting = true;
                                _currentSubmissionType = type;
                              });

                              try {
                                await onSubmit(content);
                                // 🆕 성공 시 직접 Navigator.pop 사용
                                if (context.mounted) {
                                  Navigator.of(context).pop(); // BottomSheet 닫기
                                }
                              } catch (e) {
                                // 에러는 onSubmit 내부에서 처리됨
                                if (AppConfig.debugMode) {
                                  print('⚠️ [ContactLogicMixin] 전송 오류: $e');
                                }
                              } finally {
                                // 🆕 로컬 로딩 상태 해제 (마운트 체크 없이)
                                setModalState(() {
                                  localSubmitting = false;
                                  _isSubmitting = false;
                                  _currentSubmissionType = null;
                                });
                              }
                            },
                      child: (_isSubmitting || localSubmitting) && _currentSubmissionType == type
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('전송'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ).whenComplete(() {
      // 🆕 BottomSheet 닫힐 때 간단한 정리
      _cleanupControllers(contentController, contentFocusNode);
    });
  }

  /// 에러 보고 제출 처리
  Future<void> _handleErrorReportSubmit(String content) async {
    try {
      final success = await _contactService.reportError(content);
      
      if (success) {
        // 🆕 전송 성공 시 저장된 내용 삭제
        _savedErrorReportContent = '';
        if (AppConfig.debugMode) {
          print('🎉 [ContactLogicMixin] 에러 보고 전송 성공 - 저장된 내용 삭제');
        }
        // 🆕 성공 메시지는 BottomSheet 닫힘 후 표시
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
      final success = await _contactService.requestFeature(content);
      
      if (success) {
        // 🆕 전송 성공 시 저장된 내용 삭제
        _savedFeatureRequestContent = '';
        if (AppConfig.debugMode) {
          print('🎉 [ContactLogicMixin] 기능 요청 전송 성공 - 저장된 내용 삭제');
        }
        // 🆕 성공 메시지는 BottomSheet 닫힘 후 표시
        Future.delayed(const Duration(milliseconds: 200), () {
          if (mounted) {
            _showSnackBar('기능 요청이 전송되었습니다. 검토 후 답변드리겠습니다.');
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
  
  /// 🆕 안전한 dispose 처리
  void _safeDispose(TextEditingController controller, FocusNode focusNode) {
    Future.microtask(() {
      try {
        _activeControllers.remove(controller);
        controller.dispose();
      } catch (e) {
        if (AppConfig.debugMode) {
          print('⚠️ [ContactLogicMixin] Controller dispose 에러: $e');
        }
      }
      
      try {
        _activeFocusNodes.remove(focusNode);
        if (focusNode.hasFocus) {
          focusNode.unfocus();
        }
        focusNode.dispose();
      } catch (e) {
        if (AppConfig.debugMode) {
          print('⚠️ [ContactLogicMixin] FocusNode dispose 에러: $e');
        }
      }
    });
  }
  
  /// 🆕 간단한 컸트롤러 정리 (원래 방식)
  void _cleanupControllers(TextEditingController controller, FocusNode focusNode) {
    // 🚀 즉시 등록 해제
    _activeControllers.remove(controller);
    _activeFocusNodes.remove(focusNode);
    
    // 🚀 간단한 dispose (에러 무시)
    try { controller.dispose(); } catch (_) {}
    try { focusNode.dispose(); } catch (_) {}
    
    // 🚀 상태 정리
    if (mounted) {
      setState(() {
        _isSubmitting = false;
        _currentSubmissionType = null;
      });
    }
  }
  
  /// 🆕 모든 액티브 컸트롤러 정리 (위젯 생명주기 끝에 사용)
  @override
  void dispose() {
    // 모든 액티브 컸트롤러 정리
    for (final controller in _activeControllers.toList()) {
      try {
        controller.dispose();
      } catch (e) {
        if (AppConfig.debugMode) {
          print('⚠️ [ContactLogicMixin] 전체 Controller dispose 에러: $e');
        }
      }
    }
    
    for (final focusNode in _activeFocusNodes.toList()) {
      try {
        if (focusNode.hasFocus) {
          focusNode.unfocus();
        }
        focusNode.dispose();
      } catch (e) {
        if (AppConfig.debugMode) {
          print('⚠️ [ContactLogicMixin] 전체 FocusNode dispose 에러: $e');
        }
      }
    }
    
    _activeControllers.clear();
    _activeFocusNodes.clear();
    
    super.dispose();
  }
}
