package com.geulnamu.service.voc;

import com.geulnamu.controller.voc.dto.request.VoCManageRequest;
import com.geulnamu.controller.voc.dto.request.VoCViewListRequest;
import com.geulnamu.controller.voc.dto.response.VoCViewListResponse;
import com.geulnamu.controller.voc.dto.response.VoCViewResponse;
import com.geulnamu.domain.shared.enums.DomainType;
import com.geulnamu.domain.shared.enums.Role;
import com.geulnamu.domain.voc.VoC;
import com.geulnamu.domain.voc.VoCType;
import com.geulnamu.infrastructure.exception.BadRequestException;
import com.geulnamu.infrastructure.exception.NotFoundDataException;
import com.geulnamu.infrastructure.response.ResponseMessage;
import com.geulnamu.infrastructure.response.paging.PagingResponse;
import com.geulnamu.repository.voc.VoCCommandRepository;
import com.geulnamu.repository.voc.VoCQueryRepository;
import lombok.AllArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@AllArgsConstructor
public class VoCService {

    private final VoCQueryRepository voCQueryRepository;
    private final VoCCommandRepository voCCommandRepository;

    @Transactional(rollbackFor = Exception.class)
    public void reportError(Long memberId, String content) {
        VoC voC = VoC.createVoC(memberId, VoCType.ERROR_REPORT, content);
        voCCommandRepository.save(voC);
    }

    @Transactional(rollbackFor = Exception.class)
    public void requestFeature(Long memberId, String content) {
        VoC voC = VoC.createVoC(memberId, VoCType.FEATURE_REQUEST, content);
        voCCommandRepository.save(voC);
    }

    @Transactional(readOnly = true)
    public VoCViewListResponse getIssueList(VoCViewListRequest request) {
        Page<VoCViewResponse> voCViewDslList = voCQueryRepository.findVoCIssuesWithPaging(request);

        PagingResponse pagingResponse = PagingResponse.from(voCViewDslList);
        List<VoCViewResponse> voCViewResponseList = voCViewDslList.getContent();
        return new VoCViewListResponse(pagingResponse, voCViewResponseList);
    }

    @Transactional(rollbackFor = Exception.class)
    public void modifyIssueStatus(Long vocId, Role role, VoCManageRequest request) {
        if(!role.equals(Role.ADMIN)) {
            throw new BadRequestException(ResponseMessage.ONLY_ADMIN_ROLE_RESTRICTION);
        }
        VoC voC = voCQueryRepository.findById(vocId)
            .orElseThrow(() -> new NotFoundDataException(DomainType.VOC.getDescription()));
        voC.updateIssueStatus(request.getIssueStatus(), request.getAdminComment());
    }

}
