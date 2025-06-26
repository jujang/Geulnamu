package com.geulnamu.repository.attendance;

import com.geulnamu.controller.attendance.dto.MemberInfoWithGroup;
import com.geulnamu.controller.attendance.dto.response.DiscussionGroupResponse;
import com.geulnamu.controller.attendance.dto.response.MeetingAttendanceStatusResponse;
import com.geulnamu.controller.attendance.dto.response.MeetingAttendanceSummaryResponse;
import com.geulnamu.controller.shared.dto.response.MemberIdAndNameResponse;
import com.geulnamu.domain.attendance.DiscussionGroup;
import com.geulnamu.domain.attendance.QAttendance;
import com.geulnamu.domain.meeting.QMeeting;
import com.querydsl.core.Tuple;
import com.querydsl.core.types.Projections;
import com.querydsl.core.types.dsl.CaseBuilder;
import com.querydsl.core.types.dsl.NumberExpression;
import com.querydsl.jpa.impl.JPAQueryFactory;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Repository
@RequiredArgsConstructor
public class AttendanceQueryRepositoryImpl implements AttendanceQueryRepositoryCustom {

    private final JPAQueryFactory queryFactory;
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
            .join(attendance).on(meeting.id.eq(attendance.meeting.id))
            .where(meeting.id.eq(meetingId))
            .orderBy(attendance.createdAt.desc())
            .fetchOne();
    }

    @Override
    public List<MemberIdAndNameResponse> findWantDiscussionMemberList(Long meetingId) {
        return queryFactory
            .select(Projections.constructor(MemberIdAndNameResponse.class,
                attendance.member.id, attendance.member.name)
            )
            .from(attendance)
            .where(attendance.meeting.id.eq(meetingId))
            .orderBy(attendance.member.id.asc())
            .fetch();
    }

    @Override
    public List<MemberIdAndNameResponse> findMyDiscussionMemberList(Long meetingId, DiscussionGroup discussionGroup) {
        return queryFactory
            .select(Projections.constructor(MemberIdAndNameResponse.class,
                attendance.member.id, attendance.member.name)
            )
            .from(attendance)
            .where(attendance.meeting.id.eq(meetingId),
                attendance.discussionGroup.eq(discussionGroup))
            .orderBy(attendance.member.id.asc())
            .fetch();
    }

    @Override
    public List<MemberInfoWithGroup> findAllDiscussionGroupMemberList(Long meetingId) {
        // meetingId 값을 기준으로 모두 조회
        return queryFactory
            .select(Projections.constructor(MemberInfoWithGroup.class,
                    attendance.member.id, attendance.member.name, attendance.discussionGroup)
            )
            .from(attendance)
            .where(attendance.meeting.id.eq(meetingId)
                .and(attendance.discussionGroup.isNotNull()))
            .orderBy(attendance.discussionGroup.asc(), attendance.member.id.asc())
            .fetch();
    }

    public List<MeetingAttendanceStatusResponse> findMeetingAttendanceStatus(Long meetingId) {
        return queryFactory
            .select(Projections.constructor(MeetingAttendanceStatusResponse.class,
                attendance.member.id, attendance.member.name, attendance.createdAt, attendance.createdAt.after(meeting.lateThresholdTime))
            )
            .from(meeting)
            .join(attendance).on(meeting.id.eq(attendance.meeting.id))
            .where(meeting.id.eq(meetingId))
            .orderBy(attendance.createdAt.desc())
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
