package com.geulnamu.domain.meeting;

import com.geulnamu.domain.meetingAttendance.MeetingAttendance;
import com.geulnamu.domain.member.Member;
import com.geulnamu.domain.shared.DateColumn;
import com.geulnamu.domain.shared.converter.MeetingTypeConverter;
import com.geulnamu.infrastructure.exception.ExistDataException;
import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDateTime;
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
    @Column(name = "meeting_type", length = 7)
    private MeetingType meetingType;

    @Column(name = "meeting_name", length = 70)
    private String meetingName;

    @Column(name = "meeting_date")
    private LocalDateTime meetingDate;

    @Column(name = "description")
    private String description;

    @OneToMany(mappedBy = "meeting", fetch = FetchType.LAZY)
    private List<MeetingAttendance> meetingAttendances;

    @Column(name = "private_at")
    private LocalDateTime privateAt;

    @Column(name = "deleted_at")
    private LocalDateTime deletedAt;


    public static Meeting createMeeting(Member member, String meetingName, MeetingType meetingType, LocalDateTime meetingDate, String description) {
        return Meeting.builder()
            .member(member)
            .meetingType(meetingType)
            .meetingName(meetingName)
            .meetingDate(meetingDate)
            .description(description)
            .build();
    }

    public void updateMeetingName(String meetingName) {
        this.meetingName = meetingName;
    }

    public void updateMeetingType(MeetingType targetMeetingType) {
        if(this.meetingType.equals(targetMeetingType)) {
            throw new ExistDataException();
        }
        this.meetingType = targetMeetingType;
    }

    public void updateMeetingDate(LocalDateTime targetMeetingDate) {
        if(this.meetingDate.equals(targetMeetingDate)) {
            throw new ExistDataException();
        }
        this.meetingDate = targetMeetingDate;
    }

    public void updateMeetingDescription(String description) {
        this.description = description;
    }

    public void makeMeetingPrivate() {
        if(this.privateAt != null) {
            throw new ExistDataException();
        }
        this.privateAt = LocalDateTime.now();
    }

    public void makeMeetingPublic() {
        if(this.privateAt == null) {
            throw new ExistDataException();
        }
        this.privateAt = null;
    }

}
