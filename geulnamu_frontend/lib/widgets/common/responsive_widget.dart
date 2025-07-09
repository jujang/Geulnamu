import 'package:flutter/material.dart';
import '../../core/responsive.dart';

abstract class ResponsiveWidget extends StatelessWidget {
  const ResponsiveWidget({super.key});

  // 각 화면 크기별 위젯 정의
  Widget buildDesktop(BuildContext context);
  Widget buildTablet(BuildContext context);
  Widget buildMobile(BuildContext context);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (ResponsiveHelper.isDesktop(context)) {
          return buildDesktop(context);
        } else if (ResponsiveHelper.isTablet(context)) {
          return buildTablet(context);
        } else {
          return buildMobile(context);
        }
      },
    );
  }
}

// 간단한 반응형 위젯 (하나의 위젯으로 모든 화면 처리)
abstract class SimpleResponsiveWidget extends StatelessWidget {
  const SimpleResponsiveWidget({super.key});

  Widget buildResponsive(BuildContext context);

  @override
  Widget build(BuildContext context) {
    return buildResponsive(context);
  }
}
