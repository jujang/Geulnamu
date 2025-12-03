package com.geulnamu.infrastructure.firebase;

import com.google.firebase.messaging.*;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Map;

@Slf4j
@Service
public class FcmPushSender {

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

            BatchResponse response = FirebaseMessaging.getInstance().sendEachForMulticast(message);
            log.info("멀티 캐스트 푸시 발송: 성공{}, 실패{}",
                response.getSuccessCount(), response.getFailureCount());

            if (response.getFailureCount() > 0) {
                List<SendResponse> responses = response.getResponses();
                for(int i = 0; i < responses.size(); i++) {
                    if(!responses.get(i).isSuccessful()) {
                        log.warn("토큰 {} 발송 실패: {}", tokens.get(i),
                            responses.get(i).getException().getMessage());
                    }
                }
            }
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

            String response = FirebaseMessaging.getInstance().send(message);
            log.info("푸시 발송 성공: {}", response);
        } catch (Exception e) {
            log.error("데이터 푸시 발송 실패: {}", e.getMessage());
        }
    }

    // (여러기기에) 데이터 포함 푸시 발송 (클릭 시 특정 화면으로 이동)
    public void sendWithDataToMultiple(List<String> tokens, String title, String body, Map<String, String> data) {
        try {
            MulticastMessage message = MulticastMessage.builder()
                .addAllTokens(tokens)
                .setNotification(Notification.builder()
                    .setTitle(title)
                    .setBody(body)
                    .build())
                .putAllData(data)
                .build();

            BatchResponse response = FirebaseMessaging.getInstance().sendEachForMulticast(message);
            log.info("멀티캐스트 데이터 푸시 발송: 성공{}, 싪패{}",
                response.getSuccessCount(), response.getFailureCount());

            // 실패한 토큰 로깅
            if(response.getFailureCount() > 0) {
                List<SendResponse> responses = response.getResponses();
                for(int i = 0; i < responses.size(); i++) {
                    if(!responses.get(i).isSuccessful()) {
                        log.warn("토큰 {} 발송 실패: {}", tokens.get(i),
                            responses.get(i).getException().getMessage());
                    }
                }
            }
        } catch (Exception e) {
            log.error("멀티캐스트 데이터 푸시 발송 실패: {}", e.getMessage());
        }
    }
}
