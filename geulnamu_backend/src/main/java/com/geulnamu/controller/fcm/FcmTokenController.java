package com.geulnamu.controller.fcm;

import com.geulnamu.controller.fcm.dto.request.FcmTokenRequest;
import com.geulnamu.domain.shared.enums.ActionType;
import com.geulnamu.domain.shared.enums.DomainType;
import com.geulnamu.domain.shared.enums.Level;
import com.geulnamu.infrastructure.annotation.AccessLevel;
import com.geulnamu.infrastructure.annotation.AuthMemberId;
import com.geulnamu.infrastructure.annotation.ErrorLogAction;
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

    @ErrorLogAction(value = ActionType.FCM_TOKEN_REGISTER, actionDomain = DomainType.FCM_TOKEN)
    @AccessLevel(Level.ADMIN)
    @PostMapping
    public BaseResponse<Void> registerToken(@AuthMemberId Long memberId,
                                            @Valid @RequestBody FcmTokenRequest request) {
        fcmTokenService.registerToken(memberId, request.getToken(), request.getDeviceType());
        return BaseResponse.ofSuccess();
    }

    @ErrorLogAction(value = ActionType.FCM_TOKEN_DELETE, actionDomain = DomainType.FCM_TOKEN)
    @AccessLevel(Level.ADMIN)
    @DeleteMapping
    public BaseResponse<Void> deleteToken(@RequestBody FcmTokenRequest request) {
        fcmTokenService.deleteToken(request.getToken());
        return BaseResponse.ofSuccess();
    }
}
