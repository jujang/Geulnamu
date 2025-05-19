package com.geulnamu.domain.bookQuestion;

import com.geulnamu.domain.meetingAttendance.MeetingAttendance;
import com.geulnamu.domain.shared.DateColumn;
import jakarta.persistence.*;
import lombok.AccessLevel;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Getter
@Entity(name = "book_questions")
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class BookQuestion extends DateColumn {

    @Id
    @Column(name = "book_question_id", updatable = false)
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "meeting_attendance_id")
    private MeetingAttendance meetingAttendance;

    @Column(name = "content", length = 255) // 향후 테스트해보고 길이 조정할 것
    private String content;

}
