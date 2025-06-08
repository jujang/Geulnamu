package com.geulnamu.controller.meeting.dto.response;

import com.fasterxml.jackson.annotation.JsonFormat;
import com.geulnamu.domain.meeting.Meeting;
import com.geulnamu.domain.meeting.MeetingType;
import lombok.AllArgsConstructor;
import lombok.Getter;

import java.time.LocalDateTime;

@Getter
@AllArgsConstructor
public class MeetingInfoResponseDTO {

    private Long meetingId;
    private String meetingCreatorName;
    private MeetingType meetingType;
    @JsonFormat(shape = JsonFormat.Shape.STRING, pattern = "yyyy.MM.dd HH:mm")
    private LocalDateTime meetingDateTime;
    private String description;
    @JsonFormat(shape = JsonFormat.Shape.STRING, pattern = "yyyy.MM.dd HH:mm")
    private LocalDateTime createdAt;
    private Boolean isPrivateMeeting;

    public static MeetingInfoResponseDTO of(Meeting meeting) {
        return new MeetingInfoResponseDTO(meeting.getId(), meeting.getMember().getName(),
            meeting.getMeetingType(), meeting.getMeetingDate(), meeting.getDescription(),
            meeting.getCreatedAt(), meeting.getPrivateAt() != null);
    }

}
