package com.geulnamu.controller.login.dto.response;

public record LoginResponse(String accessToken, boolean newMember) {
    public static LoginResponse of(String accessToken, boolean newMember) {
        return new LoginResponse(accessToken, newMember);
    }
}
