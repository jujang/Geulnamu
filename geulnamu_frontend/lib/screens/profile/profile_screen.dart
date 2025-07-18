import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/main_layout.dart';
import '../../widgets/common/responsive_container.dart';
import '../../services/home/home_route_service.dart'; // 🎯 RouteObserver import
import '../../services/home/home_service.dart';
import 'mixins/profile_admin_logic_mixin.dart';
import 'widgets/profile_widgets.dart';

/// 프로필 화면 - 단일 페이지 + 토글 모드
///
/// 구조:
/// - StatefulWidget + ProfileLogicMixin 조합
/// - ProfileService 활용 (API 연동)
/// - ProfileWidgets 사용 (Static Methods)
/// - MainLayout 적용으로 통일된 UI/UX
///
/// 제공 기능:
/// - 조회 모드: 프로필 정보 표시
/// - 수정 모드: 이름, 성별, 생년월일 수정
/// - 모드 토글: 편집 ↔ 조회 전환
/// - 실시간 유효성 검증
/// - 에러 처리 및 로딩 상태 관리
/// - 통일된 네비게이션 및 사용자 메뉴
class ProfileScreen extends StatefulWidget {
  /// 조회할 모임원 ID (null이면 본인)
  final int? memberId;
  
  /// 화면 모드 ('self': 본인, 'admin': 관리자)
  final String mode;
  
  /// 돌아갈 페이지 번호 (모임원 목록에서 온 경우)
  final int? returnPage;
  
  const ProfileScreen({
    super.key,
    this.memberId,
    this.mode = 'self',
    this.returnPage,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> 
    with ProfileAdminLogicMixin, RouteAware { // 🎯 RouteAware 추가
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 🎯 RouteObserver 등록
    final homeRouteService = HomeRouteService();
    homeRouteService.registerRouteObserver(context, this);
  }

  @override
  void dispose() {
    // 🎯 RouteObserver 구독 해제
    final homeRouteService = HomeRouteService();
    homeRouteService.unregisterRouteObserver(this);
    super.dispose();
  }

  // 🎯 RouteAware 콜백 메서드들
  @override
  void didPush() {
    // 화면이 처음 들어올 때 - initState에서 이미 로드하므로 생략
    print('📱 [ProfileScreen] didPush - 화면 처음 진입');
  }

  @override
  void didPushNext() {
    // 다른 화면으로 이동할 때
    print('🚚 [ProfileScreen] didPushNext - 다른 화면으로 이동');
  }

  @override
  void didPopNext() {
    // 🎯 다른 화면에서 돌아올 때 - 데이터 새로고침!
    print('🔄 [ProfileScreen] didPopNext - 다른 화면에서 돌아옴 (새로고침 시작)');
    refreshProfileData();
  }

  @override
  void didPop() {
    // 화면이 종료될 때
    print('🚜 [ProfileScreen] didPop - 화면 종료');
  }
  
  // 🎯 관리자 모드 관련 getter들
  
  /// 관리자 모드인지 확인
  bool get isAdminMode => widget.mode == 'admin';
  
  /// 본인 모드인지 확인
  bool get isSelfMode => widget.mode == 'self';
  
  /// 조회할 모임원 ID (본인 모드일 때 null)
  int? get targetMemberId => widget.memberId;
  
  /// 돌아갈 페이지 번호
  int? get returnPage => widget.returnPage;
  
  /// 화면 제목 결정
  String _getScreenTitle() {
    if (isAdminMode) {
      return '모임원 상세';
    } else {
      return isEditMode ? '프로필 편집' : '프로필';
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return MainLayoutHelpers.sub(
      title: _getScreenTitle(),
      body: _buildBody(),
      showProfileMenu: false, // 프로필 페이지에서는 사용자 메뉴 숨김
      // 🎯 편집 모드에 따른 액션 버튼들
      actions: _buildAppBarActions(),
      // 🎯 하단 액션 버튼 (편집 모드에서만)
      bottomNavigationBar: isEditMode && profile != null
          ? ProfileWidgets.buildActionButtons(
              context,
              onSave: saveProfile,
              onCancel: cancelEdit,
              isLoading: isSaving,
            )
          : null,
      // 🎯 메뉴 및 로그인/로그아웃 핸들러
      onMenuTap: _handleMenuTap,
      onLoginTap: _handleLoginTap,
      onLogoutTap: _handleLogoutTap,
      onLogoTap: _handleLogoTap,
    );
  }

  /// 상단바 액션 버튼들 빌드
  List<Widget> _buildAppBarActions() {
    final actions = <Widget>[];
    
    // 🔄 새로고침 버튼 (조회 모드 + 로딩 중 아닐 때)
    if (!isLoading && !isEditMode) {
      actions.add(
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: refreshProfileData,
          tooltip: '새로고침',
        ),
      );
    }
    
    // ✏️ 편집/저장/취소 버튼
    if (!isLoading && profile != null && isSelfMode) {
      if (isEditMode) {
        // 편집 모드: 취소 + 저장 버튼
        actions.addAll([
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: cancelEdit,
            tooltip: '취소',
          ),
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: isSaving ? null : saveProfile,
            tooltip: '저장',
          ),
        ]);
      } else {
        // 조회 모드: 편집 버튼
        actions.add(
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: toggleEditMode,
            tooltip: '편집',
          ),
        );
      }
    }
    
