/// 비고 작성 요청 모델
/// 
/// 백엔드 AttendanceNoteRequest와 매핑
/// PATCH /attendances/{attendanceId}/note API 요청용
class AttendanceNoteRequest {
  /// 비고 내용
  /// 
  /// 제약조건:
  /// - 필수 입력 (NotBlank)
  /// - 한글, 영문, 숫자, 공백 및 일부 특수문자만 허용
  /// - 허용 특수문자: : / @ [ ] ( ) ~ _ ! ? . , ; -
  /// - 1자 이상 255자 이하
  final String note;

  const AttendanceNoteRequest({
    required this.note,
  });

  /// JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'note': note,
    };
  }

  /// JSON에서 객체 생성
  factory AttendanceNoteRequest.fromJson(Map<String, dynamic> json) {
    return AttendanceNoteRequest(
      note: json['note'] as String,
    );
  }

  /// 비고 내용 유효성 검사
  /// 
  /// 백엔드 Pattern 제약조건과 동일:
  /// ^[ㄱ-ㅎ가-힣a-zA-Z0-9\\s:/@\\[\\]()~_!?.,;-]{1,255}$
  bool isValid() {
    if (note.trim().isEmpty) return false;
    if (note.length > 255) return false;
    
    // 정규식 패턴 검사
    final pattern = RegExp(r'^[ㄱ-ㅎ가-힣a-zA-Z0-9\s:/@\[\]()~_!?.,;-]{1,255}$');
    return pattern.hasMatch(note);
  }

  /// 유효성 검사 에러 메시지 반환
  String? getValidationError() {
    if (note.trim().isEmpty) {
      return '비고를 입력해주세요.';
    }
    
    if (note.length > 255) {
      return '비고는 255자 이하로 입력해주세요.';
    }
    
    final pattern = RegExp(r'^[ㄱ-ㅎ가-힣a-zA-Z0-9\s:/@\[\]()~_!?.,;-]{1,255}$');
    if (!pattern.hasMatch(note)) {
      return '비고는 한글, 영문, 숫자, 공백 및 일부 특수문자(: / @ [ ] ( ) ~ _ ! ? . , ; -)만 사용할 수 있습니다.';
    }
    
    return null; // 유효함
  }

  @override
  String toString() {
    return 'AttendanceNoteRequest{note: $note}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AttendanceNoteRequest && other.note == note;
  }

  @override
  int get hashCode => note.hashCode;
}
