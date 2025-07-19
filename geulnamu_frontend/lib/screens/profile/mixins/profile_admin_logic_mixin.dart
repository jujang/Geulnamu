import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../services/profile/profile_service.dart';
import '../../../services/member/member_service.dart'; // 🎯 MemberService 추가
import '../../../models/profile/profile_model.dart';
import '../../../core/utils/date_utils.dart' as app_date_utils;
import '../../../core/config/app_config.dart';
import '../widgets/profile_widgets.dart'; // 🎯 다이얼로그를 위해 추가

/// 프로필 화면 비즈니스 로직 Mixin (관리자 모드 + 디버그 강화)
///
/// 제공 기능:
/// - 관리자 모드: 모임원 관리 기능
/// - 본인 모드: 일반 프로필 기능
/// - 관리자 기능: 등급/이름/상태 수정
/// - 편집 모드 토글 (본인 모드만)
/// - 폼 데이터 관리 및 유효성 검증
/// - 에러 처리
/// - 🔍 상세 디버깅 로깅 (캐시 문제 진단용)
mixin ProfileAdminLogicMixin<T extends StatefulWidget> on State<T> {
  // 🎯 Service 클래스 사용
  final ProfileService _profileService = ProfileService();
  final MemberService _memberService = MemberService(); // 🎯 추가

  // 🎯 상태 관리
  ProfileModel? _profile;
  bool _isEditMode = false;
  bool _isLoading = false;
  bool _isSaving = false;
  
  // 🎯 관리자 모드 전용 상태
  bool _isProcessingAdmin = false; // 관리자 작업 진행 중

  // 🎯 수정 폼 데이터
  String _editingName = '';
  String _editingGender = '';
  DateTime? _editingBirthDate;

  // 🎯 TextEditingController 추가
  late TextEditingController _nameController;

  // 🎯 유효성 검증 에러
  Map<String, String?> _errors = {};

  // Getters
  ProfileModel? get profile => _profile;
  bool get isEditMode => _isEditMode;
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  bool get isProcessingAdmin => _isProcessingAdmin; // 🎯 추가
  String get editingName => _editingName;
  String get editingGender => _editingGender;
  DateTime? get editingBirthDate => _editingBirthDate;
  Map<String, String?> get errors => _errors;
  TextEditingController get nameController =>
      _nameController; // 🎯 Controller getter 추가

  // 🎯 위젯 속성 접근을 위한 추상 메서드들 (ProfileScreen에서 구현)
  bool get isAdminMode;
  bool get isSelfMode;
  int? get targetMemberId;
  int? get returnPage;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(); // 🎯 Controller 초기화
    
    // 🎯 MemberService 초기화
    _memberService.initialize();
    
    // 🛡️ 관리자 모드 권한 검증
    if (isAdminMode) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _checkAdminPermission();
      });
    } else {
      _loadProfile(); // 🎯 본인 모드는 바로 로드
    }
  }

  /// 🛡️ 관리자 모드 권한 검증
  Future<void> _checkAdminPermission() async {
    if (!mounted) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    // 권한 검증: 임원진 이상 (STAFF, ADMIN, VICE_LEADER, LEADER)
    if (!authProvider.isStaffLevel) {
      if (AppConfig.debugMode) {
        print('❌ [ProfileAdminLogicMixin] 관리자 모드 접근 권한 없음 - 홈으로 리다이렉트');
      }
      
      // 권한 없음 - 홈으로 리다이렉트
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/home',
        (route) => false,
      );
      
      // 에러 메시지 표시
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.security, color: Colors.white),
              SizedBox(width: 8),
              Text('모임원 관리 권한이 없습니다.'),
            ],
          ),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 4),
        ),
      );
      
      return;
    }
    
    // 권한 있음 - 정상 로드 진행
    if (AppConfig.debugMode) {
      print('✅ [ProfileAdminLogicMixin] 관리자 모드 접근 권한 확인 - 데이터 로드 시작');
    }
    
    if (targetMemberId != null) {
      await _loadMemberProfile(targetMemberId!);
    } else {
      // targetMemberId가 null이면 잘못된 접근
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/home',
          (route) => false,
        );
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('잘못된 접근입니다.'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  /// 화면에 다시 들어올 때 호출되는 메서드
  Future<void> refreshProfileData() async {

    if (isAdminMode && targetMemberId != null) {
      await _loadMemberProfile(targetMemberId!);
    } else {
      await _loadProfile();
    }
  }

  @override
  void dispose() {
    _nameController.dispose(); // 🎯 Controller 리소스 정리
    super.dispose();
  }

  /// 프로필 정보 로드
  Future<void> _loadProfile() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errors.clear();
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      if (!authProvider.isAuthenticated) {
        throw Exception('로그인이 필요합니다.');
      }

      final accessToken = await authProvider.accessToken; // accessToken은 async getter
      if (accessToken == null || accessToken.isEmpty) {
        throw Exception('인증 토큰이 없습니다.');
      }



      final profile = await _profileService.getMyProfile(accessToken);

      if (mounted) {
        setState(() {
          _profile = profile;
          _isLoading = false;
          _initializeEditingData(profile);
        });


      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });



        // 에러 다이얼로그 표시
        _showErrorDialog('프로필 정보를 불러올 수 없습니다', e.toString());
      }
    }
  }

  /// 편집 데이터 초기화
  void _initializeEditingData(ProfileModel profile) {
    _editingName = profile.name ?? ''; // null인 경우 빈 문자열
    _editingGender = profile.gender ?? 'MALE'; // null인 경우 기본값 'MALE'

    // 🎯 TextEditingController 업데이트
    _nameController.text = _editingName;

    // 생년월일 null 처리
    if (profile.birthDate != null) {
      _editingBirthDate = app_date_utils.DateUtils.parseBackendDate(
        profile.birthDate!,
      );
    } else {
      // null인 경우 기본값 (1997년 1월 1일)
      _editingBirthDate = DateTime(1997, 1, 1);
    }

    _errors.clear();
  }

  /// 편집 모드 토글
  void toggleEditMode() {
    if (!mounted) return;

    setState(() {
      _isEditMode = !_isEditMode;

      if (_isEditMode && _profile != null) {
        // 편집 모드 진입 - 현재 데이터로 초기화
        _initializeEditingData(_profile!);
      } else {
        // 편집 모드 종료 - 변경사항 취소
        _errors.clear();
      }
    });


  }

  /// 이름 변경 핸들러
  void onNameChanged(String name) {
    setState(() {
      _editingName = name;
      // 실시간 유효성 검증
      _validateName(name);
    });
  }

  /// 성별 변경 핸들러
  void onGenderChanged(String gender) {
    setState(() {
      _editingGender = gender;
      _errors.remove('gender'); // 에러 제거
    });
  }

  /// 생년월일 변경 핸들러
  void onBirthDateChanged(DateTime birthDate) {
    setState(() {
      _editingBirthDate = birthDate;
      _errors.remove('birthDate'); // 에러 제거
    });
  }

  /// 개별 필드 유효성 검증
  void _validateName(String name) {
    if (name.trim().isEmpty) {
      _errors['name'] = '이름을 입력해주세요.';
    } else if (name.length < 2 || name.length > 10) {
      _errors['name'] = '이름은 2자 이상 10자 이하로 입력해주세요.';
    } else if (RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(name)) {
      _errors['name'] = '이름에는 특수문자를 사용할 수 없습니다.';
    } else {
      _errors.remove('name');
    }
  }

  /// 전체 폼 유효성 검증
  bool _validateForm() {
    final birthDateString = _editingBirthDate != null
        ? app_date_utils.DateUtils.formatApiDate(_editingBirthDate!)
        : '';

    final validationErrors = ProfileService.validateProfileData(
      name: _editingName.trim(),
      gender: _editingGender,
      birthDate: birthDateString,
    );

    setState(() {
      _errors = Map.from(validationErrors);
    });

    return _errors.isEmpty;
  }

  /// 프로필 저장
  Future<void> saveProfile() async {
    if (!mounted) return;

    // 유효성 검증
    if (!_validateForm()) {
    return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      if (!authProvider.isAuthenticated) {
        throw Exception('로그인이 필요합니다.');
      }

      final accessToken = await authProvider.accessToken; // accessToken은 async getter
      if (accessToken == null || accessToken.isEmpty) {
        throw Exception('인증 토큰이 없습니다.');
      }

      // 수정된 프로필 데이터 생성
      final updatedProfile = _profile!.copyWithUpdates(
        name: _editingName.trim(),
        gender: _editingGender,
        birthDate: app_date_utils.DateUtils.formatApiDate(_editingBirthDate!),
      );



      // API 호출
      final success = await _profileService.updateMyProfile(
        accessToken,
        updatedProfile,
      );

      if (success && mounted) {


        // 성공 - 프로필 다시 로드하여 최신 데이터 반영
        await _loadProfile();

        // AuthProvider에 저장된 사용자 정보도 업데이트
        await authProvider.updateUserInfo();

        // 개인정보 상태 캐시 무효화 및 강제 새로고침
        await authProvider.refreshProfileStatus();

        setState(() {
          _isEditMode = false;
          _isSaving = false;
        });





        // 성공 메시지 표시
        _showSuccessSnackBar('프로필이 성공적으로 저장되었습니다.');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });



        // 에러 다이얼로그 표시
        _showErrorDialog('프로필 저장 실패', e.toString());
      }
    }
  }

  /// 편집 취소
  void cancelEdit() {
    if (!mounted) return;

    setState(() {
      _isEditMode = false;
      _errors.clear();

      // 원본 데이터로 복원
      if (_profile != null) {
        _initializeEditingData(_profile!);
      }
    });


  }

  /// 프로필 새로고침
  Future<void> refreshProfile() async {
    await _loadProfile();
  }

  /// 에러 다이얼로그 표시
  void _showErrorDialog(String title, String message) {
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.error_outline,
              color: Theme.of(context).colorScheme.error,
              size: 24,
            ),
            const SizedBox(width: 8),
            Text(title),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  /// 성공 스낵바 표시
  void _showSuccessSnackBar(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.primary,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// 로그아웃 처리 (프로필 삭제 등의 경우)
  void handleLogout() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    authProvider.logout();
    Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
  }

  // 🎯 관리자 모드 전용 메서드들

  /// 특정 모임원 프로필 로드 (관리자용)
  Future<void> _loadMemberProfile(int memberId) async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errors.clear();
    });

    try {


      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final accessToken = await authProvider.accessToken;

      if (accessToken == null || accessToken.isEmpty) {
        throw Exception('인증 토큰이 없습니다. 다시 로그인해주세요.');
      }

      final profile = await _profileService.getMemberProfile(accessToken, memberId);

      if (mounted) {
        setState(() {
          _profile = profile;
          _isLoading = false;
          // 관리자 모드에서는 편집 모드 비활성화
          _isEditMode = false;
        });

        _initializeEditingData(profile);


      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _profile = null;
          _isLoading = false;
        });


      }
    }
  }

  /// 모임원 이름 수정 (관리자용)
  Future<void> handleNameEdit(String currentName) async {
    if (!isAdminMode || targetMemberId == null) return;

    final newName = await ProfileWidgets.showNameEditDialog(context, currentName);
    if (newName == null || newName == currentName) return;

    await _updateMemberName(targetMemberId!, newName);
  }

  /// 모임원 권한 변경 (관리자용)
  Future<void> handleRoleEdit(String currentRole) async {
    if (!isAdminMode || targetMemberId == null) return;

    final newRole = await ProfileWidgets.showRoleEditDialog(context, currentRole);
    if (newRole == null || newRole == currentRole) return;

    await _updateMemberRole(targetMemberId!, newRole);
  }

  /// 모임원 상태 토글 (관리자용)
  Future<void> handleStatusToggle(bool newStatus) async {
    if (!isAdminMode || targetMemberId == null || _profile == null) return;

    final confirmed = await ProfileWidgets.showStatusToggleDialog(
      context,
      _profile!,
      newStatus,
    );

    if (confirmed != true) return;

    if (newStatus) {
      await _activateMember(targetMemberId!);
    } else {
      await _deactivateMember(targetMemberId!);
    }
  }

  /// 모임원 이름 변경 API 호출
  Future<void> _updateMemberName(int memberId, String newName) async {
    if (!mounted) return;

    setState(() {
      _isProcessingAdmin = true;
    });

    try {


      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final accessToken = await authProvider.accessToken;
      
      await _memberService.updateMemberName(memberId, newName, accessToken: accessToken);

      if (mounted) {
        // 성공 후 프로필 재로드
        await _loadMemberProfile(memberId);
        _showSuccessSnackBar('이름이 성공적으로 변경되었습니다.');


      }
    } catch (e) {
      _showErrorDialog('이름 변경 실패', e.toString());
    } finally {
      if (mounted) {
        setState(() {
          _isProcessingAdmin = false;
        });
      }
    }
  }

  /// 모임원 권한 변경 API 호출
  Future<void> _updateMemberRole(int memberId, String newRole) async {
    if (!mounted) return;

    setState(() {
      _isProcessingAdmin = true;
    });

    try {


      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final accessToken = await authProvider.accessToken;
      
      await _memberService.updateMemberRole(memberId, newRole, accessToken: accessToken);

      if (mounted) {
        // 성공 후 프로필 재로드
        await _loadMemberProfile(memberId);
        _showSuccessSnackBar('권한이 성공적으로 변경되었습니다.');


      }
    } catch (e) {
      _showErrorDialog('권한 변경 실패', e.toString());
    } finally {
      if (mounted) {
        setState(() {
          _isProcessingAdmin = false;
        });
      }
    }
  }

  /// 모임원 활성화 API 호출
  Future<void> _activateMember(int memberId) async {
    if (!mounted) return;

    setState(() {
      _isProcessingAdmin = true;
    });

    try {


      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final accessToken = await authProvider.accessToken;
      
      await _memberService.activateMember(memberId, accessToken: accessToken);

      if (mounted) {
        // 성공 후 프로필 재로드
        await _loadMemberProfile(memberId);
        _showSuccessSnackBar('계정이 성공적으로 활성화되었습니다.');


      }
    } catch (e) {
      _showErrorDialog('활성화 실패', e.toString());
    } finally {
      if (mounted) {
        setState(() {
          _isProcessingAdmin = false;
        });
      }
    }
  }

  /// 모임원 비활성화 API 호출
  Future<void> _deactivateMember(int memberId) async {
    if (!mounted) return;

    setState(() {
      _isProcessingAdmin = true;
    });

    try {


      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final accessToken = await authProvider.accessToken;
      
      await _memberService.deactivateMember(memberId, accessToken: accessToken);

      if (mounted) {
        // 성공 후 프로필 재로드
        await _loadMemberProfile(memberId);
        _showSuccessSnackBar('계정이 성공적으로 비활성화되었습니다.');


      }
    } catch (e) {
      _showErrorDialog('비활성화 실패', e.toString());
    } finally {
      if (mounted) {
        setState(() {
          _isProcessingAdmin = false;
        });
      }
    }
  }
}
