package com.geulnamu.repository.attendance;

import com.geulnamu.domain.attendance.Attendance;
import org.springframework.data.jpa.repository.JpaRepository;

public interface AttendanceCommandRepository extends JpaRepository<Attendance, Long> {
}
