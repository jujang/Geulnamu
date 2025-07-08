package com.geulnamu.repository.attendance;

import com.geulnamu.domain.attendance.Attendance;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface AttendanceQueryRepository extends JpaRepository<Attendance, Long>, AttendanceQueryRepositoryCustom {
    Optional<Attendance> findByMeetingIdAndMemberId(Long meetingId, Long memberId);
}
