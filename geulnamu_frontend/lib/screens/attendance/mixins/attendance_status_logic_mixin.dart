import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../services/attendance/attendance_service.dart';
import '../../../models/attendance/attendance_status_model.dart';
import '../../../core/config/app_config.dart';

/// 출석 현황 화면 로직 Mixin
///
/// 출석 현황 조회, 새로고침 등의 비즈니스 로직 담당
mixin AttendanceStatusLogicMixin<T extends StatefulWidget> on State<T> {
  final AttendanceService _attendanceService = AttendanceService();

  // 상태 변수들
  bool _isLoading = false;
  String? _errorMessage;
  MeetingAttendanceDetails? _attendanceDetails;
  int? _currentMeetingId;

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  MeetingAttendanceDetails? get attendanceDetails => _attendanceDetails;
  AttendanceSummary? get summary => _attendanceDetails?.summary;
  List<AttendanceStatus> get attendanceList => _attendanceDetails?.attendanceList ?? [];

  /// 출석 현황 초기 로드
  /// 
  /// [meetingId] 모임 ID
  Future<void> initializeAttendanceStatus(int meetingId) async {
    _currentMeetingId = meetingId;
    await loadAttendanceStatus(showLoading: true);
  }

  /// 출석 현황 조회
  ///
  /// [showLoading] 로딩 표시 여부
  Future<void> loadAttendanceStatus({bool showLoading = false}) async {
    if (_currentMeetingId == null) return;

    try {
      if (showLoading) {
        _setLoading(true);
      }
      _clearError();

      final accessToken = await _getAccessToken();
      if (accessToken == null) {
        throw Exception('인증 토큰을 가져올 수 없습니다.');
      }

      final response = await _attendanceService.getMeetingAttendanceStatus(
        meetingId: _currentMeetingId!,
        accessToken: accessToken,
      );

      _attendanceDetails = response;

      if (AppConfig.debugMode) {
        print('✅ [AttendanceStatusLogicMixin] 출석 현황 로드 성공');
        print('📊 [AttendanceStatusLogicMixin] 출석자: ${response.attendanceList.length}명');
      }
    } catch (e) {
      _setError(_getErrorMessage(e));
      if (AppConfig.debugMode) {
        print('❌ [AttendanceStatusLogicMixin] 출석 현황 로드 실패: $e');
      }
    } finally {
      if (showLoading) {
        _setLoading(false);
      }
    }
  }

  /// 새로고침
  Future<void> refreshAttendanceStatus() async {
    if (AppConfig.debugMode) {
      print('🔄 [AttendanceStatusLogicMixin] 출석 현황 새로고침 시작');
    }
    await loadAttendanceStatus(showLoading: false);
  }

  /// Pull-to-refresh 새로고침
  Future<void> onRefresh() async {
    await refreshAttendanceStatus();
  }

  /// 출석 삭제
  /// 
  /// [attendanceId] 삭제할 출석 ID
  /// [attendeeName] 출석자 이름 (로그용)
  Future<void> deleteAttendance(int attendanceId, String attendeeName) async {
    try {
      final accessToken = await _getAccessToken();
      if (accessToken == null) {
        throw Exception('인증 토큰을 가져올 수 없습니다.');
      }

      if (AppConfig.debugMode) {
        print('🗑️ [AttendanceStatusLogicMixin] 출석 삭제 시작: $attendeeName (ID: $attendanceId)');
      }

      await _attendanceService.deleteAttendance(
        attendanceId: attendanceId,
        accessToken: accessToken,
      );

      if (AppConfig.debugMode) {
        print('✅ [AttendanceStatusLogicMixin] 출석 삭제 성공: $attendeeName');
      }

      // 삭제 성공 후 전체 새로고침
      await refreshAttendanceStatus();

    } catch (e) {
      if (AppConfig.debugMode) {
        print('❌ [AttendanceStatusLogicMixin] 출석 삭제 실패: $e');
      }
      rethrow;
    }
  }

  // ==================== Private Methods ====================

  /// 로딩 상태 설정
  void _setLoading(bool loading) {
    if (mounted) {
      setState(() {
        _isLoading = loading;
      });
    }
  }

  /// 에러 상태 설정
  void _setError(String error) {
    if (mounted) {
      setState(() {
        _errorMessage = error;
      });
    }
  }

  /// 에러 상태 초기화
  void _clearError() {
    if (mounted) {
      setState(() {
        _errorMessage = null;
      });
    }
  }

  /// 액세스 토큰 가져오기
  Future<String?> _getAccessToken() async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      return authProvider.accessToken;
    } catch (e) {
      if (AppConfig.debugMode) {
        print('❌ [AttendanceStatusLogicMixin] 액세스 토큰 가져오기 실패: $e');
      }
      return null;
    }
  }

  /// 에러 메시지 생성
  String _getErrorMessage(dynamic error) {
    if (error is Exception) {
      final message = error.toString();
      if (message.contains('백엔드 오류')) {
        // ApiUtils에서 처리된 백엔드 오류 메시지 그대로 사용
        return message.replaceFirst('Exception: ', '');
      }
    }
    return '출석 현황을 불러오는 중 오류가 발생했습니다.';
  }
}
