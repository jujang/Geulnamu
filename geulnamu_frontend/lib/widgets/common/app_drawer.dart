import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/home/home_service.dart';
import '../../core/theme.dart';

/// 글나무 앱의 메인 Drawer 메뉴
///
/// 디자인 컨셉:
/// - 민트색 책갈피 테마
/// - 다크모드 완벽 지원
/// - 로그인 상태별 메뉴 구분
/// - 부드러운 애니메이션
/// - 접근성 고려
class AppDrawer extends StatelessWidget {
  final Function(String)? onMenuTap;
  final VoidCallback? onLoginTap;
  final VoidCallback? onLogoutTap;

  const AppDrawer({
    super.key,
    this.onMenuTap,
    this.onLoginTap,
    this.onLogoutTap,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Consumer2<AuthProvider, HomeService>(
        builder: (context, authProvider, homeService, child) {
          return Column(
            children: [
              // 🎨 헤더: 민트색 그라데이션 + 책갈피 마스코트
              _buildDrawerHeader(context, authProvider),

              // 📱 메뉴 리스트
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    // 🏠 홈 섹션
                    _buildMenuSection(context, '홈', [
                      _DrawerMenuItem(
                        icon: Icons.home_outlined,
                        title: '홈 화면',
                        subtitle: '메인 대시보드',
                        onTap: () => _handleMenuTap(context, '홈 화면'),
                      ),
                      _DrawerMenuItem(
                        icon: Icons.info_outlined,
                        title: '글나무 소개',
                        subtitle: '글나무 및 모임 진행방식 소개',
                        onTap: () => _handleMenuTap(context, '글나무 소개'),
                      ),
                    ]),

                    // 👥 모임원 섹션 (임원진 이상만)
                    if (authProvider.isAuthenticated &&
                        authProvider.isStaffLevel)
                      _buildMenuSection(context, '모임원', [
                        _DrawerMenuItem(
                          icon: Icons.people_outlined,
                          title: '모임원 목록',
                          subtitle: '전체 모임원 보기',
                          onTap: homeService.isProcessing
                              ? null // 로딩 중 비활성화
                              : () => _handleMenuTap(context, '모임원 목록'),
                          isDisabled: homeService.isProcessing,
                        ),
                      ]),

                    // 📚 모임 섹션 (로그인 후에만)
                    if (authProvider.isAuthenticated) ...[
                      _buildMenuSection(context, '모임', [
                        // 🔒 준운영진 이상만 모임 만들기 가능
                        if (authProvider.isStaffLevel)
                          _DrawerMenuItem(
                            icon: Icons.add_circle_outline,
                            title: '모임 만들기',
                            subtitle: '새로운 모임 생성',
                            onTap: () => _handleMenuTap(context, '모임 만들기'),
                          ),
                        _DrawerMenuItem(
                          icon: Icons.group_outlined,
                          title: '모임 목록',
                          subtitle: '전체 모임 목록 보기',
                          onTap: homeService.isProcessing
                              ? null
                              : () => _handleMenuTap(context, '모임 목록'),
                          isDisabled: homeService.isProcessing,
                        ),
                        // 🔒 준운영진 이상만 접근 가능
                        if (authProvider.isStaffLevel)
                          _DrawerMenuItem(
                            icon: Icons.group_outlined,
                            title: '모임 목록 (운영진용)',
                            subtitle: '전체 모임 목록 보기 (관리용)',
                            onTap: () =>
                                _handleMenuTap(context, '모임 목록 (운영진용)'),
                          ),
                      ]),

                      // ✍️ 발제 섹션
                      _buildMenuSection(context, '발제', [
                        _DrawerMenuItem(
                          icon: Icons.library_books_outlined,
                          title: '발제문 목록',
                          subtitle: '모임별 발제문 보기',
                          onTap: () => _handleMenuTap(context, '발제문 목록'),
                        ),
                      ]),
                    ],

                    // ⚙️ 기타 섹션
                    _buildMenuSection(context, '기타', [
                      // 🔒 로그인 후에만 문의하기 표시
                      if (authProvider.isAuthenticated)
                        _DrawerMenuItem(
                          icon: Icons.feedback_outlined,
                          title: '문의하기',
                          subtitle: '모임원의 소리',
                          onTap: () => _handleMenuTap(context, '문의하기'),
                        ),
                      // 🔒 관리자만 문의함 관리 표시
                      if (authProvider.isAdminLevel)
                        _DrawerMenuItem(
                          icon: Icons.folder_outlined,
                          title: '문의함 관리',
                          subtitle: '모임원의 소리 보기 (관리자용)',
                          onTap: () => _handleMenuTap(context, '문의함 관리'),
                        ),
                      _DrawerMenuItem(
                        icon: Icons.info_outline,
                        title: '앱 정보',
                        subtitle: '버전 및 라이선스',
                        onTap: () => _handleMenuTap(context, '앱 정보'),
                      ),
                    ]),
                  ],
                ),
              ),

              // 🔐 하단: 로그인 버튼만 (로그아웃 제거)
              if (!authProvider.isAuthenticated)
                _buildBottomLoginButton(context),
            ],
          );
        },
      ),
    );
  }

  /// 🎨 Drawer 헤더 - 민트색 그라데이션 + 사용자 정보
  Widget _buildDrawerHeader(BuildContext context, AuthProvider authProvider) {
    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(gradient: context.primaryGradient),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 📚 책갈피 마스코트 + 앱 로고
              Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: context.colors.surface.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(
                        color: context.colors.onPrimary.withOpacity(0.3),
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      Icons.menu_book_rounded,
                      size: 28,
                      color: context.colors.onPrimary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '글나무',
                        style: context.textStyles.headlineMedium?.copyWith(
                          color: context.colors.onPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'BOOK COMMUNITY',
                        style: context.textStyles.bodySmall?.copyWith(
                          color: context.colors.onPrimary.withOpacity(0.8),
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const Spacer(),

              // 👤 사용자 정보 또는 로그인 안내
              if (authProvider.isAuthenticated) ...[
                Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: context.colors.surface.withOpacity(0.3),
                      child: Text(
                        authProvider.userNickname[0].toUpperCase(),
                        style: TextStyle(
                          color: context.colors.onPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            authProvider.userNickname,
                            style: context.textStyles.bodyLarge?.copyWith(
                              color: context.colors.onPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (authProvider.userEmail != null)
                            Text(
                              authProvider.userEmail!,
                              style: context.textStyles.bodySmall?.copyWith(
                                color: context.colors.onPrimary.withOpacity(
                                  0.8,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ] else ...[
                Row(
                  children: [
                    Icon(
                      Icons.person_outline,
                      size: 24,
                      color: context.colors.onPrimary.withOpacity(0.8),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '로그인하여 모든 기능을 이용하세요',
                      style: context.textStyles.bodyMedium?.copyWith(
                        color: context.colors.onPrimary.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// 📝 메뉴 섹션 빌더
  Widget _buildMenuSection(
    BuildContext context,
    String sectionTitle,
    List<_DrawerMenuItem> items,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
          child: Text(
            sectionTitle,
            style: context.textStyles.bodySmall?.copyWith(
              color: context.colors.primary,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.8,
            ),
          ),
        ),
        ...items.map((item) => _buildMenuItem(context, item)),
        const SizedBox(height: 8),
      ],
    );
  }

  /// 🎯 개별 메뉴 아이템 (로딩 상태 지원)
  Widget _buildMenuItem(BuildContext context, _DrawerMenuItem item) {
    final isDisabled = item.isDisabled ?? false;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      enabled: !isDisabled,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: isDisabled
              ? context.colors.onSurface.withOpacity(0.1)
              : context.colors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          item.icon,
          size: 22,
          color: isDisabled
              ? context.colors.onSurface.withOpacity(0.4)
              : context.colors.primary,
        ),
      ),
      title: Text(
        item.title,
        style: context.textStyles.bodyMedium?.copyWith(
          fontWeight: FontWeight.w600,
          color: isDisabled ? context.colors.onSurface.withOpacity(0.4) : null,
        ),
      ),
      subtitle: item.subtitle != null
          ? Text(
              item.subtitle!,
              style: context.textStyles.bodySmall?.copyWith(
                color: isDisabled
                    ? context.colors.onSurface.withOpacity(0.3)
                    : context.colors.onSurfaceVariant,
              ),
            )
          : null,
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: isDisabled
            ? context.colors.onSurface.withOpacity(0.3)
            : context.colors.onSurfaceVariant,
      ),
      onTap: item.onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  /// 🔐 하단 로그인 버튼 (로그아웃 제거된 버전)
  Widget _buildBottomLoginButton(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: context.colors.outline.withOpacity(0.5),
            width: 1,
          ),
        ),
      ),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: () {
            Navigator.pop(context); // Drawer 닫기
            onLoginTap?.call();
          },
          icon: const Icon(Icons.login),
          label: const Text('로그인'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
        ),
      ),
    );
  }

  /// 🎯 메뉴 탭 처리
  void _handleMenuTap(BuildContext context, String menu) {
    Navigator.pop(context); // Drawer 닫기
    onMenuTap?.call(menu);
  }
}

/// 🔧 Drawer 메뉴 아이템 데이터 클래스
class _DrawerMenuItem {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;
  final bool? isDisabled;

  const _DrawerMenuItem({
    required this.icon,
    required this.title,
    this.subtitle,
    this.onTap,
    this.isDisabled,
  });
}
