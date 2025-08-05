import 'package:dio/dio.dart';
import '../../core/config/app_config.dart';
import '../../core/utils/api_utils.dart';
import '../../models/discussion/attendance_id_and_name_model.dart';
import '../../models/discussion/discussion_group_model.dart';

/// 토론 관리 서비스 (Singleton)
///
/// 제공 기능:
/// - 토론 참여 희망 명단 조회
/// - 모임별 전체 토론 그룹 명단 조회
/// - 향후: 토론 그룹 구성 등
class DiscussionService {
  static final DiscussionService _instance = DiscussionService._internal();
  factory DiscussionService() => _instance;
  DiscussionService._internal() {
    // 🔧 생성자에서 즉시 Dio 초기화
    _dio = ApiUtils.createDioWithTimeout(baseUrl: AppConfig.apiBaseUrl);
  }

  late final Dio _dio;

  /// 토론 참여 희망 명단 조회
  ///
  /// API: GET /discussions/list/want-discussion?meetingId={meetingId}
  /// 권한: STAFF 이상
  Future<List<AttendanceIdAndNameModel>?> getWantDiscussionMemberList({
    required int meetingId,
    required String accessToken,
  }) async {
    try {
      if (AppConfig.debugMode) {
        print('🚀 [토론 참여 희망 명단 조회] API 요청 시작... meetingId: $meetingId');
      }

      // 🔥 강제 캐시 버스트 추가
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final queryParams = {
        'meetingId': meetingId.toString(),
        '_cache_bust': timestamp.toString(),
        '_t': timestamp.toString(),
        '_refresh': 'true',
      };

      if (AppConfig.debugMode) {
        print('📅 [캐시 무효화] GET /discussions/list/want-discussion?${queryParams.entries.map((e) => '${e.key}=${e.value}').join('&')}');
      }

      final response = await _dio.get(
        '/discussions/list/want-discussion',
        queryParameters: queryParams,
        options: Options(
          headers: {
            'Authorization': 'Bearer $accessToken',
            'Content-Type': 'application/json',
            // 🔥 강력한 캐시 무효화 헤더
            'Cache-Control': 'no-cache, no-store, must-revalidate, max-age=0',
            'Pragma': 'no-cache',
            'Expires': '0',
            'If-Modified-Since': 'Mon, 26 Jul 1997 05:00:00 GMT',
            'X-Requested-With': 'XMLHttpRequest',
          },
        ),
      );

      if (response.statusCode == 200) {
        final processedResponse = ApiUtils.processBackendResponse(
          response,
          '토론 참여 희망 명단 조회',
        );

        // 데이터가 null인 경우 처리
        final data = processedResponse['data'];
        if (data == null) {
          if (AppConfig.debugMode) {
            print('ℹ️ [토론 참여 희망 명단 조회] 데이터가 null입니다.');
          }
          return null;
        }

        // 데이터가 비어있는 경우 처리
        if (data is List && data.isEmpty) {
          if (AppConfig.debugMode) {
            print('ℹ️ [토론 참여 희망 명단 조회] 참여 희망자가 없습니다.');
          }
          return [];
        }

        // 정상 데이터 처리
        final memberList = (data as List)
            .map((memberJson) => AttendanceIdAndNameModel.fromJson(memberJson as Map<String, dynamic>))
            .toList();

        if (AppConfig.debugMode) {
          print('✅ [토론 참여 희망 명단 조회] 성공 - 총 ${memberList.length}명');
        }

        return memberList;
      } else {
        throw Exception('[토론 참여 희망 명단 조회] HTTP 오류: ${response.statusCode}');
      }
    } catch (e) {
      if (AppConfig.debugMode) {
        print('❌ [토론 참여 희망 명단 조회] 오류 발생: $e');
      }

      if (e is DioException) {
        throw ApiUtils.processDioException(e, '토론 참여 희망 명단 조회');
      }
      rethrow;
    }
  }

