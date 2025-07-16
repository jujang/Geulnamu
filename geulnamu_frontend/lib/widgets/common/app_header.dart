import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme.dart';

class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback? onLoginPressed;
  final Widget? profileWidget;
  final bool showLoginButton;
  final bool showDrawerButton;
  final VoidCallback? onLogoTap; // 🏠 로고 클릭 핸들러 추가

  const AppHeader({
    super.key,
    this.onLoginPressed,
    this.profileWidget,
    this.showLoginButton = true,
    this.showDrawerButton = true,
    this.onLogoTap, // 🏠 로고 클릭 핸들러
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      // 🎯 테마 시스템 사용 - 하드코딩 제거
      backgroundColor: context.colors.primary,
      foregroundColor: context.colors.onPrimary,
      elevation: 0,
      
      // 🍔 Drawer 버튼 (showDrawerButton가 true일 때만)
      leading: showDrawerButton ? null : Container(),
      automaticallyImplyLeading: showDrawerButton,
      
      title: GestureDetector(
        onTap: onLogoTap, // 🏠 로고 클릭 시 홈 이동
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
      ),
      centerTitle: true,
      actions: [
        if (showLoginButton && onLoginPressed != null)
          TextButton.icon(
            onPressed: onLoginPressed,
            icon: const Icon(Icons.login, size: 20),
            label: Text(
              '로그인',
              style: context.textStyles.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            style: TextButton.styleFrom(
              foregroundColor: context.colors.onPrimary,
            ),
          ),
        if (profileWidget != null) profileWidget!,
        const SizedBox(width: 8),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
