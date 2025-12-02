package com.geulnamu.controller.fcmTokenForMeeting;

import com.geulnamu.controller.fcm.dto.request.FcmTokenRequest;
import com.geulnamu.domain.shared.enums.ActionType;
import com.geulnamu.domain.shared.enums.DomainType;
import com.geulnamu.domain.shared.enums.Level;
import com.geulnamu.infrastructure.annotation.AccessLevel;
import com.geulnamu.infrastructure.annotation.LogAction;
import com.geulnamu.infrastructure.response.BaseResponse;
import com.geulnamu.service.fcmTokenForMeeting.FcmTokenForMeetingService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

@RestController
@RequiredArgsConstructor
@RequestMapping("/fcm/meeting")
public class FcmTokenForMeetingController {

    private final FcmTokenForMeetingService fcmTokenForMeetingService;


    // 토큰 등록 (출석 하면서 같이 보낼 API)
    @LogAction(value = ActionType.FCM_TOKEN_FOR_MEETING_REGISTER, actionDomain = DomainType.FCM_TFM)
    @AccessLevel(Level.MEMBER)
    @PostMapping("/token")
    public BaseResponse<Void> registerToken(Long attendanceId, @Valid @RequestBody FcmTokenRequest request) {
        fcmTokenForMeetingService.registerToken(attendanceId, request.getToken(), request.getDeviceType());
        return BaseResponse.ofSuccess();
    }

    // 토큰 삭제 (관리자가 출석 삭제 시, 같이 보낼 API)
    @LogAction(value = ActionType.FCM_TOKEN_FOR_MEETING_UNREGISTER, actionDomain = DomainType.FCM_TFM)
    @AccessLevel(Level.ADMIN)
    @DeleteMapping("/token")
    public BaseResponse<Void> unregisterToken(Long attendanceId) {
        fcmTokenForMeetingService.unregisterToken(attendanceId);
        return BaseResponse.ofSuccess();
    }

}
