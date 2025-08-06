package com.geulnamu.controller.attendance.dto.request;

import jakarta.validation.Valid;
import lombok.AllArgsConstructor;
import lombok.Getter;

import java.util.List;

@Getter
@AllArgsConstructor
public class AssignDiscussionGroupsRequest {

    List<@Valid DiscussionGroupRequest> groups;

}
