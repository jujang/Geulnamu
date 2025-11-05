import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../../core/theme.dart';

/// 모임 목록 SpeedDial 위젯
///
/// 모바일 환경에서 FAB 충돌 문제 해결을 위한 SpeedDial 구현
/// - 기본 상태: '...' 버튼만 표시
/// - 탭 시: '모임 만들기' 등 액션 버튼 펼침
class MeetingSpeedDial extends StatefulWidget {
  /// 모임 만들기 콜백
  final VoidCallback? onCreateMeeting;

  /// 권한 체크 (모임 만들기 버튼 표시 여부)
  final bool canCreateMeeting;

  const MeetingSpeedDial({
    super.key,
    this.onCreateMeeting,
    this.canCreateMeeting = false,
  });

  @override
  State<MeetingSpeedDial> createState() => _MeetingSpeedDialState();
}

class _MeetingSpeedDialState extends State<MeetingSpeedDial>
    with SingleTickerProviderStateMixin {
  /// 애니메이션 컨트롤러
  late AnimationController _animationController;

  /// 회전 애니메이션
  late Animation<double> _rotationAnimation;

  /// 확장/축소 애니메이션
  late Animation<double> _scaleAnimation;

  /// SpeedDial 열림/닫힘 상태
  bool _isOpen = false;

  @override
  void initState() {
    super.initState();

    // 애니메이션 컨트롤러 초기화
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );

    // 회전 애니메이션 (0 -> 45도)
    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: math.pi / 4, // 45도
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    // 스케일 애니메이션 (0 -> 1)
    _scaleAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  /// SpeedDial 토글
  void _toggleSpeedDial() {
    setState(() {
      _isOpen = !_isOpen;
      if (_isOpen) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  /// SpeedDial 닫기
  void _closeSpeedDial() {
    if (_isOpen) {
      setState(() {
        _isOpen = false;
        _animationController.reverse();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // 권한이 없으면 비어있는 컸테이너 반환
    if (!widget.canCreateMeeting) {
      return const SizedBox.shrink();
    }

    return Stack(
      children: [
        // 백그라운드 오버레이 (SpeedDial 열렸을 때)
        if (_isOpen)
          Positioned.fill(
            child: GestureDetector(
              onTap: _closeSpeedDial,
              child: Container(
                color: Colors.black.withValues(alpha: 0.3),
              ),
            ),
          ),

        // SpeedDial 버튼들
        Positioned(
          bottom: 0,
          right: 0,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // 모임 만들기 버튼
                _buildSpeedDialAction(
                  icon: Icons.add,
                  label: '모임 만들기',
                  onTap: () {
                    _closeSpeedDial();
                    widget.onCreateMeeting?.call();
                  },
                ),
                const SizedBox(height: 16),

                // 메인 FAB (... 버튼)
                _buildMainFab(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// SpeedDial 액션 버튼
  Widget _buildSpeedDialAction({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Material(
        color: context.colors.primary,
        elevation: 6,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  color: context.colors.onPrimary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: context.textStyles.labelLarge?.copyWith(
                    color: context.colors.onPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 메인 FAB (... 버튼)
  Widget _buildMainFab() {
    return FloatingActionButton(
      onPressed: _toggleSpeedDial,
      backgroundColor: context.colors.primary,
      foregroundColor: context.colors.onPrimary,
      elevation: _isOpen ? 8 : 6,
      heroTag: 'meeting_speed_dial', // Hero 태그 충돌 방지
      child: AnimatedBuilder(
        animation: _rotationAnimation,
        builder: (context, child) {
          return Transform.rotate(
            angle: _rotationAnimation.value,
            child: Icon(
              _isOpen ? Icons.close : Icons.more_horiz,
              size: 28,
            ),
          );
        },
      ),
    );
  }
}
