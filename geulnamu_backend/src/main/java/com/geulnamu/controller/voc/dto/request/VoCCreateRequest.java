package com.geulnamu.controller.voc.dto.request;

import jakarta.validation.constraints.NotBlank;
import lombok.AllArgsConstructor;
import lombok.Getter;

@Getter
@AllArgsConstructor
public class VoCCreateRequest {
    @NotBlank(message = "내용 필수 입력")
    private String content;
}
