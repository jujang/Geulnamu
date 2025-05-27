package com.geulnamu.global.response;

public class ResponseMessage {
    public static final String SUCCESS = "API 호출 성공"; // 200

    public static final String BAD_REQUEST = "잘못된 요청입니다."; // 400
    public static final String NO_AUTHENTICATION = "인증 정보가 존재하지 않습니다."; // 401
    public static final String FORBIDDEN = "접근 권한 없음"; // 403
    public static final String NOT_FOUND = "조회된 데이터가 없습니다."; // 404
    public static final String INVALID_REQ_VALUE = "유효성 검사를 충족하지 못했습니다."; // 417
    public static final String NO_CHANGE_DETECTED = "현재 값과 동일하여 처리할 수 없습니다."; // 422
    public static final String INTERNAL_SERVER_ERROR = "Unknown error"; // 500


    public static final String BIRTH_DATE_NOT_VALIDATE = "생년월일은 yyyyMMdd 형식으로 입력해주세요.";

    public static final String ACCESS_TOKEN_NOT_VALIDATE = "엑세스 토큰이 유효하지 않습니다."; // 401
    public static final String REFRESH_TOKEN_NOT_VALIDATE = "리프레시 토큰이 유효하지 않습니다. 다시 로그인 해 주세요."; // 401
    public static final String NOT_FOUND_ACCESS_TOKEN = "액세스 토큰을 발견하지 못했습니다."; // 401
    public static final String NOT_FOUND_REFRESH_TOKEN = "리프레시 토큰을 발견하지 못했습니다."; // 401

}
