package com.geulnamu.repository.meeting;

import com.geulnamu.controller.meeting.dto.request.MeetingListRequest;
import com.geulnamu.controller.meeting.dto.response.MeetingInfoForAdminResponse;
import com.geulnamu.controller.meeting.dto.response.MeetingInfoResponse;
import com.geulnamu.controller.meeting.dto.response.MemberIdAndNameResponse;
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
    public Page<MeetingInfoResponse> findMeetingsWithPaging(MeetingListRequest request, Long myMemberId) {
        Pageable pageable = request.toPageable();

        List<Long> count = queryFactory
            .select(meeting.count())
            .from(meeting)
            .leftJoin(attendance).on(meeting.id.eq(attendance.meeting.id)
                .and(attendance.member.id.eq(myMemberId)))
            .where(meeting.privateAt.isNull(),
                filterByMeetingType(request.getMeetingType()),
                filterByMemberId(request.getMeetingCreatorId()),
                filterByAttendanceStatus(request.getAttendanceStatus())
            )
            .fetch();

        List<MeetingInfoResponse> content = queryFactory
            .select(Projections.constructor(MeetingInfoResponse.class,
                meeting.id, meeting.member.name, meeting.meetingType, meeting.meetingName, meeting.meetingDate,
                meeting.meetingPlace, meeting.description, attendanceStatusExpression(), attendance.discussionGroup,
                meeting.discussionTime, meeting.alarmMessage, meeting.createdAt)
            )
            .from(meeting)
            .leftJoin(attendance).on(meeting.id.eq(attendance.meeting.id)
                .and(attendance.member.id.eq(myMemberId)))
            .where(meeting.privateAt.isNull(),
                filterByMeetingType(request.getMeetingType()),
                filterByMemberId(request.getMeetingCreatorId()),
                filterByAttendanceStatus(request.getAttendanceStatus())
            )
            .orderBy(customSorting(request.getSortBy(), request.getIsAsc()),
                meeting.id.desc())
            .offset(pageable.getOffset())
            .limit(pageable.getPageSize())
            .fetch();

        return PageableExecutionUtils.getPage(content, pageable, count::size);
    }

    @Override
    public Page<MeetingInfoForAdminResponse> findMeetingsForAdminWithPaging(MeetingListRequest request) {
        Pageable pageable = request.toPageable();

        List<Long> count = queryFactory
            .select(meeting.count())
            .from(meeting)
            .where(
                filterByMeetingType(request.getMeetingType()),
                filterByMemberId(request.getMeetingCreatorId()),
                filterByIsPrivateOrNot(request.getIsPrivate())
            )
            .fetch();

        List<MeetingInfoForAdminResponse> content = queryFactory
            .select(Projections.constructor(MeetingInfoForAdminResponse.class,
                meeting.id, meeting.member.name, meeting.meetingType, meeting.meetingName, meeting.meetingDate,
                meeting.lateThresholdTime, meeting.meetingPlace, meeting.description, meeting.discussionTime,
                meeting.alarmMessage, meeting.createdAt, meeting.privateAt.isNotNull())
            )
            .from(meeting)
            .where(
                filterByMeetingType(request.getMeetingType()),
                filterByMemberId(request.getMeetingCreatorId()),
                filterByIsPrivateOrNot(request.getIsPrivate())
            )
            .orderBy(customSorting(request.getSortBy(), request.getIsAsc()),
                meeting.id.desc())
            .offset(pageable.getOffset())
            .limit(pageable.getPageSize())
            .fetch();

        return PageableExecutionUtils.getPage(content, pageable, count::size);
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
        return switch(meetingType) {
            case REGULAR -> meeting.meetingType.eq(MeetingType.REGULAR);
            case FLASH -> meeting.meetingType.eq(MeetingType.FLASH);
            case SPECIAL -> meeting.meetingType.eq(MeetingType.SPECIAL);
        };
    }

    BooleanExpression filterByMemberId(Long memberId) {
        if(memberId == null) return meeting.member.id.isNotNull();
        else return meeting.member.id.eq(memberId);
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

    // 기본 정렬 기준은 이름 오름차순, 다른 정렬 기준을 사용하더라도 2차 정렬 기준은 다시 이름 오름차순
    OrderSpecifier<?> customSorting(String sortBy, Boolean isAsc) {
        if(sortBy == null) return QueryDslUtil.getSortedColumn(Order.DESC, meeting, "id");
        if(isAsc == null) isAsc = false;

        return switch(sortBy) {
            case "meetingDate" ->
                (isAsc) ? QueryDslUtil.getSortedColumn(Order.ASC, meeting, "meetingDate")
                    : QueryDslUtil.getSortedColumn(Order.DESC, meeting, "meetingDate");
            case "meetingId" ->
                (isAsc) ? QueryDslUtil.getSortedColumn(Order.ASC, meeting, "id")
                    : QueryDslUtil.getSortedColumn(Order.DESC, meeting, "id");
            case "createdAt" ->
                (isAsc) ? QueryDslUtil.getSortedColumn(Order.ASC, meeting, "createdAt")
                    : QueryDslUtil.getSortedColumn(Order.DESC, meeting, "createdAt");
            default ->
                QueryDslUtil.getSortedColumn(Order.DESC, meeting, "id");
        };
    }

}
