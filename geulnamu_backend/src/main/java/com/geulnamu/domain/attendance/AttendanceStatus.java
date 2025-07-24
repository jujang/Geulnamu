package com.geulnamu.domain.attendance;

import lombok.AllArgsConstructor;
import lombok.Getter;

@Getter
@AllArgsConstructor
public enum AttendanceStatus {
    ATTENDED("ATTEND"),
    ATTENDED_LATE("ATTEND_LATE"),
    NOT_ATTENDED("NOT_ATTEND"),
    NOT_STARTED("NOT_STARTED");

    private final String value;
}
