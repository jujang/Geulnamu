package com.geulnamu.controller.meeting;

import com.geulnamu.controller.meeting.dto.request.*;
import com.geulnamu.controller.meeting.dto.response.*;
import com.geulnamu.controller.shared.dto.response.MemberIdAndNameResponse;
import com.geulnamu.domain.shared.enums.ActionType;
import com.geulnamu.domain.shared.enums.DomainType;
import com.geulnamu.domain.shared.enums.Level;
import com.geulnamu.domain.shared.enums.Role;
import com.geulnamu.infrastructure.annotation.*;
import com.geulnamu.infrastructure.response.BaseResponse;
import com.geulnamu.service.meeting.MeetingService;
import jakarta.validation.Valid;
import jakarta.validation.constraints.Min;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequiredArgsConstructor
@RequestMapping("/meetings")
public class MeetingController {

    private final MeetingService meetingService;


    @LogAction(value = ActionType.MEETING_CREATE, actionDomain = DomainType.MEETING)
    @AccessLevel(Level.STAFF)
    @PostMapping(value = "/create", name = "모임 생성")
    public BaseResponse<Long> createMeeting(@AuthMemberId Long memberId,
                                            @Valid @RequestBody MeetingCreateRequest request) {
        Long meetingId = meetingService.createMeeting(memberId, request);
        return BaseResponse.ofSuccess(meetingId);
    }

    // TODO: 얘를 MEMBER 도메인으로 옮기는 것에 대해서 고민해 볼 것
    @ErrorLogAction(value = ActionType.MEETING_STAFF_LIST_VIEW, actionDomain = DomainType.MEETING)
    @AccessLevel(Level.MEMBER)
    @GetMapping(value = "/staff-list", name = "운영진 명단 조회 - 필터링용")
    public BaseResponse<List<MemberIdAndNameResponse>> getStaffList() {
        List<MemberIdAndNameResponse> responseList = meetingService.getStaffList();
        return BaseResponse.ofSuccess(responseList);
    }

    @ErrorLogAction(value = ActionType.MEETING_LIST_VIEW, actionDomain = DomainType.MEETING)
    @AccessLevel(Level.MEMBER)
    @GetMapping(value = "/list", name = "모임 목록 조회")
    public BaseResponse<MeetingListResponse> getMeetingList(@AuthMemberId Long memberId,
                                                            @Valid MeetingListRequest request) {
        MeetingListResponse response = meetingService.getMeetingList(memberId, request);
        return BaseResponse.ofSuccess(response);
    }

    @ErrorLogAction(value = ActionType.MEETING_VIEW, actionDomain = DomainType.MEETING)
    @AccessLevel(Level.MEMBER)
    @GetMapping(value = "/{meetingId}", name = "모임 단일 상세 조회")
    public BaseResponse<MeetingDetailResponse> findMeeting(@PathVariable @Min(value = 1) Long meetingId, @AuthMemberId Long memberId) {
        MeetingDetailResponse response = meetingService.getMeeting(meetingId, memberId);
        return BaseResponse.ofSuccess(response);
    }

    @ErrorLogAction(value = ActionType.MEETING_VIEW_FOR_STAFF, actionDomain = DomainType.MEETING)
    @AccessLevel(Level.STAFF)
    @GetMapping(value = "/{meetingId}/staff", name = "모임 단일 상세 조회(운영진용)")
    public BaseResponse<MeetingDetailResponseForStaff> findMeetingForStaff(@PathVariable @Min(value = 1) Long meetingId) {
        MeetingDetailResponseForStaff response = meetingService.getMeetingForStaff(meetingId);
        return BaseResponse.ofSuccess(response);
    }

    @LogAction(value = ActionType.MEETING_UPDATE_BASIC, actionDomain = DomainType.MEETING)
    @AccessLevel(Level.STAFF)
    @PatchMapping(value = "/{meetingId}/basic", name = "모임 수정 - 기본 정보")
    public BaseResponse<Void> updateMeeting(@PathVariable @Min(value = 1) Long meetingId,
                                            @AuthMemberId Long memberId, @AuthRole Role role,
                                            @Valid @RequestBody MeetingUpdateRequest request) {
        meetingService.updateMeeting(meetingId, memberId, role, request);
        return BaseResponse.ofSuccess();
    }

    @LogAction(value = ActionType.MEETING_UPDATE_DISCUSSION, actionDomain = DomainType.MEETING)
    @AccessLevel(Level.STAFF)
    @PatchMapping(value = "/{meetingId}/discussion", name = "모임 수정 - 조별 활동 관련")
    public BaseResponse<Void> updateMeetingForDiscussion(@PathVariable @Min(value = 1) Long meetingId,
                                                         @AuthMemberId Long memberId, @AuthRole Role role,
                                                         @Valid @RequestBody MeetingGroupUpdateRequest request) {
        meetingService.updateMeetingForDiscussion(meetingId, memberId, role, request);
        return BaseResponse.ofSuccess();
    }

    @ErrorLogAction(value = ActionType.MEETING_MAKE_PRIVATE, actionDomain = DomainType.MEETING)
    @AccessLevel(Level.ADMIN)
    @PatchMapping(value = "/{meetingId}/make-private", name = "지난 모임 비공개 처리 - 모임 익일부터 처리 가능")
    public BaseResponse<Void> makeMeetingPrivate(@PathVariable @Min(value = 1) Long meetingId) {
        meetingService.makeMeetingPrivate(meetingId);
        return BaseResponse.ofSuccess();
    }

    @ErrorLogAction(value = ActionType.MEETING_MAKE_PUBLIC, actionDomain = DomainType.MEETING)
    @AccessLevel(Level.ADMIN)
    @PatchMapping(value = "/{meetingId}/make-public", name = "비공개 모임 공개 처리")
    public BaseResponse<Void> makeMeetingPublic(@PathVariable @Min(value = 1) Long meetingId) {
        meetingService.makeMeetingPublic(meetingId);
        return BaseResponse.ofSuccess();
    }

    @LogAction(value = ActionType.MEETING_REMOVE, actionDomain = DomainType.MEETING)
    @AccessLevel(Level.STAFF)
    @DeleteMapping(value = "/{meetingId}/remove", name = "개설한 모임 삭제 - 모임 시작 6시간 전까지만 가능")
    public BaseResponse<Void> removeMeeting(@PathVariable @Min(value = 1) Long meetingId,
                                            @AuthMemberId Long memberId, @AuthRole Role role) {
        meetingService.removeMeeting(meetingId, memberId, role);
        return BaseResponse.ofSuccess();
    }

}
