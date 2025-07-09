import 'package:flutter/material.dart';
import '../../core/responsive.dart';
import '../../core/theme.dart';  // 확장 메서드 사용

class FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color? customColor;  // 🎯 선택적 커스텀 색상
  final VoidCallback? onTap;

  const FeatureCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.customColor,  // 🎯 기본값 없음 - 테마 색상 사용
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final iconSize = ResponsiveHelper.getIconSize(context);
    final titleFontSize = ResponsiveHelper.getTitleFontSize(context);
    final subtitleFontSize = ResponsiveHelper.getSubtitleFontSize(context);
    final cardPadding = ResponsiveHelper.getCardPadding(context);
    
    // 🎯 색상 결정: 커스텀 색상이 있으면 사용, 없으면 테마의 primary 색상
    final cardColor = customColor ?? context.colors.primary;

    return Card(
      // 🎯 색상 설정 없음! 테마의 Card 스타일 자동 사용
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            cardPadding,
            cardPadding,
            cardPadding,
            cardPadding / 2,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: cardColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: cardColor,
                  size: iconSize,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                title,
                // 🎯 테마 폰트 + primary 색상 사용
                style: context.textStyles.bodyMedium?.copyWith(
                  fontSize: titleFontSize,
                  fontWeight: FontWeight.bold,
                  color: context.colors.primary,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 1),
              Text(
                subtitle,
                // 🎯 테마 폰트 + surfaceVariant 색상 사용
                style: context.textStyles.bodySmall?.copyWith(
                  fontSize: subtitleFontSize,
                  color: context.colors.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
