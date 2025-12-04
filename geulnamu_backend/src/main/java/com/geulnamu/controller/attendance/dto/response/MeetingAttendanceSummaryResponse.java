package com.geulnamu.controller.attendance.dto.response;

import com.fasterxml.jackson.annotation.JsonFormat;
import lombok.AllArgsConstructor;
import lombok.Getter;

import java.time.LocalDateTime;

@Getter
@AllArgsConstructor
public class MeetingAttendanceSummaryResponse {
    @JsonFormat(shape = JsonFormat.Shape.STRING, pattern = "yyyy.MM.dd HH:mm")
    private LocalDateTime meetingDate;
    @JsonFormat(shape = JsonFormat.Shape.STRING, pattern = "HH:mm")
    private LocalDateTime lateThresholdTime;
    private Long totalAttendCount;
    private Long attendCount;
    private Long lateAttendCount;
    private Long wantDiscussionCount;
}
