/// 🔔 FCM 푸시 발송 결과 모델
///
/// 백엔드 FcmSendResult와 동일한 구조
class FcmSendResult {
  final int successCount;
  final int failureCount;

  FcmSendResult({
    required this.successCount,
    required this.failureCount,
  });

  /// JSON에서 변환
  factory FcmSendResult.fromJson(Map<String, dynamic> json) {
    return FcmSendResult(
      successCount: json['successCount'] ?? 0,
      failureCount: json['failureCount'] ?? 0,
    );
  }

  /// 전체 성공 여부
  bool get isAllSuccess => failureCount == 0;

  /// 전체 실패 여부
  bool get isAllFailed => successCount == 0 && failureCount > 0;

  /// 부분 성공 여부
  bool get isPartialSuccess => successCount > 0 && failureCount > 0;

  /// 발송 대상 없음 여부
  bool get isEmpty => successCount == 0 && failureCount == 0;

  /// 총 발송 대상 수
  int get totalCount => successCount + failureCount;

  /// 결과 메시지 생성
  String get resultMessage {
    if (isEmpty) {
      return '발송 대상이 없습니다.';
    } else if (isAllSuccess) {
      return '${successCount}명에게 발송 완료!';
    } else if (isAllFailed) {
      return '발송 실패 (${failureCount}명)';
    } else {
      return '발송 완료! 성공: ${successCount}명, 실패: ${failureCount}명';
    }
  }

  @override
  String toString() {
    return 'FcmSendResult(successCount: $successCount, failureCount: $failureCount)';
  }
}
