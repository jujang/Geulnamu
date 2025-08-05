package com.geulnamu.controller.shared.dto.response;

import lombok.AllArgsConstructor;
import lombok.Getter;

@Getter
@AllArgsConstructor
public class AttendanceIdAndNameResponse {
    private Long attendanceId;
    private String memberName;
}
