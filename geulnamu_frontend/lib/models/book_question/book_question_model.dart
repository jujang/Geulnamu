/// 발제문 모델
/// 
/// 백엔드 BookQuestionViewResponse와 대응
class BookQuestionModel {
  final int bookQuestionId;
  final int writerMemberId;
  final String content;

  const BookQuestionModel({
    required this.bookQuestionId,
    required this.writerMemberId,
    required this.content,
  });

  /// JSON에서 모델 생성
  factory BookQuestionModel.fromJson(Map<String, dynamic> json) {
    return BookQuestionModel(
      bookQuestionId: json['bookQuestionId'] as int,
      writerMemberId: json['writerMemberId'] as int,
      content: json['content'] as String,
    );
  }

  /// 모델을 JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'bookQuestionId': bookQuestionId,
      'writerMemberId': writerMemberId,
      'content': content,
    };
  }

  @override
  String toString() {
    return 'BookQuestionModel{bookQuestionId: $bookQuestionId, writerMemberId: $writerMemberId, content: $content}';
  }
}

/// 발제문 그룹 모델
/// 
/// 백엔드 BookQuestionGroupViewResponse와 대응
class BookQuestionGroupModel {
  final List<BookQuestionModel> bookQuestionList;

  const BookQuestionGroupModel({
    required this.bookQuestionList,
  });

  /// JSON에서 모델 생성
  factory BookQuestionGroupModel.fromJson(Map<String, dynamic> json) {
    final List<dynamic> bookQuestionListJson = json['bookQuestionViewResponseList'] as List<dynamic>;
    
    return BookQuestionGroupModel(
      bookQuestionList: bookQuestionListJson
          .map((item) => BookQuestionModel.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  /// 모델을 JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'bookQuestionViewResponseList': bookQuestionList.map((item) => item.toJson()).toList(),
    };
  }

  @override
  String toString() {
    return 'BookQuestionGroupModel{bookQuestionList: ${bookQuestionList.length} items}';
  }
}

/// 발제문 응답 모델 (API 응답 전체)
class BookQuestionResponse {
  final List<BookQuestionGroupModel> groups;

  const BookQuestionResponse({
    required this.groups,
  });

  /// JSON에서 모델 생성
  factory BookQuestionResponse.fromJson(List<dynamic> json) {
    return BookQuestionResponse(
      groups: json
          .map((item) => BookQuestionGroupModel.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  /// 모든 발제문을 하나의 리스트로 통합
  List<BookQuestionModel> get allBookQuestions {
    final List<BookQuestionModel> allQuestions = [];
    for (final group in groups) {
      allQuestions.addAll(group.bookQuestionList);
    }
    return allQuestions;
  }

  @override
  String toString() {
    return 'BookQuestionResponse{groups: ${groups.length} groups, total: ${allBookQuestions.length} questions}';
  }
}
