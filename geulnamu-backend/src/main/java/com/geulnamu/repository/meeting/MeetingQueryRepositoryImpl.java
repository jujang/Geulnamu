package com.geulnamu.repository.meeting;

import com.geulnamu.controller.meeting.dto.request.MeetingListRequest;
import com.geulnamu.controller.meeting.dto.response.MeetingInfoResponse;
import com.geulnamu.controller.meeting.dto.response.StaffResponse;
import com.geulnamu.domain.meeting.MeetingType;
import com.geulnamu.domain.meeting.QMeeting;
import com.geulnamu.domain.member.QMember;
import com.geulnamu.infrastructure.util.QueryDslUtil;
import com.querydsl.core.types.Order;
import com.querydsl.core.types.OrderSpecifier;
import com.querydsl.core.types.Projections;
import com.querydsl.core.types.dsl.BooleanExpression;
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


    @Override
    public List<StaffResponse> findStaffList() {
        return queryFactory
            .select(Projections.constructor(StaffResponse.class,
                member.id, member.name)
            )
            .from(meeting)
            .join(member).on(meeting.member.id.eq(member.id))
            .distinct()
            .fetch();
    }

    @Override
    public Page<MeetingInfoResponse> findMeetingsWithPaging(MeetingListRequest request) {
        Pageable pageable = request.toPageable();

        List<Long> count = queryFactory
            .select(meeting.count())
            .from(meeting)
            .where(meeting.privateAt.isNull(),
                filterByMeetingType(request.getMeetingType()),
                filterByMemberId(request.getMeetingCreatorId())
            )
            .fetch();

        List<MeetingInfoResponse> content = queryFactory
            .select(Projections.constructor(MeetingInfoResponse.class,
                meeting.id, meeting.member.name, meeting.meetingType, meeting.meetingName, meeting.meetingDate,
                meeting.meetingPlace, meeting.description, meeting.discussionTime, meeting.alarmMessage,
                meeting.createdAt, meeting.privateAt.isNotNull())
            )
            .from(meeting)
            .where(meeting.privateAt.isNull(),
                filterByMeetingType(request.getMeetingType()),
                filterByMemberId(request.getMeetingCreatorId())
            )
            .orderBy(customSorting(request.getSortBy(), request.getIsAsc()),
                meeting.id.desc())
            .offset(pageable.getOffset())
            .limit(pageable.getPageSize())
            .fetch();

        return PageableExecutionUtils.getPage(content, pageable, count::size);
    }

    @Override
    public Page<MeetingInfoResponse> findMeetingsForAdminWithPaging(MeetingListRequest request) {
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

        List<MeetingInfoResponse> content = queryFactory
            .select(Projections.constructor(MeetingInfoResponse.class,
                meeting.id, meeting.member.name, meeting.meetingType, meeting.meetingName, meeting.meetingDate,
                meeting.meetingPlace, meeting.description, meeting.discussionTime, meeting.alarmMessage,
                meeting.createdAt, meeting.privateAt.isNotNull())
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
