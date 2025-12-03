package com.geulnamu.domain.fcm;

import com.geulnamu.domain.member.Member;
import com.geulnamu.domain.shared.DateColumn;
import jakarta.persistence.*;
import lombok.*;

@Getter
@Builder
@Entity(name = "fcm_tokens")
@AllArgsConstructor
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class FcmToken extends DateColumn {

    @Id
    @Column(name = "fcm_token_id", updatable = false)
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "member_id", nullable = false)
    private Member member;

    @Column(name = "token", nullable = false)
    private String token;

    @Column(name = "device_type", nullable = false)
    private String deviceType;


    public void updateToken(String token) {
        this.token = token;
    }
}
