import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../widgets/common/main_layout.dart';
import '../../providers/auth_provider.dart';
import '../../services/home/home_service.dart';
import '../../core/theme.dart';
import 'mixins/app_info_logic_mixin.dart';

/// 앱 정보 화면
///
/// 표시 내용:
/// - 앱 아이콘 및 로고
/// - 버전 정보
/// - 개발자 정보
/// - 캐시 관리
class AppInfoScreen extends StatefulWidget {
  const AppInfoScreen({super.key});

  @override
  State<AppInfoScreen> createState() => _AppInfoScreenState();
}

class _AppInfoScreenState extends State<AppInfoScreen> with AppInfoLogicMixin {
  @override
  Widget build(BuildContext context) {
    return Consumer2<AuthProvider, HomeService>(
      builder: (context, authProvider, homeService, child) {
        return MainLayoutHelpers.sub(
          title: '앱 정보',
          body: _buildBody(context),
          onMenuTap: (menu) => homeService.handleMenuTap(context, menu),
          onLoginTap: () => homeService.navigateToLogin(context),
          onLogoutTap: () => homeService.handleLogout(context, authProvider),
        );
      },
    );
  }

  /// 메인 콘텐츠
  Widget _buildBody(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // 📚 앱 아이콘 및 로고 섹션
          _buildAppLogoSection(context),

          const SizedBox(height: 24),

          // 👤 개발자 정보 섹션
          _buildDeveloperInfoSection(context),

          const SizedBox(height: 24),

          // ⚙️ 앱 관리 섹션
          _buildAppManagementSection(context),
        ],
      ),
    );
  }

  /// 📚 앱 로고 및 버전 정보 섹션
  Widget _buildAppLogoSection(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            // 📚 앱 아이콘
            _buildAppIcon(context),

            const SizedBox(height: 16),

            // 글나무 타이틀
            Text(
              '글나무',
              style: context.textStyles.headlineLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 4),

            Text(
              'BOOK CLUB',
              style: context.textStyles.bodyMedium?.copyWith(
                color: context.colors.onSurfaceVariant,
                letterSpacing: 1.2,
              ),
            ),

            const SizedBox(height: 24),

            // 버전 정보
            _buildVersionInfo(context),
          ],
        ),
      ),
    );
  }

  /// 📚 앱 이미지 (Long Press 로 Health Check)
  Widget _buildAppIcon(BuildContext context) {
    return GestureDetector(
      onLongPressStart: (_) => handleLogoLongPressStart(),
      onLongPressEnd: (_) => handleLogoLongPressEnd(),
      child: Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: context.colors.primary.withOpacity(0.3),
            width: 2,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: Image.asset(
            'assets/logo/app_logo.png', // 여기에 이미지 경로 지정
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }

  /// 버전 정보 (🎯 pubspec.yaml에서 자동 로드)
  Widget _buildVersionInfo(BuildContext context) {
    // 로딩 중일 때
    if (isLoadingVersion) {
      return SizedBox(
        height: 24,
        width: 24,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: context.colors.primary,
        ),
      );
    }
    
    // 버전 정보 표시
    return Text(
      '버전 $version (빌드 $buildNumber)',
      style: context.textStyles.bodyLarge?.copyWith(
        fontWeight: FontWeight.w600,
      ),
    );
  }

  /// 👤 개발자 정보 섹션
  Widget _buildDeveloperInfoSection(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 섹션 제목
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: context.colors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.person_outline,
                    size: 24,
                    color: context.colors.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '개발자 정보',
                  style: context.textStyles.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),

            // 개발자 이름
            _buildInfoRow(
              context,
              icon: Icons.badge_outlined,
              label: '개발자',
              value: 'jujang',
            ),

            const SizedBox(height: 12),

            // 이메일
            _buildInfoRow(
              context,
              icon: Icons.email_outlined,
              label: '이메일',
              value: 'jeongookjang@naver.com',
            ),
          ],
        ),
      ),
    );
  }

  /// 정보 행 빌더
  Widget _buildInfoRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: context.colors.onSurfaceVariant),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: context.textStyles.bodySmall?.copyWith(
                  color: context.colors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: context.textStyles.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// ⚙️ 앱 관리 섹션
  Widget _buildAppManagementSection(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 섹션 제목
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: context.colors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.settings_outlined,
                    size: 24,
                    color: context.colors.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '앱 관리',
                  style: context.textStyles.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),

            // 캐시 삭제 버튼
            ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 4,
              ),
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: context.colors.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.delete_outline, color: context.colors.error),
              ),
              title: Text(
                '캐시 전체 삭제',
                style: context.textStyles.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: Text(
                '앱 설정 및 캐시 데이터 삭제 (로그인 유지)',
                style: context.textStyles.bodySmall?.copyWith(
                  color: context.colors.onSurfaceVariant,
                ),
              ),
              trailing: Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: context.colors.onSurfaceVariant,
              ),
              onTap: () => handleClearCache(context),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
