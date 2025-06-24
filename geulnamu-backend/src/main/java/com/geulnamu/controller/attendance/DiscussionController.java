package com.geulnamu.controller.attendance;

import com.geulnamu.controller.attendance.dto.request.AssignDiscussionGroupsRequest;
import com.geulnamu.controller.attendance.dto.response.DiscussionGroupResponse;
import com.geulnamu.controller.shared.dto.response.MemberIdAndNameResponse;
import com.geulnamu.domain.shared.enums.ActionType;
import com.geulnamu.domain.shared.enums.Level;
import com.geulnamu.infrastructure.annotation.AccessLevel;
import com.geulnamu.infrastructure.annotation.AuthMemberId;
import com.geulnamu.infrastructure.annotation.LogAction;
import com.geulnamu.infrastructure.response.BaseResponse;
import com.geulnamu.service.attendance.AttendanceService;
import jakarta.validation.Valid;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotNull;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequiredArgsConstructor
@RequestMapping("/discussion")
public class DiscussionController {

    private final AttendanceService attendanceService;


    @AccessLevel(Level.STAFF)
    @GetMapping(value = "/list/want-discussion", name = "모임 토론 참여 희망 명단 조회")
    public BaseResponse<List<MemberIdAndNameResponse>> getWantDiscussionMemberList(@RequestParam @Min(value = 1) Long meetingId) {
        List<MemberIdAndNameResponse> memberIdAndNameResponsesList = attendanceService.getWantDiscussionMemberList(meetingId);
        return BaseResponse.ofSuccess(memberIdAndNameResponsesList);
    }

    @AccessLevel(Level.MEMBER)
    @GetMapping(value = "/{attendanceId}/my-group", name = "본인 토론 그룹 명단 조회")
    public BaseResponse<List<MemberIdAndNameResponse>> getMyDiscussionGroupMemberList(@PathVariable @Min(value = 1) Long attendanceId,
                                                                                      @AuthMemberId Long memberId) {
        List<MemberIdAndNameResponse> memberIdAndNameResponsesList = attendanceService.getMyDiscussionMemberList(attendanceId, memberId);
        return BaseResponse.ofSuccess(memberIdAndNameResponsesList);
    }

    @AccessLevel(Level.STAFF)
    @GetMapping(value = "/all-group", name = "전체 토론 그룹 명단 조회")
    public BaseResponse<List<DiscussionGroupResponse>> getAllDiscussionGroupMemberList(@NotNull(message = "모임 고유번호 필수 입력") @Min(value = 1) Long meetingId) {
        List<DiscussionGroupResponse> discussionGroupResponseList = attendanceService.getAllDiscussionGroupMemberList(meetingId);
        return BaseResponse.ofSuccess(discussionGroupResponseList);
    }

    @LogAction(value = ActionType.DISCUSSION_GROUP_ORGANIZE, actionDomain = "attendance")
    @AccessLevel(Level.STAFF)
    @PatchMapping(value = "/assign", name = "토론 그룹 구성 - 수동")
    public BaseResponse<Void> manuallyAssignDiscussionGroups(@RequestParam @Min(value = 1) Long meetingId,
                                                             @Valid @RequestBody AssignDiscussionGroupsRequest request) {
        attendanceService.manuallyAssignDiscussionGroups(meetingId, request);
        return BaseResponse.ofSuccess();
    }

    @LogAction(value = ActionType.DISCUSSION_GROUP_ORGANIZE_SOLO, actionDomain = "attendance")
    @AccessLevel(Level.ADMIN)
    @PatchMapping(value = "/assign/solo", name = "토론 그룹 할당 - 개인")
    public BaseResponse<Void> manuallyAssignDiscussionGroup(@RequestParam @Min(value = 1) Long meetingId,
                                                            @RequestParam @Min(value = 1) Long memberId,
                                                            @RequestParam @Min(value = 1) Integer groupNumber) {
        attendanceService.assignMemberToDiscussionGroup(meetingId, memberId, groupNumber-1);
        return BaseResponse.ofSuccess();
    }

}
