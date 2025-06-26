package com.geulnamu.controller.bookQuestion.dto.response;

import lombok.AllArgsConstructor;
import lombok.Getter;

import java.util.List;

@Getter
@AllArgsConstructor
public class BookQuestionMeetingViewResponse {
    List<BookQuestionGroupViewResponse> bookQuestionGroupViewResponseList;
}