    return actions;
  }

  /// 메뉴 탭 핸들러
  void _handleMenuTap(String menu) {
    final homeService = HomeService();
    homeService.handleMenuTap(context, menu);
  }

  /// 로그인 탭 핸들러
  void _handleLoginTap() {
    Navigator.pushNamed(context, '/login');
  }

  /// 로그아웃 핸들러
  void _handleLogoutTap() {
    final homeService = HomeService();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    homeService.handleLogout(context, authProvider);
  }

  /// 로고 탭 핸들러 (모드에 따라 다른 이동)
  void _handleLogoTap() {
    if (isAdminMode && returnPage != null) {
      // 🎯 관리자 모드: 모임원 목록으로 돌아가기 (페이지 상태 복원)
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/member-list',
        (route) => false,
      );
    } else {
      // 🎯 본인 모드: 홈으로 이동
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/home',
        (route) => false,
      );
    }
  }

  /// 메인 바디 빌드
  Widget _buildBody() {
    // 🎯 로딩 상태
    if (isLoading) {
      return ProfileWidgets.buildLoadingWidget(context);
    }

    // 🎯 에러 상태 (프로필이 null)
    if (profile == null) {
      return ProfileWidgets.buildErrorWidget(
        context,
        '프로필 정보를 불러올 수 없습니다.',
        refreshProfileData,
      );
    }

    // 🎯 정상 상태 - 프로필 표시
    return ResponsiveContainer(
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: Column(
          children: [
            // 🎯 프로필 이미지
            ProfileWidgets.buildProfileImage(context),
            
            const SizedBox(height: 24),

            // 🎯 조회 모드 vs 수정 모드
            if (isEditMode)
              _buildEditMode()
            else
              _buildViewMode(),

            // 추가 여백
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  /// 조회 모드 위젯
  Widget _buildViewMode() {
    return Column(
      children: [
        // 🎯 사용자 이름 (큰 텍스트)
        Text(
          profile!.displayName,  // null 안전 getter 사용
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        
        const SizedBox(height: 8),
        
        // 🎯 권한 배지
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            profile!.roleDisplayName,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),

        const SizedBox(height: 24),

        // 🎯 모드별 위젯 분기
        if (isAdminMode) 
          _buildAdminModeWidgets()
        else
          _buildSelfModeWidgets(),
      ],
    );
  }

  /// 관리자 모드 위젯들
  Widget _buildAdminModeWidgets() {
    return Column(
      children: [
        // 🎯 기본 정보 섹션 (관리자용 - 이름 수정 가능)
        ProfileWidgets.buildAdminBasicInfoSection(
          context,
          profile!,
          onNameEdit: handleNameEdit,
          isProcessing: isProcessingAdmin,
        ),

        const SizedBox(height: 16),

        // 🎯 계정 관리 섹션 (권한 및 상태 수정)
        ProfileWidgets.buildAdminAccountInfoSection(
          context,
          profile!,
          onRoleEdit: handleRoleEdit,
          onNameEdit: handleNameEdit,
          onStatusToggle: handleStatusToggle,
          isProcessing: isProcessingAdmin,
        ),
      ],
    );
  }

  /// 본인 모드 위젯들
  Widget _buildSelfModeWidgets() {
    return Column(
      children: [
        // 🎯 기본 정보 섹션 (수정 가능)
        ProfileWidgets.buildBasicInfoSection(context, profile!),

        const SizedBox(height: 16),

        ProfileWidgets.buildAccountInfoSection(context, profile!),
      ],
    );
  }

  /// 수정 모드 위젯
  Widget _buildEditMode() {
    return Column(
      children: [
        // 🎯 수정 안내 텍스트
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.info_outline,
                color: Theme.of(context).colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '이름, 성별, 생년월일을 수정할 수 있습니다.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // 🎯 수정 폼
        ProfileWidgets.buildEditForm(
          context,
          name: editingName,
          gender: editingGender,
          birthDate: editingBirthDate,
          onNameChanged: onNameChanged,
          onGenderChanged: onGenderChanged,
          onBirthDateChanged: onBirthDateChanged,
          errors: errors,
          nameController: nameController, // 🎯 Controller 전달
        ),

        const SizedBox(height: 16),

        // 🎯 읽기 전용 계정 정보 (수정 모드에서도 표시)
        ProfileWidgets.buildAccountInfoSection(context, profile!),
      ],
    );
  }
}
