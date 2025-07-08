package com.geulnamu.controller.bookQuestion.dto;

import com.geulnamu.domain.attendance.DiscussionGroup;
import lombok.AllArgsConstructor;
import lombok.Getter;

@Getter
@AllArgsConstructor
public class BookQuestionWithGroup {
    private Long bookQuestionId;
    private Long writerMemberId;
    private String content;
    private DiscussionGroup discussionGroup;

}
