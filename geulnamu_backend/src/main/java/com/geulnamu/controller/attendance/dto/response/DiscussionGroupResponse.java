package com.geulnamu.controller.attendance.dto.response;

import com.geulnamu.controller.shared.dto.response.AttendanceIdAndNameResponse;
import lombok.AllArgsConstructor;
import lombok.Getter;

import java.util.List;

@Getter
@AllArgsConstructor
public class DiscussionGroupResponse {
    private List<AttendanceIdAndNameResponse> attendanceIdAndNameResponseList;
}
