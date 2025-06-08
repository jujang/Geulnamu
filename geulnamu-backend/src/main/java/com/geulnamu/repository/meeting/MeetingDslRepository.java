package com.geulnamu.repository.meeting;

import com.geulnamu.controller.meeting.dto.response.MeetingInfoResponseDTO;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

public interface MeetingDslRepository {

    Page<MeetingInfoResponseDTO> findMeetings(Pageable pageable);
    Page<MeetingInfoResponseDTO> findMeetingsForAdmin(Pageable pageable);
}
