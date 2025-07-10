import 'package:flutter/material.dart';
import '../../widgets/common/app_header.dart';
import '../../widgets/common/responsive_container.dart';
import '../../widgets/home/welcome_card.dart';
import '../../widgets/home/feature_grid.dart';
import '../../widgets/home/pwa_install_card.dart';
import '../../core/theme.dart';  // 확장 메서드 사용

class UnauthenticatedHome extends StatelessWidget {
  final VoidCallback? onLoginPressed;
  final Function(String)? onFeatureTap;

  const UnauthenticatedHome({
    super.key,
    this.onLoginPressed,
    this.onFeatureTap,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 🎯 backgroundColor 제거! 테마에서 자동으로 처리
      appBar: AppHeader(onLoginPressed: onLoginPressed, showLoginButton: true),
      body: SafeArea(
        child: ResponsiveContainer(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 환영 카드
                const WelcomeCard(),
                const SizedBox(height: 24),

                // 주요 기능 그리드
                FeatureGrid(onFeatureTap: _handleFeatureTap),
                const SizedBox(height: 24),

                // PWA 설치 안내
                PWAInstallCard(
                  onInstallPressed: () => _showInstallInstructions(context),
                ),

                // 추가 여백
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleFeatureTap(String featureTitle) {
    onFeatureTap?.call(featureTitle);
  }

  void _showInstallInstructions(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        // 🎯 색상 설정 없음! 테마에서 자동으로 처리
        title: Text(
          '앱 설치 방법',
          // 🎯 확장 메서드로 테마 폰트 사용
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
                  // 🎯 확장 메서드로 primary 색상 사용
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
            child: Text(
              '확인',
              // 🎯 색상 없음! 테마의 TextButton 색상 자동 사용
            ),
          ),
        ],
      ),
    );
  }
}
