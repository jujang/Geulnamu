package com.geulnamu.controller.login.dto.response;

public record LoginResponse(Long memberId, String accessToken, boolean newMember) {
    public static LoginResponse of(Long memberId, String accessToken, boolean newMember) {
        return new LoginResponse(memberId, accessToken, newMember);
    }
}
