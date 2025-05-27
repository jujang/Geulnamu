package com.geulnamu.controller.member.dto;

import jakarta.validation.constraints.NotBlank;
import lombok.Getter;

@Getter
public class MemberCreateRequestDTO {

    // kakaoMemberId
    @NotBlank(message = "카카오 계정 ID 필수 입력")
    private String kakaoMemberId;

}
