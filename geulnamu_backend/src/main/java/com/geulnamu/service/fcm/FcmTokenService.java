package com.geulnamu.service.fcm;

import com.geulnamu.domain.fcmToken.FcmToken;
import com.geulnamu.domain.member.Member;
import com.geulnamu.domain.shared.enums.DomainType;
import com.geulnamu.infrastructure.exception.NotFoundDataException;
import com.geulnamu.repository.fcm.FcmTokenCommandRepository;
import com.geulnamu.repository.fcm.FcmTokenQueryRepository;
import com.geulnamu.repository.member.MemberQueryRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class FcmTokenService {

    private final FcmTokenCommandRepository fcmTokenCommandRepository;
    private final FcmTokenQueryRepository fcmTokenQueryRepository;
    private final MemberQueryRepository memberQueryRepository;

    @Transactional(rollbackFor = Exception.class)
    public void registerToken(Long memberId, String requestedToken, String deviceType) {
        Member member = memberQueryRepository.findById(memberId)
            .orElseThrow(() -> new NotFoundDataException(DomainType.MEMBER.getDescription()));
        fcmTokenQueryRepository.findByToken(requestedToken)
            .ifPresentOrElse(
                token -> {
                    token.updateMember(member);
                    token.updateIsActive(true);
                },
                () -> {
                    FcmToken newToken = FcmToken.builder()
                        .member(member)
                        .token(requestedToken)
                        .deviceType(deviceType)
                        .isActive(true)
                        .build();
                    fcmTokenCommandRepository.save(newToken);
                }
            );
    }

    @Transactional
    public void deleteToken(String token) {
        fcmTokenQueryRepository.findByToken(token)
            .ifPresent(fcmToken -> fcmToken.updateIsActive(false));
    }

}
