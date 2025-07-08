package com.geulnamu.repository.bookQuestion;

import com.geulnamu.controller.bookQuestion.dto.BookQuestionWithGroup;
import com.geulnamu.controller.bookQuestion.dto.response.BookQuestionViewResponse;
import com.geulnamu.domain.attendance.DiscussionGroup;
import com.geulnamu.domain.attendance.QAttendance;
import com.geulnamu.domain.bookQuestion.QBookQuestion;
import com.geulnamu.domain.meeting.QMeeting;
import com.querydsl.core.types.Projections;
import com.querydsl.jpa.impl.JPAQueryFactory;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
@RequiredArgsConstructor
public class BookQuestionQueryRepositoryImpl implements BookQuestionQueryRepositoryCustom {

    private final JPAQueryFactory queryFactory;
    private final QMeeting meeting = QMeeting.meeting;
    private final QAttendance attendance = QAttendance.attendance;
    private final QBookQuestion bookQuestion = QBookQuestion.bookQuestion;


    @Override
    public List<BookQuestionViewResponse> findMyDiscussionGroupBookQuestion(Long meetingId, DiscussionGroup discussionGroup) {
        return queryFactory
            .select(Projections.constructor(BookQuestionViewResponse.class,
                bookQuestion.id, attendance.member.id, bookQuestion.content)
            )
            .from(meeting)
            .join(attendance).on(attendance.meeting.id.eq(meetingId))
            .join(bookQuestion).on(bookQuestion.attendance.id.eq(attendance.id))
            .where(attendance.discussionGroup.eq(discussionGroup))
            .fetch();
    }

    @Override
    public List<BookQuestionWithGroup> findMeetingBookQuestion(Long meetingId) {
        return queryFactory
            .select(Projections.constructor(BookQuestionWithGroup.class,
                bookQuestion.id, attendance.member.id,
                bookQuestion.content, attendance.discussionGroup
            ))
            .from(meeting)
            .join(attendance).on(attendance.meeting.id.eq(meetingId))
            .join(bookQuestion).on(bookQuestion.attendance.id.eq(attendance.id))
            .fetch();
    }
}
