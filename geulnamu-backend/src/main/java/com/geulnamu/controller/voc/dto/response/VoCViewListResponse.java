package com.geulnamu.controller.voc.dto.response;

import com.geulnamu.infrastructure.response.paging.PagingResponse;
import lombok.AllArgsConstructor;
import lombok.Getter;

import java.util.List;

@Getter
@AllArgsConstructor
public class VoCViewListResponse {
    private PagingResponse pagingResponse;
    private List<VoCViewResponse> voCViewResponseList;
}
