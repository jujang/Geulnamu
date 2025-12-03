package com.geulnamu.repository.meeting;

import com.geulnamu.domain.meeting.Meeting;
import org.springframework.data.jpa.repository.JpaRepository;

import java.time.LocalDateTime;
import java.util.List;

public interface MeetingQueryRepository extends JpaRepository<Meeting, Long>, MeetingQueryRepositoryCustom {
    List<Meeting> findByDiscussionTime(LocalDateTime time);
}
