package com.geulnamu.domain.shared.enums;

import lombok.Getter;

@Getter
public enum ActionType {
    // 계정 관련
    MEMBER_LOGIN("모임원 로그인"),

    // 모임원 관련
    MEMBER_INFO_UPDATE("개인 정보 수정"),
    MEMBER_NAME_UPDATE("모임원 이름 변경"),
    MEMBER_ROLE_UPDATE("모임원 권한 변경"),
    MEMBER_ACTIVATE("모임원 활성화"),
    MEMBER_DEACTIVATE("모임원 비활성화"),

    // 모임 관련
    MEETING_CREATE("모임 생성"),
    MEETING_UPDATE("모임 수정"),
    MEETING_UPDATE_DISCUSSION("모임 토론 정보 수정"),
    MEETING_DELETE("모임 삭제"),

    // 출석 관련
    ATTENDANCE_CREATE("출석"),
    ATTENDANCE_DELETE("출석 삭제"),
    DISCUSSION_GROUP_ORGANIZE("토론 그룹 구성"),
    DISCUSSION_GROUP_ORGANIZE_SOLO("개인 토론 그룹 할당");

    private final String description;

    ActionType(String description) {
        this.description = description;
    }

}
