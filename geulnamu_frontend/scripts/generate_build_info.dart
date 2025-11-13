import 'dart:io';

/// 빌드 정보 자동 생성 스크립트
/// 
/// 실행 방법:
/// ```bash
/// dart scripts/generate_build_info.dart
/// ```
/// 
/// 또는 빌드 전 자동 실행:
/// ```bash
/// dart scripts/generate_build_info.dart && flutter build web
/// ```
void main() {
  print('🔨 빌드 정보 생성 중...');
  
  final now = DateTime.now();
  final formatted = '${now.year}.${now.month.toString().padLeft(2, '0')}.${now.day.toString().padLeft(2, '0')}';
  
  final content = '''
// ⚠️ 자동 생성 파일 - 직접 수정하지 마세요!
// Generated at: $now
// 
// 이 파일은 빌드 시점에 자동으로 생성됩니다.
// 수정이 필요한 경우 scripts/generate_build_info.dart를 수정하세요.

/// 빌드 정보 클래스
/// 
/// 컴파일 시점의 날짜와 시간 정보를 제공합니다.
class BuildInfo {
  /// 빌드 날짜 (YYYY.MM.DD 형식)
  /// 
  /// 예: 2025.01.16
  static const String buildDate = '$formatted';
  
  /// 빌드 일시 (ISO 8601 형식)
  /// 
  /// 예: 2025-01-16T15:30:45.123456
  static const String buildDateTime = '${now.toIso8601String()}';
  
  /// 빌드 타임스탬프 (밀리초)
  static const int buildTimestamp = ${now.millisecondsSinceEpoch};
}
''';

  // 파일 경로
  final outputDir = Directory('lib/core/constants');
  final outputFile = File('lib/core/constants/build_info.dart');
  
  // 디렉토리가 없으면 생성
  if (!outputDir.existsSync()) {
    outputDir.createSync(recursive: true);
    print('📁 디렉토리 생성: ${outputDir.path}');
  }
  
  // 파일 생성
  outputFile.writeAsStringSync(content);
  
  print('✅ BuildInfo 생성 완료!');
  print('📅 빌드 날짜: $formatted');
  print('📄 파일 위치: ${outputFile.path}');
}
