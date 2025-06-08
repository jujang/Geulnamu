package com.geulnamu.repository.meeting;

import com.geulnamu.domain.meeting.Meeting;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface MeetingRepository extends JpaRepository<Meeting, Long> {

}
