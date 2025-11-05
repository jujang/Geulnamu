import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/main_layout.dart';
import '../../widgets/common/loading_widgets.dart';
import '../../core/theme.dart';
import '../../models/meeting/meeting_model.dart';
import '../../services/home/home_service.dart';
import '../../services/home/home_route_service.dart'; // RouteObserver
import 'mixins/meeting_logic_mixin.dart';
import 'widgets/meeting_widgets.dart';
import 'widgets/meeting_list_widgets.dart';
import 'widgets/meeting_speed_dial.dart'; // 🆕 SpeedDial 위젯
import 'meeting_qr_scanner_screen.dart'; // 🆕 QR 스캔 화면
import '../../core/enums/permission_level.dart';
import '../../core/constants/permission_constants.dart';

/// 모임 목록 화면
///
/// 모든 사용자가 모임 목록을 조회할 수 있는 화면
/// - 카드 리스트 방식으로 모임 정보 표시
/// - 플로팅 필터 버튼으로 필터링 및 정렬
/// - 페이지네이션으로 목록 탐색
/// - 출석현황 확인 버튼 (향후 페이지 연결 예정)
/// - 🎯 초기 필터 타입 지원 (today, all 등)
class MeetingListScreen extends StatefulWidget {
  /// 초기 필터 타입
  /// - 'today': 오늘의 모임
  /// - null 또는 기타: 기본 필터
  final String? initialFilterType;

  const MeetingListScreen({super.key, this.initialFilterType});

  @override
  State<MeetingListScreen> createState() => _MeetingListScreenState();
}

class _MeetingListScreenState extends State<MeetingListScreen>
    with MeetingLogicMixin, RouteAware {
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
          print('⚠️ [MeetingListScreen] RouteObserver 등록 실패: $e');
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
      print('⚠️ [MeetingListScreen] RouteObserver 해제 실패: $e');
    }
    super.dispose();
  }

  @override
  void didPopNext() {
    // 다른 화면에서 돌아왔을 때 새로고침
    super.didPopNext();
    refreshMeetingList();
  }

  /// 화면 초기화
  Future<void> _initializeScreen() async {
    // 🎯 초기 필터 설정 (라우트 매개변수 기반)
    if (widget.initialFilterType == 'today') {
      // 오늘의 모임 필터 활성화
      final todayFilter = currentFilter.copyWith(isTodayMeeting: true);
      await initializeMeetingList(initialFilter: todayFilter);
    } else {
      // 기본 필터로 초기 데이터 로드
      await initializeMeetingList();
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
            title: '모임 목록',
            isHomePage: true, // 메인 기능이므로 사이드바 버튼 표시
            // HomeService를 통한 메뉴 및 로그아웃 처리
            onMenuTap: (menu) => _homeService.handleMenuTap(context, menu),
            onLogoutTap: () => _handleLogout(),
            // 새로고침 액션 추가
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: refreshMeetingList,
                tooltip: '새로고침',
              ),
            ],
            body: Stack(
              children: [
                // 메인 콘텐츠
                _buildMainContent(),

                // 플로팅 필터 버튼 (좌측 하단)
                Positioned(
                  bottom: 16,
                  left: 16,
                  child: MeetingListWidgets.buildFilterFab(
                    context,
                    _showFilterBottomSheet,
                  ),
                ),

                // SpeedDial (우측 하단 - 전체 화면 오버레이 가능)
                Positioned.fill(
                  child: MeetingSpeedDial(
                    canCreateMeeting: _canCreateMeeting(),
                    onCreateMeeting: _handleCreateMeeting,
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
      return MeetingListWidgets.buildLoading(context);
    }

    // 에러 상태
    if (errorMessage != null) {
      return MeetingListWidgets.buildError(
        context,
        message: errorMessage!,
        onRetry: refreshMeetingList,
      );
    }

    // 빈 목록
    if (meetingList.isEmpty) {
      return MeetingListWidgets.buildEmptyList(context);
    }

    // 정상 목록
    return Column(
      children: [
        // 목록 정보 헤더
        MeetingListWidgets.buildListHeader(
          context,
          totalElements: totalElements,
          currentFilter: currentFilter,
        ),

        // 구분선
        Divider(
          height: 1,
          color: context.colors.outline.withValues(alpha: 0.2),
        ),

        // 모임 목록
        Expanded(
          child: RefreshIndicator(
            onRefresh: refreshMeetingList,
            child: ListView.builder(
              padding: const EdgeInsets.only(
                top: 8,
                bottom: 80, // FAB 공간 확보
              ),
              itemCount: meetingList.length,
              itemBuilder: (context, index) {
                final meeting = meetingList[index];
                return MeetingWidgets.buildMeetingCard(
                  context,
                  meeting,
                  onTap: () => _handleMeetingTap(meeting),
                  onAttendance: () =>
                      _handleAttendance(meeting.meetingId), // 🆕 QR 출석
                  onAttendanceCheck: () =>
                      _handleAttendanceCheck(meeting.meetingId),
                );
              },
            ),
          ),
        ),

        // 페이지네이션
        if (totalPages > 1)
          MeetingListWidgets.buildPagination(
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
      builder: (context) => MeetingWidgets.buildFilterBottomSheet(
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

  /// 모임 카드 탭 처리 - 상세 페이지로 이동
  void _handleMeetingTap(MeetingInfo meeting) {
    Navigator.pushNamed(context, '/meeting/${meeting.meetingId}');
  }

  /// 🆕 QR 출석 버튼 처리 - QR 스캔 화면으로 직접 이동
  void _handleAttendance(int meetingId) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const MeetingQrScannerScreen()),
    );
  }

  /// 출석현황 확인 버튼 처리 (MeetingLogicMixin에서 처리)
  void _handleAttendanceCheck(int meetingId) {
    handleAttendanceCheck(meetingId);
  }

  /// 🆕 모임 만들기 권한 체크
  bool _canCreateMeeting() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userRole = authProvider.userRole;

    // 권한 확인
    final permissionLevel = PermissionConstants.convertRoleToPermissionLevel(
      userRole,
    );
    final requiredLevel = PermissionConstants.getRequiredPermissionLevel(
      '모임 만들기',
    );

    return permissionLevel.hasPermission(requiredLevel);
  }

  /// 🆕 모임 만들기 버튼 처리
  void _handleCreateMeeting() {
    Navigator.pushNamed(context, '/meeting-create'); // 정확한 라우트로 수정
  }
}
