package com.geulnamu.controller.voc.dto;

import jakarta.validation.constraints.NotBlank;
import lombok.AllArgsConstructor;
import lombok.Getter;

@Getter
@AllArgsConstructor
public class VoCRequest {
    @NotBlank(message = "내용 필수 입력")
    private String content;
}
