import 'package:dio/dio.dart';
import '../../core/config/app_config.dart';
import '../../core/utils/api_utils.dart';
import '../../models/contact/contact_request.dart';
import '../../providers/auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

/// 문의하기 (VoC) 관련 비즈니스 로직을 담당하는 Singleton Service
///
/// 기능:
/// - 에러 보고 API 호출
/// - 기능 요청 API 호출
/// - ApiUtils 활용으로 일관된 응답 처리
/// - 디버깅 로그 자동 출력
class ContactService {
  static final ContactService _instance = ContactService._internal();
  factory ContactService() => _instance;
  ContactService._internal();

  final Dio _dio = Dio();

  /// 에러 보고 API 호출
  /// 
  /// [content] 에러 내용
  /// [context] BuildContext (토큰 접근용)
  /// Returns: API 성공 여부
  Future<bool> reportError(String content, BuildContext context) async {
    try {
      // 🔑 액세스 토큰 가져오기
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final accessToken = await authProvider.accessToken;
      
      if (accessToken == null) {
        throw Exception('[에러 보고] 액세스 토큰을 찾을 수 없습니다.');
      }

      final request = ContactRequest(content: content);
      
      final response = await _dio.post(
        AppConfig.getApiEndpoint('voc/error-report'),
        data: request.toJson(),
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $accessToken', // 🔑 토큰 추가
          },
        ),
      );

      if (response.statusCode == 200) {
        // ✅ ApiUtils를 사용한 백엔드 응답 처리
        final processedResponse = ApiUtils.processBackendResponse(
          response,
          '에러 보고',
          expectData: false, // Void 응답이므로 data 체크 안함
        );

        if (processedResponse['success']) {
          return true;
        } else {
          throw Exception('[에러 보고] 백엔드 오류: ${processedResponse['message']}');
        }
      } else {
        throw Exception('[에러 보고] HTTP 오류: ${response.statusCode}');
      }
    } catch (e) {
      if (e is DioException) {
        // ✅ ApiUtils를 사용한 에러 처리
        throw ApiUtils.processDioException(e, '에러 보고');
      }
      rethrow;
    }
  }

  /// 기능 요청 API 호출
  /// 
  /// [content] 기능 요청 내용
  /// [context] BuildContext (토큰 접근용)
  /// Returns: API 성공 여부
  Future<bool> requestFeature(String content, BuildContext context) async {
    try {
      // 🔑 액세스 토큰 가져오기
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final accessToken = await authProvider.accessToken;
      
      if (accessToken == null) {
        throw Exception('[기능 요청] 액세스 토큰을 찾을 수 없습니다.');
      }

      final request = ContactRequest(content: content);
      
      final response = await _dio.post(
        AppConfig.getApiEndpoint('voc/feature-request'),
        data: request.toJson(),
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $accessToken', // 🔑 토큰 추가
          },
        ),
      );

      if (response.statusCode == 200) {
        // ✅ ApiUtils를 사용한 백엔드 응답 처리
        final processedResponse = ApiUtils.processBackendResponse(
          response,
          '기능 요청',
          expectData: false, // Void 응답이므로 data 체크 안함
        );

        if (processedResponse['success']) {
          return true;
        } else {
          throw Exception('[기능 요청] 백엔드 오류: ${processedResponse['message']}');
        }
      } else {
        throw Exception('[기능 요청] HTTP 오류: ${response.statusCode}');
      }
    } catch (e) {
      if (e is DioException) {
        // ✅ ApiUtils를 사용한 에러 처리
        throw ApiUtils.processDioException(e, '기능 요청');
      }
      rethrow;
    }
  }

  /// 문의 내용 유효성 검증
  /// 
  /// [content] 검증할 내용
  /// Returns: {isValid: bool, message: String?}
  Map<String, dynamic> validateContent(String content) {
    final trimmedContent = content.trim();
    
    if (trimmedContent.isEmpty) {
      return {
        'isValid': false,
        'message': '내용을 입력해주세요.',
      };
    }
    
    if (trimmedContent.length < 5) {
      return {
        'isValid': false,
        'message': '최소 5자 이상 입력해주세요.',
      };
    }
    
    if (trimmedContent.length > 1000) {
      return {
        'isValid': false,
        'message': '1000자 이하로 입력해주세요.',
      };
    }
    
    return {
      'isValid': true,
      'message': null,
    };
  }
}
