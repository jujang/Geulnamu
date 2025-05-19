package com.geulnamu.domain.meetingAttendance;

import com.geulnamu.domain.bookQuestion.BookQuestion;
import com.geulnamu.domain.meeting.Meeting;
import com.geulnamu.domain.member.Member;
import com.geulnamu.domain.shared.DateColumn;
import jakarta.persistence.*;
import lombok.AccessLevel;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.util.List;

@Getter
@Entity(name = "meeting_attendances")
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class MeetingAttendance extends DateColumn {

    @Id
    @Column(name = "meeting_attendance_id", updatable = false)
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "meeting_id")
    private Meeting meeting;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "member_id")
    private Member member;

    @Column(name = "discussion_group", length = 1)
    private DiscussionGroup discussionGroup;

    @OneToMany(mappedBy = "meetingAttendance", fetch = FetchType.LAZY)
    private List<BookQuestion> bookQuestions;

}
