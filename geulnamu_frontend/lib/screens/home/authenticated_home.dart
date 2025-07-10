import 'package:flutter/material.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/app_header.dart';
import '../../widgets/common/responsive_container.dart';
import '../../core/theme.dart';  // 확장 메서드 사용을 위해

class AuthenticatedHome extends StatelessWidget {
  final AuthProvider authProvider;
  final Function(String, AuthProvider)? onMenuSelected;
  final Function(String)? onQuickAction;
  final VoidCallback? onCreateMeeting;

  const AuthenticatedHome({
    super.key,
    required this.authProvider,
    this.onMenuSelected,
    this.onQuickAction,
    this.onCreateMeeting,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 🎯 backgroundColor 없음! 자동으로 FAFAFA (라이트) / 121212 (다크)
      appBar: AppHeader(
        showLoginButton: false,
        profileWidget: _buildProfileMenu(context),
      ),
      body: ResponsiveContainer(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildWelcomeSection(context),
              const SizedBox(height: 24),
              _buildQuickActions(context),
              const SizedBox(height: 24),
              _buildRecentMeetingsSection(context),
              const SizedBox(height: 24),
              _buildDevelopmentNotice(context),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => onCreateMeeting?.call(),
        // 🎯 색상 설정 없음! 테마에서 자동으로 primary/onPrimary 사용
        label: const Text('모임 만들기'),
        icon: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildProfileMenu(BuildContext context) {
    return PopupMenuButton<String>(
      icon: CircleAvatar(
        // 🎯 backgroundColor 없음! 자동으로 테마의 primary 색상 사용
        child: Text(
          authProvider.userNickname[0],
          // 🎯 style 없음! 자동으로 테마의 onPrimary 색상 사용
        ),
      ),
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'profile',
          child: Row(
            children: [
              const Icon(Icons.person_outline, size: 20),  // 🎯 색상 자동!
              const SizedBox(width: 8),
              const Text('프로필'),  // 🎯 색상 자동!
            ],
          ),
        ),
        PopupMenuItem(
          value: 'settings',
          child: Row(
            children: [
              const Icon(Icons.settings_outlined, size: 20),  // 🎯 색상 자동!
              const SizedBox(width: 8),
              const Text('설정'),  // 🎯 색상 자동!
            ],
          ),
        ),
        const PopupMenuDivider(),
        PopupMenuItem(
          value: 'logout',
          child: Row(
            children: [
              const Icon(Icons.logout, size: 20),  // 🎯 색상 자동!
              const SizedBox(width: 8),
              const Text('로그아웃'),  // 🎯 색상 자동!
            ],
          ),
        ),
      ],
      onSelected: (value) => onMenuSelected?.call(value, authProvider),
    );
  }

  Widget _buildWelcomeSection(BuildContext context) {
    return Card(
      // 🎯 색상 설정 없음! 테마의 surface 색상 자동 사용
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          // 🎯 확장 메서드로 현재 테마에 맞는 그라데이션 자동 사용
          gradient: context.primaryGradient,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '안녕하세요, ${authProvider.userNickname}님! 👋',
              // 🎯 테마의 headlineMedium + onPrimary 색상 자동 사용
              style: context.textStyles.headlineMedium?.copyWith(
                color: context.colors.onPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '오늘도 즐거운 독서 토론을 시작해보세요',
              // 🎯 테마의 bodyMedium + onPrimary 색상 자동 사용
              style: context.textStyles.bodyMedium?.copyWith(
                color: context.colors.onPrimary.withOpacity(0.9),
              ),
            ),
            if (authProvider.userEmail != null) ...[
              const SizedBox(height: 4),
              Text(
                authProvider.userEmail!,
                // 🎯 테마의 bodySmall + onPrimary 색상 자동 사용
                style: context.textStyles.bodySmall?.copyWith(
                  color: context.colors.onPrimary.withOpacity(0.7),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    final actions = [
      {'icon': Icons.people, 'title': '내 모임', 'subtitle': '참여 중인 모임'},
      {'icon': Icons.calendar_today, 'title': '출석 체크', 'subtitle': '오늘의 출석'},
      {'icon': Icons.edit_note, 'title': '발제 작성', 'subtitle': '오늘의 발제'},
      {'icon': Icons.history, 'title': '이력', 'subtitle': '나의 활동'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '빠른 메뉴',
          // 🎯 테마의 headlineSmall 자동 사용
          style: context.textStyles.headlineSmall,
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1.5,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: actions.length,
          itemBuilder: (context, index) {
            final action = actions[index];
            return Card(
              // 🎯 색상 없음! 테마의 surface 색상 자동 사용
              child: InkWell(
                onTap: () => onQuickAction?.call(action['title'] as String),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        action['icon'] as IconData,
                        size: 28,
                        // 🎯 색상 없음! 테마의 primary 색상 자동 사용
                      ),
                      const Spacer(),
                      Text(
                        action['title'] as String,
                        // 🎯 테마의 bodyLarge + 굵게
                        style: context.textStyles.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        action['subtitle'] as String,
                        // 🎯 테마의 bodySmall 자동 사용
                        style: context.textStyles.bodySmall,
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

  Widget _buildRecentMeetingsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '최근 모임',
          // 🎯 테마의 headlineSmall 자동 사용
          style: context.textStyles.headlineSmall,
        ),
        const SizedBox(height: 12),
        Card(
          // 🎯 색상 없음! 테마의 surface 색상 자동 사용
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Icon(
                  Icons.library_books_outlined,
                  size: 48,
                  // 🎯 테마의 primary 색상 + 투명도
                  color: context.colors.primary.withOpacity(0.6),
                ),
                const SizedBox(height: 16),
                Text(
                  '참여 중인 모임이 없습니다',
                  // 🎯 테마의 bodyLarge + 굵게
                  style: context.textStyles.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '새로운 모임을 만들거나 기존 모임에 참여해보세요!',
                  textAlign: TextAlign.center,
                  // 🎯 테마의 bodyMedium 자동 사용
                  style: context.textStyles.bodyMedium,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDevelopmentNotice(BuildContext context) {
    return Card(
      // 🎯 색상 없음! 테마의 surface 색상 자동 사용
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          // 🎯 확장 메서드로 info 색상 사용
          color: context.infoColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: context.infoColor.withOpacity(0.3),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: context.infoColor,  // 🎯 확장 메서드로 간편하게!
                ),
                const SizedBox(width: 8),
                Text(
                  '개발 중인 기능들',
                  style: context.textStyles.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: context.infoColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '• 모임 관리 기능\n• 출석 체크 시스템\n• 발제문 작성 도구\n• 토론 그룹 관리',
              style: context.textStyles.bodySmall?.copyWith(
                color: context.infoColor,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
