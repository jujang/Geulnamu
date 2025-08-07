package com.geulnamu.repository.bookQuestion;

import com.geulnamu.controller.bookQuestion.dto.BookQuestionWithGroup;
import com.geulnamu.controller.bookQuestion.dto.response.BookQuestionViewResponse;
import com.geulnamu.domain.attendance.DiscussionGroup;

import java.util.List;

public interface BookQuestionQueryRepositoryCustom {
    List<BookQuestionViewResponse> findMyBookQuestion(Long attendanceId);
    List<BookQuestionViewResponse> findMyDiscussionGroupBookQuestion(Long meetingId, DiscussionGroup discussionGroup);
    List<BookQuestionWithGroup> findMeetingBookQuestion(Long meetingId);
}
