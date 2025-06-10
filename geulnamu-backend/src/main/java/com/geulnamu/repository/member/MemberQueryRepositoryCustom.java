package com.geulnamu.repository.member;

import com.geulnamu.controller.member.dto.response.MemberInfoResponse;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

public interface MemberQueryRepositoryCustom {
    Page<MemberInfoResponse> findMembersWithPaging(Pageable pageable);
}
