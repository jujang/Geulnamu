import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/config/app_config.dart';
import '../../core/services/auth_service.dart';
import '../../providers/auth_provider.dart';
import '../../services/home/home_service.dart';
import '../../services/notification/fcm_service.dart';
import '../../models/fcm/fcm_send_result.dart';
import '../../widgets/common/main_layout.dart';
import 'widgets/member_select_dialog.dart';

/// 🔔 관리자 전용 푸시 알림 발송 화면
/// 
/// 기능:
/// - 푸시 알림 제목/내용 입력
/// - 수신자 회원 ID 입력 (수동/자동 선택)
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
  bool _isAutoSelect = false; // 🆕 자동 선택 모드
  Set<int> _selectedMemberIds = {}; // 🆕 선택된 멤버 ID

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

  /// 🆕 토글 전환 처리
  void _handleToggleChange(bool value) {
    setState(() {
      if (value) {
        // 수동 → 자동: 기존 입력 초기화
        _memberIdsController.clear();
        _selectedMemberIds.clear();
      } else {
        // 자동 → 수동: 선택된 ID들을 입력창에 유지
        if (_selectedMemberIds.isNotEmpty) {
          _memberIdsController.text = _selectedMemberIds.join(', ');
        }
      }
      _isAutoSelect = value;
    });
  }

  /// 🆕 모임원 선택 다이얼로그 열기
  Future<void> _openMemberSelectDialog() async {
    final accessToken = await _authService.getAccessToken();
    if (accessToken == null || accessToken.isEmpty) {
      _showErrorSnackBar('로그인이 필요합니다.');
      return;
    }

    final result = await MemberSelectDialog.show(
      context,
      accessToken: accessToken,
      initialSelectedIds: _selectedMemberIds,
    );

    if (result != null) {
      setState(() {
        _selectedMemberIds = result;
        _memberIdsController.text = result.join(', ');
      });
    }
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
      List<int> memberIds;
      if (_isAutoSelect) {
        // 자동 선택 모드: Set에서 직접 가져오기
        memberIds = _selectedMemberIds.toList();
      } else {
        // 수동 입력 모드: 텍스트 파싱
        final memberIdsString = _memberIdsController.text.trim();
        memberIds = memberIdsString
            .split(',')
            .map((s) => int.tryParse(s.trim()))
            .where((id) => id != null)
            .cast<int>()
            .toList();
      }

      if (memberIds.isEmpty) {
        _showErrorSnackBar('유효한 회원 ID를 입력해주세요.');
        return;
      }

      if (AppConfig.debugMode) {
        debugPrint('[푸시 발송] 제목: ${_titleController.text}, 수신자: $memberIds (${_isAutoSelect ? '자동' : '수동'})');
      }

      // 푸시 알림 발송
      final result = await _fcmService.sendNotification(
        title: _titleController.text.trim(),
        body: _bodyController.text.trim(),
        memberIds: memberIds,
        accessToken: accessToken,
      );

      if (result != null) {
        // 결과에 따른 메시지 표시
        if (result.isAllSuccess) {
          _showSuccessSnackBar(result.resultMessage);
        } else if (result.isAllFailed) {
          _showErrorSnackBar(result.resultMessage);
        } else if (result.isPartialSuccess) {
          _showWarningSnackBar(result.resultMessage);
        } else if (result.isEmpty) {
          _showWarningSnackBar(result.resultMessage);
        }
        
        // 성공이 1건이라도 있으면 입력 필드 초기화
        if (result.successCount > 0) {
          _titleController.clear();
          _bodyController.clear();
          _memberIdsController.clear();
          setState(() {
            _selectedMemberIds.clear();
          });
        }
      } else {
        _showErrorSnackBar('푸시 알림 발송에 실패했습니다.');
      }
    } catch (e) {
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
          showDrawerButton: false,
          showProfileMenu: true,
          // 🎯 PWA 키보드 처리를 직접 함 (viewInsets 사용)
          resizeToAvoidBottomInset: false,
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
    // 🎯 키보드 높이 가져오기 (viewInsets 직접 처리)
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    
    return GestureDetector(
      // 🎯 빈 영역 탭 시 키보드 닫기
      onTap: () => FocusScope.of(context).unfocus(),
      child: Form(
        key: _formKey,
        child: ListView(
          // 🎯 키보드 드래그 시 닫기
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          // 🎯 키보드 높이만큼 하단 패딩 추가
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            // 키보드 있을 때: 키보드 높이, 없을 때: 일반 여백
            bottom: bottomInset > 0 ? bottomInset : 32,
          ),
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
            
            // 🆕 수신자 입력 (토글 포함)
            _buildRecipientSection(context),
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

  /// 🆕 수신자 섹션 (토글 + 입력/선택)
  Widget _buildRecipientSection(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 헤더: 제목 + 토글
        Row(
          children: [
            Icon(
              Icons.people_outlined,
              size: 20,
              color: colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Text(
              '수신자 (회원 ID)',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
            const Spacer(),
            // 토글: 수동/자동
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '수동',
                  style: TextStyle(
                    fontSize: 13,
                    color: !_isAutoSelect 
                        ? colorScheme.primary 
                        : colorScheme.onSurfaceVariant,
                    fontWeight: !_isAutoSelect 
                        ? FontWeight.w600 
                        : FontWeight.normal,
                  ),
                ),
                Switch(
                  value: _isAutoSelect,
                  onChanged: _handleToggleChange,
                ),
                Text(
                  '자동',
                  style: TextStyle(
                    fontSize: 13,
                    color: _isAutoSelect 
                        ? colorScheme.primary 
                        : colorScheme.onSurfaceVariant,
                    fontWeight: _isAutoSelect 
                        ? FontWeight.w600 
                        : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),
        
        // 입력 필드 (수동/자동에 따라 다르게 표시)
        _isAutoSelect 
            ? _buildAutoSelectField(context)
            : _buildManualInputField(context),
      ],
    );
  }

  /// 🆕 수동 입력 필드
  Widget _buildManualInputField(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: _memberIdsController,
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

  /// 🆕 자동 선택 필드
  Widget _buildAutoSelectField(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 비활성화된 입력 필드 (선택된 ID 표시)
        TextFormField(
          controller: _memberIdsController,
          enabled: false, // 비활성화
          decoration: InputDecoration(
            hintText: '모임원을 선택해주세요',
            filled: true,
            fillColor: colorScheme.surfaceContainerHighest.withOpacity(0.5),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: colorScheme.outline.withOpacity(0.3),
              ),
            ),
          ),
          validator: (value) {
            if (_selectedMemberIds.isEmpty) {
              return '모임원을 선택해주세요';
            }
            return null;
          },
        ),
        const SizedBox(height: 12),
        
        // 모임원 선택 버튼
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _openMemberSelectDialog,
            icon: const Icon(Icons.person_add_outlined),
            label: Text(
              _selectedMemberIds.isEmpty 
                  ? '모임원 선택'
                  : '모임원 선택 (${_selectedMemberIds.length}명)',
            ),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '💡 버튼을 눌러 모임원 목록에서 수신자를 선택하세요.',
          style: TextStyle(
            fontSize: 12,
            color: colorScheme.onSurfaceVariant,
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

  /// 경고 스낵바 (부분 성공/발송 대상 없음)
  void _showWarningSnackBar(String message) {
    if (!mounted) return;
    
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.warning_amber, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.orange,
        duration: const Duration(seconds: 4),
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
