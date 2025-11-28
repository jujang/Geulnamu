package com.geulnamu.controller.fcm;

import com.geulnamu.controller.fcm.dto.request.FcmTokenRequest;
import com.geulnamu.controller.fcm.dto.request.NotificationRequest;
import com.geulnamu.domain.shared.enums.ActionType;
import com.geulnamu.domain.shared.enums.DomainType;
import com.geulnamu.domain.shared.enums.Level;
import com.geulnamu.infrastructure.annotation.AccessLevel;
import com.geulnamu.infrastructure.annotation.AuthMemberId;
import com.geulnamu.infrastructure.annotation.LogAction;
import com.geulnamu.infrastructure.response.BaseResponse;
import com.geulnamu.service.fcm.FcmService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;


@RestController
@RequiredArgsConstructor
@RequestMapping("/fcm")
public class FcmController {

    private final FcmService fcmService;

    @LogAction(value = ActionType.FCM_TOKEN_REGISTER, actionDomain = DomainType.FCM)
    @AccessLevel(Level.MEMBER)
    @PostMapping("/token")
    public BaseResponse<Void> registerToken(@AuthMemberId Long memberId,
                                            @Valid @RequestBody FcmTokenRequest request) {
        fcmService.registerToken(memberId, request.getToken(), request.getDeviceType());
        return BaseResponse.ofSuccess();
    }

    @LogAction(value = ActionType.FCM_NOTIFICATION, actionDomain = DomainType.FCM)
    @AccessLevel(Level.ADMIN)
    @PostMapping("/notification")
    public BaseResponse<Void> sendNotification(@Valid @RequestBody NotificationRequest request) {
        fcmService.sendNotification(request.getTitle(), request.getBody(), request.getMemberList());
        return BaseResponse.ofSuccess();
    }
}
