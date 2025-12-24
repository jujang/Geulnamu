package com.geulnamu.infrastructure.aspect;

import com.geulnamu.domain.actionHistory.ApiMethod;
import com.geulnamu.domain.shared.enums.ActionStatus;
import com.geulnamu.domain.shared.enums.ActionType;
import com.geulnamu.domain.shared.enums.DomainType;
import com.geulnamu.infrastructure.annotation.ErrorLogAction;
import com.geulnamu.infrastructure.annotation.LogAction;
import com.geulnamu.infrastructure.aspect.dto.ActionLogContext;
import com.geulnamu.infrastructure.exception.GlobalExceptionHandler;
import com.geulnamu.infrastructure.exception.ServerException;
import com.geulnamu.infrastructure.response.BaseResponse;
import com.geulnamu.service.actionHistory.ActionHistoryLoggingService;
import jakarta.servlet.http.HttpServletRequest;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.aspectj.lang.JoinPoint;
import org.aspectj.lang.annotation.AfterReturning;
import org.aspectj.lang.annotation.AfterThrowing;
import org.aspectj.lang.annotation.Around;
import org.aspectj.lang.annotation.Aspect;
import org.aspectj.lang.ProceedingJoinPoint;
import org.springframework.stereotype.Component;
import org.springframework.web.context.request.RequestContextHolder;
import org.springframework.web.context.request.ServletRequestAttributes;

import java.lang.reflect.Parameter;

/**
 * 액션 히스토리 로깅 AOP
 * @LogAction 어노테이션이 있는 메서드의 성공/실패를 자동으로 로깅
 */
@Slf4j
@Aspect
@Component
@RequiredArgsConstructor
public class ActionHistoryAspect {

    private final ActionHistoryLoggingService actionHistoryLoggingService;
    private final GlobalExceptionHandler globalExceptionHandler;
    
    // ThreadLocal로 처리 시간 측정을 위한 시작 시간 저장
    private final ThreadLocal<Long> startTimeHolder = new ThreadLocal<>();
    
    /**
     * 메서드 실행 시간을 측정하기 위한 Around 어드바이스
     */
    @Around("@annotation(logAction)")
    public Object measureExecutionTime(ProceedingJoinPoint joinPoint, LogAction logAction) throws Throwable {
        startTimeHolder.set(System.currentTimeMillis());
        return joinPoint.proceed();
    }


    /**
     * 성공 케이스 로깅
     */
    @AfterReturning(value = "@annotation(logAction)", returning = "result")
    public void logSuccess(JoinPoint joinPoint, LogAction logAction, Object result) {
        try {
            ActionLogContext context = buildLogContext(joinPoint, logAction, ActionStatus.SUCCESS, result, null);
            saveActionHistory(context);
        } catch (Exception e) {
            log.error("액션 히스토리 성공 케이스 로깅 실패", e);
        } finally {
            startTimeHolder.remove();
        }
    }

    /**
     * 실패 케이스 로깅
     */
    @AfterThrowing(value = "@annotation(logAction)", throwing = "exception")
    public void logFailure(JoinPoint joinPoint, LogAction logAction, Exception exception) {
        try {
            // 예외 타입에 따른 응답 생성
            BaseResponse<?> errorResponse = createErrorResponse(exception);
            
            ActionLogContext context = buildLogContext(joinPoint, logAction, ActionStatus.FAILURE, errorResponse, exception);
            saveActionHistory(context);
        } catch (Exception e) {
            log.error("액션 히스토리 실패 케이스 로깅 실패", e);
        } finally {
            startTimeHolder.remove();
        }
    }

    @AfterThrowing(value = "@annotation(errorLogAction)", throwing = "exception")
    public void onlyLogFailure(JoinPoint joinPoint, ErrorLogAction errorLogAction, Exception exception) {
        try {
            BaseResponse<?> errorResponse = createErrorResponse(exception);

            ActionLogContext context = buildLogContext(joinPoint, errorLogAction, ActionStatus.FAILURE, errorResponse, exception);
            saveActionHistory(context);
        } catch (Exception e) {
            log.error("액션 히스토리 단독 실패 케이스 로깅 실패", e);
        } finally {
            startTimeHolder.remove();
        }
    }

    /**
     * 로그 컨텍스트 생성
     */
    private ActionLogContext buildLogContext(JoinPoint joinPoint, Object annotation,
                                           ActionStatus status, Object responseData, Exception exception) {
        
        HttpServletRequest request = getCurrentRequest();
        Long processingTime = calculateProcessingTime();

        ActionType actionType;
        DomainType actionDomain;

        if(annotation instanceof LogAction) {
            LogAction logAction = (LogAction) annotation;
            actionType = logAction.value();
            actionDomain = logAction.actionDomain() == null ? null : logAction.actionDomain();
        } else if (annotation instanceof ErrorLogAction) {
            ErrorLogAction errorLogAction = (ErrorLogAction) annotation;
            actionType = errorLogAction.value();
            actionDomain = errorLogAction.actionDomain() == null ? null : errorLogAction.actionDomain();;
            processingTime = null;
        } else {
            throw new IllegalArgumentException("지원하지 않는 어노테이션 타입: " + annotation.getClass());
        }

        return ActionLogContext.builder()
                .actorMemberId(extractMemberIdFromRequest(request, joinPoint))
                .actionType(actionType)
                .status(status)
                .actionDomain(actionDomain)
                .targetId(extractTargetId(joinPoint))
                .requestData(extractRequestData(joinPoint))
                .responseData(responseData)
                .requestMethod(ApiMethod.valueOf(request.getMethod()))
                .requestUri(buildFullRequestUri(request))
                .processingTimeMs(processingTime)
                .ipAddress(getClientIpAddress(request))
                .userAgent(request.getHeader("User-Agent"))
                .build();
    }

