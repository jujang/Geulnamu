import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 앱 정보 화면 로직 Mixin
///
/// 주요 기능:
/// - 캐시 삭제 (SharedPreferences만, 로그인 토큰 유지)
mixin AppInfoLogicMixin<T extends StatefulWidget> on State<T> {
  
  /// 캐시 전체 삭제 처리
  Future<void> handleClearCache(BuildContext context) async {
    // 확인 다이얼로그 표시
    final confirmed = await _showClearCacheConfirmDialog(context);
    
    if (confirmed != true) {
      return; // 사용자가 취소
    }
    
    try {
      // 🎯 SharedPreferences에서 특정 키만 제외하고 삭제
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();
      
      // 🔐 로그인 관련 키는 유지
      final authKeys = {
        'accessToken',
        'refreshToken',
        'member_id',
        'nickname',
        'email',
        'permission_level',
      };
      
      // 캐시 키들만 삭제
      for (final key in keys) {
        if (!authKeys.contains(key)) {
          await prefs.remove(key);
          debugPrint('🗑️ [AppInfo] 캐시 삭제: $key');
        }
      }
      
      if (context.mounted) {
        // 성공 메시지
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('캐시가 성공적으로 삭제되었습니다.'),
            duration: Duration(seconds: 2),
          ),
        );
        
        debugPrint('✅ [AppInfo] 캐시 삭제 완료 (로그인 정보 유지)');
      }
    } catch (e) {
      debugPrint('❌ [AppInfo] 캐시 삭제 실패: $e');
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('캐시 삭제 중 오류가 발생했습니다: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }
  
  /// 캐시 삭제 확인 다이얼로그
  Future<bool?> _showClearCacheConfirmDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('캐시 전체 삭제'),
        content: const Text(
          '앱 설정 및 캐시 데이터가 삭제됩니다.\n'
          '로그인 정보는 유지됩니다.\n\n'
          '정말 삭제하시겠습니까?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('삭제'),
          ),
        ],
      ),
    );
  }
}
