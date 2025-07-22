package com.geulnamu.repository.meeting;

import com.geulnamu.controller.meeting.dto.request.MeetingListRequest;
import com.geulnamu.controller.meeting.dto.response.MeetingDetailResponse;
import com.geulnamu.controller.meeting.dto.response.MeetingInfoResponse;
import com.geulnamu.controller.shared.dto.response.MemberIdAndNameResponse;
import org.springframework.data.domain.Page;

import java.util.List;

public interface MeetingQueryRepositoryCustom {
    List<MemberIdAndNameResponse> findStaffList();
    Page<MeetingInfoResponse> findMeetingsWithPagingNew(MeetingListRequest request, Long myMemberId);
    MeetingDetailResponse findMeeting(Long meetingId, Long memberId);
}
