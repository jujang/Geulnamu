package com.geulnamu.controller.attendance.dto.response;

import com.fasterxml.jackson.annotation.JsonFormat;
import lombok.AllArgsConstructor;
import lombok.Getter;

import java.time.LocalDateTime;

@Getter
@AllArgsConstructor
public class MeetingAttendanceStatusResponse {
    private Long attendanceId;
    private Long memberId;
    private String name;
    @JsonFormat(shape = JsonFormat.Shape.STRING, pattern = "yyyy.MM.dd HH:mm")
    private LocalDateTime attendanceTime;
    private Boolean isLate;
    private Boolean wantDiscussion;
}
