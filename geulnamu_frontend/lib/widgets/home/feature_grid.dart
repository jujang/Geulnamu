import 'package:flutter/material.dart';
import '../common/responsive_widget.dart';
import '../../core/responsive.dart';
import '../../core/theme.dart';  // 확장 메서드 사용
import 'feature_card.dart';

class FeatureGrid extends SimpleResponsiveWidget {
  final Function(String)? onFeatureTap;

  const FeatureGrid({
    super.key,
    this.onFeatureTap,
  });

  static const features = [
    {
      'icon': Icons.menu_book_rounded,
      'title': '모임 소개',
      'subtitle': '모임 정보 및 소개',
      // 🎯 색상 제거! FeatureCard에서 테마 색상 사용
    },
    {
      'icon': Icons.event_outlined,
      'title': '오늘의 모임',
      'subtitle': '예정된 모임 확인',
      // 🎯 색상 제거! FeatureCard에서 테마 색상 사용
    },
    {
      'icon': Icons.qr_code_scanner_outlined,
      'title': '출석 체크',
      'subtitle': 'QR 코드로 간편 출석',
      // 🎯 색상 제거! FeatureCard에서 테마 색상 사용
    },
    {
      'icon': Icons.edit_outlined,
      'title': '발제 작성',
      'subtitle': '독서 발제문 작성',
      // 🎯 색상 제거! FeatureCard에서 테마 색상 사용
    },
  ];

  @override
  Widget buildResponsive(BuildContext context) {
    final crossAxisCount = ResponsiveHelper.getGridCrossAxisCount(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '주요 기능',
          // 🎯 테마 폰트 + primary 색상 사용
          style: context.textStyles.headlineSmall?.copyWith(
            color: context.colors.primary,
          ),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 1.14,
          ),
          itemCount: features.length,
          itemBuilder: (context, index) {
            final feature = features[index];
            return FeatureCard(
              icon: feature['icon'] as IconData,
              title: feature['title'] as String,
              subtitle: feature['subtitle'] as String,
              // 🎯 customColor 없음! 테마의 primary 색상 자동 사용
              onTap: () => onFeatureTap?.call(feature['title'] as String),
            );
          },
        ),
      ],
    );
  }
}
