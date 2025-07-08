package com.geulnamu.domain.meeting;

import lombok.AllArgsConstructor;
import lombok.Getter;

@Getter
@AllArgsConstructor
public enum MeetingType {
    REGULAR("정기"), // 정기모임
    FLASH("번개"),   // 번개모임
    SPECIAL("특수");  // 특수모임

    private final String krText;
}
