package com.geulnamu.controller.member;

import com.geulnamu.controller.member.dto.request.*;
import com.geulnamu.controller.member.dto.response.MemberInfoResponse;
import com.geulnamu.controller.member.dto.response.MemberListResponse;
import com.geulnamu.domain.shared.enums.ActionType;
import com.geulnamu.domain.shared.enums.Level;
import com.geulnamu.infrastructure.annotation.LogAction;
import com.geulnamu.infrastructure.response.paging.PagingRequest;
import com.geulnamu.infrastructure.response.BaseResponse;
import com.geulnamu.infrastructure.annotation.AuthMemberId;
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
    public BaseResponse<Void> createMember(@Valid @RequestBody MemberCreateRequest request) {
        memberService.createMember(request.getKakaoMemberId());
        return BaseResponse.ofSuccess();
    }

    @AccessLevel(Level.MEMBER)
    @GetMapping(value = "/info", name = "개인 정보 입력 여부 확인")
    public BaseResponse<Boolean> checkMemberInfoRegister(@AuthMemberId Long memberId) {
        Boolean response = memberService.isMemberInfoRegistered(memberId);
        return BaseResponse.ofSuccess(response);
    }

    @AccessLevel(Level.ADMIN)
    @GetMapping(value = "/{memberId}", name = "모임원 조회 (임시 기능)")
    public BaseResponse<MemberInfoResponse> findMember(@PathVariable @Min(value = 1) Long memberId) {
        MemberInfoResponse response = memberService.findMember(memberId);
        return BaseResponse.ofSuccess(response);
    }

    @AccessLevel(Level.ADMIN)
    @GetMapping(value = "/list", name = "모임원 목록 조회")
    public BaseResponse<MemberListResponse> getMembers(@Valid PagingRequest pagingRequest) {
        MemberListResponse memberListResponse = memberService.getMembers(pagingRequest);
        return BaseResponse.ofSuccess(memberListResponse);
    }

    @LogAction(value = ActionType.MEMBER_INFO_UPDATE, actionDomain = "member")
    @AccessLevel(Level.MEMBER)
    @PatchMapping(value = "/info", name = "개인 정보 수정")
    public BaseResponse<Void> updateMemberInfo(@AuthMemberId Long memberId, @Valid @RequestBody MemberInfoRequest request) {
        memberService.updateMemberInfo(memberId, request.getName(), request.getGender(), request.getBirthDate());
        return BaseResponse.ofSuccess();
    }

    @LogAction(value = ActionType.MEMBER_ROLE_UPDATE, actionDomain = "member")
    @AccessLevel(Level.ADMIN)
    @PatchMapping(value = "/{memberId}/role", name = "모임원 등급 변경 - 해당 모임원 재로그인 필요")
    public BaseResponse<Void> updateMemberRole(@PathVariable @Min(value = 1) Long memberId, @AuthMemberId Long authMemberId, @Valid @RequestBody MemberRoleUpdateRequest request) {
        memberService.updateMemberRole(memberId, request.getRole());
        return BaseResponse.ofSuccess();
    }

    @LogAction(value = ActionType.MEMBER_NAME_UPDATE, actionDomain = "member")
    @AccessLevel(Level.ADMIN)
    @PatchMapping(value = "/{memberId}/name", name = "모임원 이름 변경")
    public BaseResponse<Void> updateMemberName(@PathVariable @Min(value = 1) Long memberId, @AuthMemberId Long authMemberId, @Valid @RequestBody MemberNameUpdateRequest request) {
        memberService.updateMemberName(memberId, request.getName());
        return BaseResponse.ofSuccess();
    }

    @LogAction(value = ActionType.MEMBER_ACTIVATE, actionDomain = "member")
    @AccessLevel(Level.ADMIN)
    @PatchMapping(value = "/{memberId}/activate", name = "모임원 활성화")
    public BaseResponse<Void> activateMember(@PathVariable @Min(value = 1) Long memberId, @AuthMemberId Long authMemberId) {
        memberService.activateMember(memberId);
        return BaseResponse.ofSuccess();
    }

    @LogAction(value = ActionType.MEMBER_DEACTIVATE, actionDomain = "member")
    @AccessLevel(Level.ADMIN)
    @PatchMapping(value = "/{memberId}/deactivate", name = "모임원 비활성화")
    public BaseResponse<Void> deactivateMember(@PathVariable @Min(value = 1) Long memberId, @AuthMemberId Long authMemberId) {
        memberService.deactivateMember(memberId);
        return BaseResponse.ofSuccess();
    }

}
