package com.geulnamu.repository.meeting;

import com.geulnamu.controller.meeting.dto.response.MeetingInfoResponse;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

public interface MeetingQueryRepositoryCustom {
    Page<MeetingInfoResponse> findMeetingsWithPaging(Pageable pageable);
    Page<MeetingInfoResponse> findMeetingsForAdminWithPaging(Pageable pageable);

}
