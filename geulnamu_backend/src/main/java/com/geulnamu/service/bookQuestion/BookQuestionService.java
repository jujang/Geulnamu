package com.geulnamu.service.bookQuestion;

import com.geulnamu.controller.bookQuestion.dto.BookQuestionWithGroup;
import com.geulnamu.controller.bookQuestion.dto.response.BookQuestionViewResponse;
import com.geulnamu.controller.bookQuestion.dto.response.BookQuestionGroupViewResponse;
import com.geulnamu.domain.attendance.Attendance;
import com.geulnamu.domain.attendance.DiscussionGroup;
import com.geulnamu.domain.bookQuestion.BookQuestion;
import com.geulnamu.domain.meeting.Meeting;
import com.geulnamu.domain.shared.enums.DomainType;
import com.geulnamu.domain.shared.enums.Role;
import com.geulnamu.infrastructure.exception.NotFoundDataException;
import com.geulnamu.repository.attendance.AttendanceQueryRepository;
import com.geulnamu.repository.bookQuestion.BookQuestionCommandRepository;
import com.geulnamu.repository.bookQuestion.BookQuestionQueryRepository;
import com.geulnamu.repository.meeting.MeetingQueryRepository;
import lombok.AllArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.*;
import java.util.stream.Collectors;

@Service
@AllArgsConstructor
public class BookQuestionService {

    private final MeetingQueryRepository meetingQueryRepository;
    private final AttendanceQueryRepository attendanceQueryRepository;
    private final BookQuestionQueryRepository bookQuestionQueryRepository;
    private final BookQuestionCommandRepository bookQuestionCommandRepository;


    @Transactional(rollbackFor = Exception.class)
    public Long createBookQuestion(Long memberId, Long attendanceId, String content) {
        Attendance attendance = findAttendanceById(attendanceId);
        attendance.checkRequestedMember(memberId);
        attendance.checkSettingDiscussionTime();
        BookQuestion bookQuestion = BookQuestion.createBookQuestion(attendance, content);
        bookQuestionCommandRepository.save(bookQuestion);
        return bookQuestion.getId();
    }

    @Transactional(readOnly = true)
    public List<BookQuestionViewResponse> findMyBookQuestions(Long memberId, Long attendanceId) {
        Attendance attendance = findAttendanceById(attendanceId);
        attendance.checkRequestedMember(memberId);
        return bookQuestionQueryRepository.findMyBookQuestion(attendanceId);
    }

    @Transactional(readOnly = true)
    public List<BookQuestionViewResponse> findMyDiscussionGroupBookQuestions_origin(Long attendanceId) {
        Attendance attendance = findAttendanceById(attendanceId);
        attendance.checkMemberIsAssignDiscussionGroupForViewGroupBookQuestion();
        return bookQuestionQueryRepository
            .findMyDiscussionGroupBookQuestion(attendance.getMeeting().getId(), attendance.getDiscussionGroup());
    }

    @Transactional(readOnly = true)
    public List<BookQuestionViewResponse> findMyDiscussionGroupBookQuestions(Long memberId, Long meetingId) {
        Meeting meeting =  meetingQueryRepository.findById(meetingId)
            .orElseThrow(() -> new NotFoundDataException(DomainType.MEETING.getDescription()));
        Attendance attendance = attendanceQueryRepository.findByMeetingIdAndMemberId(meetingId, memberId)
            .orElseThrow(() -> new NotFoundDataException(DomainType.ATTENDANCE.getDescription()));
        if(attendance.getDiscussionGroup() == null) {
            return new ArrayList<>();
        }
        return bookQuestionQueryRepository
            .findMyDiscussionGroupBookQuestion(meeting.getId(), attendance.getDiscussionGroup());
    }

    @Transactional(readOnly = true)
    public List<BookQuestionGroupViewResponse> findMeetingBookQuestions(Long meetingId) {
        List<BookQuestionWithGroup> bookQuestionWithGroupList = bookQuestionQueryRepository.findMeetingBookQuestion(meetingId);
        return convertToMeetingViewResponse(bookQuestionWithGroupList);
    }

    @Transactional(rollbackFor = Exception.class)
    public void modifyBookQuestion(Long bookQuestionId, Long memberId, Role role, String content) {
        BookQuestion bookQuestion = findBookQuestionById(bookQuestionId);
        bookQuestion.checkModificationOrDeletionAuthority(memberId, role);
        bookQuestion.updateContent(content);
    }

    @Transactional(rollbackFor = Exception.class)
    public void removeBookQuestion(Long bookQuestionId, Long memberId, Role role) {
        BookQuestion bookQuestion = findBookQuestionById(bookQuestionId);
        bookQuestion.checkModificationOrDeletionAuthority(memberId, role);
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

    private Attendance findAttendanceById(Long attendanceId) {
        return attendanceQueryRepository.findById(attendanceId)
            .orElseThrow(() -> new NotFoundDataException(DomainType.ATTENDANCE.getDescription()));
    }

    private BookQuestion findBookQuestionById(Long bookQuestionId) {
        return bookQuestionQueryRepository.findById(bookQuestionId)
            .orElseThrow(() -> new NotFoundDataException(DomainType.BOOK_QUESTION.getDescription()));
    }

}
