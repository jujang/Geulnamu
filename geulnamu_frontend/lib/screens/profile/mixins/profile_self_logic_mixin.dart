import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../services/profile/profile_service.dart';
import '../../../models/profile/profile_model.dart';
import '../../../core/utils/date_utils.dart' as app_date_utils;
import '../../../core/config/app_config.dart';

/// 프로필 화면 비즈니스 로직 Mixin (본인 프로필용)
///
/// 제공 기능:
/// - 본인 프로필 데이터 로드/저장
/// - 편집 모드 토글
/// - 폼 데이터 관리 및 유효성 검증
/// - 에러 처리
mixin ProfileSelfLogicMixin<T extends StatefulWidget> on State<T> {
  // 🎯 Service 클래스 사용
  final ProfileService _profileService = ProfileService();

  // 🎯 상태 관리
  ProfileModel? _profile;
  bool _isEditMode = false;
  bool _isLoading = false;
  bool _isSaving = false;

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
  String get editingName => _editingName;
  String get editingGender => _editingGender;
  DateTime? get editingBirthDate => _editingBirthDate;
  Map<String, String?> get errors => _errors;
  TextEditingController get nameController =>
      _nameController; // 🎯 Controller getter 추가

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(); // 🎯 Controller 초기화
    _loadProfile(); // 🎯 초기 데이터 로드
  }

  /// 🎯 화면에 다시 들어올 때 호출되는 메서드
  ///
  /// ProfileScreen에서 RouteAware로 호출하거나,
  /// 수동으로 호출할 수 있음
  Future<void> refreshProfileData() async {
    print('🔄 [ProfileSelfLogicMixin] refreshProfileData() 호출 - 데이터 새로고침 시작');

    if (AppConfig.debugMode) {
      print('🔄 [ProfileSelfLogicMixin] 화면 재진입 - 프로필 데이터 새로고침');
    }

    await _loadProfile();

    print('✅ [ProfileSelfLogicMixin] refreshProfileData() 완료');
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

      final accessToken = await authProvider.accessToken; // 수정: async getter 사용
      if (accessToken == null) {
        throw Exception('인증 토큰이 없습니다.');
      }

      if (AppConfig.debugMode) {
        print('🔍 [ProfileSelfLogicMixin] 프로필 로드 시작...');
      }

      final profile = await _profileService.getMyProfile(accessToken);

      if (mounted) {
        setState(() {
          _profile = profile;
          _isLoading = false;
          _initializeEditingData(profile);
        });

        if (AppConfig.debugMode) {
          print('✅ [ProfileSelfLogicMixin] 프로필 로드 성공: ${profile.name}');
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        if (AppConfig.debugMode) {
          print('❌ [ProfileSelfLogicMixin] 프로필 로드 실패: $e');
        }

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

    if (AppConfig.debugMode) {
      print('🎯 [ProfileSelfLogicMixin] 편집 모드: ${_isEditMode ? '활성' : '비활성'}');
    }
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
      if (AppConfig.debugMode) {
        print('❌ [ProfileSelfLogicMixin] 유효성 검증 실패: $_errors');
      }
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

      final accessToken = await authProvider.accessToken; // 수정: async getter 사용
      if (accessToken == null) {
        throw Exception('인증 토큰이 없습니다.');
      }

      // 수정된 프로필 데이터 생성
      final updatedProfile = _profile!.copyWithUpdates(
        name: _editingName.trim(),
        gender: _editingGender,
        birthDate: app_date_utils.DateUtils.formatApiDate(_editingBirthDate!),
      );

      if (AppConfig.debugMode) {
        print('💾 [ProfileSelfLogicMixin] 프로필 저장 시작...');
      }

      // API 호출
      final success = await _profileService.updateMyProfile(
        accessToken,
        updatedProfile,
      );

      if (success && mounted) {
        if (AppConfig.debugMode) {
          print('✅ [ProfileSelfLogicMixin] 프로필 저장 성공 - 데이터 새로고침 시작');
        }

        // 성공 - 프로필 다시 로드하여 최신 데이터 반영
        await _loadProfile();

        // 🎯 AuthProvider에 저장된 사용자 정보도 업데이트
        await authProvider.updateUserInfo();

        setState(() {
          _isEditMode = false;
          _isSaving = false;
        });

        if (AppConfig.debugMode) {
          print('✅ [ProfileSelfLogicMixin] 프로필 새로고침 완료: ${_profile?.name}');
          print('✅ [ProfileSelfLogicMixin] AuthProvider 업데이트 완료');
        }

        // 성공 메시지 표시
        _showSuccessSnackBar('프로필이 성공적으로 저장되었습니다.');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });

        if (AppConfig.debugMode) {
          print('❌ [ProfileSelfLogicMixin] 프로필 저장 실패: $e');
        }

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

    if (AppConfig.debugMode) {
      print('🔄 [ProfileSelfLogicMixin] 편집 취소');
    }
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
}
