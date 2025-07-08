package com.geulnamu.controller.member.dto.request;

import com.geulnamu.domain.shared.enums.Role;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import lombok.AllArgsConstructor;

@AllArgsConstructor
public class MemberRoleUpdateRequest {

    @NotBlank(message = "변경할 등급 필수 입력")
    @Pattern(regexp = "MEMBER|VICE_STAFF|STAFF|VICE_LEADER|LEADER|ADMIN", message = "role은 'MEMBER', 'VICE_STAFF', 'STAFF', 'VICE_LEADER', 'LEADER', 'ADMIN' 중 하나만 가능합니다.")
    private String role;

    public Role getRole() {
        return Role.valueOf(role);
    }
}
