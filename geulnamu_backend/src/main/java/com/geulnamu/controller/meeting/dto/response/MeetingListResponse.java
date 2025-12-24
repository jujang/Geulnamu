package com.geulnamu.controller.meeting.dto.response;

import com.geulnamu.infrastructure.response.paging.PagingResponse;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.util.List;

@Getter
@NoArgsConstructor  // Redis 역직렬화용 기본 생성자
@AllArgsConstructor
public class MeetingListResponse {
    private PagingResponse pagingResponse;
    private List<MeetingInfoResponse> meetingList;
}
