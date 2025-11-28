package com.geulnamu.repository.fcm;

import com.geulnamu.domain.fcm.FcmToken;
import org.springframework.data.jpa.repository.JpaRepository;

public interface FcmCommandRepository extends JpaRepository<FcmToken, Long> {
}
