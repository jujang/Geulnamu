import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ai_barcode_scanner/ai_barcode_scanner.dart';
import '../../providers/auth_provider.dart';
import '../../services/attendance/qr_service.dart';
import '../../services/attendance/attendance_service.dart';
import '../../services/home/home_service.dart';
import '../../widgets/common/main_layout.dart';
import '../../core/config/app_config.dart';
import '../../models/attendance/qr_data.dart';

/// 일반 사용자용 QR 코드 스캔 화면
///
/// 기능:
/// - QR 코드 스캔 (웹/모바일 모두 지원)
/// - 출석 처리
/// - 스캔 결과 피드백
class MeetingQrScannerScreen extends StatefulWidget {
  const MeetingQrScannerScreen({super.key});

  @override
  State<MeetingQrScannerScreen> createState() => _MeetingQrScannerScreenState();
}

class _MeetingQrScannerScreenState extends State<MeetingQrScannerScreen> {
  final QrService _qrService = QrService();
  final AttendanceService _attendanceService = AttendanceService();
  final HomeService _homeService = HomeService();

  bool _isProcessing = false;
  String? _statusMessage;
  bool _isSuccess = false;
  bool _scannerActive = true; // 스캐너 활성 상태

  /// 테스트용 QR 스캔 시뮬레이션 (개발 모드에서만 사용)
  void _simulateQrScan() async {
    if (!AppConfig.debugMode) return;

    // 테스트용 모임 ID 선언
    const int testMeetingId = 1;

    setState(() {
      _isProcessing = true;
      _statusMessage = '테스트 출석 처리 중...';
      _scannerActive = false; // 스캐너 비활성화
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      if (AppConfig.debugMode) {
        print('🧪 [테스트 QR] 모의 출석 처리: 모임 ID $testMeetingId');
      }

      // AccessToken 가져오기
      final accessToken = await authProvider.accessToken;
      if (accessToken == null || accessToken.isEmpty) {
        setState(() {
          _statusMessage = '로그인이 필요합니다.';
          _isSuccess = false;
          _isProcessing = false;
          _scannerActive = true;
        });
        return;
      }

      // 출석 처리 API 호출
      final attendanceId = await _attendanceService.checkIn(
        meetingId: testMeetingId,
        accessToken: accessToken,
      );

      if (AppConfig.debugMode) {
        print('🧪 [테스트 출석] 성공: 출석 ID $attendanceId');
      }

      setState(() {
        _statusMessage = '🎉 테스트 출석이 완료되었습니다!';
        _isSuccess = true;
        _isProcessing = false;
      });

      // 3초 후 자동으로 이전 화면으로 돌아가기
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          Navigator.of(context).pop(true); // 출석 성공 여부 전달
        }
      });
    } catch (e) {
      if (AppConfig.debugMode) {
        print('🧪 [테스트 출석] 실패: $e');
      }

      String errorMessage = '테스트 출석 처리 중 오류가 발생했습니다.';

      // 에러 메시지 구체화
      if (e.toString().contains('이미 출석') || e.toString().contains('중복으로 출석')) {
        // 중복 출석 시 상세 다이얼로그 표시
        _showDuplicateAttendanceDialog(context, testMeetingId, e.toString());
        return; // 다이얼로그를 표시하기 때문에 setState는 하지 않음
      } else if (e.toString().contains('권한')) {
        errorMessage = '출석 권한이 없습니다.';
      } else if (e.toString().contains('시간')) {
        errorMessage = '출석 가능 시간이 아닙니다.';
      }

      setState(() {
        _statusMessage = errorMessage;
        _isSuccess = false;
        _isProcessing = false;
        _scannerActive = true;
      });
    }
  }

  /// QR 스캔 결과 처리
  void _handleScanResult(BarcodeCapture capture) async {
    if (_isProcessing || !_scannerActive) return;

    // QR 데이터 추출
    final String? scannedValue = capture.barcodes.firstOrNull?.rawValue;
    
    if (scannedValue == null || scannedValue.isEmpty) {
      if (AppConfig.debugMode) {
        print('⚠️ [QR 스캔] 빈 데이터');
      }
      return;
    }

    if (AppConfig.debugMode) {
      print('📱 [QR 스캔] 원본 데이터: $scannedValue');
    }

    setState(() {
      _isProcessing = true;
      _statusMessage = '출석 처리 중...';
      _scannerActive = false; // 스캐너 비활성화
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      // QR 데이터 파싱
      final QrData? qrData = _qrService.parseQrData(scannedValue);

      if (qrData == null) {
        setState(() {
          _statusMessage = '올바르지 않은 QR 코드입니다.';
          _isSuccess = false;
          _isProcessing = false;
          _scannerActive = true;
        });
        return;
      }

      if (AppConfig.debugMode) {
        print('✅ [QR 스캔] 성공: 모임 ID ${qrData.meetingId}');
      }

      // AccessToken 가져오기
      final accessToken = await authProvider.accessToken;
      if (accessToken == null || accessToken.isEmpty) {
        setState(() {
          _statusMessage = '로그인이 필요합니다.';
          _isSuccess = false;
          _isProcessing = false;
          _scannerActive = true;
        });
        return;
      }

      // 출석 처리 API 호출
      final attendanceId = await _attendanceService.checkIn(
        meetingId: qrData.meetingId,
        accessToken: accessToken,
      );

      if (AppConfig.debugMode) {
        print('✅ [출석 처리] 성공: 출석 ID $attendanceId');
      }

      setState(() {
        _statusMessage = '🎉 출석이 완료되었습니다!';
        _isSuccess = true;
        _isProcessing = false;
      });

      // 3초 후 자동으로 이전 화면으로 돌아가기
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          Navigator.of(context).pop(true); // 출석 성공 여부 전달
        }
      });
    } catch (e) {
      if (AppConfig.debugMode) {
        print('❌ [출석 처리] 실패: $e');
      }

      String errorMessage = '출석 처리 중 오류가 발생했습니다.';
      int? meetingId;

      // QR 데이터 다시 추출 (에러 핸들링용)
      final qrData = _qrService.parseQrData(scannedValue);
      if (qrData != null) {
        meetingId = qrData.meetingId;
      }

      // 에러 메시지 구체화
      if (e.toString().contains('이미 출석') || e.toString().contains('중복으로 출석')) {
        // 중복 출석 시 상세 다이얼로그 표시
        _showDuplicateAttendanceDialog(context, meetingId ?? 0, e.toString());
        return; // 다이얼로그를 표시하기 때문에 setState는 하지 않음
      } else if (e.toString().contains('권한')) {
        errorMessage = '출석 권한이 없습니다.';
      } else if (e.toString().contains('시간')) {
        errorMessage = '출석 가능 시간이 아닙니다.';
      }

      setState(() {
        _statusMessage = errorMessage;
        _isSuccess = false;
        _isProcessing = false;
        _scannerActive = true;
      });
    }
  }

  /// 중복 출석 시 상세 다이얼로그 표시
  void _showDuplicateAttendanceDialog(
    BuildContext context,
    int meetingId,
    String errorMessage,
  ) {
    // 로딩 상태 해제
    setState(() {
      _isProcessing = false;
      _statusMessage = null;
      _isSuccess = false;
      _scannerActive = false; // 다이얼로그 표시 중에는 스캐너 비활성화
    });

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.warning_amber,
                  color: Colors.orange,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '출석 중복 알림',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.orange.shade700,
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 메인 메시지
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.orange.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Colors.orange.shade700,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '이미 출석 처리된 모임입니다',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: Colors.orange.shade800,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(
                          Icons.event,
                          color: Colors.orange.shade600,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '모임번호: $meetingId',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.orange.shade700,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // 상세 설명
              Text(
                '하나의 모임에는 한 번만 출석할 수 있습니다. '
                '모임 상세 페이지에서 출석 상태를 확인해주세요.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 12),
              // 서버 메시지 (디버그 모드에서만)
              if (AppConfig.debugMode) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '디버그 정보:',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        errorMessage,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                // QR 스캔 화면 닫기
                Navigator.pop(context, false);
              },
              child: Text(
                '닫기',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                // 다시 스캔 가능하도록 상태 리셋
                _resetScanner();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
              ),
              child: const Text('다시 시도'),
            ),
          ],
        );
      },
    );
  }

  /// 다시 스캔하기
  void _resetScanner() {
    setState(() {
      _isProcessing = false;
      _statusMessage = null;
      _isSuccess = false;
      _scannerActive = true; // 스캐너 재활성화
    });
  }

  /// 로그아웃 처리 (HomeService 활용)
  Future<void> _handleLogout() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await _homeService.handleLogout(context, authProvider);
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      title: 'QR 출석',
      isHomePage: false, // 뒤로가기 버튼 표시
      onMenuTap: (menu) => _homeService.handleMenuTap(context, menu),
      onLogoutTap: () => _handleLogout(),
      body: _isProcessing || _isSuccess || _statusMessage != null
          ? _buildResultScreen()
          : _buildScannerScreen(),
    );
  }

  /// 스캐너 화면
  Widget _buildScannerScreen() {
    return Stack(
      children: [
        // QR 스캐너
        if (_scannerActive)
          AiBarcodeScanner(
            onDetect: _handleScanResult,
            controller: MobileScannerController(
              detectionSpeed: DetectionSpeed.noDuplicates,
            ),
            validator: (value) {
              // 유효성 검증 (선택적)
              return value.barcodes.isNotEmpty;
            },
          ),

        // 하단 안내 텍스트 + 테스트 버튼
        Positioned(
          bottom: 100,
          left: 0,
          right: 0,
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 32),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'QR 코드를 카메라에 비춰주세요',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              
              // 테스트 버튼 (개발 모드에서만)
              if (AppConfig.debugMode) ...[
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _simulateQrScan,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('🧪 테스트 출석'),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  /// 결과 화면
  Widget _buildResultScreen() {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 상태 아이콘
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: _isSuccess
                      ? Colors.green.withOpacity(0.1)
                      : _isProcessing
                      ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                      : Colors.red.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _isSuccess
                      ? Icons.check_circle
                      : _isProcessing
                      ? Icons.hourglass_empty
                      : Icons.error,
                  size: 48,
                  color: _isSuccess
                      ? Colors.green
                      : _isProcessing
                      ? Theme.of(context).colorScheme.primary
                      : Colors.red,
                ),
              ),

              const SizedBox(height: 24),

              // 상태 메시지
              if (_statusMessage != null)
                Text(
                  _statusMessage!,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: _isSuccess
                        ? Colors.green
                        : _isProcessing
                        ? Theme.of(context).colorScheme.onSurface
                        : Colors.red,
                  ),
                  textAlign: TextAlign.center,
                ),

              const SizedBox(height: 16),

              // 로딩 인디케이터
              if (_isProcessing)
                CircularProgressIndicator(
                  color: Theme.of(context).colorScheme.primary,
                ),

              // 성공 시 추가 메시지
              if (_isSuccess) ...[
                const SizedBox(height: 16),
                Text(
                  '잠시 후 자동으로 이전 화면으로 돌아갑니다',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.6),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
