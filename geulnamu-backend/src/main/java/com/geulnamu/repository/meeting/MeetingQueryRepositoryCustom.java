package com.geulnamu.repository.meeting;

import com.geulnamu.controller.meeting.dto.response.MeetingInfoResponseDTO;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

public interface MeetingQueryRepositoryCustom {
    Page<MeetingInfoResponseDTO> findMeetingsWithPaging(Pageable pageable);
    Page<MeetingInfoResponseDTO> findMeetingsForAdminWithPaging(Pageable pageable);

}
