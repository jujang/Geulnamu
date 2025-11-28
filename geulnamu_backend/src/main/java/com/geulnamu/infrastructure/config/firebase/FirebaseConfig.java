package com.geulnamu.infrastructure.config.firebase;

import com.google.auth.oauth2.GoogleCredentials;
import com.google.firebase.FirebaseApp;
import com.google.firebase.FirebaseOptions;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Configuration;

import javax.annotation.PostConstruct;
import org.springframework.core.io.Resource;
import java.io.InputStream;

@Slf4j
@Configuration
public class FirebaseConfig {

    @Value("${firebase.credentials.path}")
    private Resource firebaseCredentials;

    @PostConstruct
    public void initialize() {
        try (InputStream serviceAccount = firebaseCredentials.getInputStream()) {
            FirebaseOptions options = FirebaseOptions.builder()
                .setCredentials(GoogleCredentials.fromStream(serviceAccount))
                .build();

            if(FirebaseApp.getApps().isEmpty()) {
                FirebaseApp.initializeApp(options);
                log.info("Firebase Admin SDK 초기화 완료 ({})", firebaseCredentials.getDescription());
            }
        } catch (Exception e) {
            log.error("Firebase 초기화 실패: {}, {}",
                firebaseCredentials.getDescription(), e.getMessage());
        }
    }
}
