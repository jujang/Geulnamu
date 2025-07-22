package com.geulnamu.repository.meeting;

import com.geulnamu.controller.meeting.dto.request.MeetingListRequest;
import com.geulnamu.controller.meeting.dto.response.MeetingDetailResponse;
import com.geulnamu.controller.meeting.dto.response.MeetingInfoResponse;
import com.geulnamu.controller.shared.dto.response.MemberIdAndNameResponse;
import com.geulnamu.domain.attendance.AttendanceStatus;
import com.geulnamu.domain.attendance.QAttendance;
import com.geulnamu.domain.meeting.MeetingType;
import com.geulnamu.domain.meeting.QMeeting;
import com.geulnamu.domain.member.QMember;
import com.geulnamu.infrastructure.util.QueryDslUtil;
import com.querydsl.core.types.Order;
import com.querydsl.core.types.OrderSpecifier;
import com.querydsl.core.types.Projections;
import com.querydsl.core.types.dsl.*;
import com.querydsl.jpa.impl.JPAQueryFactory;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.support.PageableExecutionUtils;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;

@Repository
@RequiredArgsConstructor
public class MeetingQueryRepositoryImpl implements MeetingQueryRepositoryCustom {

    private final JPAQueryFactory queryFactory;
    private final QMeeting meeting = QMeeting.meeting;
    private final QMember member = QMember.member;
    private final QAttendance attendance = QAttendance.attendance;


    @Override
    public List<MemberIdAndNameResponse> findStaffList() {
        return queryFactory
            .select(Projections.constructor(MemberIdAndNameResponse.class,
                member.id, member.name)
            )
            .from(meeting)
            .join(member).on(meeting.member.id.eq(member.id))
            .distinct()
            .fetch();
    }

    @Override
    public Page<MeetingInfoResponse> findMeetingsWithPagingNew(MeetingListRequest request, Long myMemberId) {
        Pageable pageable = request.toPageable();

        final Long totalCount = queryFactory
            .select(meeting.count())
            .from(meeting)
            .leftJoin(attendance).on(meeting.id.eq(attendance.meeting.id)
                .and(attendance.member.id.eq(myMemberId)))
            .where(
                filterByMeetingType(request.getMeetingType()),
                filterByAttendanceStatus(request.getAttendanceStatus()),
                filterByIsPrivateOrNot(request.getIsPrivate()),
                filterByIsTodayMeeting(request.getIsTodayMeeting())
            )
            .fetchOne();

        List<MeetingInfoResponse> content = queryFactory
            .select(Projections.constructor(MeetingInfoResponse.class,
                meeting.id, meeting.member.name, meeting.member.id, meeting.meetingType, meeting.meetingName,
                meeting.meetingDate, meeting.meetingPlace, attendanceStatusExpression(),
                meeting.discussionTime, meeting.privateAt.isNotNull())
            )
            .from(meeting)
            .leftJoin(attendance).on(meeting.id.eq(attendance.meeting.id)
                .and(attendance.member.id.eq(myMemberId)))
            .where(
                filterByMeetingType(request.getMeetingType()),
                filterByAttendanceStatus(request.getAttendanceStatus()),
                filterByIsPrivateOrNot(request.getIsPrivate()),
                filterByIsTodayMeeting(request.getIsTodayMeeting())
            )
            .orderBy(customSorting(request.getSortBy(), request.getIsAsc()),
                meeting.id.desc())
            .offset(pageable.getOffset())
            .limit(pageable.getPageSize())
            .fetch();

        return PageableExecutionUtils.getPage(content, pageable, () -> totalCount != null ? totalCount : 0L);
    }

    @Override
    public MeetingDetailResponse findMeeting(Long meetingId, Long memberId) {
        return queryFactory
            .select(Projections.constructor(MeetingDetailResponse.class,
                meeting.id, meeting.member.name, meeting.member.id, meeting.meetingType, meeting.meetingName,
                meeting.meetingDate, meeting.lateThresholdTime, meeting.meetingPlace, meeting.description,
                meeting.createdAt,
                attendance.id, attendanceStatusExpression(), attendance.note,
                meeting.discussionTime, meeting.alarmMessage, attendance.wantDiscussion)
            )
            .from(meeting)
            .leftJoin(attendance).on(meeting.id.eq(attendance.meeting.id)
                .and(attendance.member.id.eq(memberId)))
            .where(meeting.id.eq(meetingId),
                meeting.privateAt.isNull())
            .fetchOne();
    }


    private StringExpression attendanceStatusExpression() {
        return new CaseBuilder()
            .when(attendance.id.isNull())
            .then(AttendanceStatus.NOT_ATTENDED.getValue())
            .when(attendance.createdAt.before(meeting.lateThresholdTime))
            .then(AttendanceStatus.ATTENDED.getValue())
            .otherwise(AttendanceStatus.ATTENDED_LATE.getValue())
            .as("attendanceStatus");
    }

    BooleanExpression filterByMeetingType(MeetingType meetingType) {
        if(meetingType == null) return meeting.meetingType.isNotNull();
        return meeting.meetingType.eq(meetingType);
    }

    BooleanExpression filterByMemberId(Long memberId) {
        if(memberId == null) return meeting.member.id.isNotNull();
        else return meeting.member.id.eq(memberId);
    }

    BooleanExpression filterByIsTodayMeeting(Boolean isTodayMeeting) {
        if(isTodayMeeting == null || !isTodayMeeting) return null;
        return meeting.meetingDate.year().eq(LocalDateTime.now().getYear())
            .and(meeting.meetingDate.dayOfYear().eq(LocalDateTime.now().getDayOfYear()));
    }

    BooleanExpression filterByIsPrivateOrNot(Boolean isPrivate) {
        if(isPrivate == null) return null;
        else if(isPrivate.equals(false)) return meeting.privateAt.isNull();
        else return meeting.privateAt.isNotNull();
    }

    BooleanExpression filterByAttendanceStatus(String attendanceStatus) {
        if(attendanceStatus == null) return null;
        else if(attendanceStatus.equals(AttendanceStatus.ATTENDED.getValue())) return attendance.id.isNotNull();
        else if(attendanceStatus.equals(AttendanceStatus.ATTENDED_LATE.getValue())) return attendance.createdAt.after(meeting.lateThresholdTime);
        else return attendance.id.isNull();
    }

    // 기본 정렬 기준은 모임 고유번호 내림차순, 다른 정렬 기준을 사용하더라도 2차 정렬 기준은 다신 모임 고유번호 내림차순
    OrderSpecifier<?> customSorting(String sortBy, Boolean isAsc) {
        if(sortBy == null) return QueryDslUtil.getSortedColumn(Order.DESC, meeting, "id");
        if(isAsc == null) isAsc = false;

        return (isAsc) ? QueryDslUtil.getSortedColumn(Order.ASC, meeting, sortBy)
            : QueryDslUtil.getSortedColumn(Order.DESC, meeting, sortBy);
    }

}
