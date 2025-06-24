package com.geulnamu.controller.meeting.dto.response;

import com.fasterxml.jackson.annotation.JsonFormat;
import com.geulnamu.domain.meeting.Meeting;
import com.geulnamu.domain.meeting.MeetingType;
import lombok.AllArgsConstructor;
import lombok.Getter;

import java.time.LocalDateTime;

@Getter
@AllArgsConstructor
public class MeetingInfoForStaffResponse {

    private Long meetingId;
    private String meetingCreatorName;
    private MeetingType meetingType;
    private String meetingName;
    @JsonFormat(shape = JsonFormat.Shape.STRING, pattern = "yyyy.MM.dd HH:mm")
    private LocalDateTime meetingDateTime;
    @JsonFormat(shape = JsonFormat.Shape.STRING, pattern = "yyyy.MM.dd HH:mm")
    private LocalDateTime lateThresholdTime;
    private String meetingPlace;
    private String description;
    @JsonFormat(shape = JsonFormat.Shape.STRING, pattern = "yyyy.MM.dd HH:mm")
    private LocalDateTime discussionTime;
    private String alarmMessage;
    @JsonFormat(shape = JsonFormat.Shape.STRING, pattern = "yyyy.MM.dd HH:mm")
    private LocalDateTime createdAt;
    private Boolean isPrivateMeeting;


    public static MeetingInfoForStaffResponse of(Meeting meeting) {
        return new MeetingInfoForStaffResponse(meeting.getId(), meeting.getMember().getName(), meeting.getMeetingType(),
            meeting.getMeetingName(), meeting.getMeetingDate(), meeting.getLateThresholdTime(), meeting.getMeetingPlace(),
            meeting.getDescription(), meeting.getDiscussionTime(), meeting.getAlarmMessage(), meeting.getCreatedAt(),
            meeting.getPrivateAt() != null);
    }

}
