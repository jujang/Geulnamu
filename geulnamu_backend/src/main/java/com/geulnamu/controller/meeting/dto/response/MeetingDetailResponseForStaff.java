package com.geulnamu.controller.meeting.dto.response;

import com.fasterxml.jackson.annotation.JsonFormat;
import com.geulnamu.domain.meeting.Meeting;
import com.geulnamu.domain.meeting.MeetingType;
import lombok.AllArgsConstructor;
import lombok.Getter;

import java.time.LocalDateTime;

@Getter
@AllArgsConstructor
public class MeetingDetailResponseForStaff {

    // 모임 관련
    private Long meetingId;
    private String meetingCreatorName;
    private Long meetingCreatorId;
    private MeetingType meetingType;
    private String meetingName;
    @JsonFormat(shape = JsonFormat.Shape.STRING, pattern = "yyyy.MM.dd HH:mm")
    private LocalDateTime meetingDateTime;
    @JsonFormat(shape = JsonFormat.Shape.STRING, pattern = "yyyy.MM.dd HH:mm")
    private LocalDateTime lateThresholdTime;
    private String meetingPlace;
    private String description;
    @JsonFormat(shape = JsonFormat.Shape.STRING, pattern = "yyyy.MM.dd HH:mm")
    private LocalDateTime createdAt;

    // 모임 관련 - 특수
    private Boolean isPrivateMeeting;

    // 토론 관련
    @JsonFormat(shape = JsonFormat.Shape.STRING, pattern = "yyyy.MM.dd HH:mm")
    private LocalDateTime discussionTime;
    private String alarmMessage;


    public static MeetingDetailResponseForStaff of(Meeting meeting) {
        return new MeetingDetailResponseForStaff(
            meeting.getId(), meeting.getMember().getName(), meeting.getMember().getId(),
            meeting.getMeetingType(), meeting.getMeetingName(), meeting.getMeetingDate(),
            meeting.getLateThresholdTime(), meeting.getMeetingPlace(), meeting.getDescription(),
            meeting.getCreatedAt(), meeting.getPrivateAt() != null,
            meeting.getDiscussionTime(), meeting.getAlarmMessage()
        );
    }

}
