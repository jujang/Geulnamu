package com.geulnamu.controller.attendance;

import com.geulnamu.controller.attendance.dto.request.AttendanceNoteRequest;
import com.geulnamu.controller.attendance.dto.request.AssignDiscussionGroupsRequest;
import com.geulnamu.controller.attendance.dto.response.AttendanceInfoResponse;
import com.geulnamu.controller.attendance.dto.response.DiscussionGroupResponse;
import com.geulnamu.controller.attendance.dto.response.MeetingAttendanceDetailsResponse;
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
@RequestMapping("/attendance")
public class AttendanceController {

    private final AttendanceService attendanceService;


    @LogAction(value = ActionType.ATTENDANCE_CREATE, actionDomain = "attendance")
    @AccessLevel(Level.MEMBER)
    @PostMapping(name = "출석")
    public BaseResponse<Long> meetingAttend(@RequestParam @Min(value = 1) Long meetingId, @AuthMemberId Long memberId) {
        Long attendanceId = attendanceService.createAttendance(meetingId, memberId);
        return BaseResponse.ofSuccess(attendanceId);
    }

    @AccessLevel(Level.MEMBER)
    @GetMapping(value = "/{attendanceId}/my", name = "개인 출석 정보 조회")
    public BaseResponse<AttendanceInfoResponse> getMyAttendanceInfo(@PathVariable @Min(value = 1) Long attendanceId,
                                                                    @AuthMemberId Long memberId) {
        AttendanceInfoResponse attendanceInfoResponse = attendanceService.getMyAttendanceInfo(attendanceId, memberId);
        return BaseResponse.ofSuccess(attendanceInfoResponse);
    }

    @AccessLevel(Level.MEMBER)
    @GetMapping(name = "모임별 참석 현황 조회")
    public BaseResponse<MeetingAttendanceDetailsResponse> getMeetingAttendanceStatus(@RequestParam @Min(value = 1) Long meetingId) {
        MeetingAttendanceDetailsResponse meetingAttendanceStatusResponseList = attendanceService.getMeetingAttendanceStatus(meetingId);
        return BaseResponse.ofSuccess(meetingAttendanceStatusResponseList);
    }

    @AccessLevel(Level.STAFF)
    @GetMapping(value = "/discussion", name = "모임 토론 참여 희망 명단 조회")
    public BaseResponse<List<MemberIdAndNameResponse>> getWantDiscussionMemberList(@RequestParam @Min(value = 1) Long meetingId) {
        List<MemberIdAndNameResponse> memberIdAndNameResponsesList = attendanceService.getWantDiscussionMemberList(meetingId);
        return BaseResponse.ofSuccess(memberIdAndNameResponsesList);
    }

    @AccessLevel(Level.MEMBER)
    @GetMapping(value = "/discussion/{attendanceId}", name = "본인 토론 그룹 명단 조회")
    public BaseResponse<List<MemberIdAndNameResponse>> getMyDiscussionGroupMemberList(@PathVariable @Min(value = 1) Long attendanceId,
                                                                                      @AuthMemberId Long memberId) {
        List<MemberIdAndNameResponse> memberIdAndNameResponsesList = attendanceService.getMyDiscussionMemberList(attendanceId, memberId);
        return BaseResponse.ofSuccess(memberIdAndNameResponsesList);
    }

    @AccessLevel(Level.STAFF)
    @GetMapping(value = "/discussion/all", name = "전체 토론 그룹 명단 조회")
    public BaseResponse<List<DiscussionGroupResponse>> getAllDiscussionGroupMemberList(@NotNull(message = "모임 고유번호 필수 입력") @Min(value = 1) Long meetingId) {
        List<DiscussionGroupResponse> discussionGroupResponseList = attendanceService.getAllDiscussionGroupMemberList(meetingId);
        return BaseResponse.ofSuccess(discussionGroupResponseList);
    }

    @AccessLevel(Level.MEMBER)
    @PatchMapping(value = "/{attendanceId}/note", name = "비고 작성")
    public BaseResponse<Void> writeNote(@PathVariable @Min(value = 1) Long attendanceId, @AuthMemberId Long memberId,
                                        @Valid @RequestBody AttendanceNoteRequest request) {
        attendanceService.writeNote(attendanceId, memberId, request.getNote());
        return BaseResponse.ofSuccess();
    }

    @AccessLevel(Level.MEMBER)
    @PatchMapping(value = "/{attendanceId}/just-read", name = "독서만 할래요")
    public BaseResponse<Void> notWantDiscussion(@PathVariable @Min(value = 1) Long attendanceId, @AuthMemberId Long memberId) {
        attendanceService.notWantDiscussion(attendanceId, memberId);
        return BaseResponse.ofSuccess();
    }

    @AccessLevel(Level.MEMBER)
    @PatchMapping(value = "/{attendanceId}/want-discussion", name = "토론할래요")
    public BaseResponse<Void> wantDiscussion(@PathVariable @Min(value = 1) Long attendanceId, @AuthMemberId Long memberId) {
        attendanceService.wantDiscussion(attendanceId, memberId);
        return BaseResponse.ofSuccess();
    }

    @LogAction(value = ActionType.DISCUSSION_GROUP_ORGANIZE, actionDomain = "attendance")
    @AccessLevel(Level.STAFF)
    @PatchMapping(value = "/group", name = "토론 그룹 구성 - 수동")
    public BaseResponse<Void> manuallyAssignDiscussionGroups(@RequestParam @Min(value = 1) Long meetingId,
                                                             @Valid @RequestBody AssignDiscussionGroupsRequest request) {
        attendanceService.manuallyAssignDiscussionGroups(meetingId, request);
        return BaseResponse.ofSuccess();
    }

    @LogAction(value = ActionType.DISCUSSION_GROUP_ORGANIZE_SOLO, actionDomain = "attendance")
    @AccessLevel(Level.ADMIN)
    @PatchMapping(value = "/group/solo", name = "토론 그룹 할당 - 개인")
    public BaseResponse<Void> manuallyAssignDiscussionGroup(@RequestParam @Min(value = 1) Long meetingId,
                                                            @RequestParam @Min(value = 1) Long memberId,
                                                            @RequestParam @Min(value = 1) Integer groupNumber) {
        attendanceService.assignMemberToDiscussionGroup(meetingId, memberId, groupNumber-1);
        return BaseResponse.ofSuccess();
    }

    @LogAction(value = ActionType.ATTENDANCE_DELETE, actionDomain = "attendance")
    @AccessLevel(Level.ADMIN)
    @DeleteMapping(value = "/{attendanceId}/delete", name = "출석 삭제")
    public BaseResponse<Void> DeleteMeetingAttend(@PathVariable @Min(value = 1) Long attendanceId) {
        attendanceService.deleteAttendance(attendanceId);
        return BaseResponse.ofSuccess();
    }

}
