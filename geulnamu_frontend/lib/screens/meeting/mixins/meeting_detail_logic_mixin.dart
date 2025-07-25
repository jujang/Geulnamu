import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../services/meeting/meeting_service.dart';
import '../../../models/meeting/meeting_detail_model.dart';
import '../../../core/config/app_config.dart';

/// 모임 상세 화면 로직 Mixin
/// 
/// 모임 상세 정보 조회 및 관련 비즈니스 로직 처리
mixin MeetingDetailLogicMixin<T extends StatefulWidget> on State<T> {
  // 서비스
  final MeetingService _meetingService = MeetingService();

  // 상태 관리
  MeetingDetailInfo? _meetingDetail;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isEditing = false; // 비고 편집 모드

  // Getters
  MeetingDetailInfo? get meetingDetail => _meetingDetail;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isEditing => _isEditing;

  /// 초기화 - 모임 상세 정보 로드
  Future<void> initializeMeetingDetail(int meetingId) async {
    await _loadMeetingDetail(meetingId);
  }

  /// 모임 상세 정보 로드
  Future<void> _loadMeetingDetail(int meetingId) async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      if (!authProvider.isAuthenticated) {
        throw Exception('로그인이 필요합니다.');
      }

      if (AppConfig.debugMode) {
        print('🔄 [MeetingDetailLogicMixin] 모임 상세 로드 시작: meetingId=$meetingId');
      }

      final accessToken = await authProvider.accessToken;
      if (accessToken == null) {
        throw Exception('인증 토큰을 가져올 수 없습니다.');
      }

      final detail = await _meetingService.getMeetingDetail(
        meetingId: meetingId,
        accessToken: accessToken,
      );

      if (mounted) {
        setState(() {
          _meetingDetail = detail;
          _isLoading = false;
        });

        if (AppConfig.debugMode) {
          print('✅ [MeetingDetailLogicMixin] 모임 상세 로드 성공: ${detail.meetingName}');
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString();
        });

        if (AppConfig.debugMode) {
          print('❌ [MeetingDetailLogicMixin] 모임 상세 로드 실패: $e');
        }
      }
    }
  }

  /// 새로고침
  Future<void> refreshMeetingDetail(int meetingId) async {
    await _loadMeetingDetail(meetingId);
  }

  /// 비고 편집 모드 토글
  void toggleEditMode() {
    if (!mounted) return;
    
    setState(() {
      _isEditing = !_isEditing;
    });

    if (AppConfig.debugMode) {
      print('🔄 [MeetingDetailLogicMixin] 편집 모드 변경: $_isEditing');
    }
  }

  /// 비고 저장 (향후 구현)
  Future<void> saveNote(String note) async {
    // TODO: 향후 비고 수정 API 구현 시 활성화
    if (AppConfig.debugMode) {
      print('💾 [MeetingDetailLogicMixin] 비고 저장: $note');
    }
    
    // 일단 편집 모드 종료
    toggleEditMode();
    
    // 향후 실제 API 호출 후 새로고침
    // await _updateNote(note);
    // await refreshMeetingDetail();
  }

  /// 비고 편집 취소
  void cancelEdit() {
    if (!mounted) return;
    
    setState(() {
      _isEditing = false;
    });

    if (AppConfig.debugMode) {
      print('❌ [MeetingDetailLogicMixin] 편집 취소');
    }
  }

  /// 모임 정보 수정 페이지로 이동 (운영진용)
  void navigateToMeetingEdit(int meetingId) {
    if (AppConfig.debugMode) {
      print('🔧 [MeetingDetailLogicMixin] 모임 정보 수정 페이지로 이동: meetingId=$meetingId');
    }
    
    // TODO: 향후 모임 수정 페이지 구현 시 활성화
    // Navigator.pushNamed(context, '/meeting/$meetingId/edit');
    
    // 임시 스낵바 표시
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.construction, color: Colors.white),
            SizedBox(width: 8),
            Text('모임 수정 기능은 준비 중입니다.'),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// 권한 확인 - 운영진 이상인지
  bool get isStaffOrAbove {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (!authProvider.isAuthenticated) return false;
    
    return authProvider.isStaffLevel;
  }

  /// 권한 확인 - 관리자인지
  bool get isAdmin {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (!authProvider.isAuthenticated) return false;
    
    return authProvider.isAdminLevel;
  }
}
