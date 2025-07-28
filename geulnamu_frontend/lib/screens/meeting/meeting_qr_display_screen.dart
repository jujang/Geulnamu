import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/attendance/qr_service.dart';
import '../../models/attendance/qr_data.dart';
import '../../widgets/common/main_layout.dart';
import '../../core/config/app_config.dart';

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
  late QrData _currentQrData;

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

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    
    return MainLayout(
      title: '모임 출석 QR',
      body: Padding(
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
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '모임 ID: ${widget.meetingId}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // QR 코드 섹션
            Expanded(
              child: Column(
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
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                  ),
                  ),
                  ],
                  ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // QR 코드 카드
                  Expanded(
                    child: Card(
                      elevation: 4,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // QR 코드
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
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
                                        color: Theme.of(context).colorScheme.primary,
                                      ),
                                    );
                                  }
                                },
                              ),
                            ),
                            
                            const SizedBox(height: 20),
                            
                            // QR 정보
                            Text(
                              '📚 고정 출석 QR 코드 (시간 제한 없음)',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // 설명 카드
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
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
                    '• 참석자가 스캔하면 자동 출석 처리됩니다\n'
                    '• 중앙의 책 아이콘은 글나무 전용 QR임을 나타냅니다',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.left,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🆕 v2.0: 시간 포맷팅 메서드 제거 (고정 QR 코드로 인해 불필요)
}
