package com.geulnamu.controller.member.dto.request;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import lombok.AllArgsConstructor;
import lombok.Getter;

@Getter
@AllArgsConstructor
public class MemberNameUpdateRequest {

    @NotBlank(message = "변경할 이름 필수 입력")
    @Pattern(regexp = "^[ㄱ-ㅎ가-힣a-zA-Z-_]{2,10}$", message = "이름은 특수문자를 제외한 2자 이상, 10자 이하이여야 합니다.")
    private String name;

}
