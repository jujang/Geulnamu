package com.geulnamu.repository.attendance;

import com.geulnamu.controller.attendance.dto.response.AttendanceInfoResponse;
import com.geulnamu.controller.attendance.dto.response.MeetingAttendanceStatusResponse;
import com.geulnamu.controller.attendance.dto.response.MeetingAttendanceSummaryResponse;

import java.util.List;
import java.util.Optional;

public interface AttendanceQueryRepositoryCustom {
    Optional<AttendanceInfoResponse> findMyAttendanceInfo(Long attendanceId, Long memberId);
    MeetingAttendanceSummaryResponse findMeetingAttendanceSummary(Long meetingId);
    List<MeetingAttendanceStatusResponse> findMeetingAttendanceStatus(Long meetingId);
}
