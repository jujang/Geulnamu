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
public class MemberDslRepositoryImpl implements MemberDslRepository{

    private final JPAQueryFactory queryFactory;
    private final QMember member = QMember.member;

    @Override
    public Page<MemberInfoResponseDTO> findMembers(Pageable pageable) {
        // 카운트 쿼리 (orderBy 제거)
        JPAQuery<Long> count = queryFactory
            .select(member.count())
            .from(member);

        // 데이터 조회 쿼리 (orderBy 추가)
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
