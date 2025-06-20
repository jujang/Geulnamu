package com.geulnamu.repository.attendance;

import com.geulnamu.controller.attendance.dto.response.AttendanceInfoResponse;
import com.geulnamu.domain.attendance.QAttendance;
import com.geulnamu.domain.meeting.QMeeting;
import com.querydsl.core.types.Projections;
import com.querydsl.core.types.dsl.Expressions;
import com.querydsl.jpa.impl.JPAQueryFactory;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Repository;

import java.util.Optional;

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

}
