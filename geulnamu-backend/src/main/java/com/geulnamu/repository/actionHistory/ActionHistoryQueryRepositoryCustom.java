package com.geulnamu.repository.actionHistory;

import com.geulnamu.controller.actionHistory.dto.request.ActionHistoryListRequest;
import com.geulnamu.controller.actionHistory.dto.response.ActionHistoryResponse;
import org.springframework.data.domain.Page;

public interface ActionHistoryQueryRepositoryCustom {
    Page<ActionHistoryResponse> findActionHistoriesWithPaging(ActionHistoryListRequest request);
}
