package com.geulnamu.repository.meeting;

import com.geulnamu.domain.meeting.Meeting;
import org.springframework.data.jpa.repository.JpaRepository;

public interface MeetingQueryRepository extends JpaRepository<Meeting, Long>, MeetingQueryRepositoryCustom {
}
