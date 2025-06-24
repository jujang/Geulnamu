package com.geulnamu.controller.attendance;

import com.geulnamu.controller.attendance.dto.request.AttendanceNoteRequest;
import com.geulnamu.controller.attendance.dto.response.AttendanceInfoResponse;
import com.geulnamu.controller.attendance.dto.response.MeetingAttendanceDetailsResponse;
import com.geulnamu.domain.shared.enums.ActionType;
import com.geulnamu.domain.shared.enums.Level;
import com.geulnamu.infrastructure.annotation.AccessLevel;
import com.geulnamu.infrastructure.annotation.AuthMemberId;
import com.geulnamu.infrastructure.annotation.LogAction;
import com.geulnamu.infrastructure.response.BaseResponse;
import com.geulnamu.service.attendance.AttendanceService;
import jakarta.validation.Valid;
import jakarta.validation.constraints.Min;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

@RestController
@RequiredArgsConstructor
@RequestMapping("/attendance")
public class AttendanceController {

    private final AttendanceService attendanceService;


    @LogAction(value = ActionType.ATTENDANCE_CREATE, actionDomain = "attendance")
    @AccessLevel(Level.MEMBER)
    @PostMapping(name = "출석")
    public BaseResponse<Long> meetingAttend(@AuthMemberId Long memberId, @RequestParam @Min(value = 1) Long meetingId) {
        Long attendanceId = attendanceService.createAttendance(memberId, meetingId);
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

    @LogAction(value = ActionType.ATTENDANCE_DELETE, actionDomain = "attendance")
    @AccessLevel(Level.ADMIN)
    @DeleteMapping(value = "/{attendanceId}/delete", name = "출석 삭제")
    public BaseResponse<Void> DeleteMeetingAttend(@PathVariable @Min(value = 1) Long attendanceId) {
        attendanceService.deleteAttendance(attendanceId);
        return BaseResponse.ofSuccess();
    }

}
