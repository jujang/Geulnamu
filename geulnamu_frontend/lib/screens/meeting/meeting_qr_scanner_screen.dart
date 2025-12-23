import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../providers/auth_provider.dart';
import '../../services/attendance/qr_service.dart';
import '../../services/attendance/attendance_service.dart';
import '../../services/home/home_service.dart';
import '../../services/notification/fcm_service.dart';
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
  final FcmService _fcmService = FcmService();

  // 스캐너 컨트롤러
  MobileScannerController? _scannerController;

  // 해상도 설정
  static const Size _fhdResolution = Size(1920, 1080); // Full HD

  bool _isProcessing = false;
  String? _statusMessage;
  bool _isSuccess = false;
  bool _scannerActive = true;
  bool _isInitializing = true;

  @override
  void initState() {
    super.initState();
    _initScanner();
  }

  /// 스캐너 초기화 (FHD 시도 → 실패 시 기본 해상도)
  Future<void> _initScanner() async {
    setState(() {
      _isInitializing = true;
    });

    // 1차 시도: FHD 해상도
    bool success = await _tryInitWithFHD();

    // 2차 시도: 기본 해상도 (FHD 실패 시)
    if (!success) {
      if (AppConfig.debugMode) {
        print('📷 [카메라] 기본 해상도로 초기화...');
      }
      _scannerController = MobileScannerController(
        detectionSpeed: DetectionSpeed.noDuplicates,
        formats: [BarcodeFormat.qrCode],
      );
    }

    if (mounted) {
      setState(() {
        _isInitializing = false;
      });
    }
  }

  /// FHD 해상도로 스캐너 초기화 시도
  Future<bool> _tryInitWithFHD() async {
    try {
      if (AppConfig.debugMode) {
        print('📷 [카메라] FHD (1920x1080) 초기화 시도...');
      }

      final controller = MobileScannerController(
        detectionSpeed: DetectionSpeed.noDuplicates,
        formats: [BarcodeFormat.qrCode],
        cameraResolution: _fhdResolution,
      );

      // 카메라 시작 시도
      await controller.start();

      _scannerController = controller;

      if (AppConfig.debugMode) {
        print('✅ [카메라] FHD 해상도 초기화 성공!');
      }

      return true;
    } catch (e) {
      if (AppConfig.debugMode) {
        print('⚠️ [카메라] FHD 해상도 실패: $e');
      }
      return false;
    }
  }

  @override
  void dispose() {
    _scannerController?.dispose();
    super.dispose();
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
      _scannerActive = false;
    });

    // 스캐너 일시 정지
    _scannerController?.stop();

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
        _scannerController?.start();
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
        _scannerController?.start();
        return;
      }

      // FCM 토큰 가져오기 (푸시 알림용)
      final fcmToken = _fcmService.currentToken;
      if (AppConfig.debugMode) {
        print('📱 [QR 출석] FCM 토큰: ${fcmToken != null ? "있음" : "없음"}');
      }

      // 출석 처리 API 호출 (FCM 토큰 포함)
      final attendanceId = await _attendanceService.checkIn(
        meetingId: qrData.meetingId,
        accessToken: accessToken,
        fcmToken: fcmToken,
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
          // 🎯 GoRouter: pop으로 이전 화면으로 돌아가기
          context.pop(true);
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
      if (e.toString().contains('이미 출석') ||
          e.toString().contains('중복으로 출석')) {
        _showDuplicateAttendanceDialog(context, meetingId ?? 0, e.toString());
        return;
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
      _scannerController?.start();
    }
  }

  /// 중복 출석 시 상세 다이얼로그 표시
  void _showDuplicateAttendanceDialog(
    BuildContext context,
    int meetingId,
    String errorMessage,
  ) {
    setState(() {
      _isProcessing = false;
      _statusMessage = null;
      _isSuccess = false;
      _scannerActive = false;
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
                  color: Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
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
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.orange.withValues(alpha: 0.3),
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
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
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
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
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
              Text(
                '하나의 모임에는 한 번만 출석할 수 있습니다. '
                '모임 상세 페이지에서 출석 상태를 확인해주세요.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                      height: 1.5,
                    ),
              ),
              if (AppConfig.debugMode) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .surfaceContainerHighest
                        .withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '디버그 정보:',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        errorMessage,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
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
                // 🎯 GoRouter: pop으로 이전 화면으로 돌아가기
                this.context.pop(false);
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
      _scannerActive = true;
    });
    _scannerController?.start();
  }

  /// 로그아웃 처리
  Future<void> _handleLogout() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await _homeService.handleLogout(context, authProvider);
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      title: 'QR 출석',
      isHomePage: false,
      onMenuTap: (menu) => _homeService.handleMenuTap(context, menu),
      onLogoutTap: () => _handleLogout(),
      body: _isProcessing || _isSuccess || _statusMessage != null
          ? _buildResultScreen()
          : _buildScannerScreen(),
    );
  }

  /// 스캐너 화면
  Widget _buildScannerScreen() {
    // 초기화 중 로딩 표시
    if (_isInitializing) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              '카메라 초기화 중...',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      );
    }

    return Stack(
      children: [
        // 카메라 프리뷰 (전체 화면)
        if (_scannerActive && _scannerController != null)
          MobileScanner(
            controller: _scannerController!,
            onDetect: _handleScanResult,
          ),

        // QR 스캔 영역 오버레이
        _buildScanOverlay(),

        // 하단 안내 텍스트
        Positioned(
          bottom: 80,
          left: 0,
          right: 0,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 32),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Text(
              'QR 코드를 프레임 안에 맞춰주세요',
              style: TextStyle(
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

  /// QR 스캔 영역 오버레이 (테두리만 표시, 배경 반투명)
  Widget _buildScanOverlay() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final scanAreaSize = constraints.maxWidth * 0.7;
        final horizontalPadding = (constraints.maxWidth - scanAreaSize) / 2;
        final verticalPadding = (constraints.maxHeight - scanAreaSize) / 2 - 40;

        return Stack(
          children: [
            // 반투명 배경 (스캔 영역 제외)
            ColorFiltered(
              colorFilter: ColorFilter.mode(
                Colors.black.withValues(alpha: 0.5),
                BlendMode.srcOut,
              ),
              child: Stack(
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      color: Colors.black,
                      backgroundBlendMode: BlendMode.dstOut,
                    ),
                  ),
                  Positioned(
                    left: horizontalPadding,
                    top: verticalPadding,
                    child: Container(
                      width: scanAreaSize,
                      height: scanAreaSize,
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 스캔 영역 테두리 (코너만)
            Positioned(
              left: horizontalPadding,
              top: verticalPadding,
              child: _buildCornerBorder(scanAreaSize),
            ),
          ],
        );
      },
    );
  }

  /// 코너 테두리 위젯
  Widget _buildCornerBorder(double size) {
    const cornerLength = 30.0;
    const borderWidth = 4.0;
    final borderColor = Theme.of(context).colorScheme.primary;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        children: [
          // 좌상단
          Positioned(
            left: 0,
            top: 0,
            child: _buildCorner(
              cornerLength,
              borderWidth,
              borderColor,
              topLeft: true,
            ),
          ),
          // 우상단
          Positioned(
            right: 0,
            top: 0,
            child: _buildCorner(
              cornerLength,
              borderWidth,
              borderColor,
              topRight: true,
            ),
          ),
          // 좌하단
          Positioned(
            left: 0,
            bottom: 0,
            child: _buildCorner(
              cornerLength,
              borderWidth,
              borderColor,
              bottomLeft: true,
            ),
          ),
          // 우하단
          Positioned(
            right: 0,
            bottom: 0,
            child: _buildCorner(
              cornerLength,
              borderWidth,
              borderColor,
              bottomRight: true,
            ),
          ),
        ],
      ),
    );
  }

  /// 개별 코너 위젯
  Widget _buildCorner(
    double length,
    double width,
    Color color, {
    bool topLeft = false,
    bool topRight = false,
    bool bottomLeft = false,
    bool bottomRight = false,
  }) {
    return SizedBox(
      width: length,
      height: length,
      child: CustomPaint(
        painter: _CornerPainter(
          color: color,
          strokeWidth: width,
          topLeft: topLeft,
          topRight: topRight,
          bottomLeft: bottomLeft,
          bottomRight: bottomRight,
        ),
      ),
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
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: _isSuccess
                      ? Colors.green.withValues(alpha: 0.1)
                      : _isProcessing
                          ? Theme.of(context)
                              .colorScheme
                              .primary
                              .withValues(alpha: 0.1)
                          : Colors.red.withValues(alpha: 0.1),
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
              if (_isProcessing)
                CircularProgressIndicator(
                  color: Theme.of(context).colorScheme.primary,
                ),
              if (_isSuccess) ...[
                const SizedBox(height: 16),
                Text(
                  '잠시 후 자동으로 이전 화면으로 돌아갑니다',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.6),
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

/// 코너 테두리를 그리는 CustomPainter
class _CornerPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final bool topLeft;
  final bool topRight;
  final bool bottomLeft;
  final bool bottomRight;

  _CornerPainter({
    required this.color,
    required this.strokeWidth,
    this.topLeft = false,
    this.topRight = false,
    this.bottomLeft = false,
    this.bottomRight = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();

    if (topLeft) {
      path.moveTo(0, size.height);
      path.lineTo(0, 0);
      path.lineTo(size.width, 0);
    } else if (topRight) {
      path.moveTo(0, 0);
      path.lineTo(size.width, 0);
      path.lineTo(size.width, size.height);
    } else if (bottomLeft) {
      path.moveTo(0, 0);
      path.lineTo(0, size.height);
      path.lineTo(size.width, size.height);
    } else if (bottomRight) {
      path.moveTo(0, size.height);
      path.lineTo(size.width, size.height);
      path.lineTo(size.width, 0);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
