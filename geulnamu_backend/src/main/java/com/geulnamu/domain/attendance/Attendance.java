package com.geulnamu.domain.attendance;

import com.geulnamu.domain.bookQuestion.BookQuestion;
import com.geulnamu.domain.meeting.Meeting;
import com.geulnamu.domain.member.Member;
import com.geulnamu.domain.shared.DateColumn;
import com.geulnamu.domain.shared.converter.DiscussionGroupConverter;
import com.geulnamu.infrastructure.exception.BadRequestException;
import com.geulnamu.infrastructure.response.ResponseMessage;
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

    @Enumerated(EnumType.STRING)
    @Column(name = "attendance_type", nullable = false)
    private AttendanceType attendanceType;

    @Column(name = "note", length = 1)
    private String note; // 비고 (출석 관련 특이사항이 적는 곳)

    @Column(name = "want_discussion", columnDefinition = "TINYINT(1)", nullable = false)
    private boolean wantDiscussion; // 토론 참여 희망

    @Convert(converter = DiscussionGroupConverter.class)
    @Column(name = "discussion_group", length = 1)
    private DiscussionGroup discussionGroup;

    @OneToMany(mappedBy = "attendance", fetch = FetchType.LAZY)
    private List<BookQuestion> bookQuestions;


    public static Attendance createAttendance(Meeting meeting, Member member, AttendanceType attendanceType) {
        return Attendance.builder()
            .meeting(meeting)
            .member(member)
            .attendanceType(attendanceType)
            .wantDiscussion(true)
            .build();
    }

    // 아직 토론 시간이 셋팅되지 않았다면 에러 발생
    public void checkSettingDiscussionTime() {
        if(this.meeting.getDiscussionTime() == null) {
            throw new BadRequestException(ResponseMessage.NOT_YET_SETTING_DISCUSSION_TIME);
        }
    }

    public void checkRequestedMember(Long memberId) {
        if(!this.getMember().getId().equals(memberId)) {
            throw new BadRequestException(ResponseMessage.NOT_SUITABLE_MEMBER);
        }
    }

    public void checkMemberIsAssignDiscussionGroupForViewGroupBookQuestion() {
        if(this.getDiscussionGroup() == null) {
            throw new BadRequestException(ResponseMessage.BOOK_QUESTION_VIEW_RESTRICTION);
        }
    }

    public void updateNote(String note) {
        this.note = note;
    }

    public void updateNotWantDiscussion() {
        this.wantDiscussion = false;
    }

    public void updateWantDiscussion() {
        this.wantDiscussion = true;
    }

    public void updateDiscussionGroup(DiscussionGroup discussionGroup) {
        this.discussionGroup = discussionGroup;
    }

}
