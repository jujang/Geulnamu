import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/main_layout.dart';
import '../../services/home/home_service.dart';
import '../../services/home/home_route_service.dart';
import '../../core/config/app_config.dart';
import 'mixins/meeting_detail_logic_mixin.dart';
import 'widgets/meeting_detail_widgets.dart';
import 'meeting_qr_display_screen.dart'; // 🆕 QR 표시 화면
import 'meeting_qr_scanner_screen.dart'; // 🆕 QR 스캔 화면

/// 모임 상세 조회 화면
///
/// 특정 모임의 상세 정보를 표시하는 화면
/// - 모임 기본 정보 (제목, 유형, 개설자, 일시 등)
/// - 출석 정보 (상태, 비고) - 비고는 편집 가능
/// - 토론 정보 (시간, 알림 메시지, 참석 희망 여부)
/// - 운영진용 모임 수정 버튼 (권한별 표시)
class MeetingDetailScreen extends StatefulWidget {
  /// 모임 ID
  final int meetingId;

  const MeetingDetailScreen({super.key, required this.meetingId});

  @override
  State<MeetingDetailScreen> createState() => _MeetingDetailScreenState();
}

class _MeetingDetailScreenState extends State<MeetingDetailScreen>
    with MeetingDetailLogicMixin, RouteAware {
  final HomeService _homeService = HomeService();

  @override
  void initState() {
    super.initState();
    // 화면 로드 후 초기 데이터 로드
    WidgetsBinding.instance.addPostFrameCallback((_) {
      initializeMeetingDetail(widget.meetingId);
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
    if (AppConfig.debugMode) {
      print('🔄 [모임 상세] 다른 화면에서 돌아오면서 새로고침');
    }
    refreshMeetingDetail(widget.meetingId);
  }

  @override
  Widget build(BuildContext context) {
    // 디버그 로그 출력 (빌드 메서드 시작에서)
    if (AppConfig.debugMode && meetingDetail != null) {
      print('🔍 [모임 상세] 빌드: meetingId=${widget.meetingId}, isStaffOrAbove=$isStaffOrAbove');
    }

    return Consumer<HomeService>(
      builder: (context, homeService, child) {
        return MainLayout(
          title: meetingDetail?.meetingName ?? '모임 상세',
          isHomePage: false, // 서브 페이지이므로 뒤로가기 버튼 표시
          // HomeService를 통한 메뉴 및 로그아웃 처리
          onMenuTap: (menu) => _homeService.handleMenuTap(context, menu),
          onLogoutTap: () => _handleLogout(),
          // 새로고침 액션 추가
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () => refreshMeetingDetail(widget.meetingId),
              tooltip: '새로고침',
            ),
          ],
          body: Stack(
            children: [
              // 메인 콘텐츠
              _buildMainContent(),

              // 운영진용 편집 버튼
              if (meetingDetail != null && isStaffOrAbove)
                MeetingDetailWidgets.buildEditFab(
                  context,
                  onPressed: () {
                    if (AppConfig.debugMode) {
                      print('🔧 [모임 상세] 편집 버튼 클릭: meetingId=${widget.meetingId}');
                    }
                    navigateToMeetingEdit(widget.meetingId);
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  /// 메인 콘텐츠 빌드
  Widget _buildMainContent() {
    // 로딩 상태
    if (isLoading) {
      return MeetingDetailWidgets.buildLoading(context);
    }

    // 에러 상태
    if (errorMessage != null) {
      return MeetingDetailWidgets.buildError(
        context,
        message: errorMessage!,
        onRetry: () => refreshMeetingDetail(widget.meetingId),
      );
    }

    // 데이터 없음
    if (meetingDetail == null) {
      return MeetingDetailWidgets.buildError(
        context,
        message: '모임 정보를 찾을 수 없습니다.',
        onRetry: () => refreshMeetingDetail(widget.meetingId),
      );
    }

    // 정상 콘텐츠
    return MeetingDetailWidgets.buildMainContent(
      context,
      meetingDetail!,
      isEditing: isEditing,
      onEditToggle: toggleEditMode,
      onNoteSave: saveNote,
      onEditCancel: cancelEdit,
      onToggleDiscussion: toggleDiscussionParticipation, // 🆕 토론 상태 토글 콜백 연결
      canToggleDiscussion: canChangeDiscussionParticipation, // 🆕 토론 상태 변경 가능 여부
      discussionTimeRemaining: discussionChangeTimeRemaining, // 🆕 남은 시간 정보 연결
      onQrDisplayTap: () => _navigateToQrDisplay(), // 🆕 QR 표시 화면 이동
      onQrScanTap: () => _navigateToQrScanner(), // 🆕 QR 스캔 화면 이동
      isStaffOrAbove: isStaffOrAbove, // 🆕 권한 정보 전달
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

  /// QR 스캔 화면으로 이동 (일반 사용자용)
  void _navigateToQrScanner() async {
    if (AppConfig.debugMode) {
      print('📷 [QR 스캔] 화면 이동');
    }
    
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => const MeetingQrScannerScreen(),
      ),
    );
    
    // 출석 성공 시 새로고침
    if (result == true) {
      if (AppConfig.debugMode) {
        print('✅ [QR 스캔] 출석 성공, 데이터 새로고침');
      }
      refreshMeetingDetail(widget.meetingId);
    }
  }

  /// 로그아웃 처리 (HomeService 활용)
  Future<void> _handleLogout() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await _homeService.handleLogout(context, authProvider);
  }
}
