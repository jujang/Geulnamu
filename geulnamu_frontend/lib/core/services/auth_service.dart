import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../config/app_config.dart';

/// 🔐 인증 서비스
/// 카카오 OAuth 로그인 및 토큰 관리를 담당합니다.
class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal() {
    // Dio 기본 설정
    _dio.options.connectTimeout = const Duration(seconds: 10);
    _dio.options.receiveTimeout = const Duration(seconds: 10);
    _dio.options.sendTimeout = const Duration(seconds: 10);
  }

  final Dio _dio = Dio();

  /// 카카오 로그인
  Future<Map<String, dynamic>> loginWithKakao() async {
    try {
      if (AppConfig.debugMode) {
        print('🥕 카카오 로그인 시작...');
      }

      OAuthToken token;

      if (kIsWeb) {
        // 웹에서는 JavaScript SDK 사용
        if (AppConfig.debugMode) {
          print('🌐 웹에서 카카오 계정 로그인 시도');
        }
        token = await UserApi.instance.loginWithKakaoAccount();
      } else {
        // 모바일에서는 카카오톡 앱 또는 웹뷰 사용
        if (await isKakaoTalkInstalled()) {
          if (AppConfig.debugMode) {
            print('📱 카카오톡 앱 로그인 시도');
          }
          token = await UserApi.instance.loginWithKakaoTalk();
        } else {
          if (AppConfig.debugMode) {
            print('🌐 카카오 계정 로그인 시도');
          }
          token = await UserApi.instance.loginWithKakaoAccount();
        }
      }

      if (AppConfig.debugMode) {
        print('✅ 카카오 토큰 획득 성공');
      }

      // 카카오 사용자 정보 가져오기
      if (AppConfig.debugMode) {
        print('👤 사용자 정보 조회 중...');
      }
      final kakaoUser = await UserApi.instance.me();
      if (AppConfig.debugMode) {
        print('✅ 사용자 정보 조회 성공: ${kakaoUser.kakaoAccount?.profile?.nickname}');
      }

      // 백엔드 연동 시도 (실패해도 계속 진행)
      Map<String, dynamic> authResponse;
      try {
        authResponse = await _sendKakaoTokenToBackend(
          token.accessToken,
          kakaoUser,
        );
        if (AppConfig.debugMode) {
          print('✅ 백엔드 연동 성공');
        }
      } catch (e) {
        if (AppConfig.debugMode) {
          print('⚠️ 백엔드 연동 실패, 로컬 모드로 계속: $e');
        }
        // 백엔드 없이도 동작하도록 로컬 데이터 생성
        authResponse = {
          'accessToken': token.accessToken,
          'refreshToken': token.refreshToken ?? '',
          'userInfo': {
            'id': kakaoUser.id,
            'nickname': kakaoUser.kakaoAccount?.profile?.nickname ?? '사용자',
            'email': kakaoUser.kakaoAccount?.email,
            'profileImageUrl': kakaoUser.kakaoAccount?.profile?.profileImageUrl,
            'isEmailVerified': kakaoUser.kakaoAccount?.isEmailVerified,
            'ageRange': kakaoUser.kakaoAccount?.ageRange?.toString(),
            'gender': kakaoUser.kakaoAccount?.gender?.toString(),
          },
        };
      }

      // 토큰 저장
      await _saveTokens(authResponse);
      if (AppConfig.debugMode) {
        print('✅ 카카오 로그인 완료');
      }

      return authResponse;
    } catch (error) {
      if (AppConfig.debugMode) {
        print('❌ 카카오 로그인 실패: $error');
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
      if (AppConfig.debugMode) {
        print('🔄 백엔드로 토큰 전송 중...');
      }

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

    await prefs.setString('access_token', authResponse['accessToken'] ?? '');
    await prefs.setString('refresh_token', authResponse['refreshToken'] ?? '');
    await prefs.setString('user_info', jsonEncode(authResponse['userInfo']));

    if (AppConfig.debugMode) {
      print('💾 토큰 저장 완료');
    }
  }

  /// 저장된 토큰 가져오기
  Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token');
  }

  /// 리프레시 토큰 가져오기
  Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('refresh_token');
  }

  /// 사용자 정보 가져오기
  Future<Map<String, dynamic>?> getUserInfo() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userInfoString = prefs.getString('user_info');

      if (userInfoString != null) {
        return jsonDecode(userInfoString);
      }
      return null;
    } catch (e) {
      if (AppConfig.debugMode) {
        print('사용자 정보 가져오기 오류: $e');
      }
      return null;
    }
  }

  /// 토큰 갱신
  Future<Map<String, dynamic>?> refreshToken() async {
    try {
      if (AppConfig.debugMode) {
        print('🔄 토큰 갱신 시도...');
      }

      final refreshToken = await getRefreshToken();
      if (refreshToken == null || refreshToken.isEmpty) {
        if (AppConfig.debugMode) {
          print('❌ 리프레시 토큰이 없습니다');
        }
        return null;
      }

      // 백엔드가 있는 경우 토큰 갱신 시도
      try {
        final response = await _dio.post(
          '${AppConfig.apiBaseUrl}/auth/refresh',
          data: {'refreshToken': refreshToken},
        );

        if (response.statusCode == 200) {
          await _saveTokens(response.data);
          if (AppConfig.debugMode) {
            print('✅ 토큰 갱신 성공');
          }
          return response.data;
        }
      } catch (e) {
        if (AppConfig.debugMode) {
          print('⚠️ 백엔드 토큰 갱신 실패: $e');
        }
      }

      // 백엔드 갱신 실패 시 카카오 사용자 정보로 토큰 유효성 확인
      try {
        final kakaoUser = await UserApi.instance.me();
        if (AppConfig.debugMode) {
          print('✅ 카카오 토큰 유효함: ${kakaoUser.kakaoAccount?.profile?.nickname}');
        }

        // 현재 저장된 사용자 정보 반환
        final userInfo = await getUserInfo();
        return {
          'accessToken': await getAccessToken(),
          'refreshToken': refreshToken,
          'userInfo': userInfo,
        };
      } catch (e) {
        if (AppConfig.debugMode) {
          print('❌ 카카오 토큰도 만료됨: $e');
        }
        return null;
      }
    } catch (e) {
      if (AppConfig.debugMode) {
        print('❌ 토큰 갱신 오류: $e');
      }
      return null;
    }
  }

  /// 로그인 상태 확인
  Future<bool> isLoggedIn() async {
    try {
      final accessToken = await getAccessToken();
      if (accessToken == null || accessToken.isEmpty) {
        if (AppConfig.debugMode) {
          print('📝 저장된 토큰이 없습니다');
        }
        return false;
      }

      // 백엔드가 있는 경우 토큰 유효성 검사
      try {
        final response = await _dio.get(
          '${AppConfig.apiBaseUrl}/auth/verify',
          options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
        );

        if (response.statusCode == 200) {
          if (AppConfig.debugMode) {
            print('✅ 백엔드 토큰 유효');
          }
          return true;
        }
      } catch (e) {
        if (AppConfig.debugMode) {
          print('⚠️ 백엔드 토큰 검증 실패: $e');
        }
      }

      // 백엔드 검증 실패 시 카카오 사용자 정보로 토큰 유효성 확인
      try {
        final kakaoUser = await UserApi.instance.me();
        if (AppConfig.debugMode) {
          print('✅ 카카오 토큰 유효: ${kakaoUser.id}');
        }
        return true;
      } catch (e) {
        if (AppConfig.debugMode) {
          print('❌ 카카오 토큰 만료: $e');
        }
        return false;
      }
    } catch (e) {
      if (AppConfig.debugMode) {
        print('❌ 로그인 상태 확인 오류: $e');
      }
      return false;
    }
  }

  /// 로그아웃
  Future<void> logout() async {
    try {
      if (AppConfig.debugMode) {
        print('👋 로그아웃 시작...');
      }

      // 카카오 로그아웃
      try {
        await UserApi.instance.logout();
        if (AppConfig.debugMode) {
          print('✅ 카카오 로그아웃 완료');
        }
      } catch (e) {
        if (AppConfig.debugMode) {
          print('⚠️ 카카오 로그아웃 오류 (계속 진행): $e');
        }
      }

      // 백엔드 로그아웃 (선택사항)
      try {
        final accessToken = await getAccessToken();
        if (accessToken != null && accessToken.isNotEmpty) {
          await _dio.post(
            '${AppConfig.apiBaseUrl}/auth/logout',
            options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
          );
          if (AppConfig.debugMode) {
            print('✅ 백엔드 로그아웃 완료');
          }
        }
      } catch (e) {
        if (AppConfig.debugMode) {
          print('⚠️ 백엔드 로그아웃 오류 (계속 진행): $e');
        }
      }

      // 로컬 토큰 삭제
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('access_token');
      await prefs.remove('refresh_token');
      await prefs.remove('user_info');

      if (AppConfig.debugMode) {
        print('✅ 로컬 데이터 삭제 완료');
        print('✅ 로그아웃 완료');
      }
    } catch (e) {
      if (AppConfig.debugMode) {
        print('❌ 로그아웃 오류: $e');
      }
      // 오류가 있어도 로컬 데이터는 삭제
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('access_token');
        await prefs.remove('refresh_token');
        await prefs.remove('user_info');
      } catch (e2) {
        if (AppConfig.debugMode) {
          print('❌ 로컬 데이터 삭제 실패: $e2');
        }
      }
    }
  }

  /// 디버그용 - 저장된 정보 출력
  Future<void> printStoredInfo() async {
    if (AppConfig.debugMode) {
      final prefs = await SharedPreferences.getInstance();
      print('🔍 === 저장된 인증 정보 ===');
      print(
        'Access Token: ${(await getAccessToken())?.substring(0, 20) ?? 'null'}...',
      );
      print(
        'Refresh Token: ${(await getRefreshToken())?.substring(0, 20) ?? 'null'}...',
      );
      print('User Info: ${await getUserInfo()}');
      print('========================');
    }
  }
}
