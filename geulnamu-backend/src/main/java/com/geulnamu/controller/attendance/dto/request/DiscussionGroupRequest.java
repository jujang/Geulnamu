package com.geulnamu.controller.attendance.dto.request;

import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotEmpty;
import lombok.AllArgsConstructor;
import lombok.Getter;

import java.util.List;

@Getter
@AllArgsConstructor
public class DiscussionGroupRequest {
    @NotEmpty(message = "토론 그룹에는 1명 이상이 반드시 들어가야 합니다.")
    private List<@Min(1) Long> memberIdList;
}
