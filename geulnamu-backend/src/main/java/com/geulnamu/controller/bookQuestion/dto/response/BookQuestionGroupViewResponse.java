package com.geulnamu.controller.bookQuestion.dto.response;

import lombok.AllArgsConstructor;
import lombok.Getter;

@Getter
@AllArgsConstructor
public class BookQuestionGroupViewResponse {
    private Long bookQuestionId;
    private Long writerMemberId; // 프론트에서 내부적으로 본인 여부 파악을 위해서만 쓰이는 값, 사용자에게는 실제로 보여주지 않는 값
    private String content;
}
