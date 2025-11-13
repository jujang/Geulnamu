import 'voc_model.dart';

/// VoC 필터 모델
class VoCFilter {
  final IssueStatus? issueStatus;
  final VoCType? voCType;
  final VoCSortBy sortBy;
  final bool isAsc;
  final int size;

  VoCFilter({
    this.issueStatus,
    this.voCType,
    this.sortBy = VoCSortBy.id,
    this.isAsc = false,
    this.size = 10,
  });

  VoCFilter copyWith({
    IssueStatus? issueStatus,
    VoCType? voCType,
    VoCSortBy? sortBy,
    bool? isAsc,
    int? size,
  }) {
    return VoCFilter(
      issueStatus: issueStatus ?? this.issueStatus,
      voCType: voCType ?? this.voCType,
      sortBy: sortBy ?? this.sortBy,
      isAsc: isAsc ?? this.isAsc,
      size: size ?? this.size,
    );
  }

  /// 쿼리 파라미터로 변환
  Map<String, String> toQueryParams(int page) {
    final params = <String, String>{
      'page': page.toString(),
      'size': size.toString(),
      'sortBy': sortBy.value,
      'isAsc': isAsc.toString(),
    };

    if (issueStatus != null) {
      params['issueStatus'] = issueStatus!.value;
    }

    if (voCType != null) {
      params['voCType'] = voCType!.value;
    }

    return params;
  }
}

/// 정렬 기준
enum VoCSortBy {
  id('id', '작성순'),
  issueStatus('issueStatus', '이슈 상태순'),
  memberId('memberId', '작성자 ID순');

  final String value;
  final String displayName;

  const VoCSortBy(this.value, this.displayName);
}
