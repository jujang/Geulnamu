package com.geulnamu.domain.shared.enums;

import lombok.AllArgsConstructor;
import lombok.Getter;

@Getter
@AllArgsConstructor
public enum Level {

    PUBLIC("인증 없이 누구나 접근 가능"),
    AUTHENTICATED("로그인한 모든 사용자 접근 가능"),
    STAFF("준운영진 이상만 접근 가능"),
    ADMIN("관리자급만 접근 가능");

    private final String description;

    public String getDescription() {
        return description;
    }
}
