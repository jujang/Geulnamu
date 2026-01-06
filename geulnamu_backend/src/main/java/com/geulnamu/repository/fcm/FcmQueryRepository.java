package com.geulnamu.repository.fcm;

import com.geulnamu.domain.fcm.FcmToken;
import com.geulnamu.domain.member.Member;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;
import java.util.Optional;

public interface FcmQueryRepository extends JpaRepository<FcmToken, Long> {
    Optional<FcmToken> findByMemberAndDeviceType(Member member, String deviceType);

    @Query(value = "SELECT ft.token " +
        "FROM fcm_tokens ft " +
        "JOIN ft.member m " +
        "WHERE m.id IN :memberIds " +
        "AND m.pushEnabled = true")
    List<String> findEnabledTokensByMemberIds(@Param("memberIds") List<Long> memberIds);
}
