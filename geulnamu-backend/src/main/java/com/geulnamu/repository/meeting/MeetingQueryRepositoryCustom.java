package com.geulnamu.repository.meeting;

import com.geulnamu.controller.meeting.dto.request.MeetingListRequest;
import com.geulnamu.controller.meeting.dto.response.MeetingInfoResponse;
import com.geulnamu.controller.meeting.dto.response.StaffResponse;
import org.springframework.data.domain.Page;

import java.util.List;

public interface MeetingQueryRepositoryCustom {
    List<StaffResponse> findStaffList();
    Page<MeetingInfoResponse> findMeetingsWithPaging(MeetingListRequest request);
    Page<MeetingInfoResponse> findMeetingsForAdminWithPaging(MeetingListRequest request);

}
