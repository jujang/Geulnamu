package com.geulnamu.infrastructure.response;

public class ResponseMessage {
    public static final String SUCCESS = "API 호출에 성공했습니다."; // 200

    public static final String BAD_REQUEST = "잘못된 요청입니다."; // 400
    public static final String NO_AUTHENTICATION = "인증 정보가 존재하지 않습니다."; // 401
    public static final String FORBIDDEN = "접근 권한이 없습니다."; // 403
    public static final String NOT_FOUND = "조회된 데이터가 없습니다."; // 404
    public static final String INVALID_REQ_VALUE = "유효성 검사를 충족하지 못했습니다."; // 417
    public static final String NO_CHANGE_DETECTED = "현재 값과 동일하여 처리할 수 없습니다."; // 422
    public static final String INTERNAL_SERVER_ERROR = "Unknown error"; // 500


    public static final String DATE_NOT_VALIDATE = "날짜값이 유효한 형식의 값이 아닙니다.";

    public static final String MEETING_INFO_UPDATE_TIME_RESTRICTION = "모임이 이뤄진 이후에는 모임 개최 관련 정보를 수정할 수 없습니다.";
    public static final String MEETING_DISCUSSION_INFO_UPDATE_TIME_RESTRICTION = "토론 활동이 시작된 이후에는 토론 관련 정보를 수정할 수 없습니다.";
    public static final String MEETING_DISCUSSION_TIME_RESTRICTION = "토론 시간은 모임 당일 내에서만, 모임 시간 이후로 가능합니다.";
    public static final String MEETING_PRIVACY_TIME_RESTRICTION  = "모임이 이뤄진 당일까지는 비공개 처리할 수 없습니다.";
    public static final String MEETING_DELETION_TIME_EXPIRED = "모임 시작 6시간 전부터는 삭제할 수 없습니다.";

    public static final String ACCESS_TOKEN_NOT_VALIDATE = "액세스 토큰이 유효하지 않습니다."; // 401
    public static final String REFRESH_TOKEN_NOT_VALIDATE = "리프레시 토큰이 유효하지 않습니다. 다시 로그인 해 주세요."; // 401
    public static final String NOT_FOUND_ACCESS_TOKEN = "액세스 토큰을 발견하지 못했습니다."; // 401
    public static final String NOT_FOUND_REFRESH_TOKEN = "리프레시 토큰을 발견하지 못했습니다."; // 401

    public static final String KAKAO_NICKNAME_PARSE_ISSUE = "카카오 닉네임 추출 중 예외 발생";

    public static final String OAUTH_SERVER_REQUEST_ISSUE = "OAuth 서버 요청에 문제가 있습니다.";
    public static final String OAUTH_SERVER_LOGOUT_ISSUE = "OAuth 로그아웃 과정에 문제가 있습니다.";

}
