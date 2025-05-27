package com.geulnamu.controller.member;

import com.geulnamu.controller.member.dto.*;
import com.geulnamu.global.response.BaseResponse;
import com.geulnamu.infrastructure.annotation.AuthToken;
import com.geulnamu.service.member.MemberService;
import jakarta.validation.Valid;
import jakarta.validation.constraints.Min;
import lombok.RequiredArgsConstructor;
import org.springframework.security.access.annotation.Secured;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

@RestController
@RequiredArgsConstructor
@RequestMapping("/member")
public class MemberController {

    private final MemberService memberService;

    @PostMapping(name = "회원 생성 (OAuth 토큰 발행 대안 기능)")
    public BaseResponse createMember(@Valid @RequestBody MemberCreateRequestDTO requestDTO) {
        memberService.createMember(requestDTO.getKakaoMemberId());
        return BaseResponse.ofSuccess();
    }

    // TODO: 등급별 API 접근 권한은 어디에 기록하지...
    @GetMapping(value = "/info", name = "회원 정보 입력 여부 확인")
    public BaseResponse checkMemberInfoRegister(@AuthToken String accessToken) {
        Boolean response = memberService.checkMemberInfoRegister(accessToken);
        return BaseResponse.ofSuccess(response);
    }

    @PatchMapping(value = "/info", name = "회원 정보 수정")
    public BaseResponse EnterMemberInfo(@AuthToken String accessToken, @Valid @RequestBody MemberInfoRequestDTO requestDTO) {
        memberService.updateMemberInfo(accessToken, requestDTO);
        return BaseResponse.ofSuccess();
    }

    @GetMapping(value = "/{memberId}", name = "회원 조회 (임시 기능)")
    public BaseResponse findMember(@PathVariable @Min(value = 1) Long memberId) {
        MemberInfoResponseDTO responseDTO = memberService.findMember(memberId);
        return BaseResponse.ofSuccess(responseDTO);
    }

    @PatchMapping(value = "/{memberId}/role", name = "회원 등급 변경 - 해당 회원 재로그인 필요")
    public BaseResponse updateMemberRole(@PathVariable @Min(value = 1) Long memberId, @Valid @RequestBody MemberRoleUpdateRequestDTO request) {
        memberService.updateMemberRole(memberId, request.getRole());
        return BaseResponse.ofSuccess();
    }

    @PatchMapping(value = "/{memberId}/status", name = "회원 활성화/비활성화")
    public BaseResponse changeMemberStatus(@PathVariable Long memberId, @Valid @RequestBody MemberStatusChangeRequestDTO request) {
        memberService.changeMemberStatus(memberId, request.getStatus());
        return BaseResponse.ofSuccess();
    }

}
