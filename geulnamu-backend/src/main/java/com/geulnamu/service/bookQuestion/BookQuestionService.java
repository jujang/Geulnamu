package com.geulnamu.service.bookQuestion;

import com.geulnamu.controller.bookQuestion.dto.BookQuestionWithGroup;
import com.geulnamu.controller.bookQuestion.dto.response.BookQuestionGroupViewResponse;
import com.geulnamu.controller.bookQuestion.dto.response.BookQuestionMeetingViewResponse;
import com.geulnamu.domain.attendance.Attendance;
import com.geulnamu.domain.attendance.DiscussionGroup;
import com.geulnamu.domain.bookQuestion.BookQuestion;
import com.geulnamu.domain.member.Member;
import com.geulnamu.domain.shared.enums.DomainType;
import com.geulnamu.domain.shared.enums.Role;
import com.geulnamu.infrastructure.exception.BadRequestException;
import com.geulnamu.infrastructure.exception.NotFoundDataException;
import com.geulnamu.infrastructure.response.ResponseMessage;
import com.geulnamu.repository.attendance.AttendanceQueryRepository;
import com.geulnamu.repository.bookQuestion.BookQuestionCommandRepository;
import com.geulnamu.repository.bookQuestion.BookQuestionQueryRepository;
import com.geulnamu.repository.member.MemberQueryRepository;
import lombok.AllArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Service
@AllArgsConstructor
public class BookQuestionService {

    private final MemberQueryRepository memberQueryRepository;
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
    public List<BookQuestionGroupViewResponse> findMyDiscussionGroupBookQuestions(Long attendanceId) {
        Attendance attendance = attendanceQueryRepository.findById(attendanceId)
            .orElseThrow(() -> new NotFoundDataException(DomainType.ATTENDANCE.getDescription()));
        attendance.checkMemberIsAssignDiscussionGroupForViewGroupBookQuestion();
        return bookQuestionQueryRepository
            .findMyDiscussionGroupBookQuestion(attendance.getMeeting().getId(), attendance.getDiscussionGroup());
    }

    @Transactional(readOnly = true)
    public List<BookQuestionMeetingViewResponse> findMeetingBookQuestions(Long meetingId) {
        List<BookQuestionWithGroup> bookQuestionWithGroupList = bookQuestionQueryRepository.findMeetingBookQuestion(meetingId);
        return convertToMeetingViewResponse(bookQuestionWithGroupList);
    }

    @Transactional(rollbackFor = Exception.class)
    public void modifyBookQuestion(Long memberId, Long bookQuestionId, String content) {
        BookQuestion bookQuestion = bookQuestionQueryRepository.findById(bookQuestionId)
            .orElseThrow(() -> new NotFoundDataException(DomainType.BOOK_HISTORY.getDescription()));
        if(!bookQuestion.isBookQuestionWriteMember(memberId)) {
            Member member = memberQueryRepository.findById(memberId)
                .orElseThrow(() -> new NotFoundDataException(DomainType.MEMBER.getDescription()));
            if(!member.getRole().equals(Role.VICE_LEADER) && !member.getRole().equals(Role.LEADER)
                && !member.getRole().equals(Role.ADMIN)) {
                throw new BadRequestException(ResponseMessage.FORBIDDEN);
            }
        } else {
            bookQuestion.checkTimeCanModifyBookQuestionContent();
        }
        bookQuestion.updateContent(content);
    }

    @Transactional(rollbackFor = Exception.class)
    public void removeBookQuestion(Long memberId, Long bookQuestionId) {
        BookQuestion bookQuestion = bookQuestionQueryRepository.findById(bookQuestionId)
            .orElseThrow(() -> new NotFoundDataException(DomainType.BOOK_HISTORY.getDescription()));
        if(!bookQuestion.isBookQuestionWriteMember(memberId)) {
            Member member = memberQueryRepository.findById(memberId)
                .orElseThrow(() -> new NotFoundDataException(DomainType.MEMBER.getDescription()));
            if(!member.getRole().equals(Role.VICE_LEADER) && !member.getRole().equals(Role.LEADER)
                && !member.getRole().equals(Role.ADMIN)) {
                throw new BadRequestException(ResponseMessage.FORBIDDEN);
            }
        } else {
            bookQuestion.checkTimeCanDeleteBookQuestionContent();
        }
        bookQuestionCommandRepository.delete(bookQuestion);
    }


    private List<BookQuestionMeetingViewResponse> convertToMeetingViewResponse(List<BookQuestionWithGroup> bookQuestionWithGroupList) {
        Map<DiscussionGroup, List<BookQuestionGroupViewResponse>> groupedByDiscussionGroup =
            bookQuestionWithGroupList.stream()
                .collect(Collectors.groupingBy(
                    BookQuestionWithGroup::getDiscussionGroup,
                    Collectors.mapping(this::toGroupViewResponse, Collectors.toList())
                ));

        return groupedByDiscussionGroup.values().stream()
            .map(BookQuestionMeetingViewResponse::new)
            .collect(Collectors.toList());
    }

    private BookQuestionGroupViewResponse toGroupViewResponse(BookQuestionWithGroup bookQuestionWithGroup) {
        return new BookQuestionGroupViewResponse(
            bookQuestionWithGroup.getBookQuestionId(),
            bookQuestionWithGroup.getWriterMemberId(),
            bookQuestionWithGroup.getContent()
        );
    }

}
