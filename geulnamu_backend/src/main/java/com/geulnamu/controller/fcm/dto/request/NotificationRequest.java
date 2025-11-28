package com.geulnamu.controller.fcm.dto.request;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotEmpty;
import lombok.Getter;

import java.util.List;

@Getter
public class NotificationRequest {

    @NotBlank(message = "제목 필수 입력")
    private String title;

    @NotBlank(message = "내용 필수 입력")
    private String body;

    @NotEmpty(message = "수신자 1명 이상 입력")
    private List<Long> memberList;

}
