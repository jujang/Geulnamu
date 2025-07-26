package com.geulnamu.controller.attendance.dto.request;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import lombok.AllArgsConstructor;
import lombok.Getter;

@Getter
@AllArgsConstructor
public class AttendanceNoteRequest {

    @NotBlank(message = "비고 필수 입력")
    @Pattern(regexp = "^[ㄱ-ㅎ가-힣a-zA-Z0-9\\s:/@\\[\\]()~_!?.,;-]{1,255}$",
        message = "비고는 한글, 영문, 숫자, 공백 및 일부 특수문자(: / @ [ ] ( ) ~ _ ! ? . , ; -)만 1자 이상, 255자 이하로 입력해주세요.")
    private String note;

}
