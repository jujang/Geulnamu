package com.geulnamu.controller.actionHistory;

import com.geulnamu.controller.actionHistory.dto.request.ActionHistoryListRequest;
import com.geulnamu.controller.actionHistory.dto.response.ActionHistoryListResponse;
import com.geulnamu.domain.shared.enums.ActionType;
import com.geulnamu.domain.shared.enums.DomainType;
import com.geulnamu.domain.shared.enums.Level;
import com.geulnamu.infrastructure.annotation.AccessLevel;
import com.geulnamu.infrastructure.annotation.ErrorLogAction;
import com.geulnamu.infrastructure.response.BaseResponse;
import com.geulnamu.service.actionHistory.ActionHistoryService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequiredArgsConstructor
@RequestMapping("/action-histories")
public class ActionHistoryController {

    private final ActionHistoryService actionHistoryService;


    @ErrorLogAction(value = ActionType.ACTION_HISTORY_LIST_VIEW, actionDomain = DomainType.ACTION_HISTORY)
    @AccessLevel(Level.ADMIN)
    @GetMapping(value = "/list", name = "로그 목록 조회")
    public BaseResponse<ActionHistoryListResponse> getActionHistories(@Valid ActionHistoryListRequest request) {
        ActionHistoryListResponse response = actionHistoryService.getActionHistoryList(request);
        return BaseResponse.ofSuccess(response);
    }
}
