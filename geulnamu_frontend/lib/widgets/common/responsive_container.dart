import 'package:flutter/material.dart';
import '../../core/breakpoints.dart';

/// 최대 폭 제한과 중앙 정렬을 제공하는 반응형 컨테이너
class ResponsiveContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final bool enableMaxWidth;

  const ResponsiveContainer({
    super.key,
    required this.child,
    this.padding,
    this.enableMaxWidth = true,
  });

  @override
  Widget build(BuildContext context) {
    Widget content = child;

    // 패딩 적용
    if (padding != null) {
      content = Padding(
        padding: padding!,
        child: content,
      );
    }

    // 최대 폭 제한 (PC에서)
    if (enableMaxWidth) {
      content = Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: Breakpoints.maxWidth),
          child: content,
        ),
      );
    }

    return content;
  }
}
