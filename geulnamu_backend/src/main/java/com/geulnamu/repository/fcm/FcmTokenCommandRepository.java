package com.geulnamu.repository.fcm;

import com.geulnamu.domain.fcmToken.FcmToken;
import org.springframework.data.jpa.repository.JpaRepository;

public interface FcmTokenCommandRepository extends JpaRepository<FcmToken, Long> {
}
