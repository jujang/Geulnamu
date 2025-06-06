package com.geulnamu.repository.member;

import com.geulnamu.controller.member.dto.response.MemberInfoResponseDTO;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

public interface MemberDslRepository {

    Page<MemberInfoResponseDTO> findMembers(Pageable pageable);

}
