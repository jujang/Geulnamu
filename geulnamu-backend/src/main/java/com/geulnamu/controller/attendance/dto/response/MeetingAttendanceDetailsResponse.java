package com.geulnamu.controller.attendance.dto.response;

import lombok.AllArgsConstructor;
import lombok.Getter;

import java.util.List;

@Getter
@AllArgsConstructor
public class MeetingAttendanceDetailsResponse {
    private MeetingAttendanceSummaryResponse meetingAttendanceSummaryResponse;
    private List<MeetingAttendanceStatusResponse> meetingAttendanceStatusResponseList;
}
