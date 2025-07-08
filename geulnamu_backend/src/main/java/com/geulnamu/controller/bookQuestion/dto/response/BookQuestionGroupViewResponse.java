package com.geulnamu.controller.bookQuestion.dto.response;

import lombok.AllArgsConstructor;
import lombok.Getter;

import java.util.List;

@Getter
@AllArgsConstructor
public class BookQuestionGroupViewResponse {
    List<BookQuestionViewResponse> bookQuestionViewResponseList;
}
