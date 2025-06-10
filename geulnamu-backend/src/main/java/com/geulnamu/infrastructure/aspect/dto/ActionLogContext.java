package com.geulnamu.infrastructure.aspect.dto;

import com.geulnamu.domain.shared.enums.ActionStatus;
import com.geulnamu.domain.shared.enums.ActionType;
import lombok.Builder;
import lombok.Getter;

/**
 * 액션 로그 컨텍스트 DTO
 * AOP에서 로그 정보를 전달하기 위한 DTO
 */
@Getter
@Builder
public class ActionLogContext {
    
    private Long actorMemberId;           // 요청을 수행한 모임원 ID
    private ActionType actionType;        // 액션 타입
    private ActionStatus status;          // 처리 결과 (성공/실패)
    private String actionDomain;          // 액션 도메인
    private Long targetId;                // 대상 엔티티 ID
    private Object requestData;           // 요청 데이터
    private Object responseData;          // 응답 데이터 (성공 시) 또는 에러 메시지 (실패 시)
    private String requestMethod;         // HTTP 메서드
    private String requestUri;            // 요청 URI
    private Long processingTimeMs;        // 처리 시간 (밀리초)
    private String ipAddress;             // 클라이언트 IP 주소
    private String userAgent;             // User-Agent 헤더
    
}
