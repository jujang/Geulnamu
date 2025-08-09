/// VoC (Voice of Customer) API 요청 모델
///
/// 백엔드 VoCCreateRequest와 일치하는 구조
class ContactRequest {
  final String content;

  const ContactRequest({
    required this.content,
  });

  /// JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'content': content,
    };
  }

  /// JSON에서 생성
  factory ContactRequest.fromJson(Map<String, dynamic> json) {
    return ContactRequest(
      content: json['content'] as String,
    );
  }

  @override
  String toString() {
    return 'ContactRequest{content: $content}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ContactRequest &&
          runtimeType == other.runtimeType &&
          content == other.content;

  @override
  int get hashCode => content.hashCode;
}
