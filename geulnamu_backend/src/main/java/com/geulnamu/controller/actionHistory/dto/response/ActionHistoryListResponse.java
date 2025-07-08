package com.geulnamu.controller.actionHistory.dto.response;

import com.geulnamu.infrastructure.response.paging.PagingResponse;
import lombok.AllArgsConstructor;
import lombok.Getter;

import java.util.List;

@Getter
@AllArgsConstructor
public class ActionHistoryListResponse {
    private PagingResponse pagingResponse;
    private List<ActionHistoryResponse> actionHistoryResponseList;
}
