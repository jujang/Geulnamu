package com.geulnamu.controller.voc.dto.request;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.AllArgsConstructor;
import lombok.Getter;

@Getter
@AllArgsConstructor
public class VoCCreateRequest {
    @NotBlank(message = "내용 필수 입력")
    @Size(max = 255, message = "내용은 255자 이내로 입력해주세요")
    private String content;
}
