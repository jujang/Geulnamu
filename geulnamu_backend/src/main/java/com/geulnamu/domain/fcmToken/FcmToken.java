package com.geulnamu.domain.fcmToken;

import com.geulnamu.domain.member.Member;
import com.geulnamu.domain.shared.DateColumn;
import jakarta.persistence.*;
import lombok.*;

@Getter
@Builder
@Entity(name = "fcm_Tokens")
@AllArgsConstructor
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class FcmToken extends DateColumn {

    @Id
    @Column(name = "fcm_token_id", updatable = false)
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "member_id")
    private Member member;

    @Column(name = "token", nullable = false)
    private String token;

    @Column(name = "device_type", nullable = false)
    private String deviceType;

    @Column(name = "is_active", columnDefinition = "TINYINT(1)", nullable = false)
    private boolean isActive;


    public void updateMember(Member member) {
        this.member = member;
    }

    public void updateIsActive(boolean isActive) {
        this.isActive = isActive;
    }
}
