import 'package:dio/dio.dart';
import '../../core/config/app_config.dart';
import '../../core/utils/api_utils.dart';
import '../../models/profile/profile_model.dart';

/// 프로필 관련 API 서비스 (Singleton)
///
/// 제공 기능:
/// - 본인 프로필 조회 (GET /members/me/profile)
/// - 개인 정보 수정 (PATCH /members/me/profile)
/// - ApiUtils를 통한 통합 에러 처리
class ProfileService {
  // 🎯 Singleton 패턴
  static final ProfileService _instance = ProfileService._internal();
  factory ProfileService() => _instance;
  ProfileService._internal() {
    // 🔧 생성자에서 즉시 Dio 초기화
    _dio = ApiUtils.createDioWithTimeout(baseUrl: AppConfig.apiBaseUrl);
  }

  late final Dio _dio;

  /// 본인 프로필 정보 조회
  ///
  /// API: GET /members/me/profile
  /// 권한: MEMBER 이상
  /// 글로벌 캐시 무효화 인터셉터 적용
  Future<ProfileModel> getMyProfile(String accessToken) async {
    try {
      if (AppConfig.debugMode) {
        print('🚀 [ProfileService] 본인 프로필 조회 시작...');
      }

      final response = await _dio.get(
        '/members/me/profile',
        options: Options(
          headers: {
            'Authorization': 'Bearer $accessToken',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        // ✅ ApiUtils 사용하여 백엔드 커스텀 응답 처리
        final processedResponse = ApiUtils.processBackendResponse(
          response,
          '본인 프로필 조회',
        );

        if (processedResponse['success']) {
          final profileData = processedResponse['data'];
          final profile = ProfileModel.fromJson(profileData);

          if (AppConfig.debugMode) {
            print('✅ [ProfileService] 프로필 조회 성공: ${profile.displayName}');
          }

          return profile;
        } else {
          throw Exception('[프로필 조회] ${processedResponse['message']}');
        }
      } else {
        throw Exception('[프로필 조회] HTTP 오류: ${response.statusCode}');
      }
    } catch (e) {
      if (e is DioException) {
        // ✅ ApiUtils 사용하여 통합 에러 처리
        throw ApiUtils.processDioException(e, '본인 프로필 조회');
      }
      rethrow;
    }
  }

  /// 개인 정보 수정
  ///
  /// API: PATCH /members/me/profile
  /// 권한: MEMBER 이상
  /// 수정 가능 필드: name, gender, birthDate
  Future<bool> updateMyProfile(
    String accessToken,
    ProfileModel updatedProfile,
  ) async {
    try {
      if (AppConfig.debugMode) {
        print('🚀 [ProfileService] 개인 정보 수정 시작...');
        print('📝 [ProfileService] 수정 데이터: ${updatedProfile.toUpdateJson()}');
      }

      final response = await _dio.patch(
        '/members/me/profile',
        data: updatedProfile.toUpdateJson(),
        options: Options(
          headers: {
            'Authorization': 'Bearer $accessToken',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        // ✅ ApiUtils 사용하여 백엔드 커스텀 응답 처리
        final processedResponse = ApiUtils.processBackendResponse(
          response,
          '개인 정보 수정',
          expectData: false, // 수정 성공시 data는 null
        );

        if (processedResponse['success']) {
          if (AppConfig.debugMode) {
            print('✅ [ProfileService] 개인 정보 수정 성공');
          }
          return true;
        } else {
          throw Exception('[개인 정보 수정] ${processedResponse['message']}');
        }
      } else {
        throw Exception('[개인 정보 수정] HTTP 오류: ${response.statusCode}');
      }
    } catch (e) {
      if (e is DioException) {
        // ✅ ApiUtils 사용하여 통합 에러 처리
        throw ApiUtils.processDioException(e, '개인 정보 수정');
      }
      rethrow;
    }
  }

  /// 🎯 관리자를 위한 모임원 정보 조회
  ///
  /// API: GET /api/members/{memberId}
  /// 권한: ADMIN 이상
  Future<ProfileModel> getMemberProfile(
    String accessToken,
    int memberId,
  ) async {
    try {
      if (AppConfig.debugMode) {
        print('🚀 [ProfileService] 모임원 정보 조회 시작... (ID: $memberId)');
      }

      final response = await _dio.get(
        '/members/$memberId',
        options: Options(
          headers: {
            'Authorization': 'Bearer $accessToken',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        // ✅ ApiUtils 사용하여 백엔드 커스텀 응답 처리
        final processedResponse = ApiUtils.processBackendResponse(
          response,
          '모임원 정보 조회',
        );

        if (processedResponse['success']) {
          final profileData = processedResponse['data'];
          final profile = ProfileModel.fromJson(profileData);

          if (AppConfig.debugMode) {
            print('✅ [ProfileService] 모임원 정보 조회 성공: ${profile.displayName}');
          }

          return profile;
        } else {
          throw Exception('[모임원 정보 조회] ${processedResponse['message']}');
        }
      } else {
        throw Exception('[모임원 정보 조회] HTTP 오류: ${response.statusCode}');
      }
    } catch (e) {
      if (e is DioException) {
        // ✅ ApiUtils 사용하여 통합 에러 처리
        throw ApiUtils.processDioException(e, '모임원 정보 조회', showDialog: false);
      }
      rethrow;
    }
  }

  /// 프로필 수정 데이터 유효성 검증
  ///
  /// 백엔드 제약조건에 맞춰 검증:
  /// - 이름: 특수문자 제외 2-10자
  /// - 성별: 'MALE' 또는 'FEMALE'
  /// - 생년월일: yyyyMMdd 형식
  static Map<String, String?> validateProfileData({
    required String name,
    required String gender,
    required String birthDate,
  }) {
    final errors = <String, String?>{};

    // 이름 검증
    if (name.trim().isEmpty) {
      errors['name'] = '이름을 입력해주세요.';
    } else if (name.length < 2 || name.length > 10) {
      errors['name'] = '이름은 2자 이상 10자 이하로 입력해주세요.';
    } else if (RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(name)) {
      errors['name'] = '이름에는 특수문자를 사용할 수 없습니다.';
    }

    // 성별 검증
    if (gender != 'MALE' && gender != 'FEMALE') {
      errors['gender'] = '성별을 선택해주세요.';
    }

    // 생년월일 검증 (yyyyMMdd 형식)
    if (birthDate.length != 8 || !RegExp(r'^\d{8}$').hasMatch(birthDate)) {
      errors['birthDate'] = '올바른 생년월일 형식이 아닙니다.';
    } else {
      try {
        final year = int.parse(birthDate.substring(0, 4));
        final month = int.parse(birthDate.substring(4, 6));
        final day = int.parse(birthDate.substring(6, 8));

        final date = DateTime(year, month, day);

        // 유효한 날짜인지 확인
        if (date.year != year || date.month != month || date.day != day) {
          errors['birthDate'] = '존재하지 않는 날짜입니다.';
        } else if (date.isAfter(DateTime.now())) {
          errors['birthDate'] = '생년월일은 현재보다 과거여야 합니다.';
        } else if (date.isBefore(DateTime(1900, 1, 1))) {
          errors['birthDate'] = '1900년 이후 날짜를 입력해주세요.';
        }
      } catch (e) {
        errors['birthDate'] = '올바른 생년월일을 입력해주세요.';
      }
    }

    return errors;
  }
}
