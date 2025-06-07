package com.geulnamu.controller.member.dto.response;

public record LoginResponseDTO(String accessToken, boolean newMember) {
    public static LoginResponseDTO of(String accessToken, boolean newMember) {
        return new LoginResponseDTO(accessToken, newMember);
    }
}