  /// 모임별 전체 토론 그룹 명단 조회
  ///
  /// API: GET /discussions/groups?meetingId={meetingId}
  /// 권한: STAFF 이상
  Future<DiscussionGroupListResponse?> getAllDiscussionGroupMemberList({
    required int meetingId,
    required String accessToken,
  }) async {
    try {
      if (AppConfig.debugMode) {
        print('🚀 [모임별 전체 토론 그룹 명단 조회] API 요청 시작... meetingId: $meetingId');
      }

      // 🔥 강제 캐시 버스트 추가
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final queryParams = {
        'meetingId': meetingId.toString(),
        '_cache_bust': timestamp.toString(),
        '_t': timestamp.toString(),
        '_refresh': 'true',
      };

      if (AppConfig.debugMode) {
        print('📅 [캐시 무효화] GET /discussions/groups?${queryParams.entries.map((e) => '${e.key}=${e.value}').join('&')}');
      }

      final response = await _dio.get(
        '/discussions/groups',
        queryParameters: queryParams,
        options: Options(
          headers: {
            'Authorization': 'Bearer $accessToken',
            'Content-Type': 'application/json',
            // 🔥 강력한 캐시 무효화 헤더
            'Cache-Control': 'no-cache, no-store, must-revalidate, max-age=0',
            'Pragma': 'no-cache',
            'Expires': '0',
            'If-Modified-Since': 'Mon, 26 Jul 1997 05:00:00 GMT',
            'X-Requested-With': 'XMLHttpRequest',
          },
        ),
      );

      if (response.statusCode == 200) {
        final processedResponse = ApiUtils.processBackendResponse(
          response,
          '모임별 전체 토론 그룹 명단 조회',
        );

        // 데이터가 null인 경우 처리
        final data = processedResponse['data'];
        if (data == null) {
          if (AppConfig.debugMode) {
            print('ℹ️ [모임별 전체 토론 그룹 명단 조회] 데이터가 null입니다.');
          }
          return null;
        }

        // 데이터가 비어있는 경우 처리
        if (data is List && data.isEmpty) {
          if (AppConfig.debugMode) {
            print('ℹ️ [모임별 전체 토론 그룹 명단 조회] 토론 그룹이 없습니다.');
          }
          return DiscussionGroupListResponse(groups: []);
        }

        // 정상 데이터 처리
        final groupListResponse = DiscussionGroupListResponse.fromJson(data as List);

        if (AppConfig.debugMode) {
          print('✅ [모임별 전체 토론 그룹 명단 조회] 성공 - 총 ${groupListResponse.groupCount}개 그룹, ${groupListResponse.totalMemberCount}명 참여');
        }

        return groupListResponse;
      } else {
        throw Exception('[모임별 전체 토론 그룹 명단 조회] HTTP 오류: ${response.statusCode}');
      }
    } catch (e) {
      if (AppConfig.debugMode) {
        print('❌ [모임별 전체 토론 그룹 명단 조회] 오류 발생: $e');
      }

      if (e is DioException) {
        throw ApiUtils.processDioException(e, '모임별 전체 토론 그룹 명단 조회');
      }
      rethrow;
    }
  }

  /// 새로고침용 메서드 - 두 API를 동시에 호출
  ///
  /// UI에서 새로고침 버튼 클릭 시 사용
  Future<Map<String, dynamic>> refreshDiscussionData({
    required int meetingId,
    required String accessToken,
  }) async {
    if (AppConfig.debugMode) {
      print('🔄 [토론 데이터 새로고침] 시작... meetingId: $meetingId');
    }

    try {
      // 두 API를 동시에 호출
      final results = await Future.wait([
        getWantDiscussionMemberList(meetingId: meetingId, accessToken: accessToken),
        getAllDiscussionGroupMemberList(meetingId: meetingId, accessToken: accessToken),
      ]);

      final wantList = results[0] as List<AttendanceIdAndNameModel>?;
      final groupList = results[1] as DiscussionGroupListResponse?;

      if (AppConfig.debugMode) {
        print('✅ [토론 데이터 새로고침] 완료');
        print('   - 참여 희망자: ${wantList?.length ?? 0}명');
        print('   - 토론 그룹: ${groupList?.groupCount ?? 0}개');
      }

      return {
        'wantDiscussionList': wantList,
        'discussionGroupList': groupList,
      };
    } catch (e) {
      if (AppConfig.debugMode) {
        print('❌ [토론 데이터 새로고침] 오류: $e');
      }
      rethrow;
    }
  }
}
