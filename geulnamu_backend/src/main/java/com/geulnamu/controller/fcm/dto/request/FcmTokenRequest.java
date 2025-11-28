package com.geulnamu.controller.fcm.dto.request;

import lombok.Getter;

@Getter
public class FcmTokenRequest {
    private String token;
    private String deviceType;
}
