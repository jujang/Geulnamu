package com.geulnamu.controller.login.dto.response;

import com.geulnamu.domain.shared.enums.Role;

public record LoginResponse(Long memberId, String memberName, Role role, String accessToken, boolean newMember) {
    public static LoginResponse of(Long memberId, String memberName, Role role, String accessToken, boolean newMember) {
        return new LoginResponse(memberId, memberName, role, accessToken, newMember);
    }
}
