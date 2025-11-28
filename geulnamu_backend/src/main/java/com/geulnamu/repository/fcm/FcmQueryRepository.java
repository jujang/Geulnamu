package com.geulnamu.repository.fcm;

import com.geulnamu.domain.fcm.FcmToken;
import com.geulnamu.domain.member.Member;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface FcmQueryRepository extends JpaRepository<FcmToken, Long> {
    Optional<FcmToken> findByToken(String token);
    Optional<FcmToken> findByMemberAndDeviceType(Member member, String deviceType);
    List<FcmToken> findByMemberIdIn(List<Long> memberIds);
    List<FcmToken> findByMemberIdInMemberPushEnabledTrue(List<Long> memberIds);
    Optional<FcmToken> findByMember(Member member);
}
