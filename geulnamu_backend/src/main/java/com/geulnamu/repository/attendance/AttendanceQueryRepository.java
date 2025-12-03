package com.geulnamu.repository.attendance;

import com.geulnamu.domain.attendance.Attendance;
import com.geulnamu.domain.attendance.DiscussionGroup;
import com.geulnamu.domain.meeting.Meeting;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface AttendanceQueryRepository extends JpaRepository<Attendance, Long>, AttendanceQueryRepositoryCustom {
    Optional<Attendance> findByMeetingIdAndMemberId(Long meetingId, Long memberId);
    List<Attendance> findByMeeting(Meeting meeting);
    List<Attendance> findByMeetingAndDiscussionGroup(Meeting meeting, DiscussionGroup discussionGroup);
}
