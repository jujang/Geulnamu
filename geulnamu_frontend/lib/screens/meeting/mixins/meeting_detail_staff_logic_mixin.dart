import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../services/meeting/meeting_service.dart';
import '../../../models/meeting/meeting_detail_staff_model.dart';
import '../../../models/meeting/request/meeting_update_requests.dart';
import '../../../core/config/app_config.dart';

/// 운영진용 모임 상세 화면 로직 처리 Mixin
/// 
/// 제공 기능:
/// - 운영진용 모임 상세 정보 로딩
/// - 인라인 편집 상태 관리 (모임 정보 / 토론 정보 별도)
/// - 수정/삭제/비공개 처리 기능
/// - 권한별 기능 제어
mixin MeetingDetailStaffLogicMixin<T extends StatefulWidget> on State<T> {
  final MeetingService _meetingService = MeetingService();

  // 🎯 로딩 상태
  bool _isLoading = false;
  bool _isSaving = false;
  String? _errorMessage;

  // 🎯 모임 정보
  MeetingDetailStaffInfo? _meetingDetail;

  // 🎯 편집 상태 (각 섹션별 독립 관리)
  bool _isEditingBasicInfo = false;
  bool _isEditingDiscussion = false;

  // 🎯 폼 컨트롤러들
  final TextEditingController _meetingNameController = TextEditingController();
  final TextEditingController _meetingPlaceController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _alarmMessageController = TextEditingController();
  
  // 🎯 선택된 값들
  String? _selectedMeetingType;
  DateTime? _selectedMeetingDateTime;
  DateTime? _selectedLateThresholdTime;
  DateTime? _selectedDiscussionTime;

  // 🎯 Getter들
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  String? get errorMessage => _errorMessage;
  MeetingDetailStaffInfo? get meetingDetail => _meetingDetail;
  bool get isEditingBasicInfo => _isEditingBasicInfo;
  bool get isEditingDiscussion => _isEditingDiscussion;

  // 🎯 컨트롤러 Getter들
  TextEditingController get meetingNameController => _meetingNameController;
  TextEditingController get meetingPlaceController => _meetingPlaceController;
  TextEditingController get descriptionController => _descriptionController;
  TextEditingController get alarmMessageController => _alarmMessageController;
  
  // 🎯 선택된 값 Getter들
  String? get selectedMeetingType => _selectedMeetingType;
  DateTime? get selectedMeetingDateTime => _selectedMeetingDateTime;
  DateTime? get selectedLateThresholdTime => _selectedLateThresholdTime;
  DateTime? get selectedDiscussionTime => _selectedDiscussionTime;

  // 🎯 권한 체크
  bool get isStaffOrAbove {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    return authProvider.isStaffLevel;
  }

  bool get isAdmin {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    return authProvider.isAdminLevel;
  }

  bool get canDeleteMeeting {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.isAdminLevel) return true; // 관리자는 항상 삭제 가능
    
    if (_meetingDetail != null && authProvider.userId != null) {
      // 생성자인 경우에만 삭제 가능
      return _meetingDetail!.meetingCreatorId == authProvider.userId!;
    }
    return false;
  }

  bool get canManagePrivacy {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    return authProvider.isAdminLevel; // 관리자만 비공개/공개 처리 가능
  }

  @override
  void dispose() {
    _meetingNameController.dispose();
    _meetingPlaceController.dispose();
    _descriptionController.dispose();
    _alarmMessageController.dispose();
    super.dispose();
  }

  /// 초기 데이터 로딩
  Future<void> initializeMeetingDetailStaff(int meetingId, {bool forceRefresh = false}) async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final accessToken = await authProvider.accessToken;
      if (accessToken == null) {
        throw Exception('인증 토큰이 없습니다.');
      }

      final meetingDetail = await _meetingService.getMeetingDetailForStaff(
        meetingId: meetingId,
        accessToken: accessToken,
        forceRefresh: forceRefresh, // 강제 새로고침 옵션 전달
      );

      if (mounted) {
        setState(() {
          _meetingDetail = meetingDetail;
          _isLoading = false;
          _initializeFormControllers();
        });

        if (AppConfig.debugMode) {
          print('✅ [운영진용 모임 상세] 데이터 로딩 완료: ${meetingDetail.meetingName}');
          if (forceRefresh) {
            print('🔄 [캐시 무효화] 새로운 데이터로 업데이트 완료');
          }
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString();
        });
      }
      
      if (AppConfig.debugMode) {
        print('❌ [운영진용 모임 상세] 로딩 실패: $e');
      }
    }
  }

  /// 새로고침 (강제 캐시 무효화)
  Future<void> refreshMeetingDetailStaff(int meetingId) async {
    await initializeMeetingDetailStaff(meetingId, forceRefresh: true); // 강제 새로고침 옵션
  }

  /// 폼 컨트롤러 초기화
  void _initializeFormControllers() {
    if (_meetingDetail == null) return;

    _meetingNameController.text = _meetingDetail!.meetingName;
    _meetingPlaceController.text = _meetingDetail!.meetingPlace;
    _descriptionController.text = _meetingDetail!.description ?? '';  // null 안전 처리
    _alarmMessageController.text = _meetingDetail!.alarmMessage ?? '';  // null 안전 처리
    
    _selectedMeetingType = _meetingDetail!.meetingType;
    _selectedMeetingDateTime = _meetingDetail!.meetingDateTime;
    _selectedLateThresholdTime = _meetingDetail!.lateThresholdTime;
    _selectedDiscussionTime = _meetingDetail!.discussionTime;  // null 가능
  }

  /// 모임 기본 정보 편집 토글
  void toggleBasicInfoEdit() {
    if (!isStaffOrAbove) return;

    setState(() {
      _isEditingBasicInfo = !_isEditingBasicInfo;
      if (!_isEditingBasicInfo) {
        // 편집 취소 시 원래 값으로 복원
        _initializeFormControllers();
      }
    });
  }

  /// 토론 정보 편집 토글
  void toggleDiscussionEdit() {
    if (!isStaffOrAbove) return;

    setState(() {
      _isEditingDiscussion = !_isEditingDiscussion;
      if (!_isEditingDiscussion) {
        // 편집 취소 시 원래 값으로 복원
        _initializeFormControllers();
      }
    });
  }

  /// 모임 기본 정보 저장
  Future<void> saveBasicInfo(int meetingId) async {
    if (!_validateBasicInfo()) return;

    // 변경사항 감지
    final request = MeetingBasicUpdateRequest.onlyChanged(
      originalMeetingType: _meetingDetail!.meetingType,
      newMeetingType: _selectedMeetingType,
      originalMeetingName: _meetingDetail!.meetingName,
      newMeetingName: _meetingNameController.text.trim(),
      originalMeetingDate: _meetingDetail!.meetingDateTime,
      newMeetingDate: _selectedMeetingDateTime,
      originalLateThresholdTime: _meetingDetail!.lateThresholdTime,
      newLateThresholdTime: _selectedLateThresholdTime,
      originalMeetingPlace: _meetingDetail!.meetingPlace,
      newMeetingPlace: _meetingPlaceController.text.trim(),
      originalDescription: _meetingDetail!.description,
      newDescription: _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim(),
    );

    // 변경사항이 없으면 요청 차단
    if (!request.hasChanges) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('변경된 내용이 없습니다.')),
        );
        setState(() => _isEditingBasicInfo = false); // 편집 모드 종료
      }
      return;
    }

    if (AppConfig.debugMode) {
      print('📝 [모임 기본 정보 수정] 변경된 필드 ${request.changeCount}개: $request');
    }

    setState(() => _isSaving = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final accessToken = await authProvider.accessToken;
      if (accessToken == null) {
        throw Exception('인증 토큰이 없습니다.');
      }

      await _meetingService.updateMeetingBasicInfo(
        meetingId: meetingId,
        request: request,
        accessToken: accessToken,
      );

      if (mounted) {
        setState(() {
          _isEditingBasicInfo = false;
          _isSaving = false;
        });

        // 성공 메시지
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('모임 정보가 수정되었습니다. (변경된 항목: ${request.changeCount}개)')),
        );

        // 짧은 지연 후 데이터 새로고침 (서버 동기화 대기)
        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted) {
          if (AppConfig.debugMode) {
            print('🔄 [모임 기본 정보 수정] 데이터 새로고침 시작...');
          }
          await refreshMeetingDetailStaff(meetingId);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('수정 실패: $e')),
        );
      }
    }
  }

  /// 토론 정보 저장
  Future<void> saveDiscussionInfo(int meetingId) async {
    if (!_validateDiscussionInfo()) return;

    // 변경사항 감지
    final request = MeetingDiscussionUpdateRequest.onlyChanged(
      originalDiscussionTime: _meetingDetail!.discussionTime,
      newDiscussionTime: _selectedDiscussionTime,
      originalAlarmMessage: _meetingDetail!.alarmMessage,
      newAlarmMessage: _alarmMessageController.text.trim().isEmpty ? null : _alarmMessageController.text.trim(),
    );

    // 변경사항이 없으면 요청 차단
    if (!request.hasChanges) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('변경된 내용이 없습니다.')),
        );
        setState(() => _isEditingDiscussion = false); // 편집 모드 종료
      }
      return;
    }

    if (AppConfig.debugMode) {
      print('📝 [토론 정보 수정] 변경된 필드 ${request.changeCount}개: $request');
    }

    setState(() => _isSaving = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final accessToken = await authProvider.accessToken;
      if (accessToken == null) {
        throw Exception('인증 토큰이 없습니다.');
      }

      await _meetingService.updateMeetingDiscussionInfo(
        meetingId: meetingId,
        request: request,
        accessToken: accessToken,
      );

      if (mounted) {
        setState(() {
          _isEditingDiscussion = false;
          _isSaving = false;
        });

        // 성공 메시지
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('토론 정보가 수정되었습니다. (변경된 항목: ${request.changeCount}개)')),
        );

        // 짧은 지연 후 데이터 새로고침 (서버 동기화 대기)
        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted) {
          if (AppConfig.debugMode) {
            print('🔄 [토론 정보 수정] 데이터 새로고침 시작...');
          }
          await refreshMeetingDetailStaff(meetingId);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('수정 실패: $e')),
        );
      }
    }
  }

  /// 모임 삭제
  Future<void> deleteMeeting(int meetingId) async {
    if (!canDeleteMeeting) return;

    // 확인 다이얼로그
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('모임 삭제'),
        content: const Text('정말로 이 모임을 삭제하시겠습니까?\\n삭제된 모임은 복구할 수 없습니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('삭제'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isSaving = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final accessToken = await authProvider.accessToken;
      if (accessToken == null) {
        throw Exception('인증 토큰이 없습니다.');
      }

      await _meetingService.deleteMeeting(
        meetingId: meetingId,
        accessToken: accessToken,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('모임이 삭제되었습니다.')),
        );

        // 목록 화면으로 돌아가기
        Navigator.of(context).pop(true); // 삭제 성공 결과 반환
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('삭제 실패: $e')),
        );
      }
    }
  }

  /// 모임 비공개/공개 토글
  Future<void> toggleMeetingPrivacy(int meetingId) async {
    if (!canManagePrivacy || _meetingDetail == null) return;

    final isCurrentlyPrivate = _meetingDetail!.isPrivateMeeting;
    final action = isCurrentlyPrivate ? '공개' : '비공개';

    // 확인 다이얼로그
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('모임 $action 처리'),
        content: Text('이 모임을 ${action}으로 변경하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(action),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isSaving = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final accessToken = await authProvider.accessToken;
      if (accessToken == null) {
        throw Exception('인증 토큰이 없습니다.');
      }

      if (isCurrentlyPrivate) {
        // 공개 처리
        await _meetingService.makeMeetingPublic(
          meetingId: meetingId,
          accessToken: accessToken,
        );
      } else {
        // 비공개 처리
        await _meetingService.makeMeetingPrivate(
          meetingId: meetingId,
          accessToken: accessToken,
        );
      }

      if (mounted) {
        setState(() => _isSaving = false);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('모임이 ${action}으로 변경되었습니다.')),
        );

        // 데이터 새로고침
        await refreshMeetingDetailStaff(meetingId);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$action 처리 실패: $e')),
        );
      }
    }
  }

  /// 기본 정보 유효성 검사
  bool _validateBasicInfo() {
    if (_meetingNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('모임 이름을 입력해주세요.')),
      );
      return false;
    }
    
    if (_selectedMeetingType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('모임 유형을 선택해주세요.')),
      );
      return false;
    }

    if (_selectedMeetingDateTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('모임 일시를 선택해주세요.')),
      );
      return false;
    }

    if (_selectedLateThresholdTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('지각 기준 시간을 선택해주세요.')),
      );
      return false;
    }

    if (_meetingPlaceController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('모임 장소를 입력해주세요.')),
      );
      return false;
    }

    return true;
  }

  /// 토론 정보 유효성 검사
  bool _validateDiscussionInfo() {
    // 토론 시간은 선택사항 (더 이상 필수 아님)
    // if (_selectedDiscussionTime == null) {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     const SnackBar(content: Text('토론 시간을 선택해주세요.')),
    //   );
    //   return false;
    // }

    // 알림 메시지도 선택사항 (빈 값 허용)
    // if (_alarmMessageController.text.trim().isEmpty) {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     const SnackBar(content: Text('알림 메시지를 입력해주세요.')),
    //   );
    //   return false;
    // }

    return true;
  }

  // 🎯 날짜/시간 선택 헬퍼 메서드들
  void onMeetingTypeChanged(String? value) {
    setState(() => _selectedMeetingType = value);
  }

  void onMeetingDateTimeChanged(DateTime? value) {
    setState(() => _selectedMeetingDateTime = value);
  }

  void onLateThresholdTimeChanged(DateTime? value) {
    setState(() => _selectedLateThresholdTime = value);
  }

  void onDiscussionTimeChanged(DateTime? value) {
    setState(() => _selectedDiscussionTime = value);
  }
}
