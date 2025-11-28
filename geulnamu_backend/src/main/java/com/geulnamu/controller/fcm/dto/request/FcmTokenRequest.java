package com.geulnamu.controller.fcm.dto.request;

import jakarta.validation.constraints.NotBlank;
import lombok.Getter;

@Getter
public class FcmTokenRequest {

    @NotBlank(message = "토큰 필수 입력")
    private String token;

    @NotBlank(message = "기기 종류 필수 입력")
    private String deviceType;
}
