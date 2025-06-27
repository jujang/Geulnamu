package com.geulnamu.controller.voc.dto.request;

import com.geulnamu.domain.voc.IssueStatus;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;
import lombok.AllArgsConstructor;
import lombok.Getter;

@AllArgsConstructor
public class VoCManageRequest {

    @NotBlank(message = "변경할 이슈 상태 필수 입력")
    @Pattern(regexp = "PENDING|IN_PROGRESS|RESOLVED|REJECTED|ON_HOLD",
        message = "이슈 상태는 'PENDING', 'IN_PROGRESS', 'RESOLVED', 'REJECTED', 'ON_HOLD' 중 하나만 가능합니다.")
    private String issueStatus;

    @Getter
    @Size(max = 255, message = "관리자 코멘트는 255자 이내로 입력해야 합니다.")
    private String adminComment;

    public IssueStatus getIssueStatus() {
        return issueStatus != null ? IssueStatus.valueOf(issueStatus) : null;
    }
}
