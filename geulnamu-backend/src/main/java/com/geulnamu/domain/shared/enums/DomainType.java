package com.geulnamu.domain.shared.enums;

import lombok.AllArgsConstructor;
import lombok.Getter;

@Getter
@AllArgsConstructor
public enum DomainType {
    MEMBER("member"),
    MEETING("meeting"),
    ATTENDANCE("attendance"),
    BOOK_HISTORY("book_history"),
    ACTION_HISTORY("action_history");

    private final String description;
}
