import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../../core/services/auth_service.dart';
import '../../core/config/app_config.dart';

// 웹 환경에서만 사용
import 'dart:html' as html show window;

/// 🔄 OAuth 콜백 핸들러 페이지
/// 카카오 OAuth 인증 완료 후 리다이렉트되는 페이지
class OAuthCallbackScreen extends StatefulWidget {
  const OAuthCallbackScreen({super.key});

  @override
  State<OAuthCallbackScreen> createState() => _OAuthCallbackScreenState();
}

class _OAuthCallbackScreenState extends State<OAuthCallbackScreen> {
  bool _isProcessing = true;
  String _statusMessage = '카카오 로그인 처리 중...';

  @override
  void initState() {
    super.initState();
    if (AppConfig.debugMode) {
      print('🔄 OAuthCallbackScreen initState 시작!');
      print('🌐 팡업 여부: ${_isPopup()}');
    }
    
    // 팡업인 경우 PostMessage 전송 후 종료
    if (_isPopup()) {
      _handlePopupCallback();
    } else {
      // 메인 창인 경우 일반 OAuth 처리
      _handleOAuthCallback();
    }
  }

  /// 팡업 여부 확인
  bool _isPopup() {
    if (!kIsWeb) return false;
    
    try {
      // opener가 있으면 팡업
      return html.window.opener != null;
    } catch (e) {
      return false;
    }
  }

  /// 팡업에서의 콜백 처리 (간단)
  Future<void> _handlePopupCallback() async {
    try {
      if (AppConfig.debugMode) {
        print('🔄 팡업 OAuth 콜백 처리 시작...');
      }

      // URL에서 코드 추출
      final code = await _extractCodeFromUrl();
      
      if (code.isNotEmpty) {
        // 부모 창으로 코드 전송
        if (html.window.opener != null) {
          html.window.opener!.postMessage('KAKAO_AUTH_CODE:$code', '*');
          if (AppConfig.debugMode) {
            print('📬 부모 창으로 코드 전송: ${code.substring(0, 20)}...');
          }
          
          // 잠시 대기 후 팡업 닫기
          await Future.delayed(const Duration(milliseconds: 500));
          html.window.close();
        }
      } else {
        throw Exception('카카오 OAuth에서 인증 코드를 받지 못했습니다.');
      }
      
    } catch (error) {
      if (AppConfig.debugMode) {
        print('❌ 팡업 OAuth 콜백 처리 실패: $error');
      }
      
      // 에러 메시지 전송
      if (html.window.opener != null) {
        html.window.opener!.postMessage('KAKAO_AUTH_ERROR:$error', '*');
      }
      
      // 팡업 닫기
      await Future.delayed(const Duration(seconds: 1));
      html.window.close();
    }
  }

  /// OAuth 콜백 처리
  Future<void> _handleOAuthCallback() async {
    try {
      if (AppConfig.debugMode) {
        print('🔄 OAuth 콜백 처리 시작...');
        print('🌐 kIsWeb: $kIsWeb');
      }

      if (!kIsWeb) {
        throw Exception('이 기능은 웹에서만 사용 가능합니다.');
      }

      // 웹 전용 URL 처리
      final code = await _extractCodeFromUrl();
      
      if (AppConfig.debugMode) {
        print('🔑 Authorization Code: ${code.substring(0, 20)}...');
      }

      if (code.isEmpty) {
        throw Exception('카카오 OAuth에서 인증 코드를 받지 못했습니다.');
      }

      setState(() {
        _statusMessage = '백엔드 서버와 통신 중...';
      });

      // AuthService를 통해 백엔드로 코드 전송
      final authService = AuthService();
      final authResponse = await authService.processOAuthCode(code);
      
      setState(() {
        _statusMessage = '로그인 완료! 메인 화면으로 이동 중...';
      });

      if (AppConfig.debugMode) {
        print('✅ OAuth 콜백 처리 완료');
        print('👤 사용자 정보: ${authResponse['userInfo']}');
      }

      // 잠시 대기 후 메인 화면으로 이동
      await Future.delayed(const Duration(seconds: 1));
      
      if (mounted) {
        // 메인 화면으로 이동
        Navigator.of(context).pushReplacementNamed('/home');
      }
      
    } catch (error) {
      if (AppConfig.debugMode) {
        print('❌ OAuth 콜백 처리 실패: $error');
      }
      
      setState(() {
        _isProcessing = false;
        _statusMessage = '로그인 실패: $error';
      });
      
      // 3초 후 로그인 화면으로 돌아가기
      await Future.delayed(const Duration(seconds: 3));
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/login');
      }
    }
  }

  /// URL에서 코드 추출 후 부모 창으로 전송
  Future<String> _extractCodeFromUrl() async {
    if (!kIsWeb) {
      throw Exception('웹 환경에서만 지원됩니다.');
    }

    try {
      if (AppConfig.debugMode) {
        print('🌐 현재 URL: ${html.window.location.href}');
      }

      // 현재 URL에서 authorization code 추출
      final uri = Uri.parse(html.window.location.href);
      final code = uri.queryParameters['code'];
      
      if (AppConfig.debugMode) {
        print('📋 URL 파라미터: ${uri.queryParameters}');
      }

      if (code != null && code.isNotEmpty) {
        // 부모 창으로 PostMessage 전송
        if (html.window.opener != null) {
          html.window.opener!.postMessage('KAKAO_AUTH_CODE:$code', '*');
          if (AppConfig.debugMode) {
            print('📬 부모 창으로 코드 전송: ${code.substring(0, 20)}...');
          }
        }
      }

      return code ?? '';
    } catch (e) {
      if (AppConfig.debugMode) {
        print('❌ 웹 URL 파싱 오류: $e');
      }
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 로고
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(40),
              ),
              child: const Icon(
                Icons.auto_stories,
                size: 40,
                color: Colors.white,
              ),
            ),
            
            const SizedBox(height: 32),
            
            // 상태 메시지
            Text(
              _statusMessage,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Theme.of(context).colorScheme.onBackground,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 24),
            
            // 로딩 인디케이터 또는 재시도 버튼
            if (_isProcessing)
              CircularProgressIndicator(
                color: Theme.of(context).colorScheme.primary,
              )
            else
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushReplacementNamed('/login');
                },
                child: const Text('로그인 화면으로 돌아가기'),
              ),
          ],
        ),
      ),
    );
  }
}
