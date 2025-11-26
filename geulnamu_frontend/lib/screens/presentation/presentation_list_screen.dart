import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/main_layout.dart';
import '../../widgets/common/loading_widgets.dart';
import '../../core/theme.dart';
import '../../core/config/app_config.dart'; // AppConfig import 추가
import '../../models/presentation/presentation_model.dart';
import '../../services/home/home_service.dart';
import '../../services/home/home_route_service.dart'; // RouteObserver
import '../book_question/book_question_detail_screen.dart'; // 발제문 상세 페이지 import
import 'mixins/presentation_logic_mixin.dart';
import 'widgets/presentation_widgets.dart';
import 'widgets/presentation_list_widgets.dart';

/// 발제문 목록 화면
///
/// 모든 사용자가 발제문 목록을 조회할 수 있는 화면
/// - 책 모양 카드로 발제문 정보 표시
/// - 플로팅 필터 버튼으로 필터링 및 정렬
/// - 페이지네이션으로 목록 탐색
/// - 📖 발제문 전용 UI/UX 제공
class PresentationListScreen extends StatefulWidget {
  /// 초기 필터 타입
  /// - 'today': 오늘의 발제문
  /// - null 또는 기타: 기본 필터
  final String? initialFilterType;

  const PresentationListScreen({super.key, this.initialFilterType});

  @override
  State<PresentationListScreen> createState() => _PresentationListScreenState();
}

