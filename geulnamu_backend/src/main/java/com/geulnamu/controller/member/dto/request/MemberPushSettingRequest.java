package com.geulnamu.controller.member.dto.request;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import lombok.AllArgsConstructor;
import lombok.Getter;

@Getter
@AllArgsConstructor
public class MemberPushSettingRequest {

    @NotBlank(message = "푸시 알림 수신 여부 필수 입력")
    @Pattern(regexp = "true|false", message = "푸시 알림 수신 여부는 'true' 또는 'false' 만 가능합니다.")
    private boolean pushEnabled;

}
