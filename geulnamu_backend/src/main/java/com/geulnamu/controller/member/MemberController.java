package com.geulnamu.controller.member;

import com.geulnamu.controller.member.dto.request.*;
import com.geulnamu.controller.member.dto.response.MemberInfoResponse;
import com.geulnamu.controller.member.dto.response.MemberListResponse;
import com.geulnamu.domain.shared.enums.ActionType;
import com.geulnamu.domain.shared.enums.DomainType;
import com.geulnamu.domain.shared.enums.Level;
import com.geulnamu.infrastructure.annotation.ErrorLogAction;
import com.geulnamu.infrastructure.annotation.LogAction;
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
@RequestMapping("/members")
public class MemberController {

    private final MemberService memberService;


    @ErrorLogAction(value = ActionType.MEMBER_CREATE, actionDomain = DomainType.MEMBER)
    @AccessLevel(Level.PUBLIC)
    @PostMapping(value = "register", name = "모임원 생성 (OAuth 토큰 발행 대안 기능)")
    public BaseResponse<Void> createMember(@Valid @RequestBody MemberCreateRequest request) {
        memberService.createMember(request.getKakaoMemberId());
        return BaseResponse.ofSuccess();
    }

    @ErrorLogAction(value = ActionType.MEMBER_CHECK_PROFILE_STATUS, actionDomain = DomainType.MEMBER)
    @AccessLevel(Level.MEMBER)
    @GetMapping(value = "/me/profile-status", name = "개인 정보 입력 여부 확인")
    public BaseResponse<Boolean> checkMyInfoRegister(@AuthMemberId Long memberId) {
        Boolean response = memberService.isMemberInfoRegistered(memberId);
        return BaseResponse.ofSuccess(response);
    }

    @ErrorLogAction(value = ActionType.MEMBER_MY_VIEW, actionDomain = DomainType.MEMBER)
    @AccessLevel(Level.MEMBER)
    @GetMapping(value = "/me/profile", name = "본인 정보 조회")
    public BaseResponse<MemberInfoResponse> findMyInfo(@AuthMemberId Long memberId) {
        MemberInfoResponse response = memberService.findMember(memberId);
        return BaseResponse.ofSuccess(response);
    }

    @ErrorLogAction(value = ActionType.MEMBER_VIEW, actionDomain = DomainType.MEMBER)
    @AccessLevel(Level.ADMIN)
    @GetMapping(value = "/{memberId}", name = "모임원 정보 조회")
    public BaseResponse<MemberInfoResponse> findMember(@PathVariable @Min(value = 1) Long memberId) {
        MemberInfoResponse response = memberService.findMember(memberId);
        return BaseResponse.ofSuccess(response);
    }

    @ErrorLogAction(value = ActionType.MEMBER_LIST_VIEW, actionDomain = DomainType.MEMBER)
    @AccessLevel(Level.STAFF)
    @GetMapping(value = "/list", name = "모임원 정보 목록 조회")
    public BaseResponse<MemberListResponse> getMembers(@Valid MemberListRequest request) {
        MemberListResponse response = memberService.getMembers(request);
        return BaseResponse.ofSuccess(response);
    }

    @LogAction(value = ActionType.MEMBER_PUSH_SETTING_VIEW, actionDomain = DomainType.MEMBER)
    @AccessLevel(Level.MEMBER)
    @GetMapping(value = "/me/push-setting", name = "앱 푸시 수신 여부 수정")
    public BaseResponse<Boolean> getPushSetting(@AuthMemberId Long memberId) {
        Boolean response = memberService.getPushSetting(memberId);
        return BaseResponse.ofSuccess(response);
    }

    @LogAction(value = ActionType.MEMBER_PUSH_SETTING_UPDATE, actionDomain = DomainType.MEMBER)
    @AccessLevel(Level.MEMBER)
    @PatchMapping(value = "/me/push-setting", name = "앱 푸시 수신 여부 수정")
    public BaseResponse<Void> updatePushSetting(@AuthMemberId Long memberId, @Valid @RequestBody MemberPushSettingRequest request) {
        memberService.updatePushSetting(memberId, request.getIsPushEnabled());
        return BaseResponse.ofSuccess();
    }

    @LogAction(value = ActionType.MEMBER_INFO_UPDATE, actionDomain = DomainType.MEMBER)
    @AccessLevel(Level.MEMBER)
    @PatchMapping(value = "/me/profile", name = "개인 정보 수정")
    public BaseResponse<Void> updateMyInfo(@AuthMemberId Long memberId, @Valid @RequestBody MemberInfoRequest request) {
        memberService.updateMemberInfo(memberId, request);
        return BaseResponse.ofSuccess();
    }

    @LogAction(value = ActionType.MEMBER_ROLE_UPDATE, actionDomain = DomainType.MEMBER)
    @AccessLevel(Level.ADMIN)
    @PatchMapping(value = "/{memberId}/role", name = "모임원 등급 변경 - 해당 모임원 재로그인 필요")
    public BaseResponse<Void> updateMemberRole(@PathVariable @Min(value = 1) Long memberId,
                                               @Valid @RequestBody MemberRoleUpdateRequest request) {
        memberService.updateMemberRole(memberId, request.getRole());
        return BaseResponse.ofSuccess();
    }

    @LogAction(value = ActionType.MEMBER_NAME_UPDATE, actionDomain = DomainType.MEMBER)
    @AccessLevel(Level.ADMIN)
    @PatchMapping(value = "/{memberId}/name", name = "모임원 이름 변경")
    public BaseResponse<Void> updateMemberName(@PathVariable @Min(value = 1) Long memberId,
                                               @Valid @RequestBody MemberNameUpdateRequest request) {
        memberService.updateMemberName(memberId, request.getName());
        return BaseResponse.ofSuccess();
    }

    @LogAction(value = ActionType.MEMBER_ACTIVATE, actionDomain = DomainType.MEMBER)
    @AccessLevel(Level.ADMIN)
    @PatchMapping(value = "/{memberId}/activate", name = "모임원 활성화")
    public BaseResponse<Void> activateMember(@PathVariable @Min(value = 1) Long memberId) {
        memberService.activateMember(memberId);
        return BaseResponse.ofSuccess();
    }

    @LogAction(value = ActionType.MEMBER_DEACTIVATE, actionDomain = DomainType.MEMBER)
    @AccessLevel(Level.ADMIN)
    @PatchMapping(value = "/{memberId}/deactivate", name = "모임원 비활성화")
    public BaseResponse<Void> deactivateMember(@PathVariable @Min(value = 1) Long memberId) {
        memberService.deactivateMember(memberId);
        return BaseResponse.ofSuccess();
    }

}
