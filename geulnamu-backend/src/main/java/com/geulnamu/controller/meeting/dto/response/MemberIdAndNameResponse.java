package com.geulnamu.controller.meeting.dto.response;

import lombok.AllArgsConstructor;
import lombok.Getter;

@Getter
@AllArgsConstructor
public class MemberIdAndNameResponse {
    private Long memberId;
    private String memberName;
}
