import 'package:dio/dio.dart';
import '../../core/config/app_config.dart';
import '../../core/utils/api_utils.dart';
import '../../models/book_question/book_question_model.dart';

/// 발제문 관련 서비스
/// 
/// 기능:
/// - 발제문 조회 (본인 토론 그룹)
/// - 발제문 조회 (모임 전체)
/// - 발제문 생성/수정/삭제 (향후 확장)
class BookQuestionService {
  static final BookQuestionService _instance = BookQuestionService._internal();
  factory BookQuestionService() => _instance;
  BookQuestionService._internal();

  final Dio _dio = Dio();

  /// 본인 토론 그룹의 발제문 조회
  /// 
  /// 백엔드 API: GET /book-questions/my-group?meetingId={meetingId}
  /// 권한: STAFF 이상
  Future<List<BookQuestionModel>> getMyGroupBookQuestions({
    required int meetingId,
    required String accessToken,
    bool forceRefresh = false,
  }) async {
    try {
      if (AppConfig.debugMode) {
        print('🚀 [발제문 조회] 본인 토론 그룹 발제문 조회 시작...');
        print('   - meetingId: $meetingId');
        print('   - forceRefresh: $forceRefresh');
      }

      // API 호출
      final response = await _dio.get(
        AppConfig.getApiEndpoint('book-questions/my-group'),
        queryParameters: {
          'meetingId': meetingId,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $accessToken',
          },
        ),
      );

      if (response.statusCode == 200) {
        // ✅ ApiUtils를 사용한 백엔드 응답 처리
        final processedResponse = ApiUtils.processBackendResponse(
          response,
          '본인 토론 그룹 발제문 조회',
        );

        // 성공한 경우 데이터 파싱
        final List<dynamic> dataList = processedResponse['data'] as List<dynamic>;
        final bookQuestions = dataList
            .map((json) => BookQuestionModel.fromJson(json as Map<String, dynamic>))
            .toList();

        if (AppConfig.debugMode) {
          print('✅ [발제문 조회] 성공 - 총 ${bookQuestions.length}개의 발제문');
          for (final question in bookQuestions) {
            print('   📝 발제문 ${question.bookQuestionId}: ${question.content.length > 50 ? question.content.substring(0, 50) + "..." : question.content}');
          }
        }

        return bookQuestions;
      } else {
        throw Exception('[발제문 조회] HTTP 오류: ${response.statusCode}');
      }
    } catch (e) {
      // ✅ ApiUtils를 사용한 에러 처리
      if (e is DioException) {
        throw ApiUtils.processDioException(e, '본인 토론 그룹 발제문 조회');
      }
      rethrow;
    }
  }

  /// 모임 전체 발제문 조회
  /// 
  /// 백엔드 API: GET /book-questions/meeting?meetingId={meetingId}
  /// 권한: MEMBER 이상
  Future<BookQuestionResponse> getMeetingBookQuestions({
    required int meetingId,
    required String accessToken,
    bool forceRefresh = false,
  }) async {
    try {
      if (AppConfig.debugMode) {
        print('🚀 [발제문 조회] 모임 전체 발제문 조회 시작...');
        print('   - meetingId: $meetingId');
        print('   - forceRefresh: $forceRefresh');
      }

      // API 호출
      final response = await _dio.get(
        AppConfig.getApiEndpoint('book-questions/meeting'),
        queryParameters: {
          'meetingId': meetingId,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $accessToken',
          },
        ),
      );

      if (response.statusCode == 200) {
        // ✅ ApiUtils를 사용한 백엔드 응답 처리
        final processedResponse = ApiUtils.processBackendResponse(
          response,
          '모임 전체 발제문 조회',
        );

        // 성공한 경우 데이터 파싱
        final List<dynamic> dataList = processedResponse['data'] as List<dynamic>;
        final bookQuestionResponse = BookQuestionResponse.fromJson(dataList);

        if (AppConfig.debugMode) {
          print('✅ [발제문 조회] 성공 - 총 ${bookQuestionResponse.groups.length}개 그룹, ${bookQuestionResponse.allBookQuestions.length}개 발제문');
        }

        return bookQuestionResponse;
      } else {
        throw Exception('[발제문 조회] HTTP 오류: ${response.statusCode}');
      }
    } catch (e) {
      // ✅ ApiUtils를 사용한 에러 처리
      if (e is DioException) {
        throw ApiUtils.processDioException(e, '모임 전체 발제문 조회');
      }
      rethrow;
    }
  }

  /// 발제문 생성
  /// 
  /// 백엔드 API: POST /book-questions/create?attendanceId={attendanceId}
  /// 권한: MEMBER 이상
  /// 
  /// 향후 확장용 메서드 (현재는 운영진용 화면에서 직접 생성 기능은 없음)
  Future<int> createBookQuestion({
    required int attendanceId,
    required String content,
    required String accessToken,
  }) async {
    try {
      if (AppConfig.debugMode) {
        print('🚀 [발제문 생성] 발제문 생성 시작...');
        print('   - attendanceId: $attendanceId');
        print('   - content 길이: ${content.length}자');
      }

      final response = await _dio.post(
        AppConfig.getApiEndpoint('book-questions/create'),
        queryParameters: {
          'attendanceId': attendanceId,
        },
        data: {
          'content': content,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $accessToken',
          },
        ),
      );

      if (response.statusCode == 200) {
        // ✅ ApiUtils를 사용한 백엔드 응답 처리
        final processedResponse = ApiUtils.processBackendResponse(
          response,
          '발제문 생성',
        );

        final bookQuestionId = processedResponse['data'] as int;

        if (AppConfig.debugMode) {
          print('✅ [발제문 생성] 성공 - 발제문 ID: $bookQuestionId');
        }

        return bookQuestionId;
      } else {
        throw Exception('[발제문 생성] HTTP 오류: ${response.statusCode}');
      }
    } catch (e) {
      // ✅ ApiUtils를 사용한 에러 처리
      if (e is DioException) {
        throw ApiUtils.processDioException(e, '발제문 생성');
      }
      rethrow;
    }
  }

  /// 발제문 수정
  /// 
  /// 백엔드 API: PATCH /book-questions/{bookQuestionId}
  /// 권한: MEMBER 이상 (본인 또는 관리자만 가능)
  /// 
  /// 향후 확장용 메서드
  Future<void> updateBookQuestion({
    required int bookQuestionId,
    required String content,
    required String accessToken,
  }) async {
    try {
      if (AppConfig.debugMode) {
        print('🚀 [발제문 수정] 발제문 수정 시작...');
        print('   - bookQuestionId: $bookQuestionId');
        print('   - content 길이: ${content.length}자');
      }

      final response = await _dio.patch(
        AppConfig.getApiEndpoint('book-questions/$bookQuestionId'),
        data: {
          'content': content,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $accessToken',
          },
        ),
      );

      if (response.statusCode == 200) {
        // ✅ ApiUtils를 사용한 백엔드 응답 처리
        ApiUtils.processBackendResponse(
          response,
          '발제문 수정',
          expectData: false, // 수정은 데이터 반환 없음
        );

        if (AppConfig.debugMode) {
          print('✅ [발제문 수정] 성공');
        }
      } else {
        throw Exception('[발제문 수정] HTTP 오류: ${response.statusCode}');
      }
    } catch (e) {
      // ✅ ApiUtils를 사용한 에러 처리
      if (e is DioException) {
        throw ApiUtils.processDioException(e, '발제문 수정');
      }
      rethrow;
    }
  }

  /// 발제문 삭제
  /// 
  /// 백엔드 API: DELETE /book-questions/{bookQuestionId}
  /// 권한: MEMBER 이상 (본인 또는 관리자만 가능)
  /// 
  /// 향후 확장용 메서드
  Future<void> deleteBookQuestion({
    required int bookQuestionId,
    required String accessToken,
  }) async {
    try {
      if (AppConfig.debugMode) {
        print('🚀 [발제문 삭제] 발제문 삭제 시작...');
        print('   - bookQuestionId: $bookQuestionId');
      }

      final response = await _dio.delete(
        AppConfig.getApiEndpoint('book-questions/$bookQuestionId'),
        options: Options(
          headers: {
            'Authorization': 'Bearer $accessToken',
          },
        ),
      );

      if (response.statusCode == 200) {
        // ✅ ApiUtils를 사용한 백엔드 응답 처리
        ApiUtils.processBackendResponse(
          response,
          '발제문 삭제',
          expectData: false, // 삭제는 데이터 반환 없음
        );

        if (AppConfig.debugMode) {
          print('✅ [발제문 삭제] 성공');
        }
      } else {
        throw Exception('[발제문 삭제] HTTP 오류: ${response.statusCode}');
      }
    } catch (e) {
      // ✅ ApiUtils를 사용한 에러 처리
      if (e is DioException) {
        throw ApiUtils.processDioException(e, '발제문 삭제');
      }
      rethrow;
    }
  }
}
