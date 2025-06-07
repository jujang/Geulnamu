package com.geulnamu.controller.member;

import com.geulnamu.controller.member.dto.request.*;
import com.geulnamu.controller.member.dto.response.MemberInfoResponseDTO;
import com.geulnamu.controller.member.dto.response.MemberListResponseDTO;
import com.geulnamu.domain.shared.enums.Level;
import com.geulnamu.domain.shared.paging.PagingRequest;
import com.geulnamu.global.response.BaseResponse;
import com.geulnamu.infrastructure.annotation.AuthMemberId;
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
    public BaseResponse<Void> createMember(@Valid @RequestBody MemberCreateRequestDTO requestDTO) {
        memberService.createMember(requestDTO.getKakaoMemberId());
        return BaseResponse.ofSuccess();
    }

    @AccessLevel(Level.AUTHENTICATED)
    @GetMapping(value = "/info", name = "개인 정보 입력 여부 확인")
    public BaseResponse<Boolean> checkMemberInfoRegister(@AuthMemberId Long memberId) {
        Boolean response = memberService.isMemberInfoRegistered(memberId);
        return BaseResponse.ofSuccess(response);
    }

    @AccessLevel(Level.AUTHENTICATED)
    @PatchMapping(value = "/info", name = "개인 정보 수정")
    public BaseResponse<Void> updateMemberInfo(@AuthMemberId Long memberId, @Valid @RequestBody MemberInfoRequestDTO requestDTO) {
        memberService.updateMemberInfo(memberId, requestDTO.getName(), requestDTO.getGender(), requestDTO.getBirthDate());
        return BaseResponse.ofSuccess();
    }

    @AccessLevel(Level.ADMIN)
    @GetMapping(value = "/{memberId}", name = "모임원 조회 (임시 기능)")
    public BaseResponse<MemberInfoResponseDTO> findMember(@PathVariable @Min(value = 1) Long memberId) {
        MemberInfoResponseDTO responseDTO = memberService.findMember(memberId);
        return BaseResponse.ofSuccess(responseDTO);
    }

    @AccessLevel(Level.ADMIN)
    @GetMapping(name = "모임원 목록 조회")
    public BaseResponse<MemberListResponseDTO> getMembers(@Valid PagingRequest listRequest) {
        MemberListResponseDTO memberListResponseDTO = memberService.getMembers(listRequest);
        return BaseResponse.ofSuccess(memberListResponseDTO);
    }

    @AccessLevel(Level.ADMIN)
    @PatchMapping(value = "/{memberId}/role", name = "모임원 등급 변경 - 해당 모임원 재로그인 필요")
    public BaseResponse<Void> updateMemberRole(@PathVariable @Min(value = 1) Long memberId, @Valid @RequestBody MemberRoleUpdateRequestDTO request) {
        memberService.updateMemberRole(memberId, request.getRole());
        return BaseResponse.ofSuccess();
    }

    @AccessLevel(Level.ADMIN)
    @PatchMapping(value = "/{memberId}/name", name = "모임원 이름 변경")
    public BaseResponse<Void> updateMemberName(@PathVariable @Min(value = 1) Long memberId, @Valid @RequestBody MemberNameUpdateRequestDTO request) {
        memberService.updateMemberName(memberId, request.getName());
        return BaseResponse.ofSuccess();
    }

    @AccessLevel(Level.ADMIN)
    @PatchMapping(value = "/{memberId}/activate", name = "모임원 활성화")
    public BaseResponse<Void> activateMember(@PathVariable @Min(value = 1) Long memberId) {
        memberService.activateMember(memberId);
        return BaseResponse.ofSuccess();
    }

    @AccessLevel(Level.ADMIN)
    @PatchMapping(value = "/{memberId}/deactivate", name = "모임원 비활성화")
    public BaseResponse<Void> deactivateMember(@PathVariable @Min(value = 1) Long memberId) {
        memberService.deactivateMember(memberId);
        return BaseResponse.ofSuccess();
    }

}
