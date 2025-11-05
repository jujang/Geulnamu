import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/services/settings_service.dart';
import '../../providers/theme_provider.dart';
import '../../widgets/common/main_layout.dart';
import '../../widgets/common/settings_widgets.dart';

/// 설정 화면
/// 테마 설정, 알림 설정 등 앱 설정 관리
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final SettingsService _settingsService = SettingsService();
  
  // 상태 변수
  bool _meetingNotificationEnabled = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  /// 모든 설정 로드
  Future<void> _loadSettings() async {
    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
    });

    try {
      // 모임 알림 설정 로드
      _meetingNotificationEnabled = await _settingsService.getMeetingNotification();
      
      if (mounted) {
        setState(() {});
      }
      
      debugPrint('✅ [SettingsScreen] 설정 로드 완료');
      debugPrint('   모임 알림: $_meetingNotificationEnabled');
    } catch (e) {
      debugPrint('❌ [SettingsScreen] 설정 로드 실패: $e');
      if (mounted) {
        _showErrorSnackBar('설정을 불러오는데 실패했습니다.');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// 테마 모드 변경 처리
  Future<void> _handleThemeChange(ThemeMode newThemeMode) async {
    debugPrint('🎨 [SettingsScreen] 테마 변경 요청: $newThemeMode');
    
    try {
      final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
      await themeProvider.setThemeMode(newThemeMode);
      
      if (mounted) {
        _showSuccessSnackBar('테마가 변경되었습니다.');
      }
    } catch (e) {
      debugPrint('❌ [SettingsScreen] 테마 변경 실패: $e');
      if (mounted) {
        _showErrorSnackBar('테마 변경에 실패했습니다.');
      }
    }
  }

  /// 모임 알림 설정 변경 처리
  Future<void> _handleNotificationChange(bool enabled) async {
    debugPrint('🔔 [SettingsScreen] 알림 설정 변경 요청: $enabled');
    
    // 즉시 UI 업데이트 (낙관적 업데이트)
    if (mounted) {
      setState(() {
        _meetingNotificationEnabled = enabled;
      });
    }

    try {
      final success = await _settingsService.setMeetingNotification(enabled);
      
      if (success) {
        if (mounted) {
          _showSuccessSnackBar(enabled ? '모임 알림이 켜졌습니다.' : '모임 알림이 꺼졌습니다.');
        }
      } else {
        // 저장 실패 시 이전 상태로 복원
        if (mounted) {
          setState(() {
            _meetingNotificationEnabled = !enabled;
          });
          _showErrorSnackBar('알림 설정 저장에 실패했습니다.');
        }
      }
    } catch (e) {
      debugPrint('❌ [SettingsScreen] 알림 설정 변경 실패: $e');
      
      // 에러 발생 시 이전 상태로 복원
      if (mounted) {
        setState(() {
          _meetingNotificationEnabled = !enabled;
        });
        _showErrorSnackBar('알림 설정 변경에 실패했습니다.');
      }
    }
  }

  /// 뒤로가기 처리
  void _handleBackPressed() {
    debugPrint('🔙 [SettingsScreen] 설정 화면 나가기');
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MainLayout(
          title: '설정',
          isHomePage: false, // 뒤로가기 버튼 표시
          showProfileMenu: false, // 설정 페이지에서는 사용자 메뉴 숨김
          onBackPressed: _handleBackPressed,
          body: _isLoading 
              ? SettingsWidgets.buildLoadingIndicator(context)
              : _buildSettingsContent(context, themeProvider),
        );
      },
    );
  }

  /// 설정 콘텐츠 빌드
  Widget _buildSettingsContent(BuildContext context, ThemeProvider themeProvider) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,  // 🎯 start → stretch로 변경 (가로 전체 사용)
        children: [
          // 🎨 외관 설정 섹션
          SettingsWidgets.buildSectionHeader(
            context,
            title: '외관',
            icon: Icons.palette_outlined,
          ),
          SettingsWidgets.buildThemeSelector(
            context,
            currentTheme: themeProvider.themeMode,
            onThemeChanged: _handleThemeChange,
            getThemeDisplayName: themeProvider.getThemeModeDisplayName,
          ),
          
          // 🔔 알림 설정 섹션
          SettingsWidgets.buildSectionHeader(
            context,
            title: '알림',
            icon: Icons.notifications_outlined,
          ),
          SettingsWidgets.buildNotificationSwitch(
            context,
            enabled: _meetingNotificationEnabled,
            onChanged: _handleNotificationChange,
          ),
          
          // 설정 완료 안내
          const SizedBox(height: 24),
          SettingsWidgets.buildCompletionCard(context),
          
          // 하단 여백
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  /// 성공 스낵바 표시
  void _showSuccessSnackBar(String message) {
    if (!mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.check_circle,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.primary, // 🎨 글나무 민트색 사용
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// 에러 스낵바 표시
  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.error,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.error, // 🎨 테마 에러 색상 사용
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
