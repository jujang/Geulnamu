import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback? onLoginPressed;
  final Widget? profileWidget;
  final bool showLoginButton;

  const AppHeader({
    super.key,
    this.onLoginPressed,
    this.profileWidget,
    this.showLoginButton = true,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: const Color(0xFF7DD3C0), // 예전 버전의 민트색
      elevation: 0,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 책 아이콘 (글나무 브랜딩)
          Icon(
            Icons.menu_book_rounded,
            color: Colors.white, // 민트색 배경에 흰색 아이콘
            size: 28,
          ),
          const SizedBox(width: 8),
          Text(
            '글나무',
            style: GoogleFonts.notoSans(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white, // 민트색 배경에 흰샄 텍스트
            ),
          ),
        ],
      ),
      centerTitle: true,
      actions: [
        if (showLoginButton && onLoginPressed != null)
          TextButton.icon(
            onPressed: onLoginPressed,
            icon: const Icon(Icons.login, size: 20),
            label: Text(
              '로그인',
              style: GoogleFonts.notoSans(
                fontWeight: FontWeight.w600,
              ),
            ),
            style: TextButton.styleFrom(
              foregroundColor: Colors.white, // 민트색 배경에 흰색 로그인 버튼
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
