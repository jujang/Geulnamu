package com.geulnamu.controller.meeting.dto.response;

import com.fasterxml.jackson.annotation.JsonFormat;
import com.geulnamu.domain.meeting.MeetingType;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Getter
@NoArgsConstructor  // Redis 역직렬화용 기본 생성자
@AllArgsConstructor
public class MeetingInfoResponse {

    private Long meetingId;
    private String meetingCreatorName;
    private Long meetingCreatorId;
    private MeetingType meetingType;
    private String meetingName;
    @JsonFormat(shape = JsonFormat.Shape.STRING, pattern = "yyyy.MM.dd HH:mm")
    private LocalDateTime meetingDateTime;
    private String meetingPlace;
    private String attendanceStatus;
    @JsonFormat(shape = JsonFormat.Shape.STRING, pattern = "yyyy.MM.dd HH:mm")
    private LocalDateTime discussionTime;
    private Boolean isPrivate;

}