    /**
     * ActionHistory 저장
     */
    private void saveActionHistory(ActionLogContext context) {
        actionHistoryLoggingService.saveActionHistory(context);
    }

    /**
     * 현재 HTTP 요청 가져오기
     */
    private HttpServletRequest getCurrentRequest() {
        ServletRequestAttributes attributes = (ServletRequestAttributes) RequestContextHolder.currentRequestAttributes();
        return attributes.getRequest();
    }

    /**
     * 처리 시간 계산
     */
    private Long calculateProcessingTime() {
        Long startTime = startTimeHolder.get();
        if (startTime == null) {
            return null;
        }
        return System.currentTimeMillis() - startTime;
    }

    /**
     * 메서드 시그니처 정보 추출 (공통 로직)
     */
    private static class MethodInfo {
        final Object[] args;
        final Parameter[] parameters;
        
        MethodInfo(JoinPoint joinPoint) {
            this.args = joinPoint.getArgs();
            this.parameters = ((org.aspectj.lang.reflect.MethodSignature) joinPoint.getSignature())
                    .getMethod().getParameters();
        }
    }

    /**
     * 요청을 수행한 멤버 ID 추출
     * @AuthMemberId 어노테이션이 있는 파라미터에서 추출
     */
    private Long extractMemberIdFromRequest(HttpServletRequest request, JoinPoint joinPoint) {
        try {
            MethodInfo methodInfo = new MethodInfo(joinPoint);
            
            for (int i = 0; i < methodInfo.parameters.length; i++) {
                if (methodInfo.parameters[i].isAnnotationPresent(com.geulnamu.infrastructure.annotation.AuthMemberId.class)) {
                    return (Long) methodInfo.args[i];
                }
            }
            
            return null;
        } catch (Exception e) {
            log.warn("모임원 ID 추출 실패", e);
            return null;
        }
    }

    /**
     * 대상 엔티티 ID 추출
     * PathVariable 중에서 ID로 추정되는 값 추출
     */
    private Long extractTargetId(JoinPoint joinPoint) {
        try {
            MethodInfo methodInfo = new MethodInfo(joinPoint);
            
            for (int i = 0; i < methodInfo.parameters.length; i++) {
                if (methodInfo.parameters[i].isAnnotationPresent(org.springframework.web.bind.annotation.PathVariable.class)) {
                    String paramName = methodInfo.parameters[i].getName().toLowerCase();
                    if (paramName.endsWith("id") && methodInfo.args[i] instanceof Long) {
                        return (Long) methodInfo.args[i];
                    }
                }
            }
            return null;
        } catch (Exception e) {
            log.warn("타겟 ID 추출 실패", e);
            return null;
        }
    }

    /**
     * 요청 데이터 추출
     * @RequestBody 파라미터만 추출 (RequestParam은 request_uri에 포함)
     */
    private Object extractRequestData(JoinPoint joinPoint) {
        try {
            MethodInfo methodInfo = new MethodInfo(joinPoint);
            
            for (int i = 0; i < methodInfo.parameters.length; i++) {
                if (methodInfo.parameters[i].isAnnotationPresent(org.springframework.web.bind.annotation.RequestBody.class)) {
                    return methodInfo.args[i];
                }
            }
            
            return null;
        } catch (Exception e) {
            log.warn("요청 데이터 추출 실패", e);
            return null;
        }
    }

    /**
     * 쿼리 파라미터를 포함한 전체 요청 URI 구성
     */
    private String buildFullRequestUri(HttpServletRequest request) {
        String uri = request.getRequestURI();
        String queryString = request.getQueryString();
        
        if (queryString != null && !queryString.trim().isEmpty()) {
            return uri + "?" + queryString;
        }
        
        return uri;
    }
    
    /**
     * 예외를 BaseResponse 형태로 변환
     */
    private BaseResponse<?> createErrorResponse(Exception exception) {
        if (exception instanceof ServerException) {
            ServerException serverException = (ServerException) exception;
            return BaseResponse.ofFail(serverException.getCode(), serverException.getMessage(), serverException.getField());
        }
        return BaseResponse.ofFail(500, exception.getMessage(), null);
    }

    /**
     * 클라이언트 IP 주소 추출
     */
    private String getClientIpAddress(HttpServletRequest request) {
        // Proxy 환경에서 실제 클라이언트 IP 확인
        String[] headers = {"X-Forwarded-For", "X-Real-IP"};
        
        for (String header : headers) {
            String ip = request.getHeader(header);
            if (ip != null && !ip.isEmpty() && !"unknown".equalsIgnoreCase(ip)) {
                // 여러 IP가 있으면 첫 번째가 실제 클라이언트 IP
                return ip.contains(",") ? ip.split(",")[0].trim() : ip;
            }
        }

        return request.getRemoteAddr();
    }
}
