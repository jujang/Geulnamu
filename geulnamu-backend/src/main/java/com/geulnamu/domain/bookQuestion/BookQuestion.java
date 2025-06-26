package com.geulnamu.domain.bookQuestion;

import com.geulnamu.domain.attendance.Attendance;
import com.geulnamu.domain.member.Member;
import com.geulnamu.domain.shared.DateColumn;
import com.geulnamu.infrastructure.exception.BadRequestException;
import com.geulnamu.infrastructure.response.ResponseMessage;
import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDateTime;

@Getter
@Builder
@Entity(name = "book_questions")
@AllArgsConstructor
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class BookQuestion extends DateColumn {

    @Id
    @Column(name = "book_question_id", updatable = false)
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "attendance_id")
    private Attendance attendance;

    @Column(name = "content", length = 255) // 향후 테스트해보고 길이 조정할 것
    private String content;


    public static BookQuestion createBookQuestion(Attendance attendance, String content) {
        return BookQuestion.builder()
            .attendance(attendance)
            .content(content)
            .build();
    }

    public void updateContent(String content) {
        this.content = content;
    }

    public void checkTimeCanModifyBookQuestionContent() {
        if(LocalDateTime.now().isAfter(this.getAttendance().getMeeting().getDiscussionTime().plusHours(2))) {
            throw new BadRequestException(ResponseMessage.BOOK_QUESTION_TIME_RESTRICTION);
        }
    }

    public void checkTimeCanDeleteBookQuestionContent() {
        if(LocalDateTime.now().isAfter(this.getAttendance().getMeeting().getDiscussionTime().plusHours(2))) {
            System.out.println(this.getAttendance().getMeeting().getDiscussionTime());
            System.out.println(LocalDateTime.now().isAfter(this.getAttendance().getMeeting().getDiscussionTime().plusHours(2)));
            throw new BadRequestException(ResponseMessage.BOOK_QUESTION_TIME_RESTRICTION);
        }
    }

    public void checkRequestedMember(Long memberId) {
        if(!this.getAttendance().getMember().getId().equals(memberId)) {
            throw new BadRequestException(ResponseMessage.NOT_SUITABLE_MEMBER);
        }
    }

    public Boolean isBookQuestionWriteMember(Long memberId) {
        return this.getAttendance().getMember().getId().equals(memberId);
    }
}
