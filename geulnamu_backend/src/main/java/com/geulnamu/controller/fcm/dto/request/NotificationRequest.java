package com.geulnamu.controller.fcm.dto.request;

import jakarta.validation.constraints.NotBlank;
import lombok.Getter;

import java.util.List;

@Getter
public class NotificationRequest {

    @NotBlank(message = "제목 필수 입력")
    private String title;

    @NotBlank(message = "내용 필수 입력")
    private String body;

    @NotBlank(message = "받는이 필수 입력")
    private List<Long> memberList;

}
