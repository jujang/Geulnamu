package com.geulnamu.repository.member;

import com.geulnamu.controller.member.dto.request.MemberListRequest;
import com.geulnamu.controller.member.dto.response.MemberInfoResponse;
import com.geulnamu.infrastructure.response.paging.PagingRequest;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

public interface MemberQueryRepositoryCustom {
    Page<MemberInfoResponse> findMembersWithPaging(MemberListRequest request);
}
