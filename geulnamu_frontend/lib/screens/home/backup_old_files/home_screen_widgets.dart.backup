import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/home/welcome_card.dart';
import '../../core/theme.dart';

/// HomeScreen의 UI 위젯들을 담당하는 mixin
///
/// 포함하는 위젯들:
/// - 환영 카드 (로그인 상태별)
/// - 빠른 메뉴 그리드
/// - 최근 모임 섹션
/// - 프로필 메뉴
/// - 각종 다이얼로그들
mixin HomeScreenWidgets<T extends StatefulWidget> on State<T> {
  // 🎯 동적 환영 카드 - 로그인 상태에 따라 메시지 변경
  Widget buildDynamicWelcomeCard(
    BuildContext context,
    AuthProvider authProvider,
  ) {
    if (authProvider.isAuthenticated) {
      // 로그인 후: 개인화된 환영 메시지
      return Card(
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: context.primaryGradient,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '안녕하세요, ${authProvider.userNickname}님! 👋',
                style: context.textStyles.headlineMedium?.copyWith(
                  color: context.colors.onPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '오늘도 즐거운 독서 및 토론을 시작해보세요',
                style: context.textStyles.bodyMedium?.copyWith(
                  color: context.colors.onPrimary.withOpacity(0.9),
                ),
              ),
              if (authProvider.userEmail != null) ...[
                const SizedBox(height: 4),
                Text(
                  authProvider.userEmail!,
                  style: context.textStyles.bodySmall?.copyWith(
                    color: context.colors.onPrimary.withOpacity(0.7),
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    } else {
      // 로그인 전: 일반 환영 메시지
      return const WelcomeCard();
    }
  }

  // 🎯 통일된 빠른 메뉴 (요청사항에 맞는 카드 콘텐츠)
  Widget buildQuickMenuGrid(
    BuildContext context,
    AuthProvider authProvider,
    Function(String, AuthProvider) onMenuTap,
  ) {
    // 🎯 카드 콘텐츠: '모임 소개', '오늘의 모임', '출석 체크', '발제 작성'
    final menuItems = [
      {
        'icon': Icons.menu_book_rounded,
        'title': '모임 소개',
        'subtitle': '모임 정보 및 소개',
      },
      {
        'icon': Icons.event_outlined,
        'title': '오늘의 모임',
        'subtitle': '예정된 모임 확인',
      },
      {
        'icon': Icons.qr_code_scanner_outlined,
        'title': '출석 체크',
        'subtitle': 'QR 코드로 간편 출석',
      },
      {'icon': Icons.edit_outlined, 'title': '발제 작성', 'subtitle': '독서 발제문 작성'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '빠른 메뉴', // 🎯 섹션명을 '빠른 메뉴'로 통일
          style: context.textStyles.headlineSmall?.copyWith(
            color: context.colors.primary,
          ),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.3,
          ),
          itemCount: menuItems.length,
          itemBuilder: (context, index) {
            final item = menuItems[index];
            return Card(
              child: InkWell(
                onTap: () => onMenuTap(item['title'] as String, authProvider),
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: context.colors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          item['icon'] as IconData,
                          size: 24,
                          color: context.colors.primary,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        item['title'] as String,
                        style: context.textStyles.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item['subtitle'] as String,
                        style: context.textStyles.bodySmall?.copyWith(
                          color: context.colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  // 🎯 최근 모임 섹션 (로그인 후에만 표시)
  Widget buildRecentMeetingsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '최근 모임',
          style: context.textStyles.headlineSmall?.copyWith(
            color: context.colors.primary,
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Icon(
                  Icons.library_books_outlined,
                  size: 48,
                  color: context.colors.primary.withOpacity(0.6),
                ),
                const SizedBox(height: 16),
                Text(
                  '참여 중인 모임이 없습니다',
                  style: context.textStyles.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '새로운 모임을 만들거나 기존 모임에 참여해보세요!',
                  textAlign: TextAlign.center,
                  style: context.textStyles.bodyMedium?.copyWith(
                    color: context.colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // 🎯 프로필 메뉴 (로그인 후)
  Widget buildProfileMenu(
    BuildContext context,
    AuthProvider authProvider,
    Function(String, AuthProvider) onMenuSelection,
  ) {
    return PopupMenuButton<String>(
      icon: CircleAvatar(
        backgroundColor: context.colors.primary,
        child: Text(
          authProvider.userNickname[0],
          style: TextStyle(
            color: context.colors.onPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'profile',
          child: Row(
            children: [
              Icon(
                Icons.person_outline,
                size: 20,
                color: context.colors.primary,
              ),
              const SizedBox(width: 8),
              const Text('프로필'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'settings',
          child: Row(
            children: [
              Icon(
                Icons.settings_outlined,
                size: 20,
                color: context.colors.primary,
              ),
              const SizedBox(width: 8),
              const Text('설정'),
            ],
          ),
        ),
        const PopupMenuDivider(),
        PopupMenuItem(
          value: 'logout',
          child: Row(
            children: [
              Icon(Icons.logout, size: 20, color: context.colors.error),
              const SizedBox(width: 8),
              Text('로그아웃', style: TextStyle(color: context.colors.error)),
            ],
          ),
        ),
      ],
      onSelected: (value) => onMenuSelection(value, authProvider),
    );
  }

  // 🎯 기능 안내 다이얼로그
  void showFeatureDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          title,
          style: GoogleFonts.notoSans(fontWeight: FontWeight.w600),
        ),
        content: Text(content, style: GoogleFonts.notoSans()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              '확인',
              style: GoogleFonts.notoSans(color: context.colors.primary),
            ),
          ),
        ],
      ),
    );
  }

  // 🎯 PWA 설치 안내 다이얼로그
  void showInstallInstructions(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          '앱 설치 방법',
          style: context.textStyles.headlineSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // PC 브라우저
              Text(
                '💻 PC 브라우저',
                style: context.textStyles.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '• 크롬: 주소창 오른쪽 설치 버튼 클릭',
                style: context.textStyles.bodyMedium,
              ),
              Text(
                '• 엣지: 주소창 오른쪽 앱 설치 버튼',
                style: context.textStyles.bodyMedium,
              ),
              const SizedBox(height: 12),

              // 안드로이드 모바일
              Text(
                '📱 안드로이드',
                style: context.textStyles.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '• 크롬: 메뉴(⋮) → "홈 화면에 추가"',
                style: context.textStyles.bodyMedium,
              ),
              Text(
                '• 삼성 브라우저: 메뉴 → "홈 화면에 추가"',
                style: context.textStyles.bodyMedium,
              ),
              const SizedBox(height: 12),

              // 아이폰
              Text(
                '🍎 아이폰 (iOS)',
                style: context.textStyles.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '• 사파리: 공유버튼(↑) → "홈 화면에 추가"',
                style: context.textStyles.bodyMedium,
              ),
              Text(
                '• 크롬: 메뉴(⋮) → "홈 화면에 추가"',
                style: context.textStyles.bodyMedium,
              ),
              const SizedBox(height: 12),

              // 추가 안내
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: context.colors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: context.colors.primary.withOpacity(0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '💡 팁:',
                      style: context.textStyles.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: context.colors.primary,
                      ),
                    ),
                    Text(
                      '설치 후 홈 화면에서 일반 앱처럼 사용할 수 있어요!',
                      style: context.textStyles.bodyMedium?.copyWith(
                        color: context.colors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  // 🎯 로그아웃 확인 다이얼로그
  Future<bool?> showLogoutConfirmDialog() {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          '로그아웃',
          style: GoogleFonts.notoSans(fontWeight: FontWeight.w600),
        ),
        content: Text('정말 로그아웃하시겠습니까?', style: GoogleFonts.notoSans()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              '취소',
              style: GoogleFonts.notoSans(
                color: context.colors.onSurfaceVariant,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              '로그아웃',
              style: GoogleFonts.notoSans(color: context.colors.error),
            ),
          ),
        ],
      ),
    );
  }

  // 🎯 스낵바 표시
  void showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.notoSans(color: Colors.white),
        ),
        backgroundColor: context.colors.inverseSurface,
      ),
    );
  }
}
