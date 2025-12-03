package com.geulnamu.infrastructure.firebase;

import com.google.firebase.messaging.*;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Map;

@Slf4j
@Service
public class FcmPushSender {

    // 단일 푸시 발송 (data가 null 이면 안 넣음)
    public FcmSendResult send(String token, String title, String body, Map<String, String> data) {
        try {
            Message.Builder builder = Message.builder()
                .setToken(token)
                .setNotification(Notification.builder()
                    .setTitle(title)
                    .setBody(body)
                    .build());

            if(data != null && !data.isEmpty()) {
                builder.putAllData(data);
            }

            String response = FirebaseMessaging.getInstance().send(builder.build());
            log.info("푸시 발송 성공: {}", response);
            return new FcmSendResult(1, 0);
        } catch (Exception e) {
            log.error("데이터 푸시 발송 실패: {}", e.getMessage());
            return new FcmSendResult(0, 1);
        }
    }

    // 다중 푸시 발송 (data가 null 이면 안 넣음)
    public FcmSendResult sendToMultiple(List<String> tokens, String title, String body, Map<String, String> data) {
        try {
            MulticastMessage.Builder builder = MulticastMessage.builder()
                .addAllTokens(tokens)
                .setNotification(Notification.builder()
                    .setTitle(title)
                    .setBody(body)
                    .build());

            if(data != null && !data.isEmpty()) {
                builder.putAllData(data);
            }

            BatchResponse response = FirebaseMessaging.getInstance().sendEachForMulticast(builder.build());
            log.info("멀티캐스트 데이터 푸시 발송: 성공{}, 실패{}",
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

            return new FcmSendResult(response.getSuccessCount(), response.getFailureCount());
        } catch (Exception e) {
            log.error("멀티캐스트 데이터 푸시 발송 실패: {}", e.getMessage());
            return new FcmSendResult(0, tokens.size());
        }
    }
}
