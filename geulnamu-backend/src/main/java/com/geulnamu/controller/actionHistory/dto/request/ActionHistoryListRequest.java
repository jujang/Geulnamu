package com.geulnamu.controller.actionHistory.dto.request;

import com.geulnamu.domain.actionHistory.ApiMethod;
import com.geulnamu.domain.shared.enums.ActionStatus;
import com.geulnamu.domain.shared.enums.DomainType;
import com.geulnamu.infrastructure.response.paging.PagingRequest;
import jakarta.validation.constraints.Pattern;
import lombok.Getter;

public class ActionHistoryListRequest extends PagingRequest {

    @Pattern(regexp = "SUCCESS|FAILURE", message = "응답 상태는 'SUCCESS' 또는 'FAILURE' 만 가능합니다.")
    private final String status;

    @Pattern(regexp = "LOGIN|MEMBER|MEETING|ATTENDANCE|BOOK_QUESTION|VOC|ACTION_HISTORY", message =
        "활동 유형은 'LOGIN', 'MEMBER', 'MEETING', 'ATTENDANCE', 'BOOK_QUESTION', 'VOC', 'ACTION_HISTORY' 중 하나만 가능합니다.")
    private final String actionDomain;

    @Pattern(regexp = "POST|GET|PATCH|DELETE", message = "API 유형은 'POST', 'GET', 'PATCH', 'DELETE' 중 하나만 가능합니다.")
    private final String apiMethod;

    @Getter
    @Pattern(regexp = "id|processingTimeMs|createdAt", message = "정렬 기준은 'id', 'processingTimeMs', 'createdAt' 중 하나만 가능합니다.")
    private final String sortBy; // 여기에 있는 id는 활동내역 고유번호를 뜻함

    @Pattern(regexp = "true|false", message = "오름차순 여부 값은 'true' 또는 'false' 만 가능합니다.")
    private final String isAsc;


    public ActionStatus getStatus() {
        return status != null ? ActionStatus.valueOf(status) : null;
    }

    public DomainType getActionDomain() {
        return actionDomain != null ? DomainType.valueOf(actionDomain) : null;
    }

    public ApiMethod getApiMethod() {
        return apiMethod != null ? ApiMethod.valueOf(apiMethod) : null;
    }

    public Boolean getIsAsc() {
        return isAsc != null ? Boolean.valueOf(isAsc) : null;
    }

    public ActionHistoryListRequest(String status, String actionDomain, String apiMethod,
                                    String sortBy, String isAsc, Integer page, Integer size) {
        super(page, size);
        this.status = status;
        this.actionDomain = actionDomain;
        this.apiMethod = apiMethod;
        this.sortBy = sortBy;
        this.isAsc = isAsc;
    }

}
