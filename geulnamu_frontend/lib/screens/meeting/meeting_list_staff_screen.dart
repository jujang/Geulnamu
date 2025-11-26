import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/main_layout.dart';
import '../../widgets/common/loading_widgets.dart';
import '../../core/theme.dart';
import '../../models/meeting/meeting_model.dart';
import '../../services/home/home_service.dart';
import '../../services/home/home_route_service.dart'; // RouteObserver 추가
import '../../core/enums/permission_level.dart'; // 🆕 권한 시스템 import
import '../../core/constants/permission_constants.dart'; // 🆕 권한 상수 import
import 'mixins/meeting_logic_mixin.dart';
import 'widgets/meeting_widgets.dart';
import 'widgets/meeting_list_widgets.dart';
import 'widgets/meeting_speed_dial.dart'; // 🆕 SpeedDial 위젯 import

/// 🆕 모임 목록 조회 (운영진용) 화면
///
/// 운영진이 모임 목록을 관리하기 위한 화면
/// - 기본 모임 목록과 동일한 API 사용
/// - 출석 상태 대신 비공개 여부 표시
/// - 필터에 비공개 여부 옵션 추가
/// - 출석현황 확인 버튼 제거
class MeetingListStaffScreen extends StatefulWidget {
  /// 초기 필터 타입
  /// - 'today': 오늘의 모임
  /// - null 또는 기타: 기본 필터
  final String? initialFilterType;
  
  const MeetingListStaffScreen({
    super.key,
    this.initialFilterType,
  });

  @override
  State<MeetingListStaffScreen> createState() => _MeetingListStaffScreenState();
}

class _MeetingListStaffScreenState extends State<MeetingListStaffScreen>
    with MeetingLogicMixin, RouteAware {
  final HomeService _homeService = HomeService();

  // 🆕 운영진 모드 활성화
  @override
  bool get isStaffMode => true;

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
          print('⚠️ [MeetingListStaffScreen] RouteObserver 등록 실패: $e');
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
      print('⚠️ [MeetingListStaffScreen] RouteObserver 해제 실패: $e');
    }
    super.dispose();
  }
  
  @override
  void didPopNext() {
    // 다른 화면에서 돌아왔을 때 새로고침
    super.didPopNext();
    print('🔄 [운영진용 모임 목록] 다른 화면에서 돌아오면서 새로고침');
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
            title: '모임 목록 (운영진용)',
            showDrawerButton: true, // 🍔 햄버거 버튼 표시
            // isRootPage: false (기본값) - 시스템 뒤로가기 허용
            // HomeService를 통한 메뉴 및 로그아웃 처리
            onMenuTap: (menu) => _homeService.handleMenuTap(context, menu),
            onLogoutTap: () => _handleLogout(),
            // 🔥 새로고침 버튼 추가
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () {
                  print('🔄 [운영진용 모임 목록] 수동 새로고침 버튼 클릭');
                  refreshMeetingList();
                },
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
                    _showStaffFilterBottomSheet,
                  ),
                ),

                // 🆕 SpeedDial (우측 하단 - 전체 화면 오버레이 가능)
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
        // 🆕 운영진용 목록 정보 헤더
        Container(
          color: context.colors.primaryContainer.withOpacity(0.1), // 🆕 운영진용 배경색
          child: MeetingWidgets.buildStaffListHeader(
            context,
            totalElements: totalElements,
            currentFilter: currentFilter,
          ),
        ),

        // 구분선
        Divider(height: 1, color: context.colors.outline.withOpacity(0.2)),

        // 🆕 운영진용 모임 목록 (출석현황 확인 버튼 없음)
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
                return MeetingWidgets.buildStaffMeetingCard(
                  context,
                  meeting,
                  onTap: () => _handleMeetingTap(meeting),
                  // 🆕 운영진용 카드 사용 (비공개 여부 표시, 출석현황 버튼 없음)
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

  /// 🆕 운영진용 필터 바텀시트 표시
  void _showStaffFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => MeetingWidgets.buildStaffFilterBottomSheet(
        context,
        currentFilter: currentFilter,
        onFilterChanged: applyFilter,
      ),
    );
  }

  /// 모임 카드 탭 처리 (운영진용 상세보기 기능)
  void _handleMeetingTap(MeetingInfo meeting) {
    Navigator.pushNamed(context, '/meeting/${meeting.meetingId}/staff').then((result) {
      // 모임 수정/삭제 후 목록 새로고침
      if (result == true && mounted) {
        refreshMeetingList();
      }
    });
  }

  /// 🆕 모임 만들기 권한 체크
  bool _canCreateMeeting() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userRole = authProvider.userRole;

    // 권한 확인
    final permissionLevel =
        PermissionConstants.convertRoleToPermissionLevel(userRole);
    final requiredLevel =
        PermissionConstants.getRequiredPermissionLevel('모임 만들기');

    return permissionLevel.hasPermission(requiredLevel);
  }

  /// 🆕 모임 만들기 버튼 처리
  void _handleCreateMeeting() {
    Navigator.pushNamed(
      context,
      '/meeting-create',
    ).then((result) {
      // 모임 생성 후 목록 새로고침
      if (result == true && mounted) {
        refreshMeetingList();
      }
    });
  }

  /// 로그아웃 처리 (HomeService 활용)
  Future<void> _handleLogout() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await _homeService.handleLogout(context, authProvider);
  }
}
