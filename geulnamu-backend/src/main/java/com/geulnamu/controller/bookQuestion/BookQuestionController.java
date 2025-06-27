package com.geulnamu.controller.bookQuestion;

import com.geulnamu.controller.bookQuestion.dto.request.BookQuestionCreateRequest;
import com.geulnamu.controller.bookQuestion.dto.response.BookQuestionViewResponse;
import com.geulnamu.controller.bookQuestion.dto.response.BookQuestionGroupViewResponse;
import com.geulnamu.domain.shared.enums.ActionType;
import com.geulnamu.domain.shared.enums.DomainType;
import com.geulnamu.domain.shared.enums.Level;
import com.geulnamu.domain.shared.enums.Role;
import com.geulnamu.infrastructure.annotation.*;
import com.geulnamu.infrastructure.response.BaseResponse;
import com.geulnamu.service.bookQuestion.BookQuestionService;
import jakarta.validation.Valid;
import jakarta.validation.constraints.Min;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequiredArgsConstructor
@RequestMapping("/book-questions")
public class BookQuestionController {

    private final BookQuestionService bookQuestionService;


    // 실제와는 다르게 모임 출석 당일, 토론 시간만 설정되어 있다면 발제문 작성이 가능함! => 실제 모임에서도 이렇게 사용해도 될 듯 함
    @LogAction(value = ActionType.BOOK_QUESTION_CREATE, actionDomain = DomainType.BOOK_QUESTION)
    @AccessLevel(Level.MEMBER)
    @PostMapping(value = "/create", name = "발제문 작성")
    public BaseResponse<Long> writeBookQuestion(@AuthMemberId Long memberId,
                                                @RequestParam @Min(value = 1) Long attendanceId,
                                                @Valid @RequestBody BookQuestionCreateRequest request) {
        Long bookQuestionId = bookQuestionService.createBookQuestion(memberId, attendanceId, request.getContent());
        return BaseResponse.ofSuccess(bookQuestionId);
    }

    @ErrorLogAction(value = ActionType.BOOK_QUESTION_MY_GROUP_LIST_VIEW, actionDomain = DomainType.BOOK_QUESTION)
    @AccessLevel(Level.MEMBER)
    @GetMapping(value = "/my-group", name = "토론 그룹별 발제문 리스트 조회 - 본인 토론 그룹")
    public BaseResponse<List<BookQuestionViewResponse>> getMyGroupBookQuestions(@RequestParam @Min(value = 1) Long attendanceId) {
        List<BookQuestionViewResponse> responseList = bookQuestionService.findMyDiscussionGroupBookQuestions(attendanceId);
        return BaseResponse.ofSuccess(responseList);
    }

    @ErrorLogAction(value = ActionType.BOOK_QUESTION_ALL_GROUP_LIST_VIEW, actionDomain = DomainType.BOOK_QUESTION)
    @AccessLevel(Level.MEMBER)
    @GetMapping(value = "/meeting", name = "모임별 발제문 리스트 조회")
    public BaseResponse<List<BookQuestionGroupViewResponse>> getMeetingBookQuestions(@RequestParam @Min(value = 1) Long meetingId) {
        List<BookQuestionGroupViewResponse> responseList = bookQuestionService.findMeetingBookQuestions(meetingId);
        return BaseResponse.ofSuccess(responseList);
    }

    @LogAction(value = ActionType.BOOK_QUESTION_MODIFY, actionDomain = DomainType.BOOK_QUESTION)
    @AccessLevel(Level.MEMBER)
    @PatchMapping(value = "/{bookQuestionId}", name = "발제문 수정")
    public BaseResponse<Void> modifyBookQuestion(@PathVariable @Min(value = 1) Long bookQuestionId,
                                                 @AuthMemberId Long memberId, @AuthRole Role role,
                                                 @Valid @RequestBody BookQuestionCreateRequest request) {
        bookQuestionService.modifyBookQuestion(bookQuestionId, memberId, role, request.getContent());
        return BaseResponse.ofSuccess();
    }

    @LogAction(value = ActionType.BOOK_QUESTION_DELETE, actionDomain = DomainType.BOOK_QUESTION)
    @AccessLevel(Level.MEMBER)
    @DeleteMapping(value = "/{bookQuestionId}", name = "발제문 삭제")
    public BaseResponse<Void> removeBookQuestion(@PathVariable @Min(value = 1) Long bookQuestionId,
                                                 @AuthMemberId Long memberId, @AuthRole Role role) {
        bookQuestionService.removeBookQuestion(bookQuestionId, memberId, role);
        return BaseResponse.ofSuccess();
    }

}
