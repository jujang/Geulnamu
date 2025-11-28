import 'package:dio/dio.dart';
import '../../core/config/app_config.dart';
import '../../core/utils/api_utils.dart';
import '../../models/profile/profile_model.dart';
import '../../models/member/member_list_model.dart';

/// 모임원 관리 서비스 (Singleton)
/// 
/// 제공 기능:
/// - 개별 모임원 조회 (관리자용)
/// - 모임원 등급 변경
/// - 모임원 이름 변경  
/// - 모임원 활성화/비활성화
/// - 모임원 목록 조회 (기존 기능 통합)
class MemberService {
  static final MemberService _instance = MemberService._internal();
  factory MemberService() => _instance;
  MemberService._internal() {
    // 🔧 생성자에서 즉시 Dio 초기화
    _dio = ApiUtils.createDioWithTimeout(
      baseUrl: AppConfig.apiBaseUrl,
    );
  }

  late final Dio _dio;

  /// 🎯 개별 모임원 상세 조회 (관리자용)
  /// 
  /// API: GET /api/members/{memberId}
  /// 권한: ADMIN 이상
  Future<ProfileModel> getMemberDetail(int memberId, {String? accessToken}) async {
    try {
      if (AppConfig.debugMode) {
        print('🚀 [모임원 상세 조회] API 요청 시작... (ID: $memberId)');
      }

      final response = await _dio.get(
        '/members/$memberId',
        options: Options(
          headers: accessToken != null ? {
            'Authorization': 'Bearer $accessToken',
            'Content-Type': 'application/json',
          } : null,
        ),
      );

      if (response.statusCode == 200) {
        final processedResponse = ApiUtils.processBackendResponse(
          response,
          '모임원 상세 조회',
        );

        return ProfileModel.fromJson(processedResponse['data']);
      } else {
        throw Exception('[모임원 상세 조회] HTTP 오류: ${response.statusCode}');
      }
    } catch (e) {
      if (e is DioException) {
        // 🛡️ context 없이 호출하나 ApiUtils에서 403 처리 안함
        throw ApiUtils.processDioException(e, '모임원 상세 조회', showDialog: false);
      }
      rethrow;
    }
  }

  /// 🎯 모임원 등급 변경
  /// 
  /// API: PATCH /api/members/{memberId}/role
  /// 권한: ADMIN 이상
  Future<void> updateMemberRole(int memberId, String newRole, {String? accessToken}) async {
    try {
      if (AppConfig.debugMode) {
        print('🚀 [모임원 등급 변경] API 요청 시작... (ID: $memberId, 새 등급: $newRole)');
      }

      final response = await _dio.patch(
        '/members/$memberId/role',
        data: {'role': newRole},
        options: Options(
          headers: accessToken != null ? {
            'Authorization': 'Bearer $accessToken',
            'Content-Type': 'application/json',
          } : null,
        ),
      );

      if (response.statusCode == 200) {
        final processedResponse = ApiUtils.processBackendResponse(
          response,
          '모임원 등급 변경',
          expectData: false, // 성공 응답에 data가 없을 수 있음
        );

        if (AppConfig.debugMode) {
          print('✅ [모임원 등급 변경] 성공: ${processedResponse['message']}');
        }
      } else {
        throw Exception('[모임원 등급 변경] HTTP 오류: ${response.statusCode}');
      }
    } catch (e) {
      if (e is DioException) {
        throw ApiUtils.processDioException(e, '모임원 등급 변경', showDialog: false);
      }
      rethrow;
    }
  }

  /// 🎯 모임원 이름 변경
  /// 
  /// API: PATCH /api/members/{memberId}/name
  /// 권한: ADMIN 이상
  Future<void> updateMemberName(int memberId, String newName, {String? accessToken}) async {
    try {
      if (AppConfig.debugMode) {
        print('🚀 [모임원 이름 변경] API 요청 시작... (ID: $memberId, 새 이름: $newName)');
      }

      final response = await _dio.patch(
        '/members/$memberId/name',
        data: {'name': newName},
        options: Options(
          headers: accessToken != null ? {
            'Authorization': 'Bearer $accessToken',
            'Content-Type': 'application/json',
          } : null,
        ),
      );

      if (response.statusCode == 200) {
        final processedResponse = ApiUtils.processBackendResponse(
          response,
          '모임원 이름 변경',
          expectData: false,
        );

        if (AppConfig.debugMode) {
          print('✅ [모임원 이름 변경] 성공: ${processedResponse['message']}');
        }
      } else {
        throw Exception('[모임원 이름 변경] HTTP 오류: ${response.statusCode}');
      }
    } catch (e) {
      if (e is DioException) {
        throw ApiUtils.processDioException(e, '모임원 이름 변경', showDialog: false);
      }
      rethrow;
    }
  }

  /// 🎯 모임원 활성화
  /// 
  /// API: PATCH /api/members/{memberId}/activate
  /// 권한: ADMIN 이상
  Future<void> activateMember(int memberId, {String? accessToken}) async {
    try {
      if (AppConfig.debugMode) {
        print('🚀 [모임원 활성화] API 요청 시작... (ID: $memberId)');
      }

      final response = await _dio.patch(
        '/members/$memberId/activate',
        options: Options(
          headers: accessToken != null ? {
            'Authorization': 'Bearer $accessToken',
            'Content-Type': 'application/json',
          } : null,
        ),
      );

      if (response.statusCode == 200) {
        final processedResponse = ApiUtils.processBackendResponse(
          response,
          '모임원 활성화',
          expectData: false,
        );

        if (AppConfig.debugMode) {
          print('✅ [모임원 활성화] 성공: ${processedResponse['message']}');
        }
      } else {
        throw Exception('[모임원 활성화] HTTP 오류: ${response.statusCode}');
      }
    } catch (e) {
      if (e is DioException) {
        throw ApiUtils.processDioException(e, '모임원 활성화', showDialog: false);
      }
      rethrow;
    }
  }

