package com.geulnamu.controller.attendance.dto;

import com.geulnamu.domain.attendance.DiscussionGroup;
import lombok.AllArgsConstructor;
import lombok.Getter;

@Getter
@AllArgsConstructor
public class MemberInfoWithGroup {
    private Long memberId;
    private String memberName;
    private DiscussionGroup discussionGroup;
}
