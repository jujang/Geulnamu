import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
// import 'package:mobile_scanner/mobile_scanner.dart'; // 웹 지원을 위해 제거
import '../../models/attendance/qr_data.dart';
import '../../core/config/app_config.dart';

/// QR 코드 생성 및 스캔 서비스 (Singleton)
///
/// 제공 기능:
/// - 모임 출석용 QR 코드 생성
/// - QR 코드 데이터 파싱
/// - QR 코드 위젯 생성
class QrService {
  static final QrService _instance = QrService._internal();
  factory QrService() => _instance;
  QrService._internal();

  // 📚 책 아이콘 이미지 캐시
  static Uint8List? _bookIconBytes;

  /// 책 아이콘 이미지 생성 (메모리에서)
  ///
  /// QR 코드 중앙에 표시될 책 모양 아이콘을 메모리에서 생성
  Future<Uint8List> _createBookIconBytes() async {
    if (_bookIconBytes != null) {
      return _bookIconBytes!;
    }

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    const size = 40.0;

    // 배경 원 그리기
    final backgroundPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawCircle(
      const Offset(size / 2, size / 2),
      size / 2 - 1,
      backgroundPaint,
    );

    canvas.drawCircle(
      const Offset(size / 2, size / 2),
      size / 2 - 1,
      borderPaint,
    );

    // 책 아이콘 그리기
    final iconPainter = TextPainter(
      text: TextSpan(
        text: String.fromCharCode(Icons.menu_book.codePoint),
        style: TextStyle(
          fontSize: 20,
          fontFamily: Icons.menu_book.fontFamily,
          color: Colors.black,
        ),
      ),
      textDirection: TextDirection.ltr,
    );

    iconPainter.layout();
    iconPainter.paint(
      canvas,
      Offset((size - iconPainter.width) / 2, (size - iconPainter.height) / 2),
    );

    final picture = recorder.endRecording();
    final img = await picture.toImage(size.toInt(), size.toInt());
    final byteData = await img.toByteData(format: ui.ImageByteFormat.png);

    _bookIconBytes = byteData!.buffer.asUint8List();
    return _bookIconBytes!;
  }

  /// 모임 출석용 QR 데이터 생성
  ///
  /// [meetingId]: 모임 ID
  /// Returns: QrData 객체
  ///
  /// 🆕 v2.0: 고정 QR 코드 지원 (시간 제한 없음)
  QrData createAttendanceQrData(int meetingId) {
    return QrData(meetingId: meetingId, type: 'attendance');
  }

  /// QR 코드 위젯 생성
  ///
  /// [qrData]: QR에 포함될 데이터
  /// [size]: QR 코드 크기 (기본: 200)
  /// [backgroundColor]: 배경색 (기본: 흰색)
  /// [foregroundColor]: 전경색 (기본: 검정색)
  /// Returns: QrImageView 위젯
  ///
  /// 🆕 v2.0: 중앙에 책 아이콘 추가 (메모리 이미지 사용)
  Future<Widget> createQrWidget({
    required QrData qrData,
    double size = 200,
    Color backgroundColor = Colors.white,
    Color? foregroundColor,
  }) async {
    // QR 데이터를 JSON 문자열로 변환
    final qrString = jsonEncode(qrData.toJson());

    if (AppConfig.debugMode) {
      print('🎯 [QR 생성] QR 데이터: $qrString');
    }

    // 책 아이콘 이미지 생성
    final bookIconBytes = await _createBookIconBytes();

    return QrImageView(
      data: qrString,
      version: QrVersions.auto,
      size: size,
      backgroundColor: backgroundColor,
      // 🆕 deprecated 경고 수정: foregroundColor 대신 eyeStyle 사용
      eyeStyle: QrEyeStyle(
        eyeShape: QrEyeShape.square,
        color: foregroundColor ?? Colors.black,
      ),
      dataModuleStyle: QrDataModuleStyle(
        dataModuleShape: QrDataModuleShape.square,
        color: foregroundColor ?? Colors.black,
      ),
      gapless: false,
      errorCorrectionLevel: QrErrorCorrectLevel.M,
      // 📚 중앙에 책 아이콘 추가
      embeddedImage: MemoryImage(bookIconBytes),
      embeddedImageStyle: const QrEmbeddedImageStyle(size: Size(40, 40)),
    );
  }

  /// QR 데이터 파싱 (parseScannedQr의 alias)
  ///
  /// [scannedData]: 스캔된 QR 코드 데이터
  /// Returns: QrData 객체 또는 null (파싱 실패 시)
  QrData? parseQrData(String scannedData) {
    return parseScannedQr(scannedData);
  }

  /// QR 스캔 결과 파싱
  ///
  /// [scannedData]: 스캔된 QR 코드 데이터
  /// Returns: QrData 객체 또는 null (파싱 실패 시)
  QrData? parseScannedQr(String scannedData) {
    try {
      if (AppConfig.debugMode) {
        print('🎯 [QR 파싱] 스캔된 데이터: $scannedData');
      }

      // JSON 형태로 파싱 시도
      final Map<String, dynamic> json = jsonDecode(scannedData);
      final qrData = QrData.fromJson(json);

      if (AppConfig.debugMode) {
        print('✅ [QR 파싱] 성공: $qrData');
      }

      return qrData;
    } catch (e) {
      if (AppConfig.debugMode) {
        print('❌ [QR 파싱] 실패: $e');
      }
      return null;
    }
  }

  /// QR 데이터 유효성 검증
  ///
  /// [qrData]: 검증할 QR 데이터
  /// Returns: 유효성 검증 결과
  ///
  /// 🆕 v2.0: 시간 제한 제거 (고정 QR 코드 지원)
  QrValidationResult validateQrData(QrData qrData) {
    // 1. QR 타입 검증
    if (qrData.type != 'attendance') {
      return QrValidationResult(
        isValid: false,
        errorMessage: '출석용 QR 코드가 아닙니다.',
      );
    }

    // 2. 모임 ID 검증 (기본 체크)
    if (qrData.meetingId <= 0) {
      return QrValidationResult(
        isValid: false,
        errorMessage: '유효하지 않은 모임 정보입니다.',
      );
    }

    // 🆕 시간 기반 만료 체크 제거 (고정 QR 코드)
    return QrValidationResult(isValid: true, qrData: qrData);
  }

  // 모바일 스캐너 관련 코드는 ai_barcode_scanner로 대체됨
}

/// QR 유효성 검증 결과
class QrValidationResult {
  final bool isValid;
  final String? errorMessage;
  final QrData? qrData;

  const QrValidationResult({
    required this.isValid,
    this.errorMessage,
    this.qrData,
  });
}

/// QR 스캔 결과
class QrScanResult {
  final bool success;
  final String? errorMessage;
  final QrData? qrData;

  const QrScanResult({required this.success, this.errorMessage, this.qrData});
}
