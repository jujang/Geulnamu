package com.geulnamu.controller.meeting.dto.response;

import com.fasterxml.jackson.annotation.JsonFormat;
import com.geulnamu.domain.attendance.DiscussionGroup;
import com.geulnamu.domain.meeting.MeetingType;
import lombok.AllArgsConstructor;
import lombok.Getter;

import java.time.LocalDateTime;

@Getter
@AllArgsConstructor
public class MeetingInfoResponse {

    private Long meetingId;
    private String meetingCreatorName;
    private MeetingType meetingType;
    private String meetingName;
    @JsonFormat(shape = JsonFormat.Shape.STRING, pattern = "yyyy.MM.dd HH:mm")
    private LocalDateTime meetingDateTime;
    @JsonFormat(shape = JsonFormat.Shape.STRING, pattern = "HH:mm")
    private LocalDateTime lateThresholdTime;
    private String meetingPlace;
    private String description;
    private String attendanceStatus;
    private DiscussionGroup discussionGroup;
    @JsonFormat(shape = JsonFormat.Shape.STRING, pattern = "HH:mm")
    private LocalDateTime discussionTime;
    private String alarmMessage;
    @JsonFormat(shape = JsonFormat.Shape.STRING, pattern = "yyyy.MM.dd HH:mm")
    private LocalDateTime createdAt;

}
