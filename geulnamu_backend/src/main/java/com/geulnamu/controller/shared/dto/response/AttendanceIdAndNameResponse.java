package com.geulnamu.controller.shared.dto.response;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Getter
@NoArgsConstructor  // Redis 역직렬화용 기본 생성자
@AllArgsConstructor
public class AttendanceIdAndNameResponse {
    private Long attendanceId;
    private String memberName;
}
