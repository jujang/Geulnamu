package com.geulnamu.controller.meeting.dto.response;

import com.fasterxml.jackson.annotation.JsonFormat;
import com.geulnamu.controller.shared.dto.response.AttendanceIdAndNameResponse;
import com.geulnamu.domain.attendance.DiscussionGroup;
import com.geulnamu.domain.meeting.MeetingType;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;
import java.util.List;

@Getter
@NoArgsConstructor  // Redis 역직렬화용 기본 생성자
@AllArgsConstructor
public class MeetingDetailResponse {

    // 모임 관련
    private long meetingId;
    private String meetingCreatorName;
    private long meetingCreatorId;
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

    // 출석 관련
    private Long attendanceId;
    private String attendanceStatus;
    private String note;

    // 토론 관련
    @JsonFormat(shape = JsonFormat.Shape.STRING, pattern = "yyyy.MM.dd HH:mm")
    private LocalDateTime discussionTime;
    private String alarmMessage;
    private Boolean wantDiscussion;
    private DiscussionGroup discussionGroup;
    private List<AttendanceIdAndNameResponse> groupMemberList;

    public void updateGroupMemberList(List<AttendanceIdAndNameResponse> groupMemberList) {
        this.groupMemberList = groupMemberList;
    }
}
