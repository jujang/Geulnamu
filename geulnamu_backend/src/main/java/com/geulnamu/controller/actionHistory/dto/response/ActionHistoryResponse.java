package com.geulnamu.controller.actionHistory.dto.response;

import com.fasterxml.jackson.annotation.JsonFormat;
import com.geulnamu.domain.actionHistory.ApiMethod;
import com.geulnamu.domain.shared.enums.ActionStatus;
import com.geulnamu.domain.shared.enums.ActionType;
import com.geulnamu.domain.shared.enums.DomainType;
import lombok.AllArgsConstructor;
import lombok.Getter;

import java.time.LocalDateTime;

@Getter
@AllArgsConstructor
public class ActionHistoryResponse {

    private Long actionHistoryId;
    private ActionType actionType;
    private ActionStatus status;
    private Long actorMemberId;
    private DomainType actionDomain;
    private Long targetId;
    private String requestData;
    private String responseData;
    private ApiMethod requestMethod;
    private String requestURI;
    private Long processingTimeMs;
    private String ipAddress;
    private String userAgent;
    @JsonFormat(shape = JsonFormat.Shape.STRING, pattern = "yyyy.MM.dd HH:mm")
    private LocalDateTime createdAt;

}
