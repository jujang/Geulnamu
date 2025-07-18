import 'package:flutter/material.dart';

/// 🚨 공통 에러 다이얼로그 위젯
/// API 타임아웃, 서버 오류 등을 일관된 UI로 표시
class ErrorDialog {
  /// 🕐 타임아웃 에러 다이얼로그
  static void showTimeoutError(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.timer_off_outlined,
              color: Theme.of(context).colorScheme.error,
              size: 24,
            ),
            const SizedBox(width: 8),
            const Text('연결 시간 초과'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '서버 응답이 지연되고 있습니다.\n잠시 후 다시 시도해주세요.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.errorContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.support_agent,
                        size: 16,
                        color: Theme.of(context).colorScheme.onErrorContainer,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '문제가 지속되면?',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onErrorContainer,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '담당자에게 문의해주세요\n(현재 시간과 발생 화면을 알려주시면 빠른 해결이 가능합니다)',
                    style: TextStyle(
                      fontSize: 11,
                      color: Theme.of(context).colorScheme.onErrorContainer,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              '확인',
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 🌐 네트워크 연결 에러 다이얼로그
  static void showNetworkError(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.wifi_off,
              color: Theme.of(context).colorScheme.error,
              size: 24,
            ),
            const SizedBox(width: 8),
            const Text('네트워크 오류'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '인터넷 연결을 확인하고\n다시 시도해주세요.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '확인해보세요:',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '• Wi-Fi 또는 모바일 데이터 연결 상태\n• 다른 웹사이트 접속 가능 여부',
                    style: TextStyle(
                      fontSize: 11,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              '확인',
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 🔧 일반 서버 에러 다이얼로그
  static void showServerError(
    BuildContext context, {
    String? customMessage,
    String? errorCode,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.error_outline,
              color: Theme.of(context).colorScheme.error,
              size: 24,
            ),
            const SizedBox(width: 8),
            const Text('서버 오류'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              customMessage ?? '서버에서 오류가 발생했습니다.\n잠시 후 다시 시도해주세요.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            if (errorCode != null) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '오류 코드: $errorCode',
                  style: TextStyle(
                    fontSize: 11,
                    fontFamily: 'monospace',
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.errorContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.support_agent,
                    size: 16,
                    color: Theme.of(context).colorScheme.onErrorContainer,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '문제가 계속되면 담당자에게 오류 코드와 함께 문의해주세요',
                      style: TextStyle(
                        fontSize: 11,
                        color: Theme.of(context).colorScheme.onErrorContainer,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              '확인',
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 🚫 비활성화 계정 에러 다이얼로그 (460 전용)
  static void showAccountDeactivatedError(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.block,
              color: Theme.of(context).colorScheme.error,
              size: 24,
            ),
            const SizedBox(width: 8),
            const Text('계정 비활성화'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '비활성화된 계정입니다.\n로그인할 수 없습니다.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.support_agent,
                        size: 16,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '계정 복구 문의',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '관리자 또는 모임장에게 문의해주세요.\n계정 복구나 문제 해결을 도와드리겠습니다.',
                    style: TextStyle(
                      fontSize: 11,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              '확인',
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 📱 사용자 친화적 에러 메시지 자동 선택
  static void showErrorFromException(
    BuildContext context,
    Exception error, {
    String? apiName,
  }) {
    final errorMessage = error.toString();

    if (errorMessage.contains('시간이 초과') || 
        errorMessage.contains('timeout') ||
        errorMessage.contains('Timeout')) {
      showTimeoutError(context);
    } else if (errorMessage.contains('연결할 수 없습니다') ||
               errorMessage.contains('network') ||
               errorMessage.contains('Network') ||
               errorMessage.contains('connection')) {
      showNetworkError(context);
    } else {
      // 에러 코드 추출 시도
      String? errorCode;
      if (apiName != null) {
        errorCode = '[$apiName] ${DateTime.now().millisecondsSinceEpoch}';
      }

      showServerError(
        context,
        customMessage: _extractUserFriendlyMessage(errorMessage),
        errorCode: errorCode,
      );
    }
  }

  /// 🎯 사용자 친화적 에러 메시지 추출
  static String _extractUserFriendlyMessage(String rawError) {
    // 백엔드 커스텀 메시지 추출
    final backendMessageRegex = RegExp(r'백엔드 오류 \([^)]+\): (.+)');
    final match = backendMessageRegex.firstMatch(rawError);
    
    if (match != null && match.group(1) != null) {
      return match.group(1)!;
    }

    // API 이름 제거한 메시지 추출
    final apiMessageRegex = RegExp(r'\[[^\]]+\] (.+)');
    final apiMatch = apiMessageRegex.firstMatch(rawError);
    
    if (apiMatch != null && apiMatch.group(1) != null) {
      return apiMatch.group(1)!;
    }

    // 기본 메시지
    return '서버에서 오류가 발생했습니다.\n잠시 후 다시 시도해주세요.';
  }
}
