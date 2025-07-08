package com.geulnamu.repository.voc;

import com.geulnamu.controller.voc.dto.request.VoCViewListRequest;
import com.geulnamu.controller.voc.dto.response.VoCViewResponse;
import org.springframework.data.domain.Page;

public interface VoCQueryRepositoryCustom {
    Page<VoCViewResponse> findVoCIssuesWithPaging(VoCViewListRequest request);
}
