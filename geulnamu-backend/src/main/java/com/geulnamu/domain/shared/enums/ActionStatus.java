package com.geulnamu.domain.shared.enums;

import lombok.Getter;

@Getter
public enum ActionStatus {
    SUCCESS("성공"),
    FAILURE("실패");

    private final String description;

    ActionStatus(String description) {
        this.description = description;
    }

}
