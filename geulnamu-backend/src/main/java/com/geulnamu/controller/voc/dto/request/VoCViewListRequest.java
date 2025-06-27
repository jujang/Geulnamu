package com.geulnamu.controller.voc.dto.request;

import com.geulnamu.domain.voc.IssueStatus;
import com.geulnamu.domain.voc.VoCType;
import com.geulnamu.infrastructure.response.paging.PagingRequest;
import jakarta.validation.constraints.Pattern;
import lombok.Getter;

public class VoCViewListRequest extends PagingRequest {

    @Pattern(regexp = "PENDING|IN_PROGRESS|RESOLVED|REJECTED|ON_HOLD",
        message = "이슈 상태는 'PENDING', 'IN_PROGRESS', 'RESOLVED', 'REJECTED', 'ON_HOLD' 중 하나만 가능합니다.")
    private final String issueStatus;

    @Pattern(regexp = "ERROR_REPORT|FEATURE_REQUEST",
        message = "이슈 유형은 'ERROR_REPORT' 또는 'FEATURE_REQUEST'만 가능합니다.")
    private final String voCType;

    @Getter
    @Pattern(regexp = "id|memberId|issueStatus|createdAt",
        message = "정렬 기준은 'id', 'memberId', 'issueStatus', 'createdAt' 중 하나만 가능합니다.")
    private final String sortBy;

    @Pattern(regexp = "true|false", message = "오름차순 여부 값은 'true' 또는 'false' 만 가능합니다.")
    private final String isAsc;


    public IssueStatus getIssueStatus() {
        return issueStatus != null ? IssueStatus.valueOf(issueStatus) : null;
    }

    public VoCType getVoCType() {
        return voCType != null ? VoCType.valueOf(voCType) : null;
    }

    public Boolean getIsAsc() {
        return isAsc != null ? Boolean.valueOf(isAsc) : null;
    }

    public VoCViewListRequest(String issueStatus, String voCType, String sortBy, String isAsc,
                              Integer page, Integer size) {
        super(page, size);
        this.issueStatus = issueStatus;
        this.voCType = voCType;
        this.sortBy = sortBy;
        this.isAsc = isAsc;
    }
}
