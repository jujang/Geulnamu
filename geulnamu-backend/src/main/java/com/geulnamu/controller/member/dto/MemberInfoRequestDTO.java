package com.geulnamu.controller.member.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import lombok.Getter;

@Getter
public class MemberInfoRequestDTO {

    @NotBlank(message = "이름 필수 입력") // TODO: 정말로 10자 이하인지 10자 미만인지 나중에 체크할 것
    @Pattern(regexp = "^[ㄱ-ㅎ가-힣a-zA-Z-_]{2,10}$", message = "이름은 특수문자를 제외한 2자 이상, 10자 이하이여야 합니다.")
    private String name;

    @NotBlank(message = "성별 필수 입력")
    @Pattern(regexp = "남자|여자", message = "성별은 '남자' 또는 '여자'만 가능합니다.")
    private String gender;

    @NotBlank(message = "생일 필수 입력")
    @Pattern(regexp = "[0-9]{6}", message = "생년월일은 숫자만으로 6자리를 입력해주세요.")
    private String birthDate;

}
