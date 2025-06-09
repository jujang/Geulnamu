package com.geulnamu.repository.meeting;

import com.geulnamu.controller.meeting.dto.response.MeetingInfoResponseDTO;
import com.geulnamu.domain.meeting.QMeeting;
import com.querydsl.core.types.Projections;
import com.querydsl.jpa.impl.JPAQuery;
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

    @Override
    public Page<MeetingInfoResponseDTO> findMeetingsWithPaging(Pageable pageable) {
        JPAQuery<Long> count = queryFactory
            .select(meeting.count())
            .from(meeting)
            .where(meeting.privateAt.isNull());

        List<MeetingInfoResponseDTO> content = queryFactory
            .select(Projections.constructor(MeetingInfoResponseDTO.class,
                meeting.id, meeting.member.name, meeting.meetingType, meeting.meetingName, meeting.meetingDate,
                meeting.description, meeting.createdAt, meeting.privateAt.isNotNull()))
            .from(meeting)
            .where(meeting.privateAt.isNull())
            .orderBy(meeting.id.desc())
            .offset(pageable.getOffset())
            .limit(pageable.getPageSize())
            .fetch();

        return PageableExecutionUtils.getPage(content, pageable, count::fetchOne);
    }

    @Override
    public Page<MeetingInfoResponseDTO> findMeetingsForAdminWithPaging(Pageable pageable) {
        JPAQuery<Long> count = queryFactory
            .select(meeting.count())
            .from(meeting);

        List<MeetingInfoResponseDTO> content = queryFactory
            .select(Projections.constructor(MeetingInfoResponseDTO.class,
                meeting.id, meeting.member.name, meeting.meetingType, meeting.meetingName, meeting.meetingDate,
                meeting.description, meeting.createdAt, meeting.privateAt.isNotNull()))
            .from(meeting)
            .orderBy(meeting.id.desc())
            .offset(pageable.getOffset())
            .limit(pageable.getPageSize())
            .fetch();

        return PageableExecutionUtils.getPage(content, pageable, count::fetchOne);
    }
}
