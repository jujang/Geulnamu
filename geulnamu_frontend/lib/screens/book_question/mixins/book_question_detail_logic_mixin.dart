import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/config/app_config.dart';
import '../../../models/book_question/book_question_model.dart';
import '../../../services/book_question/book_question_service.dart';
import '../../../providers/auth_provider.dart';
import '../widgets/post_it_widgets.dart';

/// 발제문 상세 페이지 비즈니스 로직 mixin
/// 
/// 기능:
/// - API 호출로 발제문 데이터 로드
/// - 그룹별 탭 생성
/// - 수정/삭제 권한 체크
/// - CRUD 작업 처리
mixin BookQuestionDetailLogicMixin<T extends StatefulWidget> on State<T> {
  
  // 서비스
  final BookQuestionService _bookQuestionService = BookQuestionService();
  
  // 상태 변수
  bool _isLoading = false;
  String? _errorMessage;
  BookQuestionResponse? _bookQuestionResponse;
  
  // 탭 관련
  TabController? _tabController;
  int _currentTabIndex = 0;
  
  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  BookQuestionResponse? get bookQuestionResponse => _bookQuestionResponse;
  TabController? get tabController => _tabController;
  int get currentTabIndex => _currentTabIndex;
  
  /// 그룹 수 (탭 수)
  int get groupCount => _bookQuestionResponse?.groups.length ?? 0;
  
  /// 현재 선택된 그룹의 발제문들
  List<BookQuestionModel> get currentGroupQuestions {
    if (_bookQuestionResponse == null || _currentTabIndex >= groupCount) {
      return [];
    }
    return _bookQuestionResponse!.groups[_currentTabIndex].bookQuestionList;
  }
  
  /// 권한 체크 - 관리자급(STAFF 이상) 여부
  bool get canEditDelete {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    return authProvider.isStaffLevel;
  }
  
  /// 현재 사용자 ID
  int? get currentUserId {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    return authProvider.userId;
  }

  /// 발제문 데이터 초기 로드
  Future<void> initializeBookQuestions({required int meetingId}) async {
    if (!mounted) return;
    
    try {
      _setLoading(true);
      _clearError();
      
      if (AppConfig.debugMode) {
        debugPrint('🚀 [발제문 상세] 데이터 로드 시작 - meetingId: $meetingId');
      }
      
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final accessToken = await authProvider.accessToken;
      
      if (accessToken == null) {
        throw Exception('인증 토큰이 없습니다. 다시 로그인해주세요.');
      }
      
      final response = await _bookQuestionService.getMeetingBookQuestions(
        meetingId: meetingId,
        accessToken: accessToken,
        forceRefresh: true,
      );
      
      if (mounted) {
        setState(() {
          _bookQuestionResponse = response;
        });
        
        // 탭 컨트롤러 초기화
        _initializeTabController();
        
        if (AppConfig.debugMode) {
          debugPrint('✅ [발제문 상세] 데이터 로드 성공');
          debugPrint('   - 그룹 수: ${response.groups.length}개');
          debugPrint('   - 전체 발제문 수: ${response.allBookQuestions.length}개');
        }
      }
    } catch (e) {
      if (AppConfig.debugMode) {
        debugPrint('❌ [발제문 상세] 데이터 로드 실패: $e');
      }
      
      if (mounted) {
        _setError(_getErrorMessage(e));
      }
    } finally {
      if (mounted) {
        _setLoading(false);
      }
    }
  }
  
  /// 탭 컨트롤러 초기화
  void _initializeTabController() {
    // 기존 컨트롤러 정리
    _tabController?.dispose();
    
    if (groupCount > 0) {
      _tabController = TabController(
        length: groupCount,
        vsync: this as TickerProvider, // 명시적 캐스팅
        initialIndex: 0,
      );
      
      _tabController!.addListener(() {
        if (_tabController!.indexIsChanging) {
          setState(() {
            _currentTabIndex = _tabController!.index;
          });
          
          if (AppConfig.debugMode) {
            // 탭 변경 로그
            debugPrint('📂 [탭 변경] ${_currentTabIndex + 1}조로 이동');
          }
        }
      });
    }
  }
  
  /// 발제문 새로고침
  Future<void> refreshBookQuestions({required int meetingId}) async {
    await initializeBookQuestions(meetingId: meetingId);
  }
  
  /// 발제문 수정
  Future<void> updateBookQuestion({
    required BookQuestionModel bookQuestion,
    required String newContent,
    required int meetingId,
  }) async {
    if (!mounted) return;
    
    try {
      if (AppConfig.debugMode) {
        debugPrint('🔄 [발제문 수정] 시작 - ID: ${bookQuestion.bookQuestionId}');
      }
      
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final accessToken = await authProvider.accessToken;
      
      if (accessToken == null) {
        throw Exception('인증 토큰이 없습니다.');
      }
      
      await _bookQuestionService.updateBookQuestion(
        bookQuestionId: bookQuestion.bookQuestionId,
        content: newContent,
        accessToken: accessToken,
      );
      
      if (AppConfig.debugMode) {
        debugPrint('✅ [발제문 수정] 성공');
      }
      
      // 성공 메시지 표시
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('발제문이 수정되었습니다.'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
        
        // 데이터 새로고침
        await refreshBookQuestions(meetingId: meetingId);
      }
    } catch (e) {
      if (AppConfig.debugMode) {
        debugPrint('❌ [발제문 수정] 실패: $e');
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('발제문 수정에 실패했습니다: ${_getErrorMessage(e)}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
  
  /// 발제문 삭제
  Future<void> deleteBookQuestion({
    required BookQuestionModel bookQuestion,
    required int meetingId,
  }) async {
    if (!mounted) return;
    
    try {
      if (AppConfig.debugMode) {
        debugPrint('🗑️ [발제문 삭제] 시작 - ID: ${bookQuestion.bookQuestionId}');
      }
      
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final accessToken = await authProvider.accessToken;
      
      if (accessToken == null) {
        throw Exception('인증 토큰이 없습니다.');
      }
      
      await _bookQuestionService.deleteBookQuestion(
        bookQuestionId: bookQuestion.bookQuestionId,
        accessToken: accessToken,
      );
      
      if (AppConfig.debugMode) {
        debugPrint('✅ [발제문 삭제] 성공');
      }
      
      // 성공 메시지 표시
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('발제문이 삭제되었습니다.'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
        
        // 데이터 새로고침
        await refreshBookQuestions(meetingId: meetingId);
      }
    } catch (e) {
      if (AppConfig.debugMode) {
        debugPrint('❌ [발제문 삭제] 실패: $e');
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('발제문 삭제에 실패했습니다: ${_getErrorMessage(e)}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
  
  /// 발제문 수정 핸들러 (다이얼로그 포함)
  void handleEditBookQuestion(BookQuestionModel bookQuestion, int meetingId) {
    PostItWidgets.showEditDialog(
      context,
      bookQuestion,
      onSave: (newContent) async {
        await updateBookQuestion(
          bookQuestion: bookQuestion,
          newContent: newContent,
          meetingId: meetingId,
        );
      },
    );
  }
  
  /// 발제문 삭제 핸들러 (확인 다이얼로그 포함)
  void handleDeleteBookQuestion(BookQuestionModel bookQuestion, int meetingId) {
    PostItWidgets.showDeleteDialog(
      context,
      bookQuestion,
      onConfirm: () async {
        await deleteBookQuestion(
          bookQuestion: bookQuestion,
          meetingId: meetingId,
        );
      },
    );
  }
  
  /// 탭 라벨 생성 (1조, 2조, 3조...)
  String getTabLabel(int index) {
    return '${index + 1}조';
  }
  
  /// 현재 그룹 요약 정보
  String getCurrentGroupSummary() {
    if (groupCount == 0) return '그룹 없음';
    
    final currentCount = currentGroupQuestions.length;
    return '${getTabLabel(_currentTabIndex)} · ${currentCount}개 발제문';
  }
  
  // Private methods
  void _setLoading(bool loading) {
    if (mounted && _isLoading != loading) {
      setState(() {
        _isLoading = loading;
      });
    }
  }
  
  void _setError(String? error) {
    if (mounted && _errorMessage != error) {
      setState(() {
        _errorMessage = error;
      });
    }
  }
  
  void _clearError() {
    _setError(null);
  }
  
  String _getErrorMessage(dynamic error) {
    final errorString = error.toString().toLowerCase();
    
    if (errorString.contains('401') || errorString.contains('인증')) {
      return '로그인이 필요합니다.';
    } else if (errorString.contains('403') || errorString.contains('권한')) {
      return '접근 권한이 없습니다.';
    } else if (errorString.contains('404')) {
      return '요청한 데이터를 찾을 수 없습니다.';
    } else if (errorString.contains('network') || errorString.contains('connection')) {
      return '네트워크 연결을 확인해주세요.';
    } else if (errorString.contains('timeout')) {
      return '연결 시간이 초과되었습니다.';
    } else {
      return '오류가 발생했습니다. 잠시 후 다시 시도해주세요.';
    }
  }
  
  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }
}
