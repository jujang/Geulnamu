package com.geulnamu.controller.bookQuestion.dto.request;

import jakarta.validation.constraints.NotBlank;
import lombok.AllArgsConstructor;
import lombok.Getter;

@Getter
@AllArgsConstructor
public class BookQuestionCreateRequest {

    @NotBlank(message = "내용 필수 입력")
    private String content;

}
