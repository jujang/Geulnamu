package com.geulnamu.domain.fcmTokenForMeeting;

import com.geulnamu.domain.attendance.Attendance;
import com.geulnamu.domain.shared.DateColumn;
import jakarta.persistence.*;
import lombok.*;

@Getter
@Builder
@Entity(name = "fcm_tokens_for_meetings")
@AllArgsConstructor
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class FcmTokenForMeeting extends DateColumn {

    @Id
    @Column(name = "fcm_token_id")
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "attendance_id", nullable = false)
    private Attendance attendance;

    @Column(name = "token", nullable = false)
    private String token;

    @Column(name = "device_type", nullable = false)
    private String deviceType;


    public void updateToken(String token) {
        this.token = token;
    }

}
