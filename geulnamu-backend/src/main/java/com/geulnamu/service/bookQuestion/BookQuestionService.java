package com.geulnamu.service.bookQuestion;

import com.geulnamu.controller.bookQuestion.dto.BookQuestionWithGroup;
import com.geulnamu.controller.bookQuestion.dto.response.BookQuestionViewResponse;
import com.geulnamu.controller.bookQuestion.dto.response.BookQuestionGroupViewResponse;
import com.geulnamu.domain.attendance.Attendance;
import com.geulnamu.domain.attendance.DiscussionGroup;
import com.geulnamu.domain.bookQuestion.BookQuestion;
import com.geulnamu.domain.shared.enums.DomainType;
import com.geulnamu.domain.shared.enums.Role;
import com.geulnamu.infrastructure.exception.BadRequestException;
import com.geulnamu.infrastructure.exception.NotFoundDataException;
import com.geulnamu.infrastructure.response.ResponseMessage;
import com.geulnamu.repository.attendance.AttendanceQueryRepository;
import com.geulnamu.repository.bookQuestion.BookQuestionCommandRepository;
import com.geulnamu.repository.bookQuestion.BookQuestionQueryRepository;
import lombok.AllArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Service
@AllArgsConstructor
public class BookQuestionService {

    private final AttendanceQueryRepository attendanceQueryRepository;
    private final BookQuestionQueryRepository bookQuestionQueryRepository;
    private final BookQuestionCommandRepository bookQuestionCommandRepository;


    @Transactional(rollbackFor = Exception.class)
    public Long createBookQuestion(Long memberId, Long attendanceId, String content) {
        Attendance attendance = attendanceQueryRepository.findById(attendanceId)
            .orElseThrow(() -> new NotFoundDataException(DomainType.ATTENDANCE.getDescription()));
        attendance.checkRequestedMember(memberId);
        attendance.checkSettingDiscussionTime();
        BookQuestion bookQuestion = BookQuestion.createBookQuestion(attendance, content);
        bookQuestionCommandRepository.save(bookQuestion);
        return bookQuestion.getId();
    }

    @Transactional(readOnly = true)
    public List<BookQuestionViewResponse> findMyDiscussionGroupBookQuestions(Long attendanceId) {
        Attendance attendance = attendanceQueryRepository.findById(attendanceId)
            .orElseThrow(() -> new NotFoundDataException(DomainType.ATTENDANCE.getDescription()));
        attendance.checkMemberIsAssignDiscussionGroupForViewGroupBookQuestion();
        return bookQuestionQueryRepository
            .findMyDiscussionGroupBookQuestion(attendance.getMeeting().getId(), attendance.getDiscussionGroup());
    }

    @Transactional(readOnly = true)
    public List<BookQuestionGroupViewResponse> findMeetingBookQuestions(Long meetingId) {
        List<BookQuestionWithGroup> bookQuestionWithGroupList = bookQuestionQueryRepository.findMeetingBookQuestion(meetingId);
        return convertToMeetingViewResponse(bookQuestionWithGroupList);
    }

    @Transactional(rollbackFor = Exception.class)
    public void modifyBookQuestion(Long bookQuestionId, Long memberId, Role role, String content) {
        BookQuestion bookQuestion = bookQuestionQueryRepository.findById(bookQuestionId)
            .orElseThrow(() -> new NotFoundDataException(DomainType.BOOK_HISTORY.getDescription()));
        if(!role.equals(Role.VICE_LEADER) && !role.equals(Role.LEADER) && !role.equals(Role.ADMIN)) {
            if(!bookQuestion.isBookQuestionWriteMember(memberId)) {
                throw new BadRequestException(ResponseMessage.FORBIDDEN);
            }
            bookQuestion.checkTimeCanModifyOrDeleteBookQuestionContent();
        }
        bookQuestion.updateContent(content);
    }

    @Transactional(rollbackFor = Exception.class)
    public void removeBookQuestion(Long bookQuestionId, Long memberId, Role role) {
        BookQuestion bookQuestion = bookQuestionQueryRepository.findById(bookQuestionId)
            .orElseThrow(() -> new NotFoundDataException(DomainType.BOOK_HISTORY.getDescription()));
        if(!role.equals(Role.VICE_LEADER) && !role.equals(Role.LEADER) && !role.equals(Role.ADMIN)) {
            if(!bookQuestion.isBookQuestionWriteMember(memberId)) {
                throw new BadRequestException(ResponseMessage.FORBIDDEN);
            }
            bookQuestion.checkTimeCanModifyOrDeleteBookQuestionContent();
        }
        bookQuestionCommandRepository.delete(bookQuestion);
    }


    private List<BookQuestionGroupViewResponse> convertToMeetingViewResponse(List<BookQuestionWithGroup> bookQuestionWithGroupList) {
        Map<DiscussionGroup, List<BookQuestionViewResponse>> groupedByDiscussionGroup =
            bookQuestionWithGroupList.stream()
                .collect(Collectors.groupingBy(
                    BookQuestionWithGroup::getDiscussionGroup,
                    Collectors.mapping(this::toGroupViewResponse, Collectors.toList())
                ));

        return groupedByDiscussionGroup.values().stream()
            .map(BookQuestionGroupViewResponse::new)
            .collect(Collectors.toList());
    }

    private BookQuestionViewResponse toGroupViewResponse(BookQuestionWithGroup bookQuestionWithGroup) {
        return new BookQuestionViewResponse(
            bookQuestionWithGroup.getBookQuestionId(),
            bookQuestionWithGroup.getWriterMemberId(),
            bookQuestionWithGroup.getContent()
        );
    }

}
