import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../common/responsive_widget.dart';
import '../../core/responsive.dart';
import '../../core/theme.dart';  // 확장 메서드 사용

class PWAInstallCard extends SimpleResponsiveWidget {
  final VoidCallback? onInstallPressed;

  const PWAInstallCard({
    super.key,
    this.onInstallPressed,
  });

  @override
  Widget buildResponsive(BuildContext context) {
    // PWA는 웹 환경에서만 표시
    if (!kIsWeb) return const SizedBox.shrink();

    final cardPadding = ResponsiveHelper.getPWACardPadding(context);
    final iconSize = ResponsiveHelper.getPWAIconSize(context);

    return Card(
      // 🎯 색상 설정 없음! 테마의 Card 스타일 자동 사용
      child: Padding(
        padding: EdgeInsets.all(cardPadding),
        child: Row(
          children: [
            Icon(
              Icons.install_mobile,
              color: context.colors.primary,  // 🎯 테마의 primary 색상 사용
              size: iconSize,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '앱으로 설치하기',
                    // 🎯 테마 폰트 + primary 색상 사용
                    style: context.textStyles.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: context.colors.primary,
                    ),
                  ),
                  Text(
                    '홈 화면에 추가하여 더 빠른 접근을 해보세요!',
                    // 🎯 테마 폰트 + surfaceVariant 색상 사용
                    style: context.textStyles.bodyMedium?.copyWith(
                      color: context.colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: onInstallPressed,
              child: Text(
                '설치 방법',
                // 🎯 색상 없음! 테마의 TextButton 색상 자동 사용
              ),
            ),
          ],
        ),
      ),
    );
  }
}
