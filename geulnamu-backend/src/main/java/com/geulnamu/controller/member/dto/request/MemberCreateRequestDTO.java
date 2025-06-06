package com.geulnamu.controller.member.dto.request;

import jakarta.validation.constraints.NotBlank;
import lombok.AllArgsConstructor;
import lombok.Getter;

@Getter
@AllArgsConstructor
public class MemberCreateRequestDTO {

    // kakaoMemberId
    @NotBlank(message = "카카오 계정 ID 필수 입력")
    private String kakaoMemberId;

}
