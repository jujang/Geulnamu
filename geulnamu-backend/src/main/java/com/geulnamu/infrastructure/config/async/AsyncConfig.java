package com.geulnamu.infrastructure.config.async;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.scheduling.concurrent.ThreadPoolTaskExecutor;

import java.util.concurrent.Executor;

/**
 * 비동기 처리 설정
 * 액션 히스토리 로깅을 위한 별도 스레드 풀 구성
 */
@Configuration
public class AsyncConfig {

    /**
     * 액션 히스토리 로깅 전용 스레드 풀
     */
    @Bean(name = "actionHistoryExecutor")
    public Executor actionHistoryExecutor() {
        ThreadPoolTaskExecutor executor = new ThreadPoolTaskExecutor();
        
        // 코어 스레드 수 (기본적으로 유지할 스레드 수)
        executor.setCorePoolSize(2);
        
        // 최대 스레드 수
        executor.setMaxPoolSize(5);
        
        // 큐 용량 (대기 작업 수)
        executor.setQueueCapacity(100);
        
        // 스레드 이름 접두사
        executor.setThreadNamePrefix("ActionHistory-");
        
        // 스레드 유지 시간 (초)
        executor.setKeepAliveSeconds(60);
        
        // 스레드 풀 종료 시 대기 여부
        executor.setWaitForTasksToCompleteOnShutdown(true);
        
        // 종료 대기 시간 (초)
        executor.setAwaitTerminationSeconds(20);
        
        executor.initialize();
        return executor;
    }
}
