package com.geulnamu.repository.attendance;

import com.geulnamu.domain.attendance.Attendance;
import com.geulnamu.domain.attendance.DiscussionGroup;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;

public interface AttendanceCommandRepository extends JpaRepository<Attendance, Long> {

    @Modifying(clearAutomatically = true)
    @Query(value = "UPDATE attendances a " +
        "SET a.discussionGroup = null " +
        "WHERE a.meeting.id = :meetingId")
    void resetDiscussionGroups(@Param("meetingId") Long meetingId);

    @Modifying(clearAutomatically = true)
    @Query(value = "UPDATE attendances a " +
        "SET a.discussionGroup = :group " +
        "WHERE a.meeting.id = :meetingId " +
        "AND a.id IN :attendanceIds ")
    void assignDiscussionGroup(@Param("meetingId") Long meetingId,
                               @Param("attendanceIds") List<Long> attendanceIds,
                               @Param("group") DiscussionGroup group);
}
