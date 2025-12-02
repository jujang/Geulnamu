package com.geulnamu.repository.fcmTokenForMeeting;

import com.geulnamu.domain.attendance.Attendance;
import com.geulnamu.domain.fcmTokenForMeeting.FcmTokenForMeeting;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface FcmTokenForMeetingQueryRepository extends JpaRepository<FcmTokenForMeeting, Long> {
    Optional<FcmTokenForMeeting> findByAttendanceAndDeviceType(Attendance attendance, String deviceType);
    Optional<FcmTokenForMeeting> findByAttendance(Attendance attendance);
}
