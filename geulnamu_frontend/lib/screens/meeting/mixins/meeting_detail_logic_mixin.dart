import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../services/meeting/meeting_service.dart';
import '../../../services/attendance/attendance_service.dart';
import '../../../models/meeting/meeting_detail_model.dart';
import '../../../models/attendance/request/attendance_note_request.dart';
import '../../../core/config/app_config.dart';

/// 모임 상세 화면 로직 Mixin
///
/// 모임 상세 정보 조회 및 관련 비즈니스 로직 처리
mixin MeetingDetailLogicMixin<T extends StatefulWidget> on State<T> {
  // 서비스
  final MeetingService _meetingService = MeetingService();
  final AttendanceService _attendanceService = AttendanceService();

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
          print(
            '✅ [MeetingDetailLogicMixin] 모임 상세 로드 성공: ${detail.meetingName}',
          );
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

  /// 비고 저장
  Future<void> saveNote(String note) async {
    if (!mounted) return;

    // 출석 ID가 없으면 저장 불가
    if (_meetingDetail?.attendanceId == null) {
      _showSnackBar('출석 정보가 없어 비고를 저장할 수 없습니다.', isError: true);
      return;
    }

    // 비고 유효성 검사
    final request = AttendanceNoteRequest(note: note.trim());
    final validationError = request.getValidationError();
    if (validationError != null) {
      _showSnackBar(validationError, isError: true);
      return;
    }

    try {
      if (AppConfig.debugMode) {
        print('💾 [MeetingDetailLogicMixin] 비고 저장 시작: $note');
      }

      // 로딩 상태 시작
      setState(() {
        _isLoading = true;
      });

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final accessToken = await authProvider.accessToken;

      if (accessToken == null) {
        throw Exception('인증 토큰을 가져올 수 없습니다.');
      }

      // 비고 저장 API 호출
      await _attendanceService.writeNote(
        attendanceId: _meetingDetail!.attendanceId!,
        note: note.trim(),
        accessToken: accessToken,
      );

      if (AppConfig.debugMode) {
        print('✅ [MeetingDetailLogicMixin] 비고 저장 성공');
      }

      // 편집 모드 종료 및 로딩 상태 해제
      if (mounted) {
        setState(() {
          _isEditing = false;
          _isLoading = false;
        });
      }

      // 성공 메시지 표시
      _showSnackBar('비고가 저장되었습니다.');

      // 모임 상세 정보 새로고침
      if (_meetingDetail != null) {
        await refreshMeetingDetail(_meetingDetail!.meetingId);
      }
    } catch (e) {
      if (AppConfig.debugMode) {
        print('❌ [MeetingDetailLogicMixin] 비고 저장 실패: $e');
      }

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }

      // 에러 메시지 표시
      final errorMessage = e
          .toString()
          .replaceAll('Exception: ', '')
          .replaceAll('[비고 작성] ', '');
      _showSnackBar(errorMessage, isError: true);
    }
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

  /// 스낵바 표시 헬퍼 메서드
  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle_outline,
              color: Colors.white,
            ),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: isError
            ? Theme.of(context).colorScheme.error
            : Theme.of(context).colorScheme.primary,
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: isError ? 4 : 2),
      ),
    );
  }

  /// 확인 다이얼로그 표시 헬퍼 메서드
  Future<bool> _showConfirmDialog({
    required String title,
    required String message,
    String confirmText = '확인',
    String cancelText = '취소',
  }) async {
    if (!mounted) return false;

    final result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(cancelText),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(confirmText),
            ),
          ],
        );
      },
    );

    return result ?? false;
  }

  /// 모임 정보 수정 페이지로 이동 (운영진용)
  void navigateToMeetingEdit(int meetingId) {
    if (AppConfig.debugMode) {
      print(
        '🔧 [MeetingDetailLogicMixin] 모임 정보 수정 페이지로 이동: meetingId=$meetingId',
      );
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

  /// 토론 참여 상태 토글
  ///
  /// 현재 wantDiscussion 상태에 따라 반대 상태로 변경
  /// - true(토론할래요) → false(독서만 할래요)
  /// - false(독서만 할래요) → true(토론할래요)
  Future<void> toggleDiscussionParticipation() async {
    if (!mounted) return;

    // 출석 ID가 없으면 변경 불가
    if (_meetingDetail?.attendanceId == null) {
      _showSnackBar('출석한 모임에서만 토론 참여 상태를 변경할 수 있습니다.', isError: true);
      return;
    }

    // 토론 시간이 설정되지 않았으면 변경 불가 (🆕 추가)
    if (_meetingDetail?.discussionTime == null) {
      _showSnackBar('토론 시간이 설정된 모임에서만 참여 상태를 변경할 수 있습니다.', isError: true);
      return;
    }

    // 토론 시작 30분 전까지만 변경 가능 (🆕 시간 제한 추가)
    if (!_isDiscussionChangeAllowedByTime()) {
      final remainingTime = discussionChangeTimeRemaining;
      if (remainingTime != null) {
        _showSnackBar('토론 시작 30분 전까지만 참여 의사를 변경할 수 있습니다. ($remainingTime)', isError: true);
      } else {
        _showSnackBar('토론 시작 30분 전까지만 참여 의사를 변경할 수 있습니다.', isError: true);
      }
      return;
    }

    // 현재 상태 확인
    final currentWantDiscussion = _meetingDetail?.wantDiscussion;
    if (currentWantDiscussion == null) {
      _showSnackBar('토론 참여 상태를 확인할 수 없습니다.', isError: true);
      return;
    }

    // 변경될 상태 메시지
    final willWantDiscussion = !currentWantDiscussion;
    final actionMessage = willWantDiscussion ? '토론에 참여하시겠어요?' : '독서만 하시겠어요?';
    final confirmMessage = willWantDiscussion
        ? '토론 참여로 변경하시겠습니까?'
        : '독서만 하기로 변경하시겠습니까?';

    // 확인 다이얼로그 표시
    final confirmed = await _showConfirmDialog(
      title: '토론 참여 상태 변경',
      message: confirmMessage,
      confirmText: '변경',
      cancelText: '취소',
    );

    if (!confirmed) return;

    try {
      if (AppConfig.debugMode) {
        print(
          '🔄 [MeetingDetailLogicMixin] 토론 상태 변경 시작: $currentWantDiscussion → $willWantDiscussion',
        );
      }

      // 로딩 상태 시작
      setState(() {
        _isLoading = true;
      });

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final accessToken = await authProvider.accessToken;

      if (accessToken == null) {
        throw Exception('인증 토큰을 가져올 수 없습니다.');
      }

      // 현재 상태에 따라 적절한 API 호출
      if (currentWantDiscussion) {
        // 현재 토론 참여 → 독서만 하기로 변경
        await _attendanceService.setJustRead(
          attendanceId: _meetingDetail!.attendanceId!,
          accessToken: accessToken,
        );
      } else {
        // 현재 독서만 → 토론 참여로 변경
        await _attendanceService.setWantDiscussion(
          attendanceId: _meetingDetail!.attendanceId!,
          accessToken: accessToken,
        );
      }

      if (AppConfig.debugMode) {
        print('✅ [MeetingDetailLogicMixin] 토론 상태 변경 성공');
      }

      // 로딩 상태 해제
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }

      // 성공 메시지 표시
      _showSnackBar('토론 참여 상태가 변경되었습니다.');

      // 모임 상세 정보 새로고침
      if (_meetingDetail != null) {
        await refreshMeetingDetail(_meetingDetail!.meetingId);
      }
    } catch (e) {
      if (AppConfig.debugMode) {
        print('❌ [MeetingDetailLogicMixin] 토론 상태 변경 실패: $e');
      }

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }

      // 에러 메시지 표시
      final errorMessage = e
          .toString()
          .replaceAll('Exception: ', '')
          .replaceAll('[독서만 할래요] ', '')
          .replaceAll('[토론할래요] ', '');
      _showSnackBar(errorMessage, isError: true);
    }
  }

  /// 토론 참여 상태 변경 가능 여부
  bool get canChangeDiscussionParticipation {
    // 출석ID가 있고, wantDiscussion 값이 있고, 토론 시간이 설정된 경우에만 가능
    if (_meetingDetail?.attendanceId == null ||
        _meetingDetail?.wantDiscussion == null ||
        _meetingDetail?.discussionTime == null) {
      return false;
    }

    // 토론 시작 30분 전까지만 변경 가능 (🆕 시간 제한 추가)
    return _isDiscussionChangeAllowedByTime();
  }

  /// 토론 참여 상태 변경 시간 체크
  /// 
  /// 토론 시작 30분 전까지만 변경 가능
  bool _isDiscussionChangeAllowedByTime() {
    final discussionTime = _meetingDetail?.discussionTime;
    if (discussionTime == null) return false;

    final now = DateTime.now();
    final changeDeadline = discussionTime.subtract(const Duration(minutes: 30));

    if (AppConfig.debugMode) {
      print('🕰️ [MeetingDetailLogicMixin] 토론 시간 체크:');
      print('   현재 시간: ${now.toString()}');
      print('   토론 시간: ${discussionTime.toString()}');
      print('   변경 마감 시간: ${changeDeadline.toString()}');
      print('   변경 가능 여부: ${now.isBefore(changeDeadline)}');
    }

    return now.isBefore(changeDeadline);
  }

  /// 토론 참여 상태 변경 마감까지 남은 시간 문자열
  String? get discussionChangeTimeRemaining {
    final discussionTime = _meetingDetail?.discussionTime;
    if (discussionTime == null) return null;

    final now = DateTime.now();
    final changeDeadline = discussionTime.subtract(const Duration(minutes: 30));
    
    if (now.isAfter(changeDeadline)) {
      return null; // 이미 마감
    }

    final remaining = changeDeadline.difference(now);
    final hours = remaining.inHours;
    final minutes = remaining.inMinutes % 60;

    if (hours > 0) {
      return '약 ${hours}시간 ${minutes}분 후 변경 불가';
    } else {
      return '약 ${minutes}분 후 변경 불가';
    }
  }

  /// 권한 확인 - 관리자인지
  bool get isAdmin {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (!authProvider.isAuthenticated) return false;

    return authProvider.isAdminLevel;
  }
}
