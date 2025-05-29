package com.geulnamu.controller.member.dto;

import com.geulnamu.domain.shared.enums.MemberStatus;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import lombok.AllArgsConstructor;

@AllArgsConstructor
public class MemberStatusUpdateRequestDTO {

    @NotBlank(message = "변경할 등급 필수 입력")
    @Pattern(regexp = "ACTIVE|INACTIVE", message = "status는 'ACTIVE', 'INACTIVE' 중 하나만 가능합니다.")
    private String status;

    public MemberStatus getStatus() {
        return MemberStatus.valueOf(status);
    }

}
