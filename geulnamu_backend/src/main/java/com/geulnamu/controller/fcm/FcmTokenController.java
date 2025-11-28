package com.geulnamu.controller.fcm;

import com.geulnamu.controller.fcm.dto.request.FcmTokenRequest;
import com.geulnamu.infrastructure.annotation.AuthMemberId;
import com.geulnamu.infrastructure.response.BaseResponse;
import com.geulnamu.service.fcm.FcmTokenService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;


@RestController
@RequiredArgsConstructor
@RequestMapping("/fcm-token")
public class FcmTokenController {

    private final FcmTokenService fcmTokenService;

    @PostMapping
    public BaseResponse<Void> registerToken(@AuthMemberId Long memberId,
                                            @Valid @RequestBody FcmTokenRequest request) {
        fcmTokenService.registerToken(memberId, request.getToken(), request.getDeviceType());
        return BaseResponse.ofSuccess();
    }

    @DeleteMapping
    public BaseResponse<Void> deleteToken(@RequestBody FcmTokenRequest request) {
        fcmTokenService.deleteToken(request.getToken());
        return BaseResponse.ofSuccess();
    }
}
