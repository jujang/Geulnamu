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

    private String alarmMessage; // 모임 알람용 메세지 내용

}
