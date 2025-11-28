package com.geulnamu.repository.fcm;

import com.geulnamu.domain.fcmToken.FcmToken;
import com.geulnamu.domain.member.Member;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface FcmTokenQueryRepository extends JpaRepository<FcmToken, Long> {
    Optional<FcmToken> findByToken(String token);
    Optional<FcmToken> findByMember(Member member);
}
