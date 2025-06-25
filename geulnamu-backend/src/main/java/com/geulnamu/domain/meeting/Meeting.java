package com.geulnamu.domain.meeting;

import com.geulnamu.domain.attendance.Attendance;
import com.geulnamu.domain.member.Member;
import com.geulnamu.domain.shared.DateColumn;
import com.geulnamu.domain.shared.converter.MeetingTypeConverter;
import com.geulnamu.infrastructure.exception.BadRequestException;
import com.geulnamu.infrastructure.exception.ExistDataException;
import com.geulnamu.infrastructure.exception.ForbiddenException;
import com.geulnamu.infrastructure.response.ResponseMessage;
import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.List;

@Getter
@Builder
@Entity(name = "meetings")
@AllArgsConstructor
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class Meeting extends DateColumn {

    @Id
    @Column(name = "meeting_id", updatable = false)
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "member_id")
    private Member member;

    @Convert(converter = MeetingTypeConverter.class)
    @Column(name = "meeting_type", length = 7, nullable = false)
    private MeetingType meetingType;

    @Column(name = "meeting_name", length = 70, nullable = false)
    private String meetingName;

    @Column(name = "meeting_date", nullable = false)
    private LocalDateTime meetingDate;

    @Column(name = "late_threshold_time", nullable = false)
    private LocalDateTime lateThresholdTime;

    @Column(name = "meeting_place", nullable = false)
    private String meetingPlace;

    @Column(name = "description")
    private String description;

    @Column(name = "discussion_time")
    private LocalDateTime discussionTime;

    @Column(name = "alarm_message")
    private String alarmMessage;

    @OneToMany(mappedBy = "meeting", fetch = FetchType.LAZY)
    private List<Attendance> attendances;

    @Column(name = "private_at")
    private LocalDateTime privateAt;


    public static Meeting createMeeting(Member member, String meetingName, MeetingType meetingType, LocalDateTime meetingDate,
                                        LocalDateTime lateThresholdTime, String meetingPlace, String description) {
        return Meeting.builder()
            .member(member)
            .meetingType(meetingType)
            .meetingName(meetingName)
            .meetingDate(meetingDate)
            .lateThresholdTime(lateThresholdTime == null ? meetingDate : lateThresholdTime) // 해당 값 입력 안 해줄 경우, 모임 시간과 동일한 시간을 가져가도록 함.
            .meetingPlace(meetingPlace)
            .description(description)
            .build();
    }

    public void checkMeetingUpdateTime() {
        if(LocalDateTime.now().isAfter(this.meetingDate)) {
            throw new BadRequestException(ResponseMessage.MEETING_INFO_UPDATE_TIME_RESTRICTION);
        }
    }

    public void checkDiscussionUpdateTime() {
        if(this.discussionTime != null && LocalDateTime.now().isAfter(this.discussionTime)) {
            throw new BadRequestException(ResponseMessage.MEETING_DISCUSSION_INFO_UPDATE_TIME_RESTRICTION);
        }
    }

    // 모임 출석 가능 시간 확인 (모임 당일, 모임 시작 1시간 전부터 출석 가능)
    public void checkTimeCanAttendMeeting() {
        if(LocalDateTime.now().getYear() != this.meetingDate.getYear()
            || LocalDateTime.now().getDayOfYear() != this.meetingDate.getDayOfYear()
            || !LocalDateTime.now().isAfter(this.meetingDate.minusHours(1))) {
            throw new BadRequestException(ResponseMessage.MEETING_ATTEND_TIME_RESTRICTION);
        }
    }

    // 지각 기준 시간 확인 (모임 당일, 모임 시간보다 빠르지 않아야 함)
    public void checkLateThresholdTimeBeforeMeetingTime() {
        if(this.lateThresholdTime.getYear() != this.meetingDate.getYear()
            || this.lateThresholdTime.getDayOfYear() != this.meetingDate.getDayOfYear()
            || this.lateThresholdTime.isBefore(this.meetingDate)) {
            throw new BadRequestException(ResponseMessage.LATE_THRESHOLD_TIME_RESTRICTION);
        }
    }

    // 토론 참여 여부 의사는 토론 시작 30분 전까지만 설정 가능   TODO: 해당 기능은 실 운영해보면서 수정 가능 시간이나 기능 수정 권한 조율해 볼 것
    public void checkTimeCanSwitchDiscussionAttendance() {
        if(LocalDateTime.now().isAfter(this.discussionTime.minusMinutes(30))) {
            throw new BadRequestException(ResponseMessage.DISCUSSION_INTENTION_SETTING_TIME_RESTRICTION);
        }
    }

    public void checkRequestedMember(Long memberId) {
        if(!this.getMember().getId().equals(memberId)) {
            throw new BadRequestException(ResponseMessage.NOT_SUITABLE_MEMBER);
        }
    }

    public void checkMemberIsDeActivated(Long memberId) {
        if(this.getMember().getDeletedAt() != null) {
            throw new ForbiddenException(ResponseMessage.DEACTIVATE_MEMBER_ACCESS_DENIED);
        }
    }

    public void checkTimeForDeleteMeeting() {
        if(LocalDateTime.now().plusHours(6).isAfter(this.meetingDate)) {
            throw new BadRequestException(ResponseMessage.MEETING_DELETION_TIME_EXPIRED);
        }
    }

    public void checkTimeForPrivateMeeting() {
        if(LocalDateTime.now().isBefore(this.meetingDate.plusDays(1).with(LocalTime.MIN))) {
            throw new BadRequestException(ResponseMessage.MEETING_PRIVACY_TIME_RESTRICTION);
        }
    }

    public void updateMeetingName(String meetingName) {
        this.meetingName = meetingName;
    }

    public void updateMeetingType(MeetingType targetMeetingType) {
        if(this.meetingType.equals(targetMeetingType)) {
            throw new ExistDataException("targetMeetingType");
        }
        this.meetingType = targetMeetingType;
    }

    public void updateMeetingDate(LocalDateTime targetMeetingDate) {
        if(this.meetingDate.equals(targetMeetingDate)) {
            throw new ExistDataException("targetMeetingDate");
        }
        this.meetingDate = targetMeetingDate;
    }

    public void updateLateThresholdTime(LocalDateTime lateThresholdTime) {
        if(this.lateThresholdTime.equals(lateThresholdTime)) {
            throw new ExistDataException("lateThresholdTime");
        }
        this.lateThresholdTime = lateThresholdTime;
        checkLateThresholdTimeBeforeMeetingTime();
    }

    public void updateMeetingPlace(String meetingPlace) {
        if(this.meetingPlace.equals(meetingPlace)) {
            throw new ExistDataException("meetingPlace");
        }
        this.meetingPlace = meetingPlace;
    }

    public void updateMeetingDescription(String description) {
        this.description = description;
    }

    public void updateDiscussionTime(LocalDateTime discussionTime) {
        // 이전에 입력한 시간과 동일한지 확인
        if(this.discussionTime != null && this.discussionTime.equals(discussionTime)) {
            throw new ExistDataException("discussionTime");
        }
        // 토론 시간은 모임 일정의 날짜와 같은 날 안에서만 모임 이후로 가능
        if(discussionTime != null && (!discussionTime.isAfter(this.meetingDate) ||
            discussionTime.getYear() != this.meetingDate.getYear() ||
            discussionTime.getDayOfYear() != this.meetingDate.getDayOfYear())) {
            throw new BadRequestException(ResponseMessage.MEETING_DISCUSSION_TIME_RESTRICTION);
        }
        this.discussionTime = discussionTime;
    }

    public void updateAlarmMessage(String alarmMessage) {
        this.alarmMessage = alarmMessage;
    }

    public void makeMeetingPrivate() {
        if(this.privateAt != null) {
            throw new ExistDataException("privateAt");
        }
        this.privateAt = LocalDateTime.now();
    }

    public void makeMeetingPublic() {
        if(this.privateAt == null) {
            throw new ExistDataException("privateAt");
        }
        this.privateAt = null;
    }

}
