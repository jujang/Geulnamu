import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/main_layout.dart';
import '../../widgets/common/loading_widgets.dart';
import '../../core/theme.dart';
import '../../core/config/app_config.dart'; // 🎯 AppConfig import 추가
import '../../models/member/member_list_model.dart';
import '../../services/home/home_service.dart'; // 🎯 HomeService import 추가
import 'mixins/member_logic_mixin.dart';
import 'widgets/member_widgets.dart';

/// 모임원 목록 화면
/// 
/// 임원진 이상 권한을 가진 사용자가 모임원 목록을 조회하고 관리할 수 있는 화면
/// - 카드 리스트 방식으로 모임원 정보 표시
/// - 플로팅 필터 버튼으로 필터링 및 정렬
/// - 페이지네이션으로 목록 탐색
/// - 비활성 계정은 음영 처리
class MemberListScreen extends StatefulWidget {
  const MemberListScreen({super.key});

  @override
  State<MemberListScreen> createState() => _MemberListScreenState();
}

class _MemberListScreenState extends State<MemberListScreen> 
    with MemberLogicMixin {

  final HomeService _homeService = HomeService(); // 🎯 HomeService 인스턴스 추가

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
    // 권한 확인
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (!authProvider.isStaffLevel) {
      // 권한 없음 - 이전 화면으로 돌아가기
      if (mounted) {
        // 🎯 GoRouter: pop으로 이전 화면으로 돌아가기
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('모임원 목록은 임원진 이상만 볼 수 있습니다.'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    // 초기 데이터 로드
    await initializeMemberList();
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
            title: '모임원 목록',
            showDrawerButton: true, // 🍔 햄버거 버튼 표시
            // isRootPage: false (기본값) - 시스템 뒤로가기 허용
            actions: [
              // 새로고침 버튼
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: isLoading ? null : () => refreshMemberList(),
                tooltip: '새로고침',
              ),
            ],
            // 🎯 HomeService를 통한 메뉴 및 로그아웃 처리
            onMenuTap: (menu) => _homeService.handleMenuTap(context, menu),
            onLogoutTap: () => _handleLogout(),
            body: RefreshIndicator(
              onRefresh: refreshMemberList,
              child: Stack(
              children: [
                // 메인 콘텐츠
                _buildMainContent(),
                
                // 플로팅 필터 버튼
                Positioned(
                  bottom: 16,
                  left: 16,
                  child: MemberWidgets.buildFilterFab(
                    context,
                    _showFilterBottomSheet,
                  ),
                ),
              ],
            ),
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
      return MemberWidgets.buildLoading(context);
    }

    // 에러 상태
    if (errorMessage != null) {
      return MemberWidgets.buildError(
        context,
        message: errorMessage!,
        onRetry: refreshMemberList,
      );
    }

    // 빈 목록
    if (memberList.isEmpty) {
      return MemberWidgets.buildEmptyList(context);
    }

    // 정상 목록
    return Column(
      children: [
        // 목록 정보 헤더
        MemberWidgets.buildListHeader(
          context,
          totalElements: totalElements,
          currentFilter: currentFilter,
          onFilterTap: _showFilterBottomSheet,
        ),
        
        // 구분선
        Divider(
          height: 1,
          color: context.colors.outline.withOpacity(0.2),
        ),
        
        // 모임원 목록
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.only(
              top: 8,
              bottom: 80, // FAB 공간 확보
            ),
            itemCount: memberList.length,
            itemBuilder: (context, index) {
              final member = memberList[index];
              return MemberWidgets.buildMemberCard(
                context,
                member,
                onTap: () => _handleMemberTap(member),
              );
            },
          ),
        ),
        
        // 페이지네이션
        if (totalPages > 1)
          MemberWidgets.buildPagination(
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
      builder: (context) => MemberWidgets.buildFilterBottomSheet(
        context,
        currentFilter: currentFilter,
        onFilterChanged: applyFilter,
        canShowDeletedFilter: canShowCurrentDeletedFilter,
      ),
    );
  }

  /// 로그아웃 처리 (HomeService 활용)
  Future<void> _handleLogout() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await _homeService.handleLogout(context, authProvider);
  }

  /// 모임원 카드 탭 처리
  void _handleMemberTap(MemberListItem member) {
    // 🎯 권한 체크: 관리자 이상만 접근 가능
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    // ADMIN, LEADER, VICE_LEADER 만 접근 가능
    final userRole = authProvider.userInfo?['role'] as String?;
    final isAdminLevel = userRole != null && ['ADMIN', 'LEADER', 'VICE_LEADER'].contains(userRole);
    
    if (!isAdminLevel) {
      // 권한 없음 - 아무 반응 없음 (사용자가 요청한 대로)
      if (AppConfig.debugMode) {
        print('🚫 [MemberListScreen] 모임원 카드 클릭 - 권한 없음 (역할: $userRole)');
      }
      return; // 아무 동작 안 함
    }
    
    // 권한 있음 - 관리자 모드로 모임원 상세 페이지로 이동
    if (AppConfig.debugMode) {
      print('✅ [MemberListScreen] 모임원 카드 클릭 - 관리자 모드 접근 (ID: ${member.memberId})');
    }
    
    final currentPageNum = currentPage;
    
    // 🎯 GoRouter: push로 프로필 화면 이동 (관리자 모드)
    context.push('/profile?memberId=${member.memberId}&mode=admin&returnPage=$currentPageNum');
  }
}
