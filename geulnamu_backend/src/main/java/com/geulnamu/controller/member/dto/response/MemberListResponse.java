package com.geulnamu.controller.member.dto.response;

import com.geulnamu.infrastructure.response.paging.PagingResponse;
import lombok.AllArgsConstructor;
import lombok.Getter;

import java.util.List;

@Getter
@AllArgsConstructor
public class MemberListResponse {

    private PagingResponse pagingResponse;
    private List<MemberInfoResponse> memberList;

}
