import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../services/meeting/meeting_service.dart';
import '../../../services/discussion/discussion_service.dart';
import '../../../services/attendance/attendance_service.dart';
import '../../../services/book_question/book_question_service.dart';
import '../../../models/meeting/meeting_detail_staff_model.dart';
import '../../../models/meeting/request/meeting_update_requests.dart';
import '../../../models/discussion/attendance_id_and_name_model.dart';
import '../../../models/discussion/discussion_group_model.dart';
import '../../../models/discussion/assign_discussion_groups_request.dart';
import '../../../models/attendance/attendance_status_model.dart';
import '../../../models/book_question/book_question_model.dart';
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
  final DiscussionService _discussionService = DiscussionService();
  final AttendanceService _attendanceService = AttendanceService(); // 🆕 출석 서비스 추가
  final BookQuestionService _bookQuestionService = BookQuestionService(); // 🆕 발제문 서비스 추가

  // 🎯 로딩 상태
  bool _isLoading = false;
  bool _isSaving = false;
  String? _errorMessage;

  // 🎯 모임 정보
  MeetingDetailStaffInfo? _meetingDetail;

  // 🎯 편집 상태 (각 섹션별 독립 관리)
  bool _isEditingBasicInfo = false;
  bool _isEditingDiscussion = false;
  bool _isEditingDiscussionGroups = false; // 🆕 토론 그룹 편집 상태

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
  
  // 🆕 X 버튼 상태 추적
  bool _isDiscussionTimeCleared = false; // X 버튼으로 토론 시간을 클리어했는지 여부

  // 🆕 토론 조 관련 상태
  bool _isDiscussionGroupLoading = false;
  String? _discussionGroupErrorMessage;
  List<AttendanceIdAndNameModel>? _wantDiscussionList;
  DiscussionGroupListResponse? _discussionGroupList;
  
  // 🆕 토론 그룹 편집 데이터 (편집 중인 상태를 별도 관리)
  Map<int, List<AttendanceIdAndNameModel>> _editingGroups = {}; // 그룹 번호 -> 멤버 리스트
  List<AttendanceIdAndNameModel> _editingUnassignedMembers = []; // 미할당 멤버들
  
  // 🆕 인원 추가 기능 관련 상태
  MeetingAttendanceDetails? _allAttendanceDetails; // 전체 출석자 목록
  List<AttendanceIdAndNameModel> _temporaryAddedMembers = []; // 임시 추가된 인원들
  
  // 🆕 발제문 관련 상태
  bool _isBookQuestionLoading = false;
  String? _bookQuestionErrorMessage;
  List<BookQuestionModel>? _bookQuestionList;

  // 🎯 Getter들
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  String? get errorMessage => _errorMessage;
  MeetingDetailStaffInfo? get meetingDetail => _meetingDetail;
  
  // 🆕 토론 조 관련 Getter들
  bool get isDiscussionGroupLoading => _isDiscussionGroupLoading;
  String? get discussionGroupErrorMessage => _discussionGroupErrorMessage;
  List<AttendanceIdAndNameModel>? get wantDiscussionList => _wantDiscussionList;
  DiscussionGroupListResponse? get discussionGroupList => _discussionGroupList;
  bool get isEditingBasicInfo => _isEditingBasicInfo;
  bool get isEditingDiscussion => _isEditingDiscussion;
  bool get isEditingDiscussionGroups => _isEditingDiscussionGroups;
  
  // 🆕 토론 그룹 편집 데이터 Getter들
  Map<int, List<AttendanceIdAndNameModel>> get editingGroups => Map.from(_editingGroups);
  List<AttendanceIdAndNameModel> get editingUnassignedMembers => List.from(_editingUnassignedMembers);
  
  // 🆕 인원 추가 기능 관련 Getter들
  MeetingAttendanceDetails? get allAttendanceDetails => _allAttendanceDetails;
  List<AttendanceIdAndNameModel> get temporaryAddedMembers => List.from(_temporaryAddedMembers);
  
  // 🆕 발제문 관련 Getter들
  bool get isBookQuestionLoading => _isBookQuestionLoading;
  String? get bookQuestionErrorMessage => _bookQuestionErrorMessage;
  List<BookQuestionModel>? get bookQuestionList => _bookQuestionList;

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
  
  // 🆕 X 버튼 상태 Getter
  bool get isDiscussionTimeCleared => _isDiscussionTimeCleared;

  bool get isStaffOrAbove {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    return authProvider.isStaffLevel;
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
    
    // 🆕 X 버튼 상태 초기화
    _isDiscussionTimeCleared = false;
  }

  bool get isAdmin {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    return authProvider.isAdminLevel;
  }

  // 🆕 편집 가능 여부 체크 (날짜 기반)
  bool get canEditMeetingInfo {
    if (_meetingDetail == null) return false;
    
    final now = DateTime.now();
    final meetingDate = DateTime(
      _meetingDetail!.meetingDateTime.year,
      _meetingDetail!.meetingDateTime.month,
      _meetingDetail!.meetingDateTime.day,
    );
    
    // 🔥 모임 다음 날부터 편집 불가능 (모임 당일까지는 편집 가능)
    final nextDay = meetingDate.add(const Duration(days: 1));
    final canEdit = now.isBefore(nextDay);
    
    if (AppConfig.debugMode && !canEdit) {
      print('🔒 [편집 제한] 모임 다음 날부터 편집이 제한됩니다.');
      print('   - 현재 날짜: ${_formatDate(now)}');
      print('   - 모임 날짜: ${_formatDate(_meetingDetail!.meetingDateTime)}');
      print('   - 편집 가능 마지막일: ${_formatDate(meetingDate)} (모임 당일까지)');
    }
    
    return canEdit;
  }

  // 🆕 토론 조 편집 가능 여부 체크 (추가 조건: 토론 시간 설정 필요)
  bool get canEditDiscussionGroups {
    if (_meetingDetail?.discussionTime == null) return false; // 토론 시간이 설정되지 않음
    return canEditMeetingInfo; // 기본 날짜 조건과 동일
  }

  bool get canDeleteMeeting {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    if (_meetingDetail != null && authProvider.userId != null) {
      // 생성자 또는 관리자만 삭제 가능
      final isCreator = _meetingDetail!.meetingCreatorId == authProvider.userId!;
      final isAdmin = authProvider.isAdminLevel;
      
      if (!isCreator && !isAdmin) return false;
      
      // 🔥 시간 제한 검사: 모임 개최 6시간 전까지만 삭제 가능 (관리자도 동일)
      final now = DateTime.now();
      final meetingTime = _meetingDetail!.meetingDateTime;
      final timeDifference = meetingTime.difference(now);
      
      return timeDifference.inHours >= 6; // 6시간 이상 남은 경우만 삭제 가능
    }
    return false;
  }

  bool get canManagePrivacy {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    return authProvider.isAdminLevel; // 관리자만 비공개/공개 처리 가능
  }
  
  // 🆕 인원 추가 기능 권한 체크
  bool get canAddMembers {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    return authProvider.isAdminLevel; // ADMIN 레벨만 가능 (관리자, 모임장, 부모임장)
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
        
        // 🆕 토론 시간이 설정된 경우 토론 조 데이터 로드
        if (meetingDetail.discussionTime != null) {
          loadDiscussionGroupData(meetingId);
          
          // 🆕 발제문 데이터도 로드 (토론 시간 설정 시)
          loadBookQuestionData(meetingId);
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
  
  // ====================
  // 🆕 발제문 관련 메서드들
  // ====================
  
  /// 발제문 데이터 로드
  /// 조건: discussionTime != null인 경우에만 호출
  Future<void> loadBookQuestionData(int meetingId) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final accessToken = await authProvider.accessToken;
    
    if (accessToken == null) {
      if (AppConfig.debugMode) {
        print('❌ [발제문 데이터 로드] 액세스 토큰이 없습니다.');
      }
      return;
    }

    setState(() {
      _isBookQuestionLoading = true;
      _bookQuestionErrorMessage = null;
    });

    try {
      if (AppConfig.debugMode) {
        print('🚀 [발제문 데이터 로드] 시작... meetingId: $meetingId');
      }

      // API 호출: 본인 토론 그룹 발제문 조회
      final bookQuestions = await _bookQuestionService.getMyGroupBookQuestions(
        meetingId: meetingId,
        accessToken: accessToken,
      );

      setState(() {
        _bookQuestionList = bookQuestions;
        _isBookQuestionLoading = false;
        _bookQuestionErrorMessage = null;
      });

      if (AppConfig.debugMode) {
        print('✅ [발제문 데이터 로드] 성공');
        print('   - 발제문 수: ${bookQuestions.length}개');
        for (final question in bookQuestions) {
          print('   📝 발제문 ${question.bookQuestionId}: ${question.content.length > 30 ? question.content.substring(0, 30) + "..." : question.content}');
        }
      }

    } catch (e) {
      setState(() {
        _isBookQuestionLoading = false;
        _bookQuestionErrorMessage = e.toString();
      });

      if (AppConfig.debugMode) {
        print('❌ [발제문 데이터 로드] 오류: $e');
      }
    }
  }

  /// 발제문 데이터 새로고침
  Future<void> refreshBookQuestionData(int meetingId) async {
    if (_meetingDetail?.discussionTime == null) {
      if (AppConfig.debugMode) {
        print('ℹ️ [발제문 새로고침] 토론 시간이 설정되지 않아 새로고침을 건너뛸니다.');
      }
      return;
    }

    await loadBookQuestionData(meetingId);
  }

  /// 토론 시간 변경에 따른 발제문 데이터 처리
  /// 토론 정보 저장 후 호출
  void handleBookQuestionDataUpdate(int meetingId) {
    if (_meetingDetail?.discussionTime != null) {
      // 토론 시간이 설정된 경우 발제문 데이터 로드
      loadBookQuestionData(meetingId);
    } else {
      // 토론 시간이 제거된 경우 발제문 데이터 초기화
      setState(() {
        _bookQuestionList = null;
        _bookQuestionErrorMessage = null;
        _isBookQuestionLoading = false;
      });
      
      if (AppConfig.debugMode) {
        print('🆕 [발제문 데이터] 토론 시간 제거로 인한 데이터 초기화');
      }
    }
  }

  /// 모임 기본 정보 편집 토글
  void toggleBasicInfoEdit() {
    if (!isStaffOrAbove) {
      _showPermissionDeniedMessage('기본 정보를 편집할 권한이 없습니다.');
      return;
    }

    // 🆕 날짜 기반 편집 제한 체크
    if (!canEditMeetingInfo) {
      _showEditingRestrictedMessage('모임 기본 정보');
      return;
    }

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
    if (!isStaffOrAbove) {
      _showPermissionDeniedMessage('토론 정보를 편집할 권한이 없습니다.');
      return;
    }

    // 🆕 날짜 기반 편집 제한 체크
    if (!canEditMeetingInfo) {
      _showEditingRestrictedMessage('토론 정보');
      return;
    }

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

    // 변경사항 감지 (🆕 X 버튼 상태 포함)
    final request = MeetingDiscussionUpdateRequest.onlyChanged(
      originalDiscussionTime: _meetingDetail!.discussionTime,
      newDiscussionTime: _selectedDiscussionTime,
      isDiscussionTimeCleared: _isDiscussionTimeCleared, // 🆕 X 버튼 상태 전달
      originalAlarmMessage: _meetingDetail!.alarmMessage,
      newAlarmMessage: _alarmMessageController.text.trim(), // 🆕 빈 문자열도 그대로 전송
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
          
          // 🆕 토론 시간 변경에 따른 토론 조 데이터 처리
          handleDiscussionTimeUpdate(meetingId);
          
          // 🆕 토론 시간 변경에 따른 발제문 데이터 처리
          handleBookQuestionDataUpdate(meetingId);
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
    if (!canDeleteMeeting) {
      // 🔥 삭제 불가능 사유 별 안내 메시지
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      String message = '모임을 삭제할 권한이 없습니다.';
      
      if (_meetingDetail != null && authProvider.userId != null) {
        final isCreator = _meetingDetail!.meetingCreatorId == authProvider.userId!;
        final isAdmin = authProvider.isAdminLevel;
        
        if (isCreator || isAdmin) {
          // 생성자 또는 관리자이지만 시간 제한에 걸린 경우
          final now = DateTime.now();
          final meetingTime = _meetingDetail!.meetingDateTime;
          final timeDifference = meetingTime.difference(now);
          final hoursLeft = timeDifference.inHours;
          
          if (hoursLeft < 6) {
            message = '모임 개최 6시간 전까지만 삭제가 가능합니다.\n'
                     '현재 남은 시간: 약 ${hoursLeft + 1}시간';
          }
        }
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
      return;
    }

    // 확인 다이얼로그
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('모임 삭제'),
        content: const Text(
          '정말로 이 모임을 삭제하시겠습니까?\n'
          '삭제된 모임은 복구할 수 없습니다.',
        ),
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

    // 🔥 지각 기준 시간 유효성 검사 추가
    if (!_isValidLateThresholdTime(_selectedLateThresholdTime!, _selectedMeetingDateTime!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '⚠️ 지각 기준 시간이 올바르지 않습니다.\n'
            '조건: ${_formatDate(_selectedMeetingDateTime!)} (모임 당일) ${_formatTime(_selectedMeetingDateTime!)} 이상으로 설정해주세요.',
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
        ),
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
  
  /// 지각 기준 시간 유효성 검사
  bool _isValidLateThresholdTime(DateTime lateTime, DateTime meetingTime) {
    // 같은 날짜인지 확인
    final lateDate = DateTime(lateTime.year, lateTime.month, lateTime.day);
    final meetingDate = DateTime(meetingTime.year, meetingTime.month, meetingTime.day);
    
    if (lateDate != meetingDate) {
      return false; // 다른 날짜는 불허
    }
    
    // 🔥 모임 시간과 같거나 이후인지 확인 (같은 시간도 허용)
    return !lateTime.isBefore(meetingTime); // isBefore의 반대 = 같거나 이후
  }
  
  /// 토론 시간 유효성 검사
  bool _isValidDiscussionTime(DateTime discussionTime, DateTime meetingTime) {
    // 같은 날짜인지 확인
    final discussionDate = DateTime(discussionTime.year, discussionTime.month, discussionTime.day);
    final meetingDate = DateTime(meetingTime.year, meetingTime.month, meetingTime.day);
    
    if (discussionDate != meetingDate) {
      return false; // 다른 날짜는 불허
    }
    
    // 모임 시간 이후인지 확인
    return discussionTime.isAfter(meetingTime);
  }
  
  /// 날짜 포맷터 (YYYY.MM.DD)
  String _formatDate(DateTime dateTime) {
    return '${dateTime.year}.${dateTime.month.toString().padLeft(2, '0')}.${dateTime.day.toString().padLeft(2, '0')}';
  }
  
  /// 시간 포맷터 (HH:MM)
  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
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

    // 🔥 토론 시간이 설정된 경우에만 유효성 검사
    if (_selectedDiscussionTime != null && _selectedMeetingDateTime != null) {
      if (!_isValidDiscussionTime(_selectedDiscussionTime!, _selectedMeetingDateTime!)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '⚠️ 토론 시간이 올바르지 않습니다.\n'
              '조건: ${_formatDate(_selectedMeetingDateTime!)} (모임 당일) ${_formatTime(_selectedMeetingDateTime!)} 이후로 설정해주세요.',
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
        return false;
      }
    }

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
    if (value == null) {
      setState(() => _selectedMeetingDateTime = value);
      return;
    }

    // 🔥 검증: 토론 시간과의 충돌 확인
    if (_selectedDiscussionTime != null) {
      final previousDate = _selectedMeetingDateTime != null 
        ? DateTime(_selectedMeetingDateTime!.year, _selectedMeetingDateTime!.month, _selectedMeetingDateTime!.day)
        : null;
      final newDate = DateTime(value.year, value.month, value.day);
      
      // 날짜가 변경되거나, 모임 시간이 토론 시간보다 늦어지는 경우
      if ((previousDate != null && previousDate != newDate) || 
          value.isAfter(_selectedDiscussionTime!) || 
          value.isAtSameMomentAs(_selectedDiscussionTime!)) {
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                '⚠️ 토론 시간 설정 기준과 맞지 않습니다.\n'
                '토론 시간을 먼저 초기화하고나서 모임 시간을 설정해주세요.',
              ),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 4),
            ),
          );
        }
        return; // 변경 차단
      }
    }

    setState(() {
      _selectedMeetingDateTime = value;
      
      // 🔥 지각 기준 시간 검증 및 안내 (자동 조정 제거)
      if (_selectedLateThresholdTime != null) {
        final lateDate = DateTime(_selectedLateThresholdTime!.year, _selectedLateThresholdTime!.month, _selectedLateThresholdTime!.day);
        final newDate = DateTime(value.year, value.month, value.day);
        
        // 날짜가 다르거나 지각 기준 시간이 모임 시간보다 빠른 경우
        if (lateDate != newDate || _selectedLateThresholdTime!.isBefore(value)) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  '⚠️ 지각 기준 시간을 다시 설정해주세요.\n'
                  '조건: ${_formatDate(value)} (모임 당일) ${_formatTime(value)} 이상으로 설정 가능',
                ),
                backgroundColor: Colors.orange,
                duration: const Duration(seconds: 4),
              ),
            );
          }
        }
      }
    });
  }

  void onLateThresholdTimeChanged(DateTime? value) {
    if (value != null && _selectedMeetingDateTime != null) {
      // 🔥 지각 기준 시간 검증
      if (!_isValidLateThresholdTime(value, _selectedMeetingDateTime!)) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('⚠️ 지각 기준 시간은 모임 당일에 개최 일시 이상으로 설정해야 합니다.'),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 3),
            ),
          );
        }
        return; // 변경 차단
      }
    }
    
    setState(() => _selectedLateThresholdTime = value);
  }

  void onDiscussionTimeChanged(DateTime? value) {
    if (value != null && _selectedMeetingDateTime != null) {
      // 🔥 토론 시간 검증
      if (!_isValidDiscussionTime(value, _selectedMeetingDateTime!)) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('⚠️ 토론 시간은 모임 당일에 모임 시간 이후로 설정해야 합니다.'),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 3),
            ),
          );
        }
        return; // 변경 차단
      }
    }
    
    setState(() {
      _selectedDiscussionTime = value;
      // 🆕 시간을 다시 선택한 경우 X 버튼 상태 해제
      if (value != null) {
        _isDiscussionTimeCleared = false;
      }
    });
  }
  
  /// 🆕 토론 시간 클리어 (X 버튼)
  void clearDiscussionTime() {
    setState(() {
      _selectedDiscussionTime = null;
      _isDiscussionTimeCleared = true; // X 버튼으로 클리어한 것으로 표시
      
      // 🔥 알림 메시지는 유지 (사용자가 열심히 작성한 내용 보호)
      // _alarmMessageController.clear(); // 제거됨
    });
    
    // 사용자에게 안내 메시지
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('📝 토론 시간이 초기화되었습니다. 알림 메시지는 유지되지만 토론 시간 설정 전까지는 사용되지 않습니다.'),
          duration: Duration(seconds: 4),
        ),
      );
    }
  }

  // ====================
  // 토론 조 관련 메서드들
  // ====================

  /// 토론 조 데이터 로드 
  /// 조건: discussionTime != null인 경우에만 호출
  Future<void> loadDiscussionGroupData(int meetingId) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final accessToken = await authProvider.accessToken; // 🔧 await 추가
    
    if (accessToken == null) {
      if (AppConfig.debugMode) {
        print('❌ [토론 조 데이터 로드] 액세스 토큰이 없습니다.');
      }
      return;
    }

    setState(() {
      _isDiscussionGroupLoading = true;
      _discussionGroupErrorMessage = null;
    });

    try {
      if (AppConfig.debugMode) {
        print('🚀 [토론 조 데이터 로드] 시작... meetingId: $meetingId');
      }

      final results = await _discussionService.refreshDiscussionData(
        meetingId: meetingId,
        accessToken: accessToken,
      );

      setState(() {
        _wantDiscussionList = results['wantDiscussionList'] as List<AttendanceIdAndNameModel>?;
        _discussionGroupList = results['discussionGroupList'] as DiscussionGroupListResponse?;
        _isDiscussionGroupLoading = false;
        _discussionGroupErrorMessage = null;
      });

      if (AppConfig.debugMode) {
        print('✅ [토론 조 데이터 로드] 성공');
        print('   - 참여 희망자: ${_wantDiscussionList?.length ?? 0}명');
        print('   - 토론 그룹: ${_discussionGroupList?.groupCount ?? 0}개');
      }

    } catch (e) {
      setState(() {
        _isDiscussionGroupLoading = false;
        _discussionGroupErrorMessage = e.toString();
      });

      if (AppConfig.debugMode) {
        print('❌ [토론 조 데이터 로드] 오류: $e');
      }
    }
  }

  /// 토론 조 데이터 새로고침
  Future<void> refreshDiscussionGroupData(int meetingId) async {
    if (_meetingDetail?.discussionTime == null) {
      if (AppConfig.debugMode) {
        print('ℹ️ [토론 조 새로고침] 토론 시간이 설정되지 않아 새로고침을 건너뛔니다.');
      }
      return;
    }

    await loadDiscussionGroupData(meetingId);
  }

  /// 토론 시간 변경에 따른 토론 조 데이터 처리
  /// 토론 정보 저장 후 호출
  void handleDiscussionTimeUpdate(int meetingId) {
    if (_meetingDetail?.discussionTime != null) {
      // 토론 시간이 설정된 경우 데이터 로드
      loadDiscussionGroupData(meetingId);
    } else {
      // 토론 시간이 제거된 경우 데이터 초기화
      setState(() {
        _wantDiscussionList = null;
        _discussionGroupList = null;
        _discussionGroupErrorMessage = null;
        _isDiscussionGroupLoading = false;
      });
      
      if (AppConfig.debugMode) {
        print('🆕 [토론 조 데이터] 토론 시간 제거로 인한 데이터 초기화');
      }
    }
  }

  // ====================
  // 토론 그룹 편집 관련 메서드들
  // ====================

  /// 토론 그룹 편집 모드 토글
  void toggleDiscussionGroupEdit() {
    if (!isStaffOrAbove) {
      _showPermissionDeniedMessage('토론 그룹을 편집할 권한이 없습니다.');
      return;
    }

    // 🆕 날짜 기반 편집 제한 체크 (토론 시간 설정 체크 포함)
    if (!canEditDiscussionGroups) {
      if (_meetingDetail?.discussionTime == null) {
        _showPermissionDeniedMessage('토론 시간이 설정되지 않아 토론 그룹을 편집할 수 없습니다.');
      } else {
        _showEditingRestrictedMessage('토론 그룹');
      }
      return;
    }

    setState(() {
      _isEditingDiscussionGroups = !_isEditingDiscussionGroups;
      
      if (_isEditingDiscussionGroups) {
        // 편집 모드 시작: 현재 데이터를 편집용으로 복사
        _initializeEditingData();
        
        // 🆕 ADMIN 급인 경우 출석자 목록도 로드
        if (canAddMembers && _meetingDetail != null) {
          _loadAllAttendanceList(_meetingDetail!.meetingId);
        }
        
        if (AppConfig.debugMode) {
          print('🎨 [토론 그룹 편집] 편집 모드 시작');
        }
      } else {
        // 편집 모드 종료: 편집 데이터 초기화 (취소)
        _clearEditingData();
        
        if (AppConfig.debugMode) {
          print('❌ [토론 그룹 편집] 편집 모드 취소');
        }
      }
    });
  }

  /// 편집 데이터 초기화 (현재 토론 그룹 데이터를 편집용으로 복사)
  void _initializeEditingData() {
    _editingGroups.clear();
    _editingUnassignedMembers.clear();
    
    if (_discussionGroupList == null || _wantDiscussionList == null) {
      if (AppConfig.debugMode) {
        print('⚠️ [토론 그룹 편집] 데이터가 없어 편집 데이터를 초기화할 수 없습니다.');
      }
      return;
    }
    
    // 기존 그룹 데이터 복사
    for (int i = 0; i < _discussionGroupList!.groups.length; i++) {
      final group = _discussionGroupList!.groups[i];
      final groupNumber = i + 1; // 1부터 시작
      _editingGroups[groupNumber] = List.from(group.members);
    }
    
    // 미할당 멤버 계산 (토론 희망자 중 그룹에 속하지 않은 멤버들 + 임시 추가된 남은 인원들)
    _calculateUnassignedMembers();
    
    if (AppConfig.debugMode) {
      print('📋 [토론 그룹 편집] 편집 데이터 초기화 완료');
      print('   - 그룹 수: ${_editingGroups.length}개');
      print('   - 미할당 맴버: ${_editingUnassignedMembers.length}명');
      print('   - 임시 추가된 인원: ${_temporaryAddedMembers.length}명');
    }
  }

  /// 미할당 멤버 계산 (임시 추가된 인원들도 포함)
  void _calculateUnassignedMembers() {
    if (_wantDiscussionList == null) return;
    
    // 1. 토론 희망자 전체 리스트
    final allWantMembers = Set<int>.from(
      _wantDiscussionList!.map((member) => member.attendanceId)
    );
    
    // 2. 임시 추가된 인원들 추가
    final temporaryMemberIds = Set<int>.from(
      _temporaryAddedMembers.map((member) => member.attendanceId)
    );
    
    // 3. 전체 대상자 = 기존 토론 희망자 + 임시 추가된 인원
    final allTargetMembers = {...allWantMembers, ...temporaryMemberIds};
    
    // 4. 현재 그룹에 할당된 멤버들
    final assignedMembers = Set<int>();
    for (final group in _editingGroups.values) {
      for (final member in group) {
        assignedMembers.add(member.attendanceId);
      }
    }
    
    // 5. 미할당 멤버 = 전체 대상자 - 할당된 멤버
    final unassignedIds = allTargetMembers.difference(assignedMembers);
    
    // 6. 미할당 멤버 리스트 생성 (기존 + 임시 추가)
    _editingUnassignedMembers.clear();
    
    // 6-1. 기존 토론 희망자 중 미할당
    _editingUnassignedMembers.addAll(
      _wantDiscussionList!
          .where((member) => unassignedIds.contains(member.attendanceId))
    );
    
    // 6-2. 임시 추가된 인원 중 미할당
    _editingUnassignedMembers.addAll(
      _temporaryAddedMembers
          .where((member) => unassignedIds.contains(member.attendanceId))
    );
  }
  
  /// 편집 데이터 초기화 (취소 시 사용)
  void _clearEditingData() {
    _editingGroups.clear();
    _editingUnassignedMembers.clear();
    
    // 🆕 임시 추가된 인원들도 제거
    _temporaryAddedMembers.clear();
  }

  /// 멤버를 다른 그룹으로 이동
  void moveMemberToGroup(AttendanceIdAndNameModel member, int targetGroupNumber) {
    if (!_isEditingDiscussionGroups) return;
    
    setState(() {
      // 1. 기존 그룹에서 제거
      _removeMemberFromAllGroups(member);
      _editingUnassignedMembers.removeWhere((m) => m.attendanceId == member.attendanceId);
      
      // 2. 타겟 그룹에 추가
      if (!_editingGroups.containsKey(targetGroupNumber)) {
        _editingGroups[targetGroupNumber] = [];
      }
      _editingGroups[targetGroupNumber]!.add(member);
      
      if (AppConfig.debugMode) {
        print('🔄 [멤버 이동] ${member.memberName}를 ${targetGroupNumber}조로 이동');
      }
    });
  }

  /// 멤버를 그룹에서 제거 (미할당으로 이동)
  void removeMemberFromGroup(AttendanceIdAndNameModel member) {
    if (!_isEditingDiscussionGroups) return;
    
    setState(() {
      // 모든 그룹에서 제거
      _removeMemberFromAllGroups(member);
      
      // 미할당 리스트에 추가 (중복 방지)
      if (!_editingUnassignedMembers.any((m) => m.attendanceId == member.attendanceId)) {
        _editingUnassignedMembers.add(member);
      }
      
      if (AppConfig.debugMode) {
        print('🗑️ [멤버 제거] ${member.memberName}를 그룹에서 제거하여 미할당으로 이동');
      }
    });
  }
  
  /// 모든 그룹에서 특정 멤버 제거 (내부 유틸리티)
  void _removeMemberFromAllGroups(AttendanceIdAndNameModel member) {
    for (final groupMembers in _editingGroups.values) {
      groupMembers.removeWhere((m) => m.attendanceId == member.attendanceId);
    }
  }

  /// 새 그룹 생성
  void createNewGroup() {
    if (!_isEditingDiscussionGroups) return;
    
    setState(() {
      // 가장 큰 그룹 번호 + 1
      final newGroupNumber = _editingGroups.isEmpty 
          ? 1 
          : _editingGroups.keys.reduce((a, b) => a > b ? a : b) + 1;
      
      _editingGroups[newGroupNumber] = [];
      
      if (AppConfig.debugMode) {
        print('➕ [새 그룹 생성] ${newGroupNumber}조 생성');
      }
    });
  }

  /// 빈 그룹 제거
  void removeEmptyGroups() {
    if (!_isEditingDiscussionGroups) return;
    
    setState(() {
      final groupsToRemove = <int>[];
      
      for (final entry in _editingGroups.entries) {
        if (entry.value.isEmpty) {
          groupsToRemove.add(entry.key);
        }
      }
      
      for (final groupNumber in groupsToRemove) {
        _editingGroups.remove(groupNumber);
      }
      
      if (AppConfig.debugMode && groupsToRemove.isNotEmpty) {
        print('🗑️ [빈 그룹 제거] 제거된 그룹: ${groupsToRemove.join(', ')}조');
      }
    });
  }

  /// 모든 그룹 해제 (모든 멤버를 미할당으로 이동)
  void clearAllGroups() {
    if (!_isEditingDiscussionGroups) return;
    
    setState(() {
      // 모든 그룹 멤버를 미할당으로 이동
      for (final groupMembers in _editingGroups.values) {
        for (final member in groupMembers) {
          if (!_editingUnassignedMembers.any((m) => m.attendanceId == member.attendanceId)) {
            _editingUnassignedMembers.add(member);
          }
        }
      }
      
      _editingGroups.clear();
      
      if (AppConfig.debugMode) {
        print('🗑️ [모든 그룹 해제] 모든 멤버를 미할당으로 이동');
      }
    });
  }

  /// 토론 그룹 수정 내용 저장
  Future<void> saveDiscussionGroupChanges(int meetingId) async {
    if (!_isEditingDiscussionGroups) return;
    
    // 빈 그룹 제거
    removeEmptyGroups();
    
    setState(() => _isSaving = true);
    
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final accessToken = await authProvider.accessToken;
      if (accessToken == null) {
        throw Exception('인증 토큰이 없습니다.');
      }
      
      // API 요청 모델 생성
      final request = _buildAssignDiscussionGroupsRequest();
      
      if (AppConfig.debugMode) {
        print('💾 [토론 그룹 저장] API 요청 생성: $request');
      }
      
      // API 호출
      await _discussionService.manuallyAssignDiscussionGroups(
        meetingId: meetingId,
        request: request,
        accessToken: accessToken,
      );
      
      if (mounted) {
        setState(() {
          _isEditingDiscussionGroups = false;
          _isSaving = false;
        });
        
        // 성공 메시지
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('토론 그룹이 수정되었습니다. (총 ${request.groups.length}개 그룹)'),
          ),
        );
        
        // 짧은 지연 후 데이터 새로고침
        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted) {
          if (AppConfig.debugMode) {
            print('🔄 [토론 그룹 저장] 데이터 새로고침 시작...');
          }
          await loadDiscussionGroupData(meetingId);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('토론 그룹 수정 실패: $e')),
        );
      }
      
      if (AppConfig.debugMode) {
        print('❌ [토론 그룹 저장] 실패: $e');
      }
    }
  }
  
  /// API 요청 모델 빌더
  AssignDiscussionGroupsRequest _buildAssignDiscussionGroupsRequest() {
    final groups = <DiscussionGroupRequest>[];
    
    // 그룹 번호 순으로 정렬
    final sortedGroupNumbers = _editingGroups.keys.toList()..sort();
    
    for (final groupNumber in sortedGroupNumbers) {
      final members = _editingGroups[groupNumber]!;
      if (members.isNotEmpty) { // 빈 그룹은 제외
        final attendanceIds = members.map((member) => member.attendanceId).toList();
        groups.add(DiscussionGroupRequest(attendanceIdList: attendanceIds));
      }
    }
    
    return AssignDiscussionGroupsRequest(groups: groups);
  }
  
  // ====================
  // 🆕 인원 추가 기능 관련 메서드들
  // ====================
  
  /// 전체 출석자 목록 로드 (ADMIN 급만 호출)
  Future<void> _loadAllAttendanceList(int meetingId) async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final accessToken = await authProvider.accessToken;
      
      if (accessToken == null) {
        if (AppConfig.debugMode) {
          print('❌ [출석자 목록 로드] 액세스 토큰이 없습니다.');
        }
        return;
      }
      
      if (AppConfig.debugMode) {
        print('🚀 [출석자 목록 로드] 시작... meetingId: $meetingId');
      }
      
      final attendanceDetails = await _attendanceService.getMeetingAttendanceStatus(
        meetingId: meetingId,
        accessToken: accessToken,
      );
      
      if (mounted) {
        setState(() {
          _allAttendanceDetails = attendanceDetails;
        });
        
        if (AppConfig.debugMode) {
          print('✅ [출석자 목록 로드] 성공 - 총 출석자: ${attendanceDetails.attendanceList.length}명');
        }
      }
      
    } catch (e) {
      if (AppConfig.debugMode) {
        print('❌ [출석자 목록 로드] 오류: $e');
      }
    }
  }
  
  /// 추가 가능한 인원 목록 반환 (토론 미참여자 중 아직 추가안된 인원)
  List<AttendanceStatus> getAvailableMembersToAdd() {
    if (_allAttendanceDetails == null || _wantDiscussionList == null) {
      if (AppConfig.debugMode) {
        print('⚠️ [추가 가능한 인원] 데이터가 없습니다. allAttendanceDetails=${_allAttendanceDetails != null}, wantDiscussionList=${_wantDiscussionList != null}');
      }
      return [];
    }
    
    // 1. 현재 토론 참여 희망자 ID 집합 (이미 토론에 참여 중인 인원들)
    final wantDiscussionIds = Set<int>.from(
      _wantDiscussionList!.map((member) => member.attendanceId)
    );
    
    // 2. 이미 임시 추가된 인원 ID 집합
    final temporaryAddedIds = Set<int>.from(
      _temporaryAddedMembers.map((member) => member.attendanceId)
    );
    
    // 🆕 3. 편집 중인 모든 그룹에 이미 할당된 인원 ID 집합 (신규 첔크!)
    final editingAssignedIds = Set<int>();
    if (_isEditingDiscussionGroups) {
      // 모든 편집 그룹에서 할당된 인원들 수집
      for (final groupMembers in _editingGroups.values) {
        for (final member in groupMembers) {
          editingAssignedIds.add(member.attendanceId);
        }
      }
      // 미할당 인원들도 수집 (이미 추가된 상태로 보아야 함)
      for (final member in _editingUnassignedMembers) {
        editingAssignedIds.add(member.attendanceId);
      }
    }
    
    if (AppConfig.debugMode) {
      print('🔍 [추가 가능한 인원 필터링]');
      print('   - 전체 출석자: ${_allAttendanceDetails!.attendanceList.length}명');
      print('   - 토론 참여 희망자 ID: $wantDiscussionIds');
      print('   - 임시 추가된 인원 ID: $temporaryAddedIds');
      print('   - 편집 중 할당된 인원 ID: $editingAssignedIds'); // 🆕 신규 로그
    }
    
    // 4. 출석자 중 아직 추가되지 않은 인원만 필터링
    final availableMembers = _allAttendanceDetails!.attendanceList
        .where((attendee) {
          final isNotInOriginalDiscussion = !wantDiscussionIds.contains(attendee.attendanceId);
          final isNotTemporaryAdded = !temporaryAddedIds.contains(attendee.attendanceId);
          final isNotEditingAssigned = !editingAssignedIds.contains(attendee.attendanceId); // 🆕 신규 체크!
          
          if (AppConfig.debugMode) {
            print('   🔍 ${attendee.name}(ID:${attendee.attendanceId}): '
                '원래토론미참여=$isNotInOriginalDiscussion, '
                '임시추가안됨=$isNotTemporaryAdded, '
                '편집중미할당=$isNotEditingAssigned'); // 🆕 신규 로그
          }
          
          return isNotInOriginalDiscussion && isNotTemporaryAdded && isNotEditingAssigned; // 🆕 조건 추가!
        })
        .toList();
    
    if (AppConfig.debugMode) {
      print('✅ [추가 가능한 인원] 총 ${availableMembers.length}명: ${availableMembers.map((m) => m.name).join(", ")}');
    }
    
    return availableMembers;
  }
  
  /// 인원을 토론에 추가 (미할당 인원으로)
  void addMemberToDiscussion(AttendanceStatus attendee) {
    if (!_isEditingDiscussionGroups) return;
    
    // 1. AttendanceStatus를 AttendanceIdAndNameModel로 변환
    final newMember = AttendanceIdAndNameModel(
      attendanceId: attendee.attendanceId,
      memberName: attendee.name,
    );
    
    // 2. 중복 체크
    if (_temporaryAddedMembers.any((member) => member.attendanceId == attendee.attendanceId)) {
      if (AppConfig.debugMode) {
        print('⚠️ [인원 추가] ${attendee.name}님은 이미 추가된 인원입니다.');
      }
      return;
    }
    
    setState(() {
      // 3. 임시 추가된 인원 목록에 추가
      _temporaryAddedMembers.add(newMember);
      
      // 4. 미할당 인원에 직접 추가
      _editingUnassignedMembers.add(newMember);
      
      if (AppConfig.debugMode) {
        print('✅ [인원 추가] ${attendee.name}님을 미할당 인원에 추가했습니다.');
      }
    });
  }

  // ====================
  // 🆕 안내 메시지 메서드들
  // ====================
  
  /// 모임 날짜를 기준으로 편집 제한 메시지 표시
  void _showEditingRestrictedMessage(String sectionName) {
    if (!mounted) return;
    
    final meetingDateStr = _meetingDetail != null 
        ? _formatDate(_meetingDetail!.meetingDateTime)
        : '모임 날짜';
        
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '🗓️ $sectionName 편집 제한\n'
          '모임 다음 날($meetingDateStr 이후)부터는 편집이 불가능합니다.\n'
          '모임 당일까지만 편집할 수 있습니다.',
        ),
        backgroundColor: Colors.orange,
        duration: const Duration(seconds: 5),
      ),
    );
  }
  
  /// 권한 부족 메시지 표시
  void _showPermissionDeniedMessage(String message) {
    if (!mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('❌ $message'),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
