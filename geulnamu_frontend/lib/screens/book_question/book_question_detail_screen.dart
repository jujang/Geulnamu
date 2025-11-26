import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/main_layout.dart';
import '../../widgets/common/loading_widgets.dart';
import '../../core/config/app_config.dart';
import '../../services/home/home_service.dart';
import 'mixins/book_question_detail_logic_mixin.dart';
import 'widgets/book_question_detail_widgets.dart';

/// 발제문 상세 페이지
///
/// 기능:
/// - 모임별 발제문을 그룹(조)별 탭으로 표시
/// - 포스트잇 모양의 발제문 카드
/// - 익명 표시 (작성자 이름 숨김)
/// - 관리자급만 수정/삭제 가능
/// - 동적 탭 생성 (그룹 수만큼)
class BookQuestionDetailScreen extends StatefulWidget {
  /// 모임 ID (필수)
  final int meetingId;

  /// 모임 제목 (선택, 헤더 표시용)
  final String? meetingTitle;

  const BookQuestionDetailScreen({
    super.key,
    required this.meetingId,
    this.meetingTitle,
  });

  @override
  State<BookQuestionDetailScreen> createState() =>
      _BookQuestionDetailScreenState();
}

class _BookQuestionDetailScreenState extends State<BookQuestionDetailScreen>
    with TickerProviderStateMixin, BookQuestionDetailLogicMixin {
  final HomeService _homeService = HomeService();

  @override
  void initState() {
    super.initState();

    // 화면 로드 후 초기 데이터 로드
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeScreen();
    });
  }

  /// 화면 초기화
  Future<void> _initializeScreen() async {
    if (AppConfig.debugMode) {
      debugPrint('🚀 [발제문 상세] 화면 초기화 시작');
      debugPrint('   - meetingId: ${widget.meetingId}');
      debugPrint('   - meetingTitle: ${widget.meetingTitle ?? "제목 없음"}');
    }

    await initializeBookQuestions(meetingId: widget.meetingId);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeService>(
      builder: (context, homeService, child) {
        return LoadingWidgets.buildOverlayLoading(
          context,
          isLoading: homeService.isProcessing,
          loadingMessage: homeService.currentOperation,
          child: MainLayout(
            title: '발제문',
            isHomePage: false, // 서브 페이지이므로 뒤로가기 버튼 표시
            // HomeService를 통한 메뉴 및 로그아웃 처리
            onMenuTap: (menu) => _homeService.handleMenuTap(context, menu),
            onLogoutTap: () => _handleLogout(),
            // 새로고침 액션 추가
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () => _handleRefresh(),
                tooltip: '새로고침',
              ),
            ],
            // 플로팅 액션 버튼 (새로고침)
            floatingActionButton:
                BookQuestionDetailWidgets.buildFloatingActionButton(
                  context,
                  () => _handleRefresh(),
                ),
            body: _buildMainContent(),
          ),
        );
      },
    );
  }

  /// 메인 콘텐츠 빌드
  Widget _buildMainContent() {
    // 로딩 상태
    if (isLoading) {
      return BookQuestionDetailWidgets.buildLoading(context);
    }

    // 에러 상태
    if (errorMessage != null) {
      return BookQuestionDetailWidgets.buildError(
        context,
        message: errorMessage!,
        onRetry: () => _handleRefresh(),
      );
    }

    // 데이터가 없는 경우
    if (bookQuestionResponse == null) {
      return BookQuestionDetailWidgets.buildError(
        context,
        message: '발제문 데이터를 불러올 수 없습니다.',
        onRetry: () => _handleRefresh(),
      );
    }

    // 권한 체크 (필요시 - 현재는 모든 사용자가 볼 수 있음)
    // if (!canViewBookQuestions) {
    //   return BookQuestionDetailWidgets.buildNoPermission(context);
    // }

    // 정상 데이터가 있는 경우
    return Column(
      children: [
        // 헤더 정보 (모임 제목 + 통계)
        BookQuestionDetailWidgets.buildHeaderInfo(
          context,
          meetingTitle: widget.meetingTitle ?? '모임 발제문',
          totalGroups: groupCount,
          totalQuestions: bookQuestionResponse!.allBookQuestions.length,
          currentGroupSummary: getCurrentGroupSummary(),
        ),

        // 탭바 (그룹별)
        if (groupCount > 0)
          BookQuestionDetailWidgets.buildTabBar(
            context,
            tabController!,
            groupCount,
            getTabLabel,
          ),

        const SizedBox(height: 16),

        // 탭뷰 (발제문 그리드)
        Expanded(
          child: groupCount > 0
              ? BookQuestionDetailWidgets.buildTabBarView(
                  context,
                  tabController!,
                  bookQuestionResponse!,
                  canEdit: canEditDelete,
                  onEdit: (bookQuestion) => _handleEdit(bookQuestion),
                  onDelete: (bookQuestion) => _handleDelete(bookQuestion),
                )
              : BookQuestionDetailWidgets.buildEmptyAllGroups(context),
        ),
      ],
    );
  }

  /// 새로고침 처리
  Future<void> _handleRefresh() async {
    if (AppConfig.debugMode) {
      debugPrint('🔄 [발제문 상세] 새로고침 시작');
    }

    await refreshBookQuestions(meetingId: widget.meetingId);
  }

  /// 발제문 수정 처리
  void _handleEdit(bookQuestion) {
    if (!canEditDelete) {
      BookQuestionDetailWidgets.showPermissionSnackBar(context);
      return;
    }

    if (AppConfig.debugMode) {
      debugPrint('✏️ [발제문 수정] ID: ${bookQuestion.bookQuestionId}');
    }

    handleEditBookQuestion(bookQuestion, widget.meetingId);
  }

  /// 발제문 삭제 처리
  void _handleDelete(bookQuestion) {
    if (!canEditDelete) {
      BookQuestionDetailWidgets.showPermissionSnackBar(context);
      return;
    }

    if (AppConfig.debugMode) {
      debugPrint('🗑️ [발제문 삭제] ID: ${bookQuestion.bookQuestionId}');
    }

    handleDeleteBookQuestion(bookQuestion, widget.meetingId);
  }

  /// 로그아웃 처리 (HomeService 활용)
  Future<void> _handleLogout() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await _homeService.handleLogout(context, authProvider);
  }
}
