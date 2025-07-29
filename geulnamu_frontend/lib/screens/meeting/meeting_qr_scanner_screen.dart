import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../providers/auth_provider.dart';
import '../../services/attendance/qr_service.dart';
import '../../services/attendance/attendance_service.dart';
import '../../widgets/common/main_layout.dart';
import '../../core/config/app_config.dart';

/// 일반 사용자용 QR 코드 스캔 화면
///
/// 기능:
/// - QR 코드 스캔
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
  late MobileScannerController _scannerController;

  bool _isProcessing = false;
  String? _statusMessage;
  bool _isSuccess = false;

  @override
  void initState() {
    super.initState();
    _scannerController = _qrService.createScannerController();
  }

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  /// 테스트용 QR 스캔 시뮬레이션 (개발 모드에서만 사용)
  void _simulateQrScan() async {
    if (!AppConfig.debugMode) return;

    setState(() {
      _isProcessing = true;
      _statusMessage = '테스트 출석 처리 중...';
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      // 가짜 QR 데이터 생성 (모임 ID 1로 고정)
      const testMeetingId = 1;

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
      if (e.toString().contains('이미 출석')) {
        errorMessage = '이미 출석 처리되었습니다.';
      } else if (e.toString().contains('권한')) {
        errorMessage = '출석 권한이 없습니다.';
      } else if (e.toString().contains('시간')) {
        errorMessage = '출석 가능 시간이 아닙니다.';
      }

      setState(() {
        _statusMessage = errorMessage;
        _isSuccess = false;
        _isProcessing = false;
      });
    }
  }

  /// QR 스캔 결과 처리
  void _handleScanResult(BarcodeCapture capture) async {
    if (_isProcessing) return;

    setState(() {
      _isProcessing = true;
      _statusMessage = '출석 처리 중...';
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      // QR 스캔 결과 파싱
      final scanResult = _qrService.processScanResult(capture);

      if (!scanResult.success) {
        setState(() {
          _statusMessage = scanResult.errorMessage;
          _isSuccess = false;
          _isProcessing = false;
        });
        return;
      }

      final qrData = scanResult.qrData!;

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

      // 에러 메시지 구체화
      if (e.toString().contains('이미 출석')) {
        errorMessage = '이미 출석 처리되었습니다.';
      } else if (e.toString().contains('권한')) {
        errorMessage = '출석 권한이 없습니다.';
      } else if (e.toString().contains('시간')) {
        errorMessage = '출석 가능 시간이 아닙니다.';
      }

      setState(() {
        _statusMessage = errorMessage;
        _isSuccess = false;
        _isProcessing = false;
      });
    }
  }

  /// 다시 스캔하기
  void _resetScanner() {
    setState(() {
      _isProcessing = false;
      _statusMessage = null;
      _isSuccess = false;
    });
    _scannerController.start();
  }

  /// 플래시 토글
  void _toggleFlash() {
    _scannerController.toggleTorch();
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      title: 'QR 출석',
      body: Column(
        children: [
          // 안내 메시지
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.qr_code_scanner,
                  size: 32,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
                const SizedBox(height: 8),

                // 🧪 개발용 테스트 버튼 (디버그 모드에서만 표시)
                if (AppConfig.debugMode) ...[
                  ElevatedButton.icon(
                    onPressed: _simulateQrScan,
                    icon: const Icon(Icons.bug_report),
                    label: const Text('🧪 테스트용 출석 처리'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '개발 테스트용: QR 스캔 없이 출석 처리',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.orange,
                      fontSize: 10,
                    ),
                  ),
                ],
                Text(
                  '📷 운영진의 QR 코드를 스캔해주세요',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '카메라를 QR 코드에 맞춰주시면 자동으로 출석 처리됩니다',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                // 웹 환경 추가 안내
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.surface.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '💻 PC에서 카메라 권한을 허용해주세요',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 스캐너 또는 결과 화면
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              clipBehavior: Clip.hardEdge,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
              ),
              child: _isProcessing || _statusMessage != null
                  ? _buildResultScreen()
                  : _buildScannerScreen(),
            ),
          ),

          // 하단 버튼들
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                if (!_isProcessing && _statusMessage == null) ...[
                  // 플래시 버튼
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: _toggleFlash,
                        icon: const Icon(Icons.flash_on),
                        iconSize: 32,
                        style: IconButton.styleFrom(
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.surface,
                          foregroundColor: Theme.of(
                            context,
                          ).colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text('플래시', style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                ] else if (_statusMessage != null && !_isSuccess) ...[
                  // 다시 스캔 버튼
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _resetScanner,
                      icon: const Icon(Icons.refresh),
                      label: const Text('다시 스캔하기'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 8),

                // 도움말
                Text(
                  '💡 QR 코드가 잘 보이지 않으면 플래시를 켜보세요',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.6),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 스캐너 화면
  Widget _buildScannerScreen() {
    return Stack(
      children: [
        // 카메라 뷰
        MobileScanner(
          controller: _scannerController,
          onDetect: _handleScanResult,
        ),

        // 스캔 가이드 오버레이
        Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: Theme.of(context).colorScheme.primary,
              width: 2,
            ),
          ),
          child: Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(
                  color: Theme.of(context).colorScheme.primary,
                  width: 3,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),

        // 상단 안내 텍스트
        Positioned(
          top: 20,
          left: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.7),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'QR 코드를 네모 안에 맞춰주세요',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
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
