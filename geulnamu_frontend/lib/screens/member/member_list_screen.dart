import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/main_layout.dart';
import '../../core/theme.dart';
import '../../models/member/member_list_model.dart';
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
        Navigator.pop(context);
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
    return MainLayout(
      title: '모임원 목록',
      isHomePage: false, // 서브 화면이므로 뒤로가기 버튼 표시
      body: Stack(
        children: [
          // 메인 콘텐츠
          _buildMainContent(),
          
          // 플로팅 필터 버튼
          Positioned(
            bottom: 16,
            right: 16,
            child: MemberWidgets.buildFilterFab(
              context,
              _showFilterBottomSheet,
            ),
          ),
        ],
      ),
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
        ),
        
        // 구분선
        Divider(
          height: 1,
          color: context.colors.outline.withOpacity(0.2),
        ),
        
        // 모임원 목록
        Expanded(
          child: RefreshIndicator(
            onRefresh: refreshMemberList,
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

  /// 모임원 카드 탭 처리
  void _handleMemberTap(MemberListItem member) {
    // TODO: 향후 모임원 상세보기 기능 구현
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${member.displayName} 상세보기 (향후 구현 예정)'),
        duration: const Duration(seconds: 1),
      ),
    );
  }
}
