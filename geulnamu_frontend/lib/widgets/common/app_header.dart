import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme.dart';

class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  /// 화면 제목
  final String? title;
  
  /// 로그인 버튼 핸들러
  final VoidCallback? onLoginPressed;
  
  /// 사용자 프로필 위젯
  final Widget? profileWidget;
  
  /// 로그인 버튼 표시 여부
  final bool showLoginButton;
  
  /// 드로어 버튼 표시 여부 (🍔 햄버거 메뉴)
  final bool showDrawerButton;
  
  /// 뒤로가기 버튼 표시 여부
  final bool showBackButton;
  
  /// 로고 클릭 핸들러 (홈으로 이동)
  final VoidCallback? onLogoTap;
  
  /// 뒤로가기 버튼 커스텀 핸들러
  final VoidCallback? onBackPressed;
  
  /// 상단바 액션 버튼들
  final List<Widget>? actions;

  const AppHeader({
    super.key,
    this.title,
    this.onLoginPressed,
    this.profileWidget,
    this.showLoginButton = true,
    this.showDrawerButton = true,
    this.showBackButton = false,
    this.onLogoTap,
    this.onBackPressed,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      // 🎯 테마 시스템 사용 - 하드코딩 제거
      backgroundColor: context.colors.primary,
      foregroundColor: context.colors.onPrimary,
      elevation: 0,
      
      // 🧭 네비게이션 버튼 처리 (우선순위: 뒤로가기 > 드로어)
      leading: _buildLeadingWidget(context),
      automaticallyImplyLeading: false, // 수동 제어
      
      // 🏷️ 제목 또는 로고
      title: _buildTitleWidget(context),
      centerTitle: true, // 항상 가운데 정렬 (제목과 로고 모두)
      
      // ⚙️ 액션 버튼들 + 사용자 메뉴
      actions: _buildActions(context),
    );
  }

  /// 좌측 네비게이션 버튼 빌드
  Widget? _buildLeadingWidget(BuildContext context) {
    if (showBackButton) {
      // ← 뒤로가기 버튼 우선
      return IconButton(
        onPressed: onBackPressed ?? () => Navigator.of(context).pop(),
        icon: const Icon(Icons.arrow_back_ios),
        tooltip: '뒤로가기',
      );
    } else if (showDrawerButton) {
      // 🍔 햄버거 메뉴 (Drawer 버튼)
      return IconButton(
        onPressed: () => Scaffold.of(context).openDrawer(),
        icon: const Icon(Icons.menu),
        tooltip: '메뉴',
      );
    }
    return null; // 둘 다 표시 안함
  }

  /// 제목 또는 로고 빌드
  Widget _buildTitleWidget(BuildContext context) {
    if (title != null) {
      // 📝 일반 화면 제목
      return Text(
        title!,
        style: context.textStyles.headlineSmall?.copyWith(
          color: context.colors.onPrimary,
          fontWeight: FontWeight.bold,
        ),
      );
    } else {
      // 🏠 글나무 로고 (홈화면용)
      return GestureDetector(
        onTap: onLogoTap,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 📚 책 아이콘 (글나무 브랜딩)
            Icon(
              Icons.menu_book_rounded,
              color: context.colors.onPrimary,
              size: 28,
            ),
            const SizedBox(width: 8),
            Text(
              '글나무',
              style: context.textStyles.headlineMedium?.copyWith(
                color: context.colors.onPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }
  }

  /// 액션 버튼들 빌드
  List<Widget> _buildActions(BuildContext context) {
    final actionsList = <Widget>[];
    
    // ⚙️ 커스텀 액션 버튼들 추가
    if (actions != null) {
      actionsList.addAll(actions!);
    }
    
    // 🔐 로그인 버튼 (비로그인 시)
    if (showLoginButton && onLoginPressed != null) {
      actionsList.add(
        TextButton.icon(
          onPressed: onLoginPressed,
          icon: const Icon(Icons.login, size: 20),
          label: Text(
            '로그인',
            style: context.textStyles.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: context.colors.onPrimary, // 한 색상 명시적 지정
            ),
          ),
          style: TextButton.styleFrom(
            foregroundColor: context.colors.onPrimary,
          ),
        ),
      );
    }
    
    // 👤 사용자 프로필 메뉴 (로그인 시)
    if (profileWidget != null) {
      actionsList.add(profileWidget!);
    }
    
    // 우측 여백
    actionsList.add(const SizedBox(width: 8));
    
    return actionsList;
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
