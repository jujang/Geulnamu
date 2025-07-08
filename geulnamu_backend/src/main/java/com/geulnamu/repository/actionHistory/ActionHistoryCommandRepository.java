package com.geulnamu.repository.actionHistory;

import com.geulnamu.domain.actionHistory.ActionHistory;
import org.springframework.data.jpa.repository.JpaRepository;

public interface ActionHistoryCommandRepository extends JpaRepository<ActionHistory, Long> {
}
