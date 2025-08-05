import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/main_layout.dart';
import '../../services/home/home_service.dart';
import '../../services/home/home_route_service.dart';
import '../../core/config/app_config.dart'; // AppConfig import 추가
import 'mixins/meeting_detail_staff_logic_mixin.dart';
import 'widgets/meeting_detail_staff_widgets.dart';
import 'meeting_qr_display_screen.dart'; // 🆕 QR 표시 화면
import 'meeting_detail_screen.dart'; // 🆕 일반 사용자 화면

/// 운영진용 모임 상세 조회 화면
///
/// 운영진이 모임을 상세 조회하고 관리할 수 있는 화면
/// - 모임 기본 정보 (인라인 편집)
/// - 토론 정보 (인라인 편집)
/// - 관리 기능 (삭제, 비공개/공개 처리)
/// - 권한별 기능 제어
class MeetingDetailStaffScreen extends StatefulWidget {
  /// 모임 ID
  final int meetingId;
  
  const MeetingDetailStaffScreen({
    super.key,
    required this.meetingId,
  });

  @override
  State<MeetingDetailStaffScreen> createState() => _MeetingDetailStaffScreenState();
}

class _MeetingDetailStaffScreenState extends State<MeetingDetailStaffScreen>
    with MeetingDetailStaffLogicMixin, RouteAware {
  final HomeService _homeService = HomeService();

  @override
  void initState() {
    super.initState();
    // 화면 로드 후 초기 데이터 로드
    WidgetsBinding.instance.addPostFrameCallback((_) {
      initializeMeetingDetailStaff(widget.meetingId);
    });
  }
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // RouteObserver 등록
    final route = ModalRoute.of(context);
    if (route is PageRoute) {
      HomeRouteService.routeObserver.subscribe(this, route);
    }
  }
  
  @override
  void dispose() {
    // RouteObserver 등록 해제
    HomeRouteService.routeObserver.unsubscribe(this);
    super.dispose();
  }
  
  @override
  void didPopNext() {
    // 다른 화면에서 돌아왔을 때 새로고침
    super.didPopNext();
    print('🔄 [운영진용 모임 상세] 다른 화면에서 돌아오면서 새로고침');
    refreshMeetingDetailStaff(widget.meetingId);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeService>(
      builder: (context, homeService, child) {
        // 모임 정보가 업데이트되면 타이틀도 자동 업데이트
        final currentTitle = meetingDetail?.meetingName ?? '모임 상세 (운영진용)';
        
        return MainLayout(
          title: currentTitle,
          isHomePage: false, // 서브 페이지이므로 뒤로가기 버튼 표시
          // HomeService를 통한 메뉴 및 로그아웃 처리
          onMenuTap: (menu) => _homeService.handleMenuTap(context, menu),
          onLogoutTap: () => _handleLogout(),
          // 새로고침 액션 추가
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                if (AppConfig.debugMode) {
                  print('🔄 [수동 새로고침] 사용자가 새로고침 버튼 클릭');
                }
                refreshMeetingDetailStaff(widget.meetingId);
              },
              tooltip: '새로고침',
            ),
          ],
          body: _buildMainContent(),
        );
      },
    );
  }

  /// 메인 콘텐츠 빌드
  Widget _buildMainContent() {
    // 로딩 상태
    if (isLoading) {
      return MeetingDetailStaffWidgets.buildLoading(context);
    }

    // 에러 상태
    if (errorMessage != null) {
      return MeetingDetailStaffWidgets.buildError(
        context,
        message: errorMessage!,
        onRetry: () => refreshMeetingDetailStaff(widget.meetingId),
      );
    }

    // 데이터 없음
    if (meetingDetail == null) {
      return MeetingDetailStaffWidgets.buildError(
        context,
        message: '모임 정보를 찾을 수 없습니다.',
        onRetry: () => refreshMeetingDetailStaff(widget.meetingId),
      );
    }

    // 정상 콘텐츠
    return MeetingDetailStaffWidgets.buildMainContent(
      context,
      meetingDetail!,
      isEditingBasicInfo: isEditingBasicInfo,
      isEditingDiscussion: isEditingDiscussion,
      isSaving: isSaving,
      canDeleteMeeting: canDeleteMeeting,
      canManagePrivacy: canManagePrivacy,
      onToggleBasicEdit: toggleBasicInfoEdit,
      onToggleDiscussionEdit: toggleDiscussionEdit,
      onSaveBasicInfo: () => saveBasicInfo(widget.meetingId),
      onSaveDiscussionInfo: () => saveDiscussionInfo(widget.meetingId),
      onDeleteMeeting: () => deleteMeeting(widget.meetingId),
      onTogglePrivacy: () => toggleMeetingPrivacy(widget.meetingId),
      // 🆕 출석 관리 콜백들
      onQrDisplayTap: () => _navigateToQrDisplay(),
      onViewAsUserTap: () => _navigateToUserView(),
      // 폼 컨트롤러들
      meetingNameController: meetingNameController,
      meetingPlaceController: meetingPlaceController,
      descriptionController: descriptionController,
      alarmMessageController: alarmMessageController,
      // 선택된 값들
      selectedMeetingType: selectedMeetingType,
      selectedMeetingDateTime: selectedMeetingDateTime,
      selectedLateThresholdTime: selectedLateThresholdTime,
      selectedDiscussionTime: selectedDiscussionTime,
      isDiscussionTimeCleared: isDiscussionTimeCleared, // 🆕 X 버튼 상태 전달
      // 변경 콜백들
      onMeetingTypeChanged: onMeetingTypeChanged,
      onMeetingDateTimeChanged: onMeetingDateTimeChanged,
      onLateThresholdTimeChanged: onLateThresholdTimeChanged,
      onDiscussionTimeChanged: onDiscussionTimeChanged,
      onClearDiscussionTime: clearDiscussionTime, // 🆕 X 버튼 콜백 전달
      // 🆕 토론 조 관련 콜백들
      onGetDiscussionGroupLoading: () => isDiscussionGroupLoading,
      onGetWantDiscussionList: () => wantDiscussionList,
      onGetDiscussionGroupList: () => discussionGroupList,
      onGetDiscussionGroupErrorMessage: () => discussionGroupErrorMessage,
      onRefreshDiscussionGroupData: () => refreshDiscussionGroupData(widget.meetingId),
    );
  }

  /// QR 표시 화면으로 이동 (운영진용)
  void _navigateToQrDisplay() {
    if (meetingDetail == null) return;
    
    if (AppConfig.debugMode) {
      print('📱 [QR 표시] 화면 이동: meetingId=${widget.meetingId}');
    }
    
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => MeetingQrDisplayScreen(
          meetingId: widget.meetingId,
          meetingTitle: meetingDetail!.meetingName,
        ),
      ),
    );
  }

  /// 일반 사용자 화면으로 이동
  void _navigateToUserView() {
    if (AppConfig.debugMode) {
      print('👥 [사용자 화면] 이동: meetingId=${widget.meetingId}');
    }
    
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => MeetingDetailScreen(
          meetingId: widget.meetingId,
        ),
      ),
    );
  }

  /// 로그아웃 처리 (HomeService 활용)
  Future<void> _handleLogout() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await _homeService.handleLogout(context, authProvider);
  }
}
