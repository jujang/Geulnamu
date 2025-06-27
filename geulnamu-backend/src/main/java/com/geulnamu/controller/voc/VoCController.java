package com.geulnamu.controller.voc;

import com.geulnamu.controller.voc.dto.request.VoCCreateRequest;
import com.geulnamu.controller.voc.dto.request.VoCViewListRequest;
import com.geulnamu.controller.voc.dto.response.VoCViewListResponse;
import com.geulnamu.domain.shared.enums.ActionType;
import com.geulnamu.domain.shared.enums.DomainType;
import com.geulnamu.domain.shared.enums.Level;
import com.geulnamu.infrastructure.annotation.AccessLevel;
import com.geulnamu.infrastructure.annotation.AuthMemberId;
import com.geulnamu.infrastructure.annotation.ErrorLogAction;
import com.geulnamu.infrastructure.annotation.LogAction;
import com.geulnamu.infrastructure.response.BaseResponse;
import com.geulnamu.service.voc.VoCService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

@RestController
@RequiredArgsConstructor
@RequestMapping("/voc")
public class VoCController {

    private final VoCService voCService;


    @LogAction(value = ActionType.VOC_ERROR_REPORT, actionDomain = DomainType.VOC)
    @AccessLevel(Level.MEMBER)
    @PostMapping(value = "/error-report", name = "에러 보고")
    public BaseResponse<Void> reportError(@AuthMemberId Long memberId,
                                         @Valid @RequestBody VoCCreateRequest request) {
        voCService.reportError(memberId, request.getContent());
        return BaseResponse.ofSuccess();
    }

    @LogAction(value = ActionType.VOC_FEATURE_REQUEST, actionDomain = DomainType.VOC)
    @AccessLevel(Level.MEMBER)
    @PostMapping(value = "/feature-request", name = "기능 요청")
    public BaseResponse<Void> requestFeature(@AuthMemberId Long memberId,
                                          @Valid @RequestBody VoCCreateRequest request) {
        voCService.requestFeature(memberId, request.getContent());
        return BaseResponse.ofSuccess();
    }

    @ErrorLogAction(value = ActionType.VOC_ISSUE_LIST_VIEW, actionDomain = DomainType.VOC)
    @AccessLevel(Level.ADMIN)
    @GetMapping(value = "/list", name = "이슈 목록 조회")
    public BaseResponse<VoCViewListResponse> getIssueList(@Valid VoCViewListRequest request) {
        VoCViewListResponse response = voCService.getIssueList(request);
        return BaseResponse.ofSuccess(response);
    }

}
