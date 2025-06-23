package com.geulnamu.repository.attendance;

import com.geulnamu.controller.attendance.dto.response.AttendanceInfoResponse;
import com.geulnamu.controller.attendance.dto.response.DiscussionGroupResponse;
import com.geulnamu.controller.attendance.dto.response.MeetingAttendanceStatusResponse;
import com.geulnamu.controller.attendance.dto.response.MeetingAttendanceSummaryResponse;
import com.geulnamu.controller.shared.dto.response.MemberIdAndNameResponse;
import com.geulnamu.domain.attendance.DiscussionGroup;

import java.util.List;
import java.util.Optional;

public interface AttendanceQueryRepositoryCustom {
    Optional<AttendanceInfoResponse> findMyAttendanceInfo(Long attendanceId, Long memberId);
    MeetingAttendanceSummaryResponse findMeetingAttendanceSummary(Long meetingId);
    List<MemberIdAndNameResponse> findWantDiscussionMemberList(Long meetingId);
    List<MemberIdAndNameResponse> findMyDiscussionMemberList(Long meetingId, DiscussionGroup discussionGroup);
    List<DiscussionGroupResponse> findAllDiscussionGroupMemberList(Long meetingId);
    List<MeetingAttendanceStatusResponse> findMeetingAttendanceStatus(Long meetingId);
}
