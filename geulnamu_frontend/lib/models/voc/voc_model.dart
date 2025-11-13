/// VoC (Voice of Customer) 이슈 모델

import '../../core/config/app_config.dart';

class VoCIssue {
  final int vocId;
  final int memberId;
  final VoCType voCType;
  final String content;
  final IssueStatus issueStatus;
  final String? adminComment;
  final DateTime createdAt;
  final DateTime? lastModifiedAt; // 🔥 null 가능하게 변경!

  VoCIssue({
    required this.vocId,
    required this.memberId,
    required this.voCType,
    required this.content,
    required this.issueStatus,
    this.adminComment,
    required this.createdAt,
    this.lastModifiedAt, // 🔥 required 제거
  });

  factory VoCIssue.fromJson(Map<String, dynamic> json) {
    try {
      return VoCIssue(
        vocId: json['vocId'] as int,
        memberId: json['memberId'] as int,
        voCType: VoCType.fromString(json['voCType'] as String),
        content: json['content'] as String,
        issueStatus: IssueStatus.fromString(json['issueStatus'] as String),
        adminComment: json['adminComment'] as String?,
        createdAt: _parseCustomDateTime(json['createdAt'] as String),
        lastModifiedAt: json['lastModifiedAt'] != null
            ? _parseCustomDateTime(json['lastModifiedAt'] as String)
            : null, // 🔥 null 처리
      );
    } catch (e) {
      print('❌ [VoCIssue.fromJson] 파싱 오류: $e');
      print('📄 JSON 데이터: $json');
      rethrow;
    }
  }

  /// 백엔드 커스텀 날짜 형식 파싱 (yyyy.MM.dd HH:mm)
  static DateTime _parseCustomDateTime(String dateTimeStr) {
    // "2025.11.12 18:26" -> "2025-11-12T18:26:00"
    final parts = dateTimeStr.split(' ');
    if (parts.length != 2) {
      throw FormatException('Invalid date format: $dateTimeStr');
    }

    final datePart = parts[0].replaceAll('.', '-'); // "2025.11.12" -> "2025-11-12"
    final timePart = parts[1]; // "18:26"

    return DateTime.parse('${datePart}T$timePart:00'); // ISO 8601 형식으로 변환
  }

  Map<String, dynamic> toJson() {
    return {
      'vocId': vocId,
      'memberId': memberId,
      'voCType': voCType.value,
      'content': content,
      'issueStatus': issueStatus.value,
      'adminComment': adminComment,
      'createdAt': createdAt.toIso8601String(),
      'lastModifiedAt': lastModifiedAt?.toIso8601String(), // 🔥 null-aware 연산자
    };
  }
}

/// VoC 이슈 유형
enum VoCType {
  errorReport('ERROR_REPORT', '에러 보고', '🐛'),
  featureRequest('FEATURE_REQUEST', '기능 요청', '💡');

  final String value;
  final String displayName;
  final String icon;

  const VoCType(this.value, this.displayName, this.icon);

  static VoCType fromString(String value) {
    return VoCType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => VoCType.errorReport,
    );
  }
}

/// 이슈 상태
enum IssueStatus {
  pending('PENDING', '대기중', '⏳', 0xFF9E9E9E), // 회색
  inProgress('IN_PROGRESS', '진행중', '🔄', 0xFF2196F3), // 파란색
  resolved('RESOLVED', '해결됨', '✅', 0xFF4CAF50), // 초록색
  rejected('REJECTED', '거절됨', '❌', 0xFFF44336), // 빨간색
  onHold('ON_HOLD', '보류', '⏸️', 0xFFFF9800); // 주황색

  final String value;
  final String displayName;
  final String icon;
  final int colorValue;

  const IssueStatus(this.value, this.displayName, this.icon, this.colorValue);

  static IssueStatus fromString(String value) {
    return IssueStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => IssueStatus.pending,
    );
  }
}

/// VoC 목록 응답
class VoCListResponse {
  final int pageNumber;
  final int totalPages;
  final int totalElements;
  final List<VoCIssue> issues;

  VoCListResponse({
    required this.pageNumber,
    required this.totalPages,
    required this.totalElements,
    required this.issues,
  });

  factory VoCListResponse.fromJson(Map<String, dynamic> json) {
    try {
      final pagingResponse = json['pagingResponse'] as Map<String, dynamic>;
      final issueList = json['voCViewResponseList'] as List<dynamic>;

      if (AppConfig.debugMode) {
        print('📄 [VoCListResponse] pagingResponse: $pagingResponse');
        print('📄 [VoCListResponse] issueList 개수: ${issueList.length}');
      }

      return VoCListResponse(
        pageNumber: pagingResponse['pageNumber'] as int,
        totalPages: pagingResponse['totalPages'] as int,
        totalElements: pagingResponse['totalElements'] as int,
        issues: issueList
            .map((item) => VoCIssue.fromJson(item as Map<String, dynamic>))
            .toList(),
      );
    } catch (e) {
      print('❌ [VoCListResponse.fromJson] 파싱 오류: $e');
      print('📄 JSON 데이터: $json');
      rethrow;
    }
  }
}
