package com.geulnamu.controller.attendance.dto.response;

import com.geulnamu.controller.shared.dto.response.MemberIdAndNameResponse;
import lombok.AllArgsConstructor;
import lombok.Getter;

import java.util.List;

@Getter
@AllArgsConstructor
public class DiscussionGroupResponse {
    private List<MemberIdAndNameResponse> memberIdAndNameResponseList;
}
