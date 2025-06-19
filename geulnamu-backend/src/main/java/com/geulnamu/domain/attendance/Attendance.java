package com.geulnamu.domain.attendance;

import com.geulnamu.domain.bookQuestion.BookQuestion;
import com.geulnamu.domain.meeting.Meeting;
import com.geulnamu.domain.member.Member;
import com.geulnamu.domain.shared.DateColumn;
import com.geulnamu.domain.shared.converter.DiscussionGroupConverter;
import jakarta.persistence.*;
import lombok.*;

import java.util.List;

@Getter
@Builder
@Entity(name = "attendances")
@AllArgsConstructor
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class Attendance extends DateColumn {

    @Id
    @Column(name = "attendance_id", updatable = false)
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "meeting_id")
    private Meeting meeting;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "member_id")
    private Member member;

    @Column(name = "note", length = 1)
    private String note; // 비고 (출석 관련 특이사항이 적는 곳)

    @Convert(converter = DiscussionGroupConverter.class)
    @Column(name = "discussion_group", length = 1)
    private DiscussionGroup discussionGroup;

    @OneToMany(mappedBy = "attendance", fetch = FetchType.LAZY)
    private List<BookQuestion> bookQuestions;


    public static Attendance createAttendance(Meeting meeting, Member member) {
        return Attendance.builder()
            .meeting(meeting)
            .member(member)
            .build();
    }

}
