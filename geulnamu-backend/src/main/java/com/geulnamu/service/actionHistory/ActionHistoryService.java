package com.geulnamu.service.actionHistory;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.geulnamu.domain.actionHistory.ActionHistory;
import com.geulnamu.infrastructure.aspect.dto.ActionLogContext;
import com.geulnamu.repository.actionHistory.ActionHistoryCommandRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/**
 * 액션 히스토리 저장 서비스
 * 비즈니스 로직과 분리하여 로깅 전용으로 사용
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class ActionHistoryService {

    private final ObjectMapper objectMapper;
    private final ActionHistoryCommandRepository actionHistoryRepository;

    /**
     * 액션 히스토리 저장 (비동기 처리)
     * ActionLogContext를 받아서 저장
     */
    @Async("actionHistoryExecutor")
    @Transactional
    public void saveActionHistory(ActionLogContext context) {
        try {
            ActionHistory actionHistory = ActionHistory.builder()
                .actionType(context.getActionType())
                .status(context.getStatus())
                .actorMemberId(context.getActorMemberId())
                .actionDomain(context.getActionDomain())
                .targetId(context.getTargetId())
                .requestData(convertToJson(context.getRequestData()))
                .responseData(convertToJson(context.getResponseData()))
                .requestMethod(context.getRequestMethod())
                .requestUri(context.getRequestUri())
                .processingTimeMs(context.getProcessingTimeMs())
                .ipAddress(context.getIpAddress())
                .userAgent(context.getUserAgent())
                .build();

            actionHistoryRepository.save(actionHistory);

            log.debug("액션 히스토리 저장 완료: actionType={}, status={}, memberId={}",
                context.getActionType(), context.getStatus(), context.getActorMemberId());
        } catch (Exception e) {
            // 로깅 실패가 원본 로직에 영향을 주지 않도록 예외를 잡아서 로그만 남김
            log.error("액션 히스토리 저장 실패: actionType={}, status={}, memberId={}",
                context.getActionType(), context.getStatus(), context.getActorMemberId(), e);
        }
    }

    /**
     * 객체를 JSON 문자열로 변환
     * 민감한 정보는 마스킹 처리
     */
    private String convertToJson(Object data) {
        if (data == null) {
            return null;
        }
        
        try {
            String json = objectMapper.writeValueAsString(data);
            return maskSensitiveData(json);
        } catch (JsonProcessingException e) {
            log.warn("JSON 변환 실패: {}", e.getMessage());
            return data.toString();
        }
    }

    /**
     * 민감한 정보 마스킹 처리
     */
    private static String maskSensitiveData(String json) {
        if (json == null) {
            return null;
        }
        
        // 비밀번호, 토큰 등 민감한 정보 마스킹
        return json
                .replaceAll("(\"password\"\\s*:\\s*\")[^\"]*\"", "$1****\"")
                .replaceAll("(\"token\"\\s*:\\s*\")[^\"]*\"", "$1****\"")
                .replaceAll("(\"refreshToken\"\\s*:\\s*\")[^\"]*\"", "$1****\"")
                .replaceAll("(\"accessToken\"\\s*:\\s*\")[^\"]*\"", "$1****\"");
    }
}
