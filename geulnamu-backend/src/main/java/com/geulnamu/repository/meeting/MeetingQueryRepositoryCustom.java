package com.geulnamu.repository.meeting;

import com.geulnamu.controller.attendance.dto.response.AttendanceInfoResponse;
import com.geulnamu.controller.meeting.dto.request.MeetingListRequest;
import com.geulnamu.controller.meeting.dto.response.MeetingInfoForStaffResponse;
import com.geulnamu.controller.meeting.dto.response.MeetingInfoResponse;
import com.geulnamu.controller.shared.dto.response.MemberIdAndNameResponse;
import org.springframework.data.domain.Page;

import java.util.List;

public interface MeetingQueryRepositoryCustom {
    List<MemberIdAndNameResponse> findStaffList();
    Page<MeetingInfoResponse> findMeetingsWithPaging(MeetingListRequest request, Long myMemberId);
    List<AttendanceInfoResponse> findTodayMeetingList(Long memberId);
    Page<MeetingInfoForStaffResponse> findMeetingsForAdminWithPaging(MeetingListRequest request);
}