class _PresentationListScreenState extends State<PresentationListScreen>
    with PresentationLogicMixin, RouteAware {
  final HomeService _homeService = HomeService();

  @override
  void initState() {
    super.initState();
    // 화면 로드 후 초기 데이터 로드
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeScreen();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 🎯 RouteObserver 등록 - 안전하게 처리
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final route = ModalRoute.of(context);
      if (route is PageRoute && mounted) {
        try {
          HomeRouteService.routeObserver.subscribe(this, route);
        } catch (e) {
          print('⚠️ [PresentationListScreen] RouteObserver 등록 실패: $e');
        }
      }
    });
  }

  @override
  void dispose() {
    // RouteObserver 등록 해제
    try {
      HomeRouteService.routeObserver.unsubscribe(this);
    } catch (e) {
      print('⚠️ [PresentationListScreen] RouteObserver 해제 실패: $e');
    }
    super.dispose();
  }

  @override
  void didPopNext() {
    // 다른 화면에서 돌아왔을 때 새로고침
    super.didPopNext();
    refreshPresentationList();
  }

  /// 화면 초기화
  Future<void> _initializeScreen() async {
    // 🎯 초기 필터 설정 (라우트 매개변수 기반)
    if (widget.initialFilterType == 'today') {
      // 오늘의 발제문 필터 활성화
      final todayFilter = currentFilter.copyWith(isTodayMeeting: true);
      await initializePresentationList(initialFilter: todayFilter);
    } else {
      // 기본 필터로 초기 데이터 로드
      await initializePresentationList();
    }
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
            title: '발제문 목록',
            showDrawerButton: true, // 🍔 햄버거 버튼 표시
            // isRootPage: false (기본값) - 시스템 뒤로가기 허용
            // HomeService를 통한 메뉴 및 로그아웃 처리
            onMenuTap: (menu) => _homeService.handleMenuTap(context, menu),
            onLogoutTap: () => _handleLogout(),
            // 새로고침 액션 추가
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: refreshPresentationList,
                tooltip: '새로고침',
              ),
            ],
            body: Stack(
              children: [
                // 메인 콘텐츠
                _buildMainContent(),

                // 플로팅 필터 버튼
                Positioned(
                  bottom: 16,
                  left: 16,
                  child: PresentationListWidgets.buildFilterFab(
                    context,
                    _showFilterBottomSheet,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// 메인 콘텐츠 빌드
  Widget _buildMainContent() {
    // 로딩 상태
    if (isLoading) {
      return PresentationListWidgets.buildLoading(context);
    }

    // 에러 상태
    if (errorMessage != null) {
      return PresentationListWidgets.buildError(
        context,
        message: errorMessage!,
        onRetry: refreshPresentationList,
      );
    }

    // 빈 목록
    if (presentationList.isEmpty) {
      return Column(
        children: [
          // 발제문 안내 메시지
          PresentationListWidgets.buildIntroduction(context),
          
          // 빈 목록 메시지
          Expanded(
            child: PresentationListWidgets.buildEmptyList(context),
          ),
        ],
      );
    }

    // 정상 목록
    return Column(
      children: [
        // 발제문 안내 메시지 (목록이 있을 때만 간단히)
        Container(
          margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: Row(
            children: [
              Icon(
                Icons.library_books,
                size: 20,
                color: context.colors.primary,
              ),
              const SizedBox(width: 8),
              Text(
                '📖 모임별 발제문을 책 형태로 확인하세요',
                style: context.textStyles.bodySmall?.copyWith(
                  color: context.colors.onSurface.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),

        // 목록 정보 헤더
        PresentationListWidgets.buildListHeader(
          context,
          totalElements: totalElements,
          currentFilter: currentFilter,
        ),

        // 구분선
        Divider(
          height: 1,
          color: context.colors.outline.withOpacity(0.2),
        ),

        // 발제문 목록 (실제 책장 모양 - 반응형 그리드)
        Expanded(
          child: RefreshIndicator(
            onRefresh: refreshPresentationList,
            child: LayoutBuilder(
              builder: (context, constraints) {
                // 📱 반응형 그리드 설정
                int crossAxisCount;
                if (constraints.maxWidth < 600) {
                  crossAxisCount = 2; // 모바일: 2개
                } else if (constraints.maxWidth < 900) {
                  crossAxisCount = 3; // 태블릿: 3개
                } else {
                  crossAxisCount = 4; // 데스크탑: 4개+
                }
                
                return Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF8B4513).withValues(alpha: 0.1), // 갈색 책장 배경
                  ),
                  child: GridView.builder(
                    padding: const EdgeInsets.only(
                      top: 16,
                      left: 12,
                      right: 12,
                      bottom: 80, // FAB 공간 확보
                    ),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      childAspectRatio: 160 / 200, // 책 비율 수정 (160x200)
                      crossAxisSpacing: 6, // 간격 줄임 (8 → 6)
                      mainAxisSpacing: 12, // 선반 간격 줄임 (16 → 12)
                    ),
                    itemCount: presentationList.length,
                    itemBuilder: (context, index) {
                      final presentation = presentationList[index];
                      final row = index ~/ crossAxisCount;
                      
                      return Stack(
                        children: [
                          // 📚 책장 선반 구분선 (각 행 상단)
                          if (row > 0)
                            Positioned(
                              top: -8,
                              left: 0,
                              right: 0,
                              child: Container(
                                height: 3,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF8B4513), // 갈색 선반
                                  borderRadius: BorderRadius.circular(1.5),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.2),
                                      blurRadius: 2,
                                      offset: const Offset(0, 1),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          
                          // 📖 책 (클릭 연결 활성화)
                          PresentationWidgets.buildBookCard(
                            context,
                            presentation,
                            onTap: () => _handlePresentationTap(presentation), // 클릭 연결
                          ),
                        ],
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ),

        // 페이지네이션
        if (totalPages > 1)
          PresentationListWidgets.buildPagination(
            context,
            currentPage: currentPage,
            totalPages: totalPages,
            onPageChanged: goToPage,
          ),
      ],
    );
  }

  /// 필터 바텀시트 표시
  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => PresentationWidgets.buildFilterBottomSheet(
        context,
        currentFilter: currentFilter,
        onFilterChanged: applyFilter,
      ),
    );
  }

  /// 로그아웃 처리 (HomeService 활용)
  Future<void> _handleLogout() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await _homeService.handleLogout(context, authProvider);
  }

  /// 발제문 카드 탭 처리 - 상세 페이지로 이동
  void _handlePresentationTap(PresentationInfo presentation) {
    if (AppConfig.debugMode) {
      print('📖 [발제문] 클릭: ${presentation.bookTitle} (meetingId: ${presentation.meetingId})');
    }
    
    // 발제문 상세 페이지로 이동
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BookQuestionDetailScreen(
          meetingId: presentation.meetingId,
          meetingTitle: presentation.bookTitle,
        ),
      ),
    );
  }
}
