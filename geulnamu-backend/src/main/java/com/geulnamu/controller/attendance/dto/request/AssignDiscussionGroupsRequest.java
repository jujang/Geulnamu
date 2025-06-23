package com.geulnamu.controller.attendance.dto.request;

import jakarta.validation.Valid;
import jakarta.validation.constraints.NotEmpty;
import lombok.AllArgsConstructor;
import lombok.Getter;

import java.util.List;

@Getter
@AllArgsConstructor
public class AssignDiscussionGroupsRequest {

    @NotEmpty(message = "토론 그룹 정보는 필수입니다.")
    List<@Valid DiscussionGroupRequest> groups;

}
