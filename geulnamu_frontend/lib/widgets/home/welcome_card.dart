import 'package:flutter/material.dart';
import '../common/responsive_widget.dart';
import '../../core/theme.dart';  // 확장 메서드 사용

class WelcomeCard extends SimpleResponsiveWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const WelcomeCard({
    super.key,
    this.title = '글나무에 오신 것을 환영합니다!',
    this.subtitle = '독서 토론 모임 관리를 쉽게 해보세요',
    this.icon = Icons.waving_hand,
  });

  @override
  Widget buildResponsive(BuildContext context) {
    return Card(
      // 🎯 색상 설정 없음! 테마의 Card 스타일 자동 사용
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                // 🎯 확장 메서드로 primary 색상 사용
                color: context.colors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: context.colors.primary,  // 🎯 primary 색상 자동 사용
                size: 32,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    // 🎯 테마의 headlineSmall + primary 색상
                    style: context.textStyles.headlineSmall?.copyWith(
                      color: context.colors.primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    // 🎯 테마의 bodyMedium + surfaceVariant 색상
                    style: context.textStyles.bodyMedium?.copyWith(
                      color: context.colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