  /// 🎯 모임원 비활성화
  /// 
  /// API: PATCH /api/members/{memberId}/deactivate
  /// 권한: ADMIN 이상
  Future<void> deactivateMember(int memberId, {String? accessToken}) async {
    try {
      if (AppConfig.debugMode) {
        print('🚀 [모임원 비활성화] API 요청 시작... (ID: $memberId)');
      }

      final response = await _dio.patch(
        '/members/$memberId/deactivate',
        options: Options(
          headers: accessToken != null ? {
            'Authorization': 'Bearer $accessToken',
            'Content-Type': 'application/json',
          } : null,
        ),
      );

      if (response.statusCode == 200) {
        final processedResponse = ApiUtils.processBackendResponse(
          response,
          '모임원 비활성화',
          expectData: false,
        );

        if (AppConfig.debugMode) {
          print('✅ [모임원 비활성화] 성공: ${processedResponse['message']}');
        }
      } else {
        throw Exception('[모임원 비활성화] HTTP 오류: ${response.statusCode}');
      }
    } catch (e) {
      if (e is DioException) {
        throw ApiUtils.processDioException(e, '모임원 비활성화', showDialog: false);
      }
      rethrow;
    }
  }

  /// 🎯 모임원 목록 조회 (기존 기능 통합)
  /// 
  /// API: GET /api/members/list
  /// 권한: STAFF 이상
  Future<MemberListResponse> getMemberList({
    required MemberListFilter filter,
    required String accessToken,
    String? userRole,
  }) async {
    try {
      if (AppConfig.debugMode) {
        print('🚀 [모임원 목록 조회] API 요청 시작... 필터: $filter');
      }

      final response = await _dio.get(
        '/members/list',
        queryParameters: filter.toQueryParameters(),
        options: Options(
          headers: {
            'Authorization': 'Bearer $accessToken',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        final processedResponse = ApiUtils.processBackendResponse(
          response,
          '모임원 목록 조회',
        );

        return MemberListResponse.fromJson(processedResponse['data']);
      } else {
        throw Exception('[모임원 목록 조회] HTTP 오류: ${response.statusCode}');
      }
    } catch (e) {
      if (e is DioException) {
        throw ApiUtils.processDioException(e, '모임원 목록 조회');
      }
      rethrow;
    }
  }

  /// 🛡️ 비활성 계정 필터 사용 가능 여부 확인
  ///
  /// 운영진·준운영진은 비활성 계정 필터 사용 불가
  /// 관리자 이상만 사용 가능
  static bool canUseDeletedFilter(String? userRole) {
    if (userRole == null) return false;
    
    // 관리자 이상만 사용 가능
    const adminRoles = ['ADMIN', 'VICE_LEADER', 'LEADER'];
    return adminRoles.contains(userRole);
  }

  /// 🔔 앵 푸시 수신 여부 조회
  /// 
  /// API: GET /api/members/me/push-setting
  /// 권한: MEMBER 이상
  Future<bool> getPushSetting({required String accessToken}) async {
    try {
      if (AppConfig.debugMode) {
        print('🚀 [앱 푸시 설정 조회] API 요청 시작...');
      }

      final response = await _dio.get(
        '/members/me/push-setting',
        options: Options(
          headers: {
            'Authorization': 'Bearer $accessToken',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        final processedResponse = ApiUtils.processBackendResponse(
          response,
          '앱 푸시 설정 조회',
        );

        final pushEnabled = processedResponse['data'] as bool;
        if (AppConfig.debugMode) {
          print('✅ [앱 푸시 설정 조회] 성공: $pushEnabled');
        }
        return pushEnabled;
      } else {
        throw Exception('[앱 푸시 설정 조회] HTTP 오류: ${response.statusCode}');
      }
    } catch (e) {
      if (e is DioException) {
        throw ApiUtils.processDioException(e, '앱 푸시 설정 조회', showDialog: false);
      }
      rethrow;
    }
  }

  /// 🔔 앵 푸시 수신 여부 수정
  /// 
  /// API: PATCH /api/members/me/push
  /// 권한: MEMBER 이상
  Future<void> updatePushSetting(bool enabled, {required String accessToken}) async {
    try {
      if (AppConfig.debugMode) {
        print('🚀 [앱 푸시 설정] API 요청 시작... (enabled: $enabled)');
      }

      final response = await _dio.patch(
        '/members/me/push-setting',
        data: {'isPushEnabled': enabled},
        options: Options(
          headers: {
            'Authorization': 'Bearer $accessToken',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        final processedResponse = ApiUtils.processBackendResponse(
          response,
          '앱 푸시 설정',
          expectData: false,
        );

        if (AppConfig.debugMode) {
          print('✅ [앱 푸시 설정] 성공: ${processedResponse['message']}');
        }
      } else {
        throw Exception('[앱 푸시 설정] HTTP 오류: ${response.statusCode}');
      }
    } catch (e) {
      if (e is DioException) {
        throw ApiUtils.processDioException(e, '앱 푸시 설정', showDialog: false);
      }
      rethrow;
    }
  }
}
