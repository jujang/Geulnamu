package com.geulnamu.repository.actionHistory;

import com.geulnamu.domain.actionHistory.ActionHistory;
import org.springframework.data.jpa.repository.JpaRepository;

public interface ActionHistoryQueryRepository extends JpaRepository<ActionHistory, Long>, ActionHistoryQueryRepositoryCustom {
}
