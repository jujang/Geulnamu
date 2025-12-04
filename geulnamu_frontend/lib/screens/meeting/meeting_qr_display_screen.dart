import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/attendance/qr_service.dart';
import '../../services/home/home_service.dart';
import '../../models/attendance/qr_data.dart';
import '../../widgets/common/main_layout.dart';
import '../../core/config/app_config.dart';
import '../../core/theme.dart';

// 웹 환경에서 다운로드를 위한 import
import 'package:web/web.dart' as web;

/// 운영진용 QR 코드 표시 화면
///
/// 기능:
/// - 모임 출석용 QR 코드 생성 및 표시
/// - 실시간 QR 코드 새로고침
/// - 출석 안내 메시지
class MeetingQrDisplayScreen extends StatefulWidget {
  final int meetingId;
  final String meetingTitle;

  const MeetingQrDisplayScreen({
    super.key,
    required this.meetingId,
    required this.meetingTitle,
  });

  @override
  State<MeetingQrDisplayScreen> createState() => _MeetingQrDisplayScreenState();
}

class _MeetingQrDisplayScreenState extends State<MeetingQrDisplayScreen> {
  final QrService _qrService = QrService();
  final HomeService _homeService = HomeService();
  late QrData _currentQrData;

  // 🆕 QR 코드 캔처를 위한 GlobalKey
  final GlobalKey _qrKey = GlobalKey();
  bool _isDownloading = false;

  @override
  void initState() {
    super.initState();
    _initializeQr();
  }

  /// 고정 QR 코드 초기화
  ///
  /// 🆕 v2.0: 시간에 관계없이 동일한 QR 코드 생성
  void _initializeQr() {
    _currentQrData = _qrService.createAttendanceQrData(widget.meetingId);

    if (AppConfig.debugMode) {
      print('🎯 [QR 표시] 고정 QR 초기화: ${_currentQrData.meetingId}');
    }
  }

  /// 로그아웃 처리 (HomeService 활용)
  Future<void> _handleLogout() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await _homeService.handleLogout(context, authProvider);
  }

  /// 🆕 QR 코드 이미지 다운로드
  Future<void> _downloadQrImage() async {
    if (_isDownloading) return;

    setState(() {
      _isDownloading = true;
    });

    try {
      // RepaintBoundary로부터 이미지 캔처
      final RenderRepaintBoundary? boundary =
          _qrKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;

      if (boundary == null) {
        throw Exception('QR 코드를 찾을 수 없습니다.');
      }

      // 이미지로 변환 (고해상도)
      final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      final ByteData? byteData = await image.toByteData(
        format: ui.ImageByteFormat.png,
      );

      if (byteData == null) {
        throw Exception('이미지 변환에 실패했습니다.');
      }

      final Uint8List pngBytes = byteData.buffer.asUint8List();

      // 웹 환경에서 다운로드
      await _downloadImageWeb(pngBytes);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('QR 코드 이미지가 다운로드되었습니다.'),
              ],
            ),
            backgroundColor: context.colors.primary,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }

      if (AppConfig.debugMode) {
        print('✅ [QR 다운로드] 성공');
      }
    } catch (e) {
      if (AppConfig.debugMode) {
        print('❌ [QR 다운로드] 실패: $e');
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(child: Text('QR 다운로드 실패: $e')),
              ],
            ),
            backgroundColor: context.colors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isDownloading = false;
        });
      }
    }
  }

  /// 웹 환경에서 이미지 다운로드
  Future<void> _downloadImageWeb(Uint8List imageBytes) async {
    // Base64로 인코딩
    final base64Image = base64Encode(imageBytes);
    final dataUrl = 'data:image/png;base64,$base64Image';

    // 파일명 생성 (모임명_QR_날짜)
    final now = DateTime.now();
    final dateStr =
        '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';
    final safeTitle = widget.meetingTitle
        .replaceAll(RegExp(r'[^a-zA-Z0-9가-힣]'), '_');
    final fileName = '${safeTitle}_QR_$dateStr.png';

    // 다운로드 링크 생성 및 클릭
    final anchor = web.HTMLAnchorElement()
      ..href = dataUrl
      ..download = fileName
      ..style.display = 'none';

    web.document.body?.appendChild(anchor);
    anchor.click();
    anchor.remove();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return MainLayout(
      title: '모임 출석 QR',
      isHomePage: false, // 뒤로가기 버튼 표시
      onMenuTap: (menu) => _homeService.handleMenuTap(context, menu),
      onLogoutTap: () => _handleLogout(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // 모임 정보 카드
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.book,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            widget.meetingTitle,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface,
                                ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '모임번호: ${widget.meetingId}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // QR 코드 섹션
            Column(
              children: [
                // QR 코드 제목
                Text(
                  '📱 출석용 QR 코드',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),

                const SizedBox(height: 16),

                // 안내 메시지
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '📚 참석자들에게 이 QR 코드를 보여주세요 (고정 QR)',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onPrimaryContainer,
                              ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // QR 코드 카드
                Card(
                  elevation: 4,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // QR 코드 (🆕 RepaintBoundary로 감싸서 캔처 가능하게)
                        RepaintBoundary(
                          key: _qrKey,
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: FutureBuilder<Widget>(
                              future: _qrService.createQrWidget(
                                qrData: _currentQrData,
                                size: 250,
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.black,
                              ),
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  return snapshot.data!;
                                } else {
                                  return Container(
                                    width: 250,
                                    height: 250,
                                    alignment: Alignment.center,
                                    child: CircularProgressIndicator(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primary,
                                    ),
                                  );
                                }
                              },
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // 🆕 다운로드 버튼
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _isDownloading ? null : _downloadQrImage,
                            icon: _isDownloading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Icon(Icons.download),
                            label: Text(
                              _isDownloading ? '다운로드 중...' : 'QR 이미지 다운로드',
                            ),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // 설명 카드
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Theme.of(
                    context,
                  ).colorScheme.outline.withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.menu_book,
                    color: Theme.of(context).colorScheme.primary,
                    size: 32,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '고정 QR 코드 안내',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '• 이 QR 코드는 모임별로 고정되어 있습니다\n'
                    '• 시간 제한 없이 언제나 사용 가능합니다\n'
                    '• 참석자가 스캔하면 자동 출석 처리됩니다',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.left,
                  ),
                ],
              ),
            ),

            // 추가 여백 (스크롤 여유 공간)
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  // 🆕 v2.0: 시간 포맷팅 메서드 제거 (고정 QR 코드로 인해 불필요)
}
