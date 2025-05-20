package com.geulnamu.domain.meeting;

import com.geulnamu.domain.meetingAttendance.MeetingAttendance;
import com.geulnamu.domain.member.Member;
import com.geulnamu.domain.shared.DateColumn;
import com.geulnamu.domain.shared.MeetingTypeConverter;
import jakarta.persistence.*;
import lombok.AccessLevel;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;
import java.util.List;

@Getter
@Entity(name = "meetings")
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

    @Column(name = "meeting_name", length = 30)
    private String meetingName;

    @Column(name = "meeting_date")
    private LocalDateTime meetingDate;

    @OneToMany(mappedBy = "meeting", fetch = FetchType.LAZY)
    private List<MeetingAttendance> meetingAttendances;

    @Column(name = "deleted_at")
    private LocalDateTime deletedAt;
}
