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

    @Column(name = "note", length = 1)
    private String note; // 비고 (출석 관련 특이사항이 적는 곳)

    @Column(name = "not_want_discussion", columnDefinition = "TINYINT(1)", nullable = false)
    private boolean notWantDiscussion; // 토론 미참여 희망

    @Convert(converter = DiscussionGroupConverter.class)
    @Column(name = "discussion_group", length = 1)
    private DiscussionGroup discussionGroup;

    @OneToMany(mappedBy = "attendance", fetch = FetchType.LAZY)
    private List<BookQuestion> bookQuestions;


    public static Attendance createAttendance(Meeting meeting, Member member) {
        return Attendance.builder()
            .meeting(meeting)
            .member(member)
            .notWantDiscussion(false)
            .build();
    }

    // 불참 의사를 비친 모임원과 해당 모임의 출석한 모임원 정보가 동일하지 않을 경우, 에러 발생
    public void checkRequestedMemberAndAttendanceMember(Member member) {
        if(!this.member.equals(member)) {
            throw new BadRequestException(ResponseMessage.NOT_SUITABLE_MEMBER);
        }
    }

    // 아직 토론 시간이 셋팅되지 않았다면 에러 발생
    public void checkSettingDiscussionTime() {
        if(this.meeting.getDiscussionTime() == null) {
            throw new BadRequestException(ResponseMessage.NOT_YET_SETTING_DISCUSSION_TIME);
        }
    }

    public void updateNotWantDiscussion() {
        this.notWantDiscussion = true;
    }

    public void updateWantDiscussion() {
        this.notWantDiscussion = false;
    }

}
