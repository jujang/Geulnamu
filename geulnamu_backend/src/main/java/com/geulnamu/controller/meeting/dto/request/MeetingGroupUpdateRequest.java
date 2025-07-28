package com.geulnamu.controller.meeting.dto.request;

import com.fasterxml.jackson.annotation.JsonFormat;
import jakarta.validation.constraints.Future;
import lombok.AllArgsConstructor;
import lombok.Getter;

import java.time.LocalDateTime;

@Getter
@AllArgsConstructor
public class MeetingGroupUpdateRequest {

    @Future(message = "토론 시간은 미래의 시간이어야 합니다.")
    @JsonFormat(pattern = "yyyyMMdd HH:mm")
    private LocalDateTime discussionTime;

    private Boolean discussionTimeNull; // 토론 시간을 null로 초기화하고 싶을 경우에 사용하는 값

    private String alarmMessage; // 모임 알람용 메세지 내용

}
