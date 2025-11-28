import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/config/app_config.dart';
import '../../core/services/auth_service.dart';
import '../../providers/auth_provider.dart';
import '../../services/home/home_service.dart';
import '../../services/notification/fcm_service.dart';
import '../../widgets/common/main_layout.dart';

/// 🔔 관리자 전용 푸시 알림 발송 화면
/// 
/// 기능:
/// - 푸시 알림 제목/내용 입력
/// - 수신자 회원 ID 입력 (쉼표로 구분)
/// - 알림 발송
class PushNotificationScreen extends StatefulWidget {
  const PushNotificationScreen({super.key});

  @override
  State<PushNotificationScreen> createState() => _PushNotificationScreenState();
}

class _PushNotificationScreenState extends State<PushNotificationScreen> {
  final FcmService _fcmService = FcmService();
  final AuthService _authService = AuthService();
  final HomeService _homeService = HomeService();
  
  // 폼 컨트롤러
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();
  final _memberIdsController = TextEditingController();
  
  // 상태
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    _memberIdsController.dispose();
    super.dispose();
  }

  /// 뒤로가기 처리
  void _handleBackPressed() {
    Navigator.of(context).pop();
  }

  /// 푸시 알림 발송
  Future<void> _handleSendNotification() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // 액세스 토큰 가져오기
      final accessToken = await _authService.getAccessToken();
      if (accessToken == null || accessToken.isEmpty) {
        _showErrorSnackBar('로그인이 필요합니다.');
        return;
      }

      // 회원 ID 파싱
      final memberIdsString = _memberIdsController.text.trim();
      final memberIds = memberIdsString
          .split(',')
          .map((s) => int.tryParse(s.trim()))
          .where((id) => id != null)
          .cast<int>()
          .toList();

      if (memberIds.isEmpty) {
        _showErrorSnackBar('유효한 회원 ID를 입력해주세요.');
        return;
      }

      if (AppConfig.debugMode) {
        debugPrint('📤 [푸시 발송] 시작...');
        debugPrint('   제목: ${_titleController.text}');
        debugPrint('   내용: ${_bodyController.text}');
        debugPrint('   수신자: $memberIds');
      }

      // 푸시 알림 발송
      final success = await _fcmService.sendNotification(
        title: _titleController.text.trim(),
        body: _bodyController.text.trim(),
        memberIds: memberIds,
        accessToken: accessToken,
      );

      if (success) {
        _showSuccessSnackBar('푸시 알림이 발송되었습니다!');
        // 입력 필드 초기화
        _titleController.clear();
        _bodyController.clear();
        _memberIdsController.clear();
      } else {
        _showErrorSnackBar('푸시 알림 발송에 실패했습니다.');
      }
    } catch (e) {
      debugPrint('❌ [푸시 발송] 오류: $e');
      _showErrorSnackBar('푸시 알림 발송 중 오류가 발생했습니다.');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<AuthProvider, HomeService>(
      builder: (context, authProvider, homeService, child) {
        final userRole = authProvider.userInfo?['role'] as String?;
        
        // 관리자 권한 체크
        final isAdmin = userRole == 'ADMIN' || userRole == 'LEADER' || userRole == 'VICE_LEADER';
        
        return MainLayout(
          title: '푸시 알림 발송',
          showDrawerButton: false, // ← 뒤로가기 버튼 표시
          showProfileMenu: true,
          onBackPressed: _handleBackPressed,
          onMenuTap: (menu) => _homeService.handleMenuTap(context, menu),
          onLogoutTap: authProvider.isAuthenticated
              ? () => homeService.handleLogout(context, authProvider)
              : null,
          body: isAdmin 
              ? _buildContent(context)
              : _buildAccessDenied(context),
        );
      },
    );
  }

  /// 메인 콘텐츠
  Widget _buildContent(BuildContext context) {
    return GestureDetector(
      // 🎯 빈 영역 탭 시 키보드 닫기
      onTap: () => FocusScope.of(context).unfocus(),
      child: Form(
        key: _formKey,
        // 🎯 ListView 사용 - 키보드가 올라올 때 자동으로 포커스된 필드로 스크롤
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // 안내 카드
            _buildInfoCard(context),
            const SizedBox(height: 24),
            
            // 제목 입력
            _buildSectionTitle(context, '알림 제목', Icons.title),
            const SizedBox(height: 8),
            _buildTitleField(context),
            const SizedBox(height: 20),
            
            // 내용 입력
            _buildSectionTitle(context, '알림 내용', Icons.message_outlined),
            const SizedBox(height: 8),
            _buildBodyField(context),
            const SizedBox(height: 20),
            
            // 수신자 입력
            _buildSectionTitle(context, '수신자 (회원 ID)', Icons.people_outlined),
            const SizedBox(height: 8),
            _buildMemberIdsField(context),
            const SizedBox(height: 32),
            
            // 발송 버튼
            _buildSendButton(context),
            
            // 하단 여백
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  /// 안내 카드
  Widget _buildInfoCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              Icons.info_outline,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                '관리자 전용 기능입니다.\n특정 회원들에게 푸시 알림을 발송할 수 있습니다.',
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 섹션 제목
  Widget _buildSectionTitle(BuildContext context, String title, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  /// 제목 입력 필드
  Widget _buildTitleField(BuildContext context) {
    return TextFormField(
      controller: _titleController,
      // 🎯 브라우저 자동완성 비활성화
      autofillHints: const [],
      autocorrect: false,
      enableSuggestions: false,
      decoration: InputDecoration(
        hintText: '알림 제목을 입력하세요',
        filled: true,
        fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return '제목을 입력해주세요';
        }
        return null;
      },
    );
  }

  /// 내용 입력 필드
  Widget _buildBodyField(BuildContext context) {
    return TextFormField(
      controller: _bodyController,
      maxLines: 4,
      decoration: InputDecoration(
        hintText: '알림 내용을 입력하세요',
        filled: true,
        fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.all(16),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return '내용을 입력해주세요';
        }
        return null;
      },
    );
  }

  /// 수신자 입력 필드
  Widget _buildMemberIdsField(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: _memberIdsController,
          // 🎯 브라우저 자동완성 비활성화
          autofillHints: const [],
          autocorrect: false,
          enableSuggestions: false,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: '회원 ID를 쉼표로 구분하여 입력 (예: 1, 2, 3)',
            filled: true,
            fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return '수신자를 입력해주세요';
            }
            // 숫자와 쉼표만 허용
            final ids = value.split(',').map((s) => int.tryParse(s.trim()));
            if (ids.every((id) => id == null)) {
              return '유효한 회원 ID를 입력해주세요';
            }
            return null;
          },
        ),
        const SizedBox(height: 8),
        Text(
          '💡 수신자의 회원 ID를 쉼표(,)로 구분하여 입력하세요.',
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  /// 발송 버튼
  Widget _buildSendButton(BuildContext context) {
    return SizedBox(
      height: 52,
      child: ElevatedButton.icon(
        onPressed: _isLoading ? null : _handleSendNotification,
        icon: _isLoading 
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              )
            : const Icon(Icons.send),
        label: Text(_isLoading ? '발송 중...' : '푸시 알림 발송'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Theme.of(context).colorScheme.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  /// 접근 거부 화면
  Widget _buildAccessDenied(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.lock_outline,
            size: 64,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            '접근 권한이 없습니다',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '이 페이지는 관리자만 접근할 수 있습니다.',
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  /// 성공 스낵바
  void _showSuccessSnackBar(String message) {
    if (!mounted) return;
    
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// 에러 스낵바
  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.error,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
