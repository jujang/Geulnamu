package com.geulnamu.controller.meeting.dto.response;

import com.geulnamu.infrastructure.response.paging.PagingResponse;
import lombok.AllArgsConstructor;
import lombok.Getter;

import java.util.List;

@Getter
@AllArgsConstructor
public class MeetingListForStaffResponse {
    private PagingResponse pagingResponse;
    private List<MeetingInfoForStaffResponse> meetingList;
}
