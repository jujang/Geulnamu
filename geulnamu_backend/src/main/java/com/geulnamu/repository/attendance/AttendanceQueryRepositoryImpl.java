package com.geulnamu.repository.attendance;

import com.geulnamu.controller.attendance.dto.MemberAttendanceInfoWithGroup;
import com.geulnamu.controller.attendance.dto.response.MeetingAttendanceStatusResponse;
import com.geulnamu.controller.attendance.dto.response.MeetingAttendanceSummaryResponse;
import com.geulnamu.controller.shared.dto.response.AttendanceIdAndNameResponse;
import com.geulnamu.domain.attendance.Attendance;
import com.geulnamu.domain.attendance.DiscussionGroup;
import com.geulnamu.domain.attendance.QAttendance;
import com.geulnamu.domain.meeting.QMeeting;
import com.geulnamu.domain.member.QMember;
import com.querydsl.core.types.Projections;
import com.querydsl.core.types.dsl.CaseBuilder;
import com.querydsl.core.types.dsl.NumberExpression;
import com.querydsl.jpa.impl.JPAQueryFactory;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;

@Repository
@RequiredArgsConstructor
public class AttendanceQueryRepositoryImpl implements AttendanceQueryRepositoryCustom {

    private final JPAQueryFactory queryFactory;
    private final QMember member = QMember.member;
    private final QMeeting meeting = QMeeting.meeting;
    private final QAttendance attendance = QAttendance.attendance;


    @Override
    public MeetingAttendanceSummaryResponse findMeetingAttendanceSummary(Long meetingId) {
        return queryFactory
            .select(Projections.constructor(MeetingAttendanceSummaryResponse.class,
                meeting.meetingDate, meeting.lateThresholdTime, attendance.member.count(),
                    normalAttendanceCount(),
                    attendance.member.count().subtract(normalAttendanceCount()))
            )
            .from(meeting)
            .leftJoin(attendance).on(meeting.id.eq(attendance.meeting.id))
            .where(meeting.id.eq(meetingId))
            .orderBy(attendance.createdAt.desc())
            .fetchOne();
    }

    @Override
    public List<AttendanceIdAndNameResponse> findWantDiscussionMemberList(Long meetingId) {
        return queryFactory
            .select(Projections.constructor(AttendanceIdAndNameResponse.class,
                attendance.id, attendance.member.name)
            )
            .from(attendance)
            .where(attendance.meeting.id.eq(meetingId),
                attendance.wantDiscussion.eq(true))
            .orderBy(attendance.member.id.asc())
            .fetch();
    }

    @Override
    public List<AttendanceIdAndNameResponse> findMyDiscussionMemberList(Long meetingId, DiscussionGroup discussionGroup) {
        return queryFactory
            .select(Projections.constructor(AttendanceIdAndNameResponse.class,
                attendance.id, attendance.member.name)
            )
            .from(attendance)
            .where(attendance.meeting.id.eq(meetingId),
                attendance.discussionGroup.eq(discussionGroup))
            .orderBy(attendance.id.asc())
            .fetch();
    }

    @Override
    public List<MemberAttendanceInfoWithGroup> findAllDiscussionGroupMemberList(Long meetingId) {
        // meetingId 값을 기준으로 모두 조회
        return queryFactory
            .select(Projections.constructor(MemberAttendanceInfoWithGroup.class,
                    attendance.id, attendance.member.name, attendance.discussionGroup)
            )
            .from(attendance)
            .where(attendance.meeting.id.eq(meetingId)
                .and(attendance.discussionGroup.isNotNull()))
            .orderBy(attendance.discussionGroup.asc(), attendance.id.asc())
            .fetch();
    }

    public List<MeetingAttendanceStatusResponse> findMeetingAttendanceStatus(Long meetingId) {
        return queryFactory
            .select(Projections.constructor(MeetingAttendanceStatusResponse.class,
                attendance.id, attendance.member.id, attendance.member.name,
                attendance.createdAt, attendance.createdAt.after(meeting.lateThresholdTime),
                attendance.wantDiscussion)
            )
            .from(meeting)
            .join(attendance).on(meeting.id.eq(attendance.meeting.id))
            .where(meeting.id.eq(meetingId))
            .orderBy(attendance.createdAt.desc())
            .fetch();
    }

    @Override
    public long countValidAttendanceIds(List<Long> attendanceIds, Long meetingId) {
        Long count = queryFactory
            .select(attendance.count())
            .from(attendance)
            .where(
                attendance.id.in(attendanceIds)
                    .and(attendance.meeting.id.eq(meetingId))
            )
            .fetchOne();

        return count != null ? count : 0L;
    }

    @Override
    public List<Attendance> findAllForDiscussionNotification(LocalDateTime discussionTime) {
        return queryFactory
            .selectFrom(attendance)
            .join(attendance.meeting).fetchJoin()
            .join(attendance.member).fetchJoin()
            .where(
                meeting.discussionTime.eq(discussionTime),
                attendance.wantDiscussion.eq(true),
                attendance.discussionGroup.isNotNull(),
                attendance.fcmToken.isNotNull()
            )
            .orderBy(
                meeting.id.asc(),
                attendance.discussionGroup.asc()
            )
            .fetch();
    }


    private NumberExpression<Long> normalAttendanceCount() {
        return new CaseBuilder()
            .when(attendance.createdAt.before(meeting.lateThresholdTime))
            .then(1)
            .otherwise(0)
            .longValue().sum();
    }

}
