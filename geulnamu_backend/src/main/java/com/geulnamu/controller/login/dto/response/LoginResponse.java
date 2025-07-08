package com.geulnamu.controller.login.dto.response;

import com.geulnamu.domain.shared.enums.Role;

public record LoginResponse(Long memberId, Role role, String accessToken, boolean newMember) {
    public static LoginResponse of(Long memberId, Role role, String accessToken, boolean newMember) {
        return new LoginResponse(memberId, role, accessToken, newMember);
    }
}
