package com.geulnamu.repository.meeting;

import com.geulnamu.controller.meeting.dto.response.MeetingInfoResponse;
import com.geulnamu.controller.meeting.dto.response.StaffResponse;
import com.geulnamu.domain.meeting.QMeeting;
import com.geulnamu.domain.member.QMember;
import com.querydsl.core.types.Projections;
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
                member.id, member.name))
            .from(meeting)
            .join(member).on(meeting.member.id.eq(member.id))
            .distinct()
            .fetch();
    }

    @Override
    public Page<MeetingInfoResponse> findMeetingsWithPaging(Pageable pageable) {
        List<Long> count = queryFactory
            .select(meeting.count())
            .from(meeting)
            .where(meeting.privateAt.isNull())
            .fetch();

        List<MeetingInfoResponse> content = queryFactory
            .select(Projections.constructor(MeetingInfoResponse.class,
                meeting.id, meeting.member.name, meeting.meetingType, meeting.meetingName, meeting.meetingDate,
                meeting.meetingPlace, meeting.description, meeting.discussionTime, meeting.alarmMessage,
                meeting.createdAt, meeting.privateAt.isNotNull()))
            .from(meeting)
            .where(meeting.privateAt.isNull())
            .orderBy(meeting.id.desc())
            .offset(pageable.getOffset())
            .limit(pageable.getPageSize())
            .fetch();

        return PageableExecutionUtils.getPage(content, pageable, count::size);
    }

    @Override
    public Page<MeetingInfoResponse> findMeetingsForAdminWithPaging(Pageable pageable) {
        List<Long> count = queryFactory
            .select(meeting.count())
            .from(meeting)
            .fetch();

        List<MeetingInfoResponse> content = queryFactory
            .select(Projections.constructor(MeetingInfoResponse.class,
                meeting.id, meeting.member.name, meeting.meetingType, meeting.meetingName, meeting.meetingDate,
                meeting.meetingPlace, meeting.description, meeting.discussionTime, meeting.alarmMessage,
                meeting.createdAt, meeting.privateAt.isNotNull()))
            .from(meeting)
            .orderBy(meeting.id.desc())
            .offset(pageable.getOffset())
            .limit(pageable.getPageSize())
            .fetch();

        return PageableExecutionUtils.getPage(content, pageable, count::size);
    }

}
