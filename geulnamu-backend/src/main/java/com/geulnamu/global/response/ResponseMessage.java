package com.geulnamu.global.response;

public class ResponseMessage {
    public static final String SUCCESS = "API Call successful"; // 200
    public static final String NOT_FOUND = "조회된 데이터가 없습니다."; // 404
    public static final String DUPLICATE_DATA_EXIST = "이미 존재하는 데이터입니다.";
    public static final String INVALID_REQ_VALUE = "유효성 검사를 충족하지 못했습니다."; // 417
    public static final String BAD_REQUEST = "잘못된 요청입니다.";
    public static final String INTERNAL_SERVER_ERROR = "Unknown error";
}
