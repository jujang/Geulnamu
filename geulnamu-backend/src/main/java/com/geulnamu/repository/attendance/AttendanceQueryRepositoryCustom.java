package com.geulnamu.repository.attendance;

import com.geulnamu.controller.attendance.dto.response.AttendanceInfoResponse;

import java.util.Optional;

public interface AttendanceQueryRepositoryCustom {
    Optional<AttendanceInfoResponse> findMyAttendanceInfo(Long attendanceId, Long memberId);
}
