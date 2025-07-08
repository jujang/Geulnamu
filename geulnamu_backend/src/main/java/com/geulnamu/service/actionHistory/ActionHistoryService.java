package com.geulnamu.service.actionHistory;

import com.geulnamu.controller.actionHistory.dto.request.ActionHistoryListRequest;
import com.geulnamu.controller.actionHistory.dto.response.ActionHistoryListResponse;
import com.geulnamu.controller.actionHistory.dto.response.ActionHistoryResponse;
import com.geulnamu.infrastructure.response.paging.PagingResponse;
import com.geulnamu.repository.actionHistory.ActionHistoryQueryRepository;
import lombok.AllArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@AllArgsConstructor
public class ActionHistoryService {

    private final ActionHistoryQueryRepository actionHistoryQueryRepository;


    @Transactional(readOnly = true)
    public ActionHistoryListResponse getActionHistoryList(ActionHistoryListRequest request) {
        Page<ActionHistoryResponse> actionHistoryDslList = actionHistoryQueryRepository.findActionHistoriesWithPaging(request);

        PagingResponse pagingResponse = PagingResponse.from(actionHistoryDslList);
        List<ActionHistoryResponse> actionHistoryList = actionHistoryDslList.getContent();
        return new ActionHistoryListResponse(pagingResponse, actionHistoryList);
    }

}
