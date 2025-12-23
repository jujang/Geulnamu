package com.geulnamu.infrastructure.security.token;

public class TokenInfo {

    private static final long ONE_MINUTE_TIME = 60 * 1000;

    // 액세스 토큰 유효시간 (모임 이용간 불편없이 사용 고려)
    public static final long LOGIN_VALID_TIME = 6 * 60 * ONE_MINUTE_TIME;

    // 리프레쉬 토큰 유효시간 (편의 고려해 180일 사용)
    public static final long REFRESH_TOKEN_VALID_TIME = 180 * 24 * 60 * ONE_MINUTE_TIME;

    public static final String TOKEN_PREFIX = "Bearer ";
}
