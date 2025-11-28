package com.geulnamu.service.fcm;

import com.geulnamu.domain.fcm.FcmToken;
import com.geulnamu.domain.member.Member;
import com.geulnamu.domain.shared.enums.DomainType;
import com.geulnamu.infrastructure.exception.NotFoundDataException;
import com.geulnamu.repository.fcm.FcmCommandRepository;
import com.geulnamu.repository.fcm.FcmQueryRepository;
import com.geulnamu.repository.member.MemberQueryRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
public class FcmService {

    private final FcmCommandRepository fcmCommandRepository;
    private final FcmQueryRepository fcmQueryRepository;
    private final MemberQueryRepository memberQueryRepository;
    private final FcmPushService fcmPushService;


    @Transactional(rollbackFor = Exception.class)
    public void registerToken(Long memberId, String requestedToken, String deviceType) {
        Member member = memberQueryRepository.findById(memberId)
            .orElseThrow(() -> new NotFoundDataException(DomainType.MEMBER.getDescription()));
        fcmQueryRepository.findByMemberAndDeviceType(member, deviceType)
            .ifPresentOrElse(
                token -> {
                    token.updateToken(requestedToken);
                },
                () -> {
                    FcmToken newToken = FcmToken.builder()
                        .member(member)
                        .token(requestedToken)
                        .deviceType(deviceType)
                        .build();
                    fcmCommandRepository.save(newToken);
                }
            );
    }

    @Transactional(rollbackFor = Exception.class)
    public void sendNotification(String title, String body, List<Long> memberId) {
        List<String> tokens = fcmQueryRepository.findByMemberIdIn(memberId)
            .stream()
            .filter(token -> token.getMember().isPushEnabled())
            .map(FcmToken::getToken)
            .toList();
        fcmPushService.sendToMultipleTokens(tokens, title, body);
    }

}
