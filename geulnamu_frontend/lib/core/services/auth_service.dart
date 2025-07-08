import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import '../config/app_config.dart';

/// 🔐 인증 서비스
/// 카카오 OAuth 로그인 및 토큰 관리를 담당합니다.
class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final Dio _dio = Dio();

  /// 카카오 로그인
  Future<Map<String, dynamic>> loginWithKakao() async {
    try {
      OAuthToken token;
      
      if (kIsWeb) {
        // 웹에서는 JavaScript SDK 사용
        token = await UserApi.instance.loginWithKakaoAccount();
      } else {
        // 모바일에서는 카카오톡 앱 또는 웹뷰 사용
        if (await isKakaoTalkInstalled()) {
          token = await UserApi.instance.loginWithKakaoTalk();
        } else {
          token = await UserApi.instance.loginWithKakaoAccount();
        }
      }

      // 카카오 사용자 정보 가져오기
      final kakaoUser = await UserApi.instance.me();
      
      // 백엔드로 카카오 토큰 전송하여 JWT 토큰 받기
      final authResponse = await _sendKakaoTokenToBackend(
        token.accessToken,
        kakaoUser,
      );

      // 토큰 저장
      await _saveTokens(authResponse);

      return authResponse;
      
    } catch (error) {
      if (AppConfig.debugMode) {
        print('카카오 로그인 실패: $error');
      }
      rethrow;
    }
  }

  /// 백엔드로 카카오 토큰 전송
  Future<Map<String, dynamic>> _sendKakaoTokenToBackend(
    String kakaoAccessToken,
    User kakaoUser,
  ) async {
    try {
      final response = await _dio.post(
        '${AppConfig.apiBaseUrl}/auth/kakao/login',
        data: {
          'kakaoAccessToken': kakaoAccessToken,
          'kakaoUserId': kakaoUser.id,
          'nickname': kakaoUser.kakaoAccount?.profile?.nickname,
          'email': kakaoUser.kakaoAccount?.email,
          'profileImageUrl': kakaoUser.kakaoAccount?.profile?.profileImageUrl,
        },
      );

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('백엔드 인증 실패: ${response.statusCode}');
      }
    } catch (e) {
      if (AppConfig.debugMode) {
        print('백엔드 인증 오류: $e');
      }
      rethrow;
    }
  }

  /// 토큰 저장
  Future<void> _saveTokens(Map<String, dynamic> authResponse) async {
    final prefs = await SharedPreferences.getInstance();
    
    await prefs.setString('access_token', authResponse['accessToken']);
    await prefs.setString('refresh_token', authResponse['refreshToken']);
    await prefs.setString('user_info', authResponse['userInfo'].toString());
  }

  /// 저장된 토큰 가져오기
  Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token');
  }

  /// 로그인 상태 확인
  Future<bool> isLoggedIn() async {
    try {
      final accessToken = await getAccessToken();
      if (accessToken == null) return false;

      // 토큰 유효성 검사
      final response = await _dio.get(
        '${AppConfig.apiBaseUrl}/auth/verify',
        options: Options(
          headers: {'Authorization': 'Bearer $accessToken'},
        ),
      );

      return response.statusCode == 200;
    } catch (e) {
      if (AppConfig.debugMode) {
        print('로그인 상태 확인 오류: $e');
      }
      return false;
    }
  }

  /// 로그아웃
  Future<void> logout() async {
    try {
      // 카카오 로그아웃
      await UserApi.instance.logout();
      
      // 로컬 토큰 삭제
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('access_token');
      await prefs.remove('refresh_token');
      await prefs.remove('user_info');
      
    } catch (e) {
      if (AppConfig.debugMode) {
        print('로그아웃 오류: $e');
      }
      // 로컬 데이터는 삭제되었으므로 오류가 있어도 계속 진행
    }
  }
}