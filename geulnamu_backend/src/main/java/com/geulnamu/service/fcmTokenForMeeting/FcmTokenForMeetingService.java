package com.geulnamu.service.fcmTokenForMeeting;

import com.geulnamu.domain.attendance.Attendance;
import com.geulnamu.domain.fcmTokenForMeeting.FcmTokenForMeeting;
import com.geulnamu.domain.shared.enums.DomainType;
import com.geulnamu.infrastructure.exception.ExistDataException;
import com.geulnamu.infrastructure.exception.NotFoundDataException;
import com.geulnamu.infrastructure.firebase.FcmPushSender;
import com.geulnamu.repository.attendance.AttendanceQueryRepository;
import com.geulnamu.repository.fcmTokenForMeeting.FcmTokenForMeetingCommandRepository;
import com.geulnamu.repository.fcmTokenForMeeting.FcmTokenForMeetingQueryRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class FcmTokenForMeetingService {

    private final FcmTokenForMeetingCommandRepository fcmTokenForMeetingCommandRepository;
    private final FcmTokenForMeetingQueryRepository fcmTokenForMeetingQueryRepository;
    private final AttendanceQueryRepository attendanceQueryRepository;


    @Transactional(rollbackFor = Exception.class)
    public void registerToken(Long attendanceId, String requestedToken, String deviceType) {
        Attendance attendance = attendanceQueryRepository.findById(attendanceId)
                .orElseThrow(() -> new NotFoundDataException(DomainType.ATTENDANCE.getDescription()));
        fcmTokenForMeetingQueryRepository.findByAttendanceAndDeviceType(attendance, deviceType)
            .ifPresentOrElse(
                token -> {
                    throw new ExistDataException(DomainType.FCM_TFM.getDescription());
                },
                () -> {
                    FcmTokenForMeeting newToken = FcmTokenForMeeting.builder()
                        .attendance(attendance)
                        .token(requestedToken)
                        .deviceType(deviceType)
                        .build();
                    fcmTokenForMeetingCommandRepository.save(newToken);
                }
            );
    }

    @Transactional(rollbackFor = Exception.class)
    public void unregisterToken(Long attendanceId) {
        Attendance attendance = attendanceQueryRepository.findById(attendanceId)
            .orElseThrow(() -> new NotFoundDataException(DomainType.ATTENDANCE.getDescription()));
        FcmTokenForMeeting token = fcmTokenForMeetingQueryRepository.findByAttendance(attendance)
            .orElseThrow(() -> new NotFoundDataException(DomainType.FCM_TFM.getDescription()));
        fcmTokenForMeetingCommandRepository.delete(token);
    }

}
