package com.geulnamu.domain.shared;

public record TokenReissueResult(String accessToken, String refreshToken, boolean refreshTokenRenewed) {
}
