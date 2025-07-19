import 'package:flutter/material.dart';

/// 🔄 공통 로딩 위젯 모음
/// 
/// 다양한 로딩 상황에 맞는 일관된 로딩 UI 제공
/// - 전체 화면 로딩
/// - 인라인 로딩
/// - 버튼 로딩
/// - 오버레이 로딩
/// - 커스텀 메시지 로딩
class LoadingWidgets {
  
  /// 🔄 전체 화면 로딩 (Scaffold body용)
  static Widget buildFullScreenLoading(
    BuildContext context, {
    String? message,
    bool showLogo = true,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 로고 표시 (옵션)
          if (showLogo) ...[
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                Icons.book,
                size: 40,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 24),
          ],
          
          // 로딩 인디케이터
          SizedBox(
            width: 40,
            height: 40,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          
          // 메시지 (옵션)
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  /// 🔄 인라인 로딩 (작은 공간용)
  static Widget buildInlineLoading(
    BuildContext context, {
    String? message,
    double size = 24,
    MainAxisAlignment alignment = MainAxisAlignment.center,
  }) {
    return Row(
      mainAxisAlignment: alignment,
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: size,
          height: size,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(
              Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
        if (message != null) ...[
          const SizedBox(width: 12),
          Text(
            message,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }

  /// 🔄 버튼 로딩 (ElevatedButton, TextButton 등)
  static Widget buildButtonLoading(
    BuildContext context, {
    String? text,
    Color? color,
    double size = 20,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: size,
          height: size,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(
              color ?? Theme.of(context).colorScheme.onPrimary,
            ),
          ),
        ),
        if (text != null) ...[
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              color: color ?? Theme.of(context).colorScheme.onPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ],
    );
  }

  /// 🔄 카드 로딩 (Card 내부용)
  static Widget buildCardLoading(
    BuildContext context, {
    String? message,
    double padding = 24,
  }) {
    return Padding(
      padding: EdgeInsets.all(padding),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 32,
            height: 32,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          if (message != null) ...[
            const SizedBox(height: 12),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  /// 🔄 리스트 로딩 (ListView, GridView 등)
  static Widget buildListLoading(
    BuildContext context, {
    String? message,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 36,
              height: 36,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              message ?? '목록을 불러오는 중...',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// 🔄 오버레이 로딩 (기존 화면 위에 표시)
  static Widget buildOverlayLoading(
    BuildContext context, {
    required Widget child,
    required bool isLoading,
    String? loadingMessage,
    Color? overlayColor,
  }) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Positioned.fill(
            child: Container(
              color: overlayColor ?? 
                     Theme.of(context).colorScheme.surface.withOpacity(0.8),
              child: buildFullScreenLoading(
                context,
                message: loadingMessage,
                showLogo: false,
              ),
            ),
          ),
      ],
    );
  }

  /// 🔄 스켈레톤 로딩 (placeholder 형태)
  static Widget buildSkeletonLoading(
    BuildContext context, {
    double height = 16,
    double? width,
    BorderRadius? borderRadius,
  }) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.6),
        borderRadius: borderRadius ?? BorderRadius.circular(8),
      ),
      child: _buildShimmerEffect(context),
    );
  }

  /// 🔄 스켈레톤 카드 (프로필, 목록 아이템 등)
  static Widget buildSkeletonCard(
    BuildContext context, {
    double height = 120,
    EdgeInsets? padding,
  }) {
    return Card(
      child: Padding(
        padding: padding ?? const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 제목 스켈레톤
            buildSkeletonLoading(context, height: 20, width: 150),
            const SizedBox(height: 8),
            // 부제목 스켈레톤
            buildSkeletonLoading(context, height: 16, width: 100),
            const SizedBox(height: 12),
            // 본문 스켈레톤
            buildSkeletonLoading(context, height: 14),
            const SizedBox(height: 4),
            buildSkeletonLoading(context, height: 14, width: 200),
          ],
        ),
      ),
    );
  }

  /// 🔄 애니메이션 효과용 shimmer
  static Widget _buildShimmerEffect(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 1000),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.transparent,
            Theme.of(context).colorScheme.primary.withOpacity(0.1),
            Colors.transparent,
          ],
          stops: const [0.0, 0.5, 1.0],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
    );
  }

  /// 🔄 새로고침 버튼이 있는 로딩 (에러 상황용)
  static Widget buildRefreshableLoading(
    BuildContext context, {
    required String message,
    required VoidCallback onRefresh,
    String refreshButtonText = '다시 시도',
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.refresh,
              size: 48,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: onRefresh,
              icon: const Icon(Icons.refresh),
              label: Text(refreshButtonText),
            ),
          ],
        ),
      ),
    );
  }
}

/// 🔄 로딩 오버레이 다이얼로그
class LoadingOverlay {
  static OverlayEntry? _overlayEntry;

  /// 로딩 오버레이 표시
  static void show(
    BuildContext context, {
    String? message,
    bool barrierDismissible = false,
  }) {
    if (_overlayEntry != null) return; // 이미 표시 중이면 무시

    _overlayEntry = OverlayEntry(
      builder: (context) => Material(
        color: Colors.black.withOpacity(0.5),
        child: InkWell(
          onTap: barrierDismissible ? hide : null,
          child: LoadingWidgets.buildFullScreenLoading(
            context,
            message: message,
            showLogo: true,
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  /// 로딩 오버레이 숨김
  static void hide() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }
}
