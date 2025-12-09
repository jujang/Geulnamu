import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../core/config/app_config.dart';
import '../core/services/settings_service.dart';
import '../core/services/auth_service.dart';
import '../providers/theme_provider.dart';
import '../widgets/common/main_layout.dart';
import '../widgets/common/settings_widgets.dart';
import '../services/member/member_service.dart';

/// 설정 화면
/// 테마 설정, 알림 설정 등 앱 설정 관리
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final SettingsService _settingsService = SettingsService();
  final MemberService _memberService = MemberService();
  final AuthService _authService = AuthService();
  
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
      // 🔐 액세스 토큰 확인
      final accessToken = await _authService.getAccessToken();
      
      if (accessToken != null && accessToken.isNotEmpty) {
        // 로그인 상태: 백엔드에서 푸시 설정 조회
        try {
          _meetingNotificationEnabled = await _memberService.getPushSetting(
            accessToken: accessToken,
          );
          debugPrint('✅ [SettingsScreen] 백엔드에서 푸시 설정 로드 완료: $_meetingNotificationEnabled');
        } catch (e) {
          // 백엔드 조회 실패 시 로컬 값 사용 (폴백)
          debugPrint('⚠️ [SettingsScreen] 백엔드 조회 실패, 로컬 값 사용: $e');
          _meetingNotificationEnabled = await _settingsService.getMeetingNotification();
        }
      } else {
        // 비로그인 상태: 로컬 저장소에서 로드
        _meetingNotificationEnabled = await _settingsService.getMeetingNotification();
        debugPrint('ℹ️ [SettingsScreen] 비로그인 상태 - 로컬 설정 사용');
      }
      
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
      // 🔐 액세스 토큰 가져오기
      final accessToken = await _authService.getAccessToken();
      if (accessToken == null || accessToken.isEmpty) {
        throw Exception('로그인이 필요합니다.');
      }

      // 🔔 백엔드 API 호출
      await _memberService.updatePushSetting(enabled, accessToken: accessToken);
      
      // 로컬 저장도 함께 업데이트
      await _settingsService.setMeetingNotification(enabled);
      
      if (mounted) {
        _showSuccessSnackBar(enabled ? '모임 알림이 켜졌습니다.' : '모임 알림이 꺼졌습니다.');
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
    // 🎯 GoRouter: pop으로 이전 화면으로 돌아가기
    context.pop();
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
    
    // 🎯 이전 스낵바 즉시 제거 후 새 스낵바 표시
    ScaffoldMessenger.of(context).clearSnackBars();
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
    
    // 🎯 이전 스낵바 즉시 제거 후 새 스낵바 표시
    ScaffoldMessenger.of(context).clearSnackBars();
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
