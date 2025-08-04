import 'package:flutter/material.dart';
import '../../../providers/auth_provider.dart';
import '../../../widgets/home/welcome_card.dart';
import '../../../core/theme.dart';

/// HomeScreen의 UI 위젯들을 제공하는 Static Methods 클래스
///
/// 포함하는 위젯들:
/// - 환영 카드 (로그인 상태별)
/// - 빠른 메뉴 그리드
/// - 프로필 메뉴
class HomeWidgets {
  // 🎯 동적 환영 카드 - 로그인 상태에 따라 메시지 변경
  static Widget buildDynamicWelcomeCard(
    BuildContext context,
    AuthProvider authProvider, {
    VoidCallback? onProfileInputTap, // 개인정보 입력 버튼 클릭 핸들러
  }) {
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

              // 개인정보 입력 버튼 (필요한 경우에만 표시)
              if (authProvider.profileCompleted == false) ...[
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: onProfileInputTap,
                  child: _buildProfileInputButton(context),
                ),
              ] else if (authProvider.profileCompleted == null) ...[
                const SizedBox(height: 16),
                _buildProfileStatusLoading(context),
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

  // 🎯 통일된 빠른 메뉴 그리드
  static Widget buildQuickMenuGrid(
    BuildContext context,
    AuthProvider authProvider,
    Function(String) onMenuTap,
  ) {
    // 🎯 카드 콘텐츠: '글나무 소개', '오늘의 모임', '출석 체크', '발제문 목록'
    final menuItems = [
      {
        'icon': Icons.menu_book_rounded,
        'title': '글나무 소개',
        'subtitle': '글나무 및 모임 진행방식 소개',
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
      {
        'icon': Icons.library_books_outlined,
        'title': '발제문 목록',
        'subtitle': '모임별 작성된 발제문 확인',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '빠른 메뉴',
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
                onTap: () => onMenuTap(item['title'] as String),
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
  static Widget buildRecentMeetingsSection(BuildContext context) {
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
  static Widget buildProfileMenu(
    BuildContext context,
    AuthProvider authProvider,
    Function(String) onMenuSelection,
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
      onSelected: onMenuSelection,
    );
  }

  // 🔍 개인정보 입력 버튼
  static Widget _buildProfileInputButton(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.colors.surface.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: context.colors.onPrimary.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: context.colors.surface.withOpacity(0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.person_add_outlined,
              size: 20,
              color: context.colors.onPrimary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '개인정보 입력하기',
                  style: context.textStyles.bodyMedium?.copyWith(
                    color: context.colors.onPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '사용자 이름 등 기본 정보를 입력해주세요',
                  style: context.textStyles.bodySmall?.copyWith(
                    color: context.colors.onPrimary.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: context.colors.onPrimary.withOpacity(0.7),
          ),
        ],
      ),
    );
  }

  // 🔄 개인정보 상태 로딩
  static Widget _buildProfileStatusLoading(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.colors.surface.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: context.colors.onPrimary.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                context.colors.onPrimary.withOpacity(0.7),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '개인정보 상태 확인 중...',
            style: context.textStyles.bodyMedium?.copyWith(
              color: context.colors.onPrimary.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }
}
