import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../services/meeting/meeting_service.dart';
import '../../../models/meeting/request/meeting_create_request.dart';
import '../../../core/config/app_config.dart';

/// 모임 만들기 로직 Mixin
/// 
/// 제공 기능:
/// - 폼 관리 및 검증
/// - 날짜/시간 선택 처리
/// - 지각 시간 자동 설정
/// - API 호출 및 상태 관리
mixin MeetingCreateLogicMixin<T extends StatefulWidget> on State<T> {
  // 🎯 서비스 및 컨트롤러
  final MeetingService _meetingService = MeetingService();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  
  // 📝 텍스트 컨트롤러들
  late final TextEditingController meetingNameController;
  late final TextEditingController meetingPlaceController;
  late final TextEditingController descriptionController;
  late final TextEditingController meetingDateController;
  late final TextEditingController meetingTimeController;
  late final TextEditingController lateDateController;
  late final TextEditingController lateTimeController;
  
  // 📅 날짜/시간 상태
  DateTime? selectedMeetingDate;
  TimeOfDay? selectedMeetingTime;
  DateTime? selectedLateDate;
  TimeOfDay? selectedLateTime;
  
  // 🎨 UI 상태
  MeetingType selectedMeetingType = MeetingType.regular;
  bool isLoading = false;
  
  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }
  
  @override
  void dispose() {
    _disposeControllers();
    super.dispose();
  }
  
  /// 컨트롤러 초기화
  void _initializeControllers() {
    meetingNameController = TextEditingController();
    meetingPlaceController = TextEditingController();
    descriptionController = TextEditingController();
    meetingDateController = TextEditingController();
    meetingTimeController = TextEditingController();
    lateDateController = TextEditingController();
    lateTimeController = TextEditingController();
  }
  
  /// 컨트롤러 정리
  void _disposeControllers() {
    meetingNameController.dispose();
    meetingPlaceController.dispose();
    descriptionController.dispose();
    meetingDateController.dispose();
    meetingTimeController.dispose();
    lateDateController.dispose();
    lateTimeController.dispose();
  }
  
  /// 모임 타입 변경
  void onMeetingTypeChanged(MeetingType type) {
    setState(() {
      selectedMeetingType = type;
    });
    
    if (AppConfig.debugMode) {
      print('🎯 [모임 만들기] 모임 타입 변경: ${type.displayName}');
    }
  }
  
  /// 모임 날짜 선택
  Future<void> selectMeetingDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedMeetingDate ?? DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      helpText: '모임 날짜 선택',
    );
    
    if (picked != null) {
      setState(() {
        selectedMeetingDate = picked;
        meetingDateController.text = _formatDate(picked);
        
        // 지각 기준 날짜도 같은 날로 설정
        selectedLateDate = picked;
        lateDateController.text = _formatDate(picked);
      });
      
      if (AppConfig.debugMode) {
        print('📅 [모임 만들기] 모임 날짜 선택: ${_formatDate(picked)}');
      }
    }
  }
  
  /// 모임 시간 선택
  Future<void> selectMeetingTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedMeetingTime ?? const TimeOfDay(hour: 14, minute: 0),
      helpText: '모임 시간 선택',
    );
    
    if (picked != null) {
      setState(() {
        selectedMeetingTime = picked;
        meetingTimeController.text = _formatTime(picked);
        
        // 지각 기준 시간도 같은 시간으로 설정 (사용자 요구사항)
        selectedLateTime = picked;
        lateTimeController.text = _formatTime(picked);
      });
      
      if (AppConfig.debugMode) {
        print('⏰ [모임 만들기] 모임 시간 선택: ${_formatTime(picked)}');
      }
    }
  }
  
  /// 지각 기준 날짜 선택 (모임 날짜로 고정)
  Future<void> selectLateDate() async {
    // 모임 날짜가 설정되어 있지 않으면 메시지 표시
    if (selectedMeetingDate == null) {
      _showSnackBar('모임 날짜를 먼저 선택해주세요.');
      return;
    }
    
    // 지각 기준 날짜는 모임 날짜와 동일하게 고정
    setState(() {
      selectedLateDate = selectedMeetingDate;
      lateDateController.text = _formatDate(selectedMeetingDate!);
    });
    
    _showSnackBar('지각 기준 날짜는 모임 날짜와 동일하게 설정됩니다.');
  }
  
  /// 지각 기준 시간 선택
  Future<void> selectLateTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedLateTime ?? selectedMeetingTime ?? const TimeOfDay(hour: 14, minute: 0),
      helpText: '지각 기준 시간 선택',
    );
    
    if (picked != null) {
      // 모임 시간보다 빠른 지 검증
      if (selectedMeetingTime != null) {
        final meetingMinutes = selectedMeetingTime!.hour * 60 + selectedMeetingTime!.minute;
        final lateMinutes = picked.hour * 60 + picked.minute;
        
        if (lateMinutes < meetingMinutes) {
          _showSnackBar('지각 기준 시간은 모임 시간보다 빠를 수 없습니다.');
          return;
        }
      }
      
      setState(() {
        selectedLateTime = picked;
        lateTimeController.text = _formatTime(picked);
      });
      
      if (AppConfig.debugMode) {
        print('⏰ [모임 만들기] 지각 기준 시간 선택: ${_formatTime(picked)}');
      }
    }
  }
  
  /// 모임 생성 처리
  Future<void> handleCreateMeeting() async {
    if (!formKey.currentState!.validate()) {
      return;
    }
    
    if (selectedMeetingDate == null || selectedMeetingTime == null) {
      _showSnackBar('모임 날짜와 시간을 모두 선택해주세요.');
      return;
    }
    
    setState(() {
      isLoading = true;
    });
    
    try {
      // 🔧 MeetingService 초기화 확인
      _meetingService.initialize();
      
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      // AccessToken 가져오기
      final accessToken = await authProvider.accessToken;
      if (accessToken == null) {
        _showSnackBar('인증 토큰이 없습니다. 다시 로그인해주세요.');
        return;
      }
      
      // DateTime 조합
      final meetingDateTime = DateTime(
        selectedMeetingDate!.year,
        selectedMeetingDate!.month,
        selectedMeetingDate!.day,
        selectedMeetingTime!.hour,
        selectedMeetingTime!.minute,
      );
      
      // 지각 기준 시간 (선택된 경우만)
      DateTime? lateDateTime;
      if (selectedLateDate != null && selectedLateTime != null) {
        lateDateTime = DateTime(
          selectedLateDate!.year,
          selectedLateDate!.month,
          selectedLateDate!.day,
          selectedLateTime!.hour,
          selectedLateTime!.minute,
        );
      }
      
      // 요청 모델 생성
      final request = MeetingCreateRequest(
        meetingType: selectedMeetingType.apiValue,
        meetingName: meetingNameController.text.trim(),
        meetingDate: MeetingCreateRequest.formatDateTime(meetingDateTime),
        lateThresholdTime: lateDateTime != null 
          ? MeetingCreateRequest.formatDateTime(lateDateTime) 
          : null,
        meetingPlace: meetingPlaceController.text.trim(),
        description: descriptionController.text.isNotEmpty 
          ? descriptionController.text.trim() 
          : null,
      );
      
      // API 호출
      final meetingId = await _meetingService.createMeeting(
        request: request,
        accessToken: accessToken,
      );
      
      if (AppConfig.debugMode) {
        print('✅ [모임 만들기] 모임 생성 완료 - ID: $meetingId');
      }
      
      // 성공 메시지 및 목록으로 돌아가기
      _showSnackBar('모임이 성공적으로 생성되었습니다!');
      
      // 딜레이 후 뒤로가기
      await Future.delayed(const Duration(milliseconds: 1500));
      if (mounted) {
        Navigator.pop(context, true); // true: 새로고침 필요함을 알림
      }
      
    } catch (e) {
      if (AppConfig.debugMode) {
        print('❌ [모임 만들기] 모임 생성 실패: $e');
      }
      
      _showSnackBar('모임 생성에 실패했습니다: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }
  
  /// 폼 유효성 검증
  String? validateMeetingName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return '모임 제목을 입력해주세요';
    }
    
    if (value.trim().length > 70) {
      return '모임 제목은 70자 이하로 입력해주세요';
    }
    
    // 백엔드 정규식과 일치하는 검증
    final regex = RegExp(r'^[ㄱ-ㅎ가-힣a-zA-Z0-9\s:/@\[\]()~_-]{1,70}$');
    if (!regex.hasMatch(value.trim())) {
      return '한글, 영문, 숫자, 공백 및 일부 특수문자만 사용 가능합니다';
    }
    
    return null;
  }
  
  /// 실시간 폼 유효성 검사 트리거
  void _revalidateForm() {
    if (formKey.currentState != null) {
      formKey.currentState!.validate();
    }
  }
  
  String? validateMeetingPlace(String? value) {
    if (value == null || value.trim().isEmpty) {
      return '모임 장소를 입력해주세요';
    }
    
    if (value.trim().length > 255) {
      return '모임 장소는 255자 이하로 입력해주세요';
    }
    
    // 백엔드 정규식과 일치하는 검증
    final regex = RegExp(r'^[ㄱ-ㅎ가-힣a-zA-Z0-9\s:/@\[\]()~_-]{1,255}$');
    if (!regex.hasMatch(value.trim())) {
      return '한글, 영문, 숫자, 공백 및 일부 특수문자만 사용 가능합니다';
    }
    
    return null;
  }
  
  /// 날짜 포맷팅
  String _formatDate(DateTime date) {
    return '${date.year}년 ${date.month.toString().padLeft(2, '0')}월 ${date.day.toString().padLeft(2, '0')}일';
  }
  
  /// 시간 포맷팅
  String _formatTime(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
  
  /// 스낵바 표시
  void _showSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }
}
