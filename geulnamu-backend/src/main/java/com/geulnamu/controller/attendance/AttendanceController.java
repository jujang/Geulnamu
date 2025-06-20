package com.geulnamu.controller.attendance;

import com.geulnamu.domain.shared.enums.ActionType;
import com.geulnamu.domain.shared.enums.Level;
import com.geulnamu.infrastructure.annotation.AccessLevel;
import com.geulnamu.infrastructure.annotation.AuthMemberId;
import com.geulnamu.infrastructure.annotation.LogAction;
import com.geulnamu.infrastructure.response.BaseResponse;
import com.geulnamu.service.attendance.AttendanceService;
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
    @PostMapping(value = "/{meetingId}", name = "출석")
    public BaseResponse<Long> meetingAttend(@PathVariable @Min(value = 1) Long meetingId, @AuthMemberId Long memberId) {
        Long attendanceId = attendanceService.createAttendance(meetingId, memberId);
        return BaseResponse.ofSuccess(attendanceId);
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
