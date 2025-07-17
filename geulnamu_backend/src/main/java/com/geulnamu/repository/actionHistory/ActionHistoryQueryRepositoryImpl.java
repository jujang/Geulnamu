package com.geulnamu.repository.actionHistory;

import com.geulnamu.controller.actionHistory.dto.request.ActionHistoryListRequest;
import com.geulnamu.controller.actionHistory.dto.response.ActionHistoryResponse;
import com.geulnamu.domain.actionHistory.ApiMethod;
import com.geulnamu.domain.actionHistory.QActionHistory;
import com.geulnamu.domain.shared.enums.ActionStatus;
import com.geulnamu.domain.shared.enums.DomainType;
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
public class ActionHistoryQueryRepositoryImpl implements ActionHistoryQueryRepositoryCustom {

    private final JPAQueryFactory queryFactory;
    private final QActionHistory actionHistory = QActionHistory.actionHistory;

    @Override
    public Page<ActionHistoryResponse> findActionHistoriesWithPaging(ActionHistoryListRequest request) {
        Pageable pageable = request.toPageable();

        final Long totalCount = queryFactory
            .select(actionHistory.count())
            .from(actionHistory)
            .where(
                filterByStatus(request.getStatus()),
                filterByActionDomain(request.getActionDomain()),
                filterByApiMethod(request.getApiMethod())
            )
            .fetchOne();

        List<ActionHistoryResponse> content = queryFactory
            .select(Projections.constructor(ActionHistoryResponse.class,
                actionHistory.id, actionHistory.actionType, actionHistory.status,
                actionHistory.actorMemberId, actionHistory.actionDomain, actionHistory.targetId,
                actionHistory.requestData, actionHistory.responseData, actionHistory.requestMethod,
                actionHistory.requestUri, actionHistory.processingTimeMs, actionHistory.ipAddress,
                actionHistory.userAgent, actionHistory.createdAt
                )
            )
            .from(actionHistory)
            .where(
                filterByStatus(request.getStatus()),
                filterByActionDomain(request.getActionDomain()),
                filterByApiMethod(request.getApiMethod())
            )
            .orderBy(customSorting(request.getSortBy(), request.getIsAsc()),
                actionHistory.id.desc()
            )
            .offset(pageable.getOffset())
            .limit(pageable.getPageSize())
            .fetch();

        return PageableExecutionUtils.getPage(content, pageable, () -> totalCount != null ? totalCount : 0L);
    }


    BooleanExpression filterByStatus(ActionStatus actionStatus) {
        if(actionStatus == null) return null;
        else if(actionStatus.equals(ActionStatus.SUCCESS)) return actionHistory.status.eq(ActionStatus.SUCCESS);
        else return actionHistory.status.eq(ActionStatus.FAILURE);
    }

    BooleanExpression filterByActionDomain(DomainType actionDomain) {
        if(actionDomain == null) return null;
        else if(actionDomain.equals(DomainType.LOGIN)) return actionHistory.actionDomain.eq(DomainType.LOGIN);
        else if(actionDomain.equals(DomainType.MEMBER)) return actionHistory.actionDomain.eq(DomainType.MEMBER);
        else if(actionDomain.equals(DomainType.MEETING)) return actionHistory.actionDomain.eq(DomainType.MEETING);
        else if(actionDomain.equals(DomainType.ATTENDANCE)) return actionHistory.actionDomain.eq(DomainType.ATTENDANCE);
        else if(actionDomain.equals(DomainType.BOOK_QUESTION)) return actionHistory.actionDomain.eq(DomainType.BOOK_QUESTION);
        else if(actionDomain.equals(DomainType.VOC)) return actionHistory.actionDomain.eq(DomainType.VOC);
        else return actionHistory.actionDomain.eq(DomainType.ACTION_HISTORY);
    }

    BooleanExpression filterByApiMethod(ApiMethod apiMethod) {
        if(apiMethod == null) return null;
        else if(apiMethod.equals(ApiMethod.POST)) return actionHistory.requestMethod.eq(ApiMethod.POST);
        else if(apiMethod.equals(ApiMethod.GET)) return actionHistory.requestMethod.eq(ApiMethod.GET);
        else if(apiMethod.equals(ApiMethod.PATCH)) return actionHistory.requestMethod.eq(ApiMethod.PATCH);
        else if(apiMethod.equals(ApiMethod.DELETE)) return actionHistory.requestMethod.eq(ApiMethod.DELETE);
        else return actionHistory.requestMethod.isNotNull();
    }

    // 기본 정렬 기준은 이름 오름차순, 다른 정렬 기준을 사용하더라도 2차 정렬 기준은 다시 이름 오름차순
    OrderSpecifier<?> customSorting(String sortBy, Boolean isAsc) {
        if(sortBy == null) return QueryDslUtil.getSortedColumn(Order.DESC, actionHistory, "id");
        if(isAsc == null) isAsc = false;

        return (isAsc) ? QueryDslUtil.getSortedColumn(Order.ASC, actionHistory, sortBy)
            : QueryDslUtil.getSortedColumn(Order.DESC, actionHistory, sortBy);
    }
}
