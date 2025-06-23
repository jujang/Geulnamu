package com.geulnamu.controller.attendance.dto.response;

import com.fasterxml.jackson.annotation.JsonFormat;
import com.geulnamu.controller.shared.dto.response.MemberIdAndNameResponse;
import com.geulnamu.domain.attendance.Attendance;
import com.geulnamu.domain.meeting.MeetingType;
import lombok.AllArgsConstructor;
import lombok.Getter;

import java.time.LocalDateTime;
import java.util.List;

@Getter
@AllArgsConstructor
public class AttendanceInfoResponse {

    private Long attendanceId;
    private MeetingType meetingType;
    @JsonFormat(shape = JsonFormat.Shape.STRING, pattern = "yyyy.MM.dd HH:mm")
    private LocalDateTime meetingDateTime;
    @JsonFormat(shape = JsonFormat.Shape.STRING, pattern = "yyyy.MM.dd HH:mm")
    private LocalDateTime lateThresholdTime;
    private String meetingName;
    private String meetingPlace;
    private String description;
    private String note;
    @JsonFormat(shape = JsonFormat.Shape.STRING, pattern = "yyyy.MM.dd HH:mm")
    private LocalDateTime discussionTime;
    private List<MemberIdAndNameResponse> groupMemberList;
    @JsonFormat(shape = JsonFormat.Shape.STRING, pattern = "yyyy.MM.dd HH:mm")
    private LocalDateTime createdAt;
    // TODO: 발제문 내용을 여기다가 적을지 어떻게 할지 고민해 볼 것 (근데 따로 빼는 게 나을 것 같음..;)


    public AttendanceInfoResponse(Attendance attendance, List<MemberIdAndNameResponse> memberIdAndNameResponseList) {
        this.attendanceId = attendance.getId();
        this.meetingType = attendance.getMeeting().getMeetingType();
        this.meetingDateTime = attendance.getMeeting().getMeetingDate();
        this.lateThresholdTime = attendance.getMeeting().getLateThresholdTime();
        this.meetingName = attendance.getMeeting().getMeetingName();
        this.meetingPlace = attendance.getMeeting().getMeetingPlace();
        this.description = attendance.getMeeting().getDescription();
        this.note = attendance.getNote();
        this.discussionTime = attendance.getMeeting().getDiscussionTime();
        this.groupMemberList = memberIdAndNameResponseList;
        this.createdAt = attendance.getCreatedAt();
    }

}
