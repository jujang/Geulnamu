package com.geulnamu.service.fcm;

import com.google.firebase.messaging.*;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Map;

@Slf4j
@Service
public class FcmPushService {

    // 단일 기기에 푸시 발송
    public void sendToToken(String token, String title, String body) {
        try {
            Message message = Message.builder()
                .setToken(token)
                .setNotification(Notification.builder()
                    .setTitle(title)
                    .setBody(body)
                    .build())
                .build();

            String response = FirebaseMessaging.getInstance().send(message);
            log.info("푸시 발송 성공: {}", response);
        } catch (Exception e) {
            log.error("푸시 발송 실패: {} ", e.getMessage());
        }
    }

    // 여러 기기에 푸시 발송
    public void sendToMultipleTokens(List<String> tokens, String title, String body) {
        try {
            MulticastMessage message = MulticastMessage.builder()
                .addAllTokens(tokens)
                .setNotification(Notification.builder()
                    .setTitle(title)
                    .setBody(body)
                    .build())
                .build();

            BatchResponse response = FirebaseMessaging.getInstance().sendMulticast(message);
            log.info("멀티 캐스트 푸시 발송: 성공{}, 실패{}",
                response.getSuccessCount(), response.getFailureCount());
        } catch (Exception e) {
            log.error("멀티캐스트 푸시 발송 실패: {}", e.getMessage());
        }
    }

    // 데이터 포함 푸시 발송 (클릭 시 특정 화면으로 이동)
    public void sendWithData(String token, String title, String body, Map<String, String> data) {
        try {
            Message message = Message.builder()
                .setToken(token)
                .setNotification(Notification.builder()
                    .setTitle(title)
                    .setBody(body)
                    .build())
                .putAllData(data)
                .build();

            FirebaseMessaging.getInstance().send(message);
        } catch (Exception e) {
            log.error("데이터 푸시 발송 실패: {}", e.getMessage());
        }
    }
}
