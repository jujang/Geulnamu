package com.geulnamu.controller.member;

import com.geulnamu.controller.member.dto.*;
import com.geulnamu.domain.shared.enums.Level;
import com.geulnamu.global.response.BaseResponse;
import com.geulnamu.infrastructure.annotation.AuthToken;
import com.geulnamu.infrastructure.annotation.AccessLevel;
import com.geulnamu.service.member.MemberService;
import jakarta.validation.Valid;
import jakarta.validation.constraints.Min;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

@RestController
@RequiredArgsConstructor
@RequestMapping("/member")
public class MemberController {

    private final MemberService memberService;

    @AccessLevel(Level.PUBLIC)
    @PostMapping(name = "모임원 생성 (OAuth 토큰 발행 대안 기능)")
    public BaseResponse createMember(@Valid @RequestBody MemberCreateRequestDTO requestDTO) {
        memberService.createMember(requestDTO.getKakaoMemberId());
        return BaseResponse.ofSuccess();
    }

    @AccessLevel(Level.AUTHENTICATED)
    @GetMapping(value = "/info", name = "모임원 정보 입력 여부 확인")
    public BaseResponse checkMemberInfoRegister(@AuthToken String accessToken) {
        Boolean response = memberService.checkMemberInfoRegister(accessToken);
        return BaseResponse.ofSuccess(response);
    }

    @AccessLevel(Level.AUTHENTICATED)
    @PatchMapping(value = "/info", name = "모임원 정보 수정")
    public BaseResponse updateMemberInfo(@AuthToken String accessToken, @Valid @RequestBody MemberInfoRequestDTO requestDTO) {
        memberService.updateMemberInfo(accessToken, requestDTO);
        return BaseResponse.ofSuccess();
    }

    @AccessLevel(Level.ADMIN)
    @GetMapping(value = "/{memberId}", name = "모임원 조회 (임시 기능)")
    public BaseResponse findMember(@PathVariable @Min(value = 1) Long memberId) {
        MemberInfoResponseDTO responseDTO = memberService.findMember(memberId);
        return BaseResponse.ofSuccess(responseDTO);
    }

    @AccessLevel(Level.ADMIN)
    @PatchMapping(value = "/{memberId}/role", name = "모임원 등급 변경 - 해당 모임원 재로그인 필요")
    public BaseResponse updateMemberRole(@PathVariable @Min(value = 1) Long memberId, @Valid @RequestBody MemberRoleUpdateRequestDTO request) {
        memberService.updateMemberRole(memberId, request.getRole());
        return BaseResponse.ofSuccess();
    }

    @AccessLevel(Level.ADMIN)
    @PatchMapping(value = "/{memberId}/status", name = "모임원 활성화/비활성화")
    public BaseResponse updateMemberStatus(@PathVariable Long memberId, @Valid @RequestBody MemberStatusUpdateRequestDTO request) {
        memberService.updateMemberStatus(memberId, request.getStatus());
        return BaseResponse.ofSuccess();
    }

}
