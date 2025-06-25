package com.geulnamu.repository.member;

import com.geulnamu.controller.member.dto.request.MemberListRequest;
import com.geulnamu.controller.member.dto.response.MemberInfoResponse;
import com.geulnamu.domain.member.Gender;
import com.geulnamu.domain.member.QMember;
import com.geulnamu.domain.shared.enums.Role;
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
public class MemberQueryRepositoryImpl implements MemberQueryRepositoryCustom {

    private final JPAQueryFactory queryFactory;
    private final QMember member = QMember.member;

    @Override
    public Page<MemberInfoResponse> findMembersWithPaging(MemberListRequest request) {
        Pageable pageable = request.toPageable();

        List<Long> count = queryFactory
            .select(member.count())
            .from(member)
            .where(filterByGender(request.getGender()),
                filterByRole(request.getRole()),
                filterByIsDeleted(request.getIsDeleted()))
            .fetch();

        List<MemberInfoResponse> content = queryFactory
            .select(Projections.constructor(MemberInfoResponse.class,
                member.id, member.name, member.gender, member.birthDate, member.nickname, member.role, member.deletedAt))
            .from(member)
            .where(filterByGender(request.getGender()),
                filterByRole(request.getRole()),
                filterByIsDeleted(request.getIsDeleted()))
            .orderBy(customSorting(request.getSortBy(), request.getIsAsc()),
                member.name.asc())
            .offset(pageable.getOffset())
            .limit(pageable.getPageSize())
            .fetch();

        return PageableExecutionUtils.getPage(content, pageable, count::size);
    }


    BooleanExpression filterByGender(Gender gender) {
        if(gender == null) return member.gender.isNotNull();
        else if(gender.equals(Gender.MALE)) return member.gender.eq(Gender.MALE);
        else return member.gender.eq(Gender.FEMALE);
    }

    BooleanExpression filterByRole(Role role) {
        if(role == null) return member.role.isNotNull();
        return switch(role) {
            case MEMBER -> member.role.eq(Role.MEMBER);
            case VICE_STAFF -> member.role.eq(Role.VICE_STAFF);
            case STAFF -> member.role.eq(Role.STAFF);
            case VICE_LEADER -> member.role.eq(Role.VICE_LEADER);
            case LEADER -> member.role.eq(Role.LEADER);
            case ADMIN -> member.role.eq(Role.ADMIN);
        };
    }

    BooleanExpression filterByIsDeleted(Boolean isDeleted) {
        if(isDeleted == null) {
            return member.deletedAt.isNull().or(member.deletedAt.isNotNull());
        } else if(isDeleted) {
            return member.deletedAt.isNotNull();
        } else {
            return member.deletedAt.isNull();
        }
    }

    // 기본 정렬 기준은 이름 오름차순, 다른 정렬 기준을 사용하더라도 2차 정렬 기준은 다시 이름 오름차순
    OrderSpecifier<?> customSorting(String sortBy, Boolean isAsc) {
        if(sortBy == null) return QueryDslUtil.getSortedColumn(Order.ASC, member, "name");
        if(isAsc == null) isAsc = false;

        return (isAsc) ? QueryDslUtil.getSortedColumn(Order.ASC, member, sortBy)
            : QueryDslUtil.getSortedColumn(Order.DESC, member, sortBy);
    }
}
