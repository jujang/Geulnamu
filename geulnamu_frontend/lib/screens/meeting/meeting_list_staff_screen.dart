import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/main_layout.dart';
import '../../widgets/common/loading_widgets.dart';
import '../../core/theme.dart';
import '../../models/meeting/meeting_model.dart';
import '../../services/home/home_service.dart';
import 'mixins/meeting_logic_mixin.dart';
import 'widgets/meeting_widgets.dart';
import 'widgets/meeting_list_widgets.dart';

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
    with MeetingLogicMixin {
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
    // 🔍 디버그: 운영진용 화면 빌드 확인
    print('👥 [운영진 화면] MeetingListStaffScreen build() 호출');
    
    return Consumer<HomeService>(
      builder: (context, homeService, child) {
        return LoadingWidgets.buildOverlayLoading(
          context,
          isLoading: homeService.isProcessing,
          loadingMessage: homeService.currentOperation,
          child: MainLayout(
            title: '👥 모임 목록 (운영진)',
            isHomePage: true, // 메인 기능이므로 사이드바 버튼 표시
            // HomeService를 통한 메뉴 및 로그아웃 처리
            onMenuTap: (menu) => _homeService.handleMenuTap(context, menu),
            onLogoutTap: () => _handleLogout(),
            body: Stack(
              children: [
                // 메인 콘텐츠
                _buildMainContent(),

                // 플로팅 필터 버튼
                Positioned(
                  bottom: 16,
                  right: 16,
                  child: MeetingListWidgets.buildFilterFab(
                    context,
                    _showStaffFilterBottomSheet,
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

  /// 로그아웃 처리 (HomeService 활용)
  Future<void> _handleLogout() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await _homeService.handleLogout(context, authProvider);
  }

  /// 모임 카드 탭 처리 (향후 상세보기 기능)
  void _handleMeetingTap(MeetingInfo meeting) {
    // TODO: 향후 모임 상세 페이지 구현 시 아래 코드 활성화
    // Navigator.pushNamed(context, '/meeting/${meeting.meetingId}');
  }
}
