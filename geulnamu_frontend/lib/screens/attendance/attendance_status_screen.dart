import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/main_layout.dart';
import '../../widgets/common/loading_widgets.dart';
import '../../core/theme.dart';
import '../../services/home/home_service.dart';
import 'mixins/attendance_status_logic_mixin.dart';
import 'widgets/attendance_status_widgets.dart';

/// 출석 현황 화면
///
/// 특정 모임의 출석 현황을 조회하고 표시하는 화면
/// - 출석 요약 정보 (전체/출석/지각 인원수, 모임 시간, 지각 기준)
/// - 출석자 목록 (늦게 온 순, 지각 여부를 색상으로 구분)
/// - Pull-to-refresh 및 상단바 새로고침 버튼 지원
class AttendanceStatusScreen extends StatefulWidget {
  /// 모임 ID
  final int meetingId;

  /// 모임 제목 (선택사항, AppBar 제목 표시용)
  final String? meetingTitle;

  const AttendanceStatusScreen({
    super.key,
    required this.meetingId,
    this.meetingTitle,
  });

  @override
  State<AttendanceStatusScreen> createState() => _AttendanceStatusScreenState();
}

class _AttendanceStatusScreenState extends State<AttendanceStatusScreen>
    with AttendanceStatusLogicMixin {
  final HomeService _homeService = HomeService();

  @override
  void initState() {
    super.initState();

    // 화면 로드 후 초기 데이터 로드
    WidgetsBinding.instance.addPostFrameCallback((_) {
      initializeAttendanceStatus(widget.meetingId);
    });
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
            title: widget.meetingTitle != null
                ? '${widget.meetingTitle} - 출석 현황'
                : '출석 현황',
            isHomePage: false, // 서브 페이지이므로 뒤로가기 버튼 표시
            // HomeService를 통한 메뉴 및 로그아웃 처리
            onMenuTap: (menu) => _homeService.handleMenuTap(context, menu),
            onLogoutTap: () => _handleLogout(),
            // 새로고침 액션 추가
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: refreshAttendanceStatus,
                tooltip: '새로고침',
              ),
            ],
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
      return AttendanceStatusWidgets.buildLoading(context);
    }

    // 에러 상태
    if (errorMessage != null) {
      return AttendanceStatusWidgets.buildError(
        context,
        message: errorMessage!,
        onRetry: () => initializeAttendanceStatus(widget.meetingId),
      );
    }

    // 데이터 없음 또는 비정상 데이터
    if (attendanceDetails == null || summary == null) {
      return AttendanceStatusWidgets.buildError(
        context,
        message: '출석 현황 데이터를 불러올 수 없습니다.',
        onRetry: () => initializeAttendanceStatus(widget.meetingId),
      );
    }

    // 정상 데이터 표시
    return Column(
      children: [
        // 출석 요약 카드
        AttendanceStatusWidgets.buildSummaryCard(context, summary!),

        // 구분선
        Divider(height: 1, color: context.colors.outline.withOpacity(0.2)),

        // 출석자 목록 헤더
        AttendanceStatusWidgets.buildAttendanceListHeader(context),

        // 출석자 목록
        Expanded(
          child: AttendanceStatusWidgets.buildAttendanceList(
            context,
            attendanceList,
            refreshAttendanceStatus,
            onDeleteAttendance: deleteAttendance, // 삭제 콜백 연결
            showAdminActions: _isAdminLevel(), // 관리자 권한 체크
          ),
        ),
      ],
    );
  }

  /// 로그아웃 처리 (HomeService 활용)
  Future<void> _handleLogout() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await _homeService.handleLogout(context, authProvider);
  }

  /// 관리자 급 권한 체크
  bool _isAdminLevel() {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      return authProvider.isAdminLevel; // 관리자급 체크
    } catch (e) {
      return false; // 오류 시 기본적으로 권한 없음
    }
  }
}
