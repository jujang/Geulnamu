package com.geulnamu.infrastructure.security.token;

public record TokenReissueResult(String accessToken, String refreshToken, boolean refreshTokenRenewed) {
}
