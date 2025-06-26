package com.geulnamu.repository.bookQuestion;

import com.geulnamu.controller.bookQuestion.dto.BookQuestionWithGroup;
import com.geulnamu.controller.bookQuestion.dto.response.BookQuestionGroupViewResponse;
import com.geulnamu.domain.attendance.DiscussionGroup;

import java.util.List;

public interface BookQuestionQueryRepositoryCustom {
    List<BookQuestionGroupViewResponse> findMyDiscussionGroupBookQuestion(Long meetingId, DiscussionGroup discussionGroup);
    List<BookQuestionWithGroup> findMeetingBookQuestion(Long meetingId);
}
