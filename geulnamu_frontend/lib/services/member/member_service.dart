import 'package:dio/dio.dart';
import '../../core/config/app_config.dart';
import '../../core/utils/api_utils.dart';
import '../../models/member/member_list_model.dart';

/// 모임원 관련 API 서비스
/// 
/// 임원진 이상 권한이 필요한 모임원 관리 기능 제공
class MemberService {
  static final MemberService _instance = MemberService._internal();
  factory MemberService() => _instance;
  MemberService._internal();

  final Dio _dio = Dio();

  /// 모임원 목록 조회
  /// 
  /// [filter] 필터 및 정렬 옵션
  /// [accessToken] 인증 토큰 (임원진 이상 권한 필요)
  /// [userRole] 사용자 권한 (운영진·준운영진은 활성 계정만 조회)
  Future<MemberListResponse> getMemberList({
    required MemberListFilter filter,
    required String accessToken,
    required String? userRole,
  }) async {
    try {
      // 🎯 운영진·준운영진은 자동으로 활성 계정만 조회
      final adjustedFilter = _adjustFilterForUserRole(filter, userRole);
      
      if (AppConfig.debugMode) {
        print('🚀 [모임원 목록 조회] API 요청 시작...');
        print('🔍 [모임원 목록 조회] 사용자 권한: $userRole');
        print('🔍 [모임원 목록 조회] 원본 필터: $filter');
        print('🔍 [모임원 목록 조회] 조정된 필터: $adjustedFilter');
      }

      final response = await _dio.get(
        AppConfig.getApiEndpoint('members/list'),
        queryParameters: adjustedFilter.toQueryParameters(),
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

        final memberListResponse = MemberListResponse.fromJson(processedResponse['data']);

        if (AppConfig.debugMode) {
          print('✅ [모임원 목록 조회] 성공: ${memberListResponse.memberList.length}명');
          print('📄 [모임원 목록 조회] 페이지: ${memberListResponse.pagingResponse.pageNumber}/${memberListResponse.pagingResponse.totalPages}');
          print('📄 [모임원 목록 조회] 전체 인원: ${memberListResponse.pagingResponse.totalElements}명');
        }

        return memberListResponse;
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

  /// 특정 모임원 상세 조회 (관리자급 이상)
  /// 
  /// [memberId] 조회할 모임원 ID
  /// [accessToken] 인증 토큰 (관리자급 이상 권한 필요)
  /// 
  /// 향후 구현 예정
  Future<Map<String, dynamic>> getMemberDetail({
    required int memberId,
    required String accessToken,
  }) async {
    // TODO: 향후 구현
    throw UnimplementedError('모임원 상세 조회 기능은 향후 구현 예정입니다.');
  }

  /// 모임원 권한 변경 (관리자급 이상)
  /// 
  /// [memberId] 대상 모임원 ID
  /// [newRole] 새로운 권한
  /// [accessToken] 인증 토큰 (관리자급 이상 권한 필요)
  /// 
  /// 향후 구현 예정
  Future<void> updateMemberRole({
    required int memberId,
    required String newRole,
    required String accessToken,
  }) async {
    // TODO: 향후 구현
    throw UnimplementedError('모임원 권한 변경 기능은 향후 구현 예정입니다.');
  }

  /// 모임원 이름 변경 (관리자급 이상)
  /// 
  /// [memberId] 대상 모임원 ID
  /// [newName] 새로운 이름
  /// [accessToken] 인증 토큰 (관리자급 이상 권한 필요)
  /// 
  /// 향후 구현 예정
  Future<void> updateMemberName({
    required int memberId,
    required String newName,
    required String accessToken,
  }) async {
    // TODO: 향후 구현
    throw UnimplementedError('모임원 이름 변경 기능은 향후 구현 예정입니다.');
  }

  /// 모임원 활성화/비활성화 (관리자급 이상)
  /// 
  /// [memberId] 대상 모임원 ID
  /// [activate] true: 활성화, false: 비활성화
  /// [accessToken] 인증 토큰 (관리자급 이상 권한 필요)
  /// 
  /// 향후 구현 예정
  Future<void> updateMemberStatus({
    required int memberId,
    required bool activate,
    required String accessToken,
  }) async {
    // TODO: 향후 구현
    throw UnimplementedError('모임원 상태 변경 기능은 향후 구현 예정입니다.');
  }

  /// 사용자 권한에 따른 필터 조정
  /// 
  /// 운영진·준운영진은 자동으로 활성 계정만 조회하도록 필터 조정
  MemberListFilter _adjustFilterForUserRole(MemberListFilter filter, String? userRole) {
    // 🎯 운영진·준운영진은 항상 활성 계정만 조회
    if (userRole == 'STAFF' || userRole == 'VICE_STAFF') {
      return filter.copyWith(isDeleted: false);
    }
    
    // 다른 권한(관리자, 부모임장, 모임장)은 원본 필터 그대로 사용
    return filter;
  }

  /// 사용자 권한이 비활성 계정 필터를 사용할 수 있는지 확인
  /// 
  /// 운영진·준운영진은 비활성 계정 필터 사용 불가
  static bool canUseDeletedFilter(String? userRole) {
    if (userRole == null) return false;
    
    // 🎯 운영진·준운영진은 비활성 계정 필터 사용 불가
    if (userRole == 'STAFF' || userRole == 'VICE_STAFF') {
      return false;
    }
    
    // 관리자, 부모임장, 모임장은 비활성 계정 필터 사용 가능
    return true;
  }

  /// 디버그용 - 서비스 상태 출력
  void printServiceInfo() {
    print('📊 === MemberService 정보 ===');
    print('서비스: 모임원 관리');
    print('권한: STAFF 이상 (임원진 이상)');
    print('주요 기능: 모임원 목록 조회, 필터링, 정렬');
    print('🆕 특별 규칙: 운영진·준운영진은 활성 계정만 조회');
    print('🆕 필터 제한: 운영진·준운영진은 비활성 계정 필터 사용 불가');
    print('==========================');
  }
}
