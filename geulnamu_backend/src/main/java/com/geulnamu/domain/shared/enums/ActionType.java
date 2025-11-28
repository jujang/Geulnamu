package com.geulnamu.domain.shared.enums;

import lombok.Getter;

@Getter
public enum ActionType {
    // 계정 관련
    ACCOUNT_LOGIN("모임원 로그인"),
    ACCOUNT_REISSUE_TOKEN("토큰 재발급"),
    ACCOUNT_LOGOUT("모임원 로그아웃"),

    // 모임원 관련
    MEMBER_CREATE("모임원 생성"), // TODO: 임시 기능
    MEMBER_CHECK_PROFILE_STATUS("개인 정보 입력 여부 확인"),
    MEMBER_MY_VIEW("모임원 조회 - 본인용"),
    MEMBER_VIEW("모임원 조회 - 관리자용"),
    MEMBER_LIST_VIEW("모임원 목록 조회"),
    MEMBER_PUSH_SETTING_VIEW("푸시 알림 수신 여부 변경"),
    MEMBER_PUSH_SETTING_UPDATE("푸시 알림 수신 여부 변경"),
    MEMBER_INFO_UPDATE("개인 정보 수정"),
    MEMBER_ROLE_UPDATE("모임원 권한 변경"),
    MEMBER_NAME_UPDATE("모임원 이름 변경"),
    MEMBER_ACTIVATE("모임원 활성화"),
    MEMBER_DEACTIVATE("모임원 비활성화"),

    // 모임 관련
    MEETING_CREATE("모임 생성"),
    MEETING_STAFF_LIST_VIEW("운영진 명단 조회"),
    MEETING_LIST_VIEW("모임 목록 조회"),
    MEETING_VIEW("모임 단일 상세 조회"),
    MEETING_VIEW_FOR_STAFF("모임 단일 상세 조회 - 운영진용"),
    MEETING_UPDATE_BASIC("모임 수정"),
    MEETING_UPDATE_DISCUSSION("모임 토론 정보 수정"),
    MEETING_MAKE_PRIVATE("모임 비공개"),
    MEETING_MAKE_PUBLIC("비공개 모임 공개"),
    MEETING_REMOVE("모임 삭제"),

    // 출석 관련
    ATTENDANCE_CREATE("출석"),
    ATTENDANCE_MY_VIEW("개인 출석 정보 조회"),
    ATTENDANCE_LIST_VIEW("모임원 출석 현황 조회"),
    ATTENDANCE_WRITE_NOTE("비고 작성"),
    ATTENDANCE_JUST_READ("독서만 할래요"),
    ATTENDANCE_WANT_DISCUSSION("토론할래요"),
    ATTENDANCE_DELETE("출석 삭제"),

    DISCUSSION_WANT_LIST_VIEW("토론 참여 희망자 조회"),
    DISCUSSION_MY_GROUP_LIST_VIEW("본인 토론 그룹 명단 조회"),
    DISCUSSION_ALL_GROUP_LIST_VIEW("전체 토론 그룹 명단 조회"),
    DISCUSSION_GROUP_ORGANIZE("토론 그룹 구성"),
    DISCUSSION_GROUP_ORGANIZE_SOLO("개인 토론 그룹 할당"),

    // 발제문 관련
    BOOK_QUESTION_CREATE("발제문 작성"),
    BOOK_QUESTION_MY_LIST_VIEW("본인 발제문 조회"),
    BOOK_QUESTION_MY_GROUP_LIST_VIEW("본인 그룹 발제문 리스트 조회"),
    BOOK_QUESTION_ALL_GROUP_LIST_VIEW("전체 그룹 발제문 리스트 조회"),
    BOOK_QUESTION_MODIFY("발제문 수정"),
    BOOK_QUESTION_DELETE("발제문 삭제"),

    // 모임원의 소리 관련
    VOC_ERROR_REPORT("오류 보고"),
    VOC_FEATURE_REQUEST("요청 기능"),
    VOC_ISSUE_LIST_VIEW("이슈 목록 조회"),
    VOC_ISSUE_STATUS_MODIFY("이슈 상태 변경"),

    // 활동 내역 관련
    ACTION_HISTORY_LIST_VIEW("활동 내역 조회"),

    // FCM 앱 푸시 관련
    FCM_TOKEN_REGISTER("FCM 토큰 등록"),
    FCM_NOTIFICATION("FCM 수동 알림");

    private final String description;

    ActionType(String description) {
        this.description = description;
    }

}
