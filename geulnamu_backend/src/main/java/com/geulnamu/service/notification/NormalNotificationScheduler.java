package com.geulnamu.service.notification;

import com.geulnamu.domain.fcm.FcmToken;
import com.geulnamu.domain.member.Member;
import com.geulnamu.domain.shared.enums.DomainType;
import com.geulnamu.infrastructure.exception.NotFoundDataException;
import com.geulnamu.repository.fcm.FcmQueryRepository;
import com.geulnamu.repository.member.MemberQueryRepository;
import com.geulnamu.service.fcm.FcmPushService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

import java.time.LocalDateTime;

@Slf4j
@Component
@RequiredArgsConstructor
public class NormalNotificationScheduler {

    private final MemberQueryRepository memberQueryRepository;
    private final FcmQueryRepository fcmQueryRepository;
    private final FcmPushService fcmPushService;

    @Scheduled(cron = "0 * * 28 11 *") // 초 분 시 일 월 요일
    public void NormalNotification() {
        LocalDateTime now = LocalDateTime.now();

        Member member = memberQueryRepository.findById(10L)
            .orElseThrow(() -> new NotFoundDataException(DomainType.MEMBER.getDescription()));

        FcmToken token = fcmQueryRepository.findByMember(member)
            .orElseThrow(() -> new NotFoundDataException(DomainType.MEMBER.getDescription()));

        String title = "타이틀입니다~";
        String body = "바디입니다~";

        fcmPushService.sendToToken(token.getToken(), title, body);

        log.info("토론 알림 발송 완료: {} ", title);
    }

}
