package com.geulnamu.controller.member;

import com.geulnamu.controller.member.dto.MemberCreateRequestDTO;
import com.geulnamu.controller.member.dto.MemberInfoResponseDTO;
import com.geulnamu.controller.member.dto.MemberRoleUpdateRequestDTO;
import com.geulnamu.controller.member.dto.MemberStatusChangeRequestDTO;
import com.geulnamu.global.response.BaseResponse;
import com.geulnamu.service.member.MemberService;
import jakarta.validation.Valid;
import jakarta.validation.constraints.Min;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.web.bind.annotation.*;

@Slf4j
@RestController
@RequiredArgsConstructor
@RequestMapping("/member")
public class MemberController {

    private final MemberService memberService;

    @PostMapping(name = "회원 생성 (임시 기능)")
    public BaseResponse createMember(@Valid @RequestBody MemberCreateRequestDTO request) {
        memberService.createMember(request);
        return BaseResponse.ofSuccess();
    }

    @GetMapping(value = "/{memberId}", name = "회원 조회 (임시 기능)")
    public BaseResponse findMember(@PathVariable @Min(value = 1) Long memberId) {
        MemberInfoResponseDTO responseDTO = memberService.findMember(memberId);
        return BaseResponse.ofSuccess(responseDTO);
    }

    @PatchMapping(value = "/{memberId}/role", name = "회원 등급 조정 (임시 기능)")
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
