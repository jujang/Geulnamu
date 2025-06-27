package com.geulnamu.repository.voc;

import com.geulnamu.controller.voc.dto.request.VoCViewListRequest;
import com.geulnamu.controller.voc.dto.response.VoCViewResponse;
import com.geulnamu.domain.voc.IssueStatus;
import com.geulnamu.domain.voc.QVoC;
import com.geulnamu.domain.voc.VoCType;
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
public class VoCQueryRepositoryImpl implements VoCQueryRepositoryCustom {

    private final JPAQueryFactory queryFactory;
    private final QVoC voC = QVoC.voC;

    @Override
    public Page<VoCViewResponse> findVoCIssuesWithPaging(VoCViewListRequest request) {
        Pageable pageable = request.toPageable();

        List<Long> count = queryFactory
            .select(voC.count())
            .from(voC)
            .where(filterByIssueStatus(request.getIssueStatus()),
                filterByVoCType(request.getVoCType()))
            .fetch();

        List<VoCViewResponse> content = queryFactory
            .select(Projections.constructor(VoCViewResponse.class,
                voC.id, voC.memberId, voC.voCType, voC.content, voC.issueStatus,
                voC.adminComment, voC.createdAt, voC.lastModifiedAt)
            )
            .from(voC)
            .where(filterByIssueStatus(request.getIssueStatus()),
                filterByVoCType(request.getVoCType()))
            .orderBy(customSorting(request.getSortBy(), request.getIsAsc()),
                voC.id.desc())
            .offset(pageable.getOffset())
            .limit(pageable.getPageSize())
            .fetch();

        return PageableExecutionUtils.getPage(content, pageable, count::size);
    }


    BooleanExpression filterByIssueStatus(IssueStatus issueStatus) {
        if(issueStatus == null) return null;
        else if(issueStatus.equals(IssueStatus.PENDING)) return voC.issueStatus.eq(IssueStatus.PENDING);
        else if(issueStatus.equals(IssueStatus.IN_PROGRESS)) return voC.issueStatus.eq(IssueStatus.IN_PROGRESS);
        else if(issueStatus.equals(IssueStatus.RESOLVED)) return voC.issueStatus.eq(IssueStatus.RESOLVED);
        else if(issueStatus.equals(IssueStatus.REJECTED)) return voC.issueStatus.eq(IssueStatus.REJECTED);
        else if(issueStatus.equals(IssueStatus.ON_HOLD)) return voC.issueStatus.eq(IssueStatus.ON_HOLD);
        else return voC.issueStatus.isNull();
    }

    BooleanExpression filterByVoCType(VoCType voCType) {
        if(voCType == null) return null;
        else if(voCType.equals(VoCType.ERROR_REPORT)) return voC.voCType.eq(VoCType.ERROR_REPORT);
        else if(voCType.equals(VoCType.FEATURE_REQUEST)) return voC.voCType.eq(VoCType.FEATURE_REQUEST);
        else return voC.voCType.isNull();
    }

    // 기본 정렬 기준은 이름 오름차순, 다른 정렬 기준을 사용하더라도 2차 정렬 기준은 다시 이름 오름차순
    OrderSpecifier<?> customSorting(String sortBy, Boolean isAsc) {
        if(sortBy == null) return QueryDslUtil.getSortedColumn(Order.DESC, voC, "id");
        if(isAsc == null) isAsc = false;

        return (isAsc) ? QueryDslUtil.getSortedColumn(Order.ASC, voC, sortBy)
            : QueryDslUtil.getSortedColumn(Order.DESC, voC, sortBy);
    }

}
