package com.geulnamu.repository.attendance;

import com.geulnamu.controller.attendance.dto.response.AttendanceInfoResponse;
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
import com.querydsl.core.types.dsl.Expressions;
import com.querydsl.core.types.dsl.NumberExpression;
import com.querydsl.jpa.impl.JPAQueryFactory;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.stream.Collectors;

@Repository
@RequiredArgsConstructor
public class AttendanceQueryRepositoryImpl implements AttendanceQueryRepositoryCustom {

    private final JPAQueryFactory queryFactory;
    private final QMeeting meeting = QMeeting.meeting;
    private final QAttendance attendance = QAttendance.attendance;

    @Override
    public Optional<AttendanceInfoResponse> findMyAttendanceInfo(Long attendanceId, Long memberId) {
        return Optional.ofNullable(queryFactory
            .select(Projections.constructor(AttendanceInfoResponse.class,
                attendance.id, attendance.meeting.meetingType, attendance.meeting.meetingDate,
                attendance.meeting.lateThresholdTime, attendance.meeting.meetingName, attendance.meeting.meetingPlace,
                attendance.meeting.description, attendance.note, attendance.meeting.discussionTime,
                Expressions.nullExpression(String.class), attendance.meeting.createdAt)
            )
            .from(attendance)
            .where(attendance.id.eq(attendanceId)
                .and(attendance.member.id.eq(memberId)))
            .fetchOne());
    }

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
    public List<DiscussionGroupResponse> findAllDiscussionGroupMemberList(Long meetingId) {
        // meetingId 값을 기준으로 모두 조회
        List<Tuple> results = queryFactory
            .select(attendance.discussionGroup, attendance.member.id, attendance.member.name)
            .from(attendance)
            .where(attendance.meeting.id.eq(meetingId)
                .and(attendance.discussionGroup.isNotNull()))
            .orderBy(attendance.discussionGroup.asc(), attendance.member.id.asc())
            .fetch();

        // discussionGroup 값을 기준으로 같은 discussionGroup 끼리 List로 묶어서 map 으로 만들기
        Map<DiscussionGroup, List<MemberIdAndNameResponse>> groupMap = results.stream()
            .collect(Collectors.groupingBy(
                tuple -> tuple.get(attendance.discussionGroup),
                Collectors.mapping(
                    tuple -> new MemberIdAndNameResponse(
                        tuple.get(attendance.member.id),
                        tuple.get(attendance.member.name)
                    ),
                    Collectors.toList()
                )
            ));

        // 맵들을 discussionGroup 값으로 정렬하고, 값들을 DiscussionGroupResponse 타입에 담아 전체를 list로 만들어 반환
        return groupMap.entrySet().stream()
            .sorted(Map.Entry.comparingByKey())
            .map(entry -> new DiscussionGroupResponse(entry.getValue()))
            .collect(Collectors.toList());
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
