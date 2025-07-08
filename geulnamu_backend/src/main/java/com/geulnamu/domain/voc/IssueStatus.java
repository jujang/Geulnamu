package com.geulnamu.domain.voc;

import lombok.Getter;

@Getter
public enum IssueStatus {

    PENDING("접수됨", "새로 접수된 이슈"),
    IN_PROGRESS("처리중", "개발자가 확인하여 처리중인 이슈"),
    RESOLVED("해결됨", "이슈가 해결되어 완료된 상태"),
    REJECTED("반려됨", "처리할 수 없거나 부적절한 이슈"),
    ON_HOLD("보류", "현재 처리가 보류된 상태");

    private final String displayName;
    private final String description;

    IssueStatus(String displayName, String description) {
        this.displayName = displayName;
        this.description = description;
    }

}
