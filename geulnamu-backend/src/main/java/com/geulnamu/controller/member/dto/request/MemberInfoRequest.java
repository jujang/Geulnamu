package com.geulnamu.controller.member.dto.request;

import com.fasterxml.jackson.annotation.JsonFormat;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Past;
import jakarta.validation.constraints.Pattern;
import lombok.AllArgsConstructor;
import lombok.Getter;

import java.time.LocalDate;

@Getter
@AllArgsConstructor
public class MemberInfoRequest {

    @NotBlank(message = "이름 필수 입력")
    @Pattern(regexp = "^[ㄱ-ㅎ가-힣a-zA-Z-_]{2,10}$", message = "이름은 특수문자를 제외한 2자 이상, 10자 이하이여야 합니다.")
    private String name;

    @NotBlank(message = "성별 필수 입력")
    @Pattern(regexp = "MALE|FEMALE", message = "성별은 'MALE' 또는 'FEMALE' 만 가능합니다.")
    private String gender;

    @NotNull(message = "생일 필수 입력")
    @Past(message = "생년월일은 과거 날짜여야 합니다.")
    @JsonFormat(pattern = "yyyyMMdd")
    private LocalDate birthDate;

}
