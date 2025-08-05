package com.geulnamu.controller.attendance;

import com.geulnamu.controller.attendance.dto.request.AssignDiscussionGroupsRequest;
import com.geulnamu.controller.attendance.dto.response.DiscussionGroupResponse;
import com.geulnamu.controller.shared.dto.response.AttendanceIdAndNameResponse;
import com.geulnamu.domain.shared.enums.ActionType;
import com.geulnamu.domain.shared.enums.DomainType;
import com.geulnamu.domain.shared.enums.Level;
import com.geulnamu.infrastructure.annotation.AccessLevel;
import com.geulnamu.infrastructure.annotation.AuthMemberId;
import com.geulnamu.infrastructure.annotation.ErrorLogAction;
import com.geulnamu.infrastructure.annotation.LogAction;
import com.geulnamu.infrastructure.response.BaseResponse;
import com.geulnamu.service.attendance.AttendanceService;
import jakarta.validation.Valid;
import jakarta.validation.constraints.Min;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequiredArgsConstructor
@RequestMapping("/discussions")
public class DiscussionController {

    private final AttendanceService attendanceService;


    @ErrorLogAction(value = ActionType.DISCUSSION_WANT_LIST_VIEW, actionDomain = DomainType.ATTENDANCE)
    @AccessLevel(Level.STAFF)
    @GetMapping(value = "/list/want-discussion", name = "모임 토론 참여 희망 명단 조회")
    public BaseResponse<List<AttendanceIdAndNameResponse>> getWantDiscussionMemberList(@RequestParam @Min(value = 1) Long meetingId) {
        List<AttendanceIdAndNameResponse> responseList = attendanceService.getWantDiscussionMemberList(meetingId);
        return BaseResponse.ofSuccess(responseList);
    }

    @ErrorLogAction(value = ActionType.DISCUSSION_MY_GROUP_LIST_VIEW, actionDomain = DomainType.ATTENDANCE)
    @AccessLevel(Level.MEMBER)
    @GetMapping(value = "/{attendanceId}/my-group", name = "본인 토론 그룹 명단 조회")
    public BaseResponse<List<AttendanceIdAndNameResponse>> getMyDiscussionGroupMemberList(@PathVariable @Min(value = 1) Long attendanceId,
                                                                                          @AuthMemberId Long memberId) {
        List<AttendanceIdAndNameResponse> responseList = attendanceService.getMyDiscussionMemberList(attendanceId, memberId);
        return BaseResponse.ofSuccess(responseList);
    }

    @ErrorLogAction(value = ActionType.DISCUSSION_ALL_GROUP_LIST_VIEW, actionDomain = DomainType.ATTENDANCE)
    @AccessLevel(Level.STAFF)
    @GetMapping(value = "/groups", name = "모임별 전체 토론 그룹 명단 조회")
    public BaseResponse<List<DiscussionGroupResponse>> getAllDiscussionGroupMemberList(@RequestParam @Min(value = 1) Long meetingId) {
        List<DiscussionGroupResponse> responseList = attendanceService.getAllDiscussionGroupMemberList(meetingId);
        return BaseResponse.ofSuccess(responseList);
    }

    @LogAction(value = ActionType.DISCUSSION_GROUP_ORGANIZE, actionDomain = DomainType.ATTENDANCE)
    @AccessLevel(Level.STAFF)
    @PatchMapping(value = "/groups/assign", name = "토론 그룹 구성 - 수동")
    public BaseResponse<Void> manuallyAssignDiscussionGroups(@RequestParam @Min(value = 1) Long meetingId,
                                                             @Valid @RequestBody AssignDiscussionGroupsRequest request) {
        attendanceService.manuallyAssignDiscussionGroups(meetingId, request);
        return BaseResponse.ofSuccess();
    }

    @LogAction(value = ActionType.DISCUSSION_GROUP_ORGANIZE_SOLO, actionDomain = DomainType.ATTENDANCE)
    @AccessLevel(Level.ADMIN)
    @PatchMapping(value = "/groups/assign-member", name = "토론 그룹 할당 - 개인")
    public BaseResponse<Void> manuallyAssignDiscussionGroup(@RequestParam @Min(value = 1) Long meetingId,
                                                            @RequestParam @Min(value = 1) Long attendanceId,
                                                            @RequestParam @Min(value = 1) Integer groupNumber) {
        attendanceService.assignMemberToDiscussionGroup(meetingId, attendanceId, groupNumber-1);
        return BaseResponse.ofSuccess();
    }

}
