/// QR 코드에 포함될 데이터 모델
/// 
/// 모임 출석용 QR 코드에 저장되는 정보를 정의합니다.
/// JSON 형태로 직렬화되어 QR 코드에 인코딩됩니다.
/// 
/// 🆕 v2.0 변경사항:
/// - generatedAt 필드 제거 (고정 QR 코드 지원)
/// - 시간 기반 만료 체크 제거
class QrData {
  /// 모임 ID
  final int meetingId;
  
  /// QR 타입 (출석용)
  final String type;

  const QrData({
    required this.meetingId,
    this.type = 'attendance',
  });

  /// JSON에서 QrData 객체 생성
  factory QrData.fromJson(Map<String, dynamic> json) {
    return QrData(
      meetingId: json['meetingId'] as int,
      type: json['type'] as String? ?? 'attendance',
    );
  }

  /// QrData 객체를 JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'meetingId': meetingId,
      'type': type,
    };
  }

  /// QR 코드용 JSON 문자열 생성
  String toQrString() {
    return '${toJson()}';
  }

  /// QR 코드 문자열에서 QrData 객체 생성
  static QrData fromQrString(String qrString) {
    try {
      // 문자열을 Map으로 파싱 (간단한 파싱)
      final cleanString = qrString.replaceAll('{', '').replaceAll('}', '');
      final pairs = cleanString.split(', ');
      
      final Map<String, dynamic> json = {};
      for (String pair in pairs) {
        final keyValue = pair.split(': ');
        if (keyValue.length == 2) {
          final key = keyValue[0].trim();
          final value = keyValue[1].trim();
          
          if (key == 'meetingId') {
            json[key] = int.parse(value);
          } else if (key == 'type') {
            json[key] = value;
          }
          // generatedAt 필드 제거로 인한 처리 삭제
        }
      }
      
      return QrData.fromJson(json);
    } catch (e) {
      throw FormatException('Invalid QR code format: $qrString');
    }
  }

  /// 더 안전한 JSON 파싱을 위한 대안 메서드
  static QrData? tryFromQrString(String qrString) {
    try {
      return fromQrString(qrString);
    } catch (e) {
      return null;
    }
  }

  @override
  String toString() {
    return 'QrData{meetingId: $meetingId, type: $type}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is QrData &&
        other.meetingId == meetingId &&
        other.type == type;
  }

  @override
  int get hashCode {
    return meetingId.hashCode ^ type.hashCode;
  }
}
