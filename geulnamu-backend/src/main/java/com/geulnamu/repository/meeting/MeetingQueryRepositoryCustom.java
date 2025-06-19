package com.geulnamu.repository.meeting;

import com.geulnamu.controller.meeting.dto.response.MeetingInfoResponse;
import com.geulnamu.controller.meeting.dto.response.StaffResponse;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

import java.util.List;

public interface MeetingQueryRepositoryCustom {
    List<StaffResponse> findStaffList();
    Page<MeetingInfoResponse> findMeetingsWithPaging(Pageable pageable);
    Page<MeetingInfoResponse> findMeetingsForAdminWithPaging(Pageable pageable);

}
