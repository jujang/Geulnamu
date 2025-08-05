package com.geulnamu.repository.attendance;

import com.geulnamu.controller.attendance.dto.MemberAttendanceInfoWithGroup;
import com.geulnamu.controller.attendance.dto.response.MeetingAttendanceStatusResponse;
import com.geulnamu.controller.attendance.dto.response.MeetingAttendanceSummaryResponse;
import com.geulnamu.controller.shared.dto.response.AttendanceIdAndNameResponse;
import com.geulnamu.domain.attendance.DiscussionGroup;

import java.util.List;

public interface AttendanceQueryRepositoryCustom {
    MeetingAttendanceSummaryResponse findMeetingAttendanceSummary(Long meetingId);
    List<AttendanceIdAndNameResponse> findWantDiscussionMemberList(Long meetingId);
    List<AttendanceIdAndNameResponse> findMyDiscussionMemberList(Long meetingId, DiscussionGroup discussionGroup);
    List<MemberAttendanceInfoWithGroup> findAllDiscussionGroupMemberList(Long meetingId);
    List<MeetingAttendanceStatusResponse> findMeetingAttendanceStatus(Long meetingId);
    long countValidAttendanceIds(List<Long> attendanceIds, Long meetingId);
}
