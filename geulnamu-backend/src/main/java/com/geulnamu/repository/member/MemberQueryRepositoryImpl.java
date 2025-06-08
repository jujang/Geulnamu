package com.geulnamu.repository.member;

import com.geulnamu.controller.member.dto.response.MemberInfoResponseDTO;
import com.geulnamu.domain.member.QMember;
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
public class MemberQueryRepositoryImpl implements MemberQueryRepositoryCustom {

    private final JPAQueryFactory queryFactory;
    private final QMember member = QMember.member;

    @Override
    public Page<MemberInfoResponseDTO> findMembersWithPaging(Pageable pageable) {
        JPAQuery<Long> count = queryFactory
            .select(member.count())
            .from(member);

        List<MemberInfoResponseDTO> content = queryFactory
            .select(Projections.constructor(MemberInfoResponseDTO.class,
                member.id, member.name, member.gender, member.birthDate, member.nickname, member.role, member.deletedAt))
            .from(member)
            .orderBy(member.id.desc())
            .offset(pageable.getOffset())
            .limit(pageable.getPageSize())
            .fetch();

        return PageableExecutionUtils.getPage(content, pageable, count::fetchOne);
    }
}
