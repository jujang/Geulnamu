package com.geulnamu.controller.bookQuestion.dto.request;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.AllArgsConstructor;
import lombok.Getter;

@Getter
@AllArgsConstructor
public class BookQuestionCreateRequest {

    @NotBlank(message = "내용 필수 입력")
    @Size(max = 255, message = "발제문 내용은 255자 이내로 입력해주세요")
    private String content;

}
