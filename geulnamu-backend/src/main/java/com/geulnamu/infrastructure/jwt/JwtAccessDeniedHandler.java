package com.geulnamu.infrastructure.jwt;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.geulnamu.infrastructure.response.BaseResponse;
import com.geulnamu.infrastructure.response.ResponseMessage;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.MediaType;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.security.web.access.AccessDeniedHandler;
import org.springframework.stereotype.Component;

import java.io.IOException;

@Slf4j
@Component
@RequiredArgsConstructor
public class JwtAccessDeniedHandler implements AccessDeniedHandler {

    private final ObjectMapper objectMapper;

    @Override
    public void handle(HttpServletRequest request, HttpServletResponse response, AccessDeniedException accessDeniedException) throws IOException {
        log.error("NO Authorities", accessDeniedException);
        log.error("Request Uri : {}", request.getRequestURI());

        String responseContent = objectMapper.writeValueAsString(BaseResponse.ofFail(403, ResponseMessage.FORBIDDEN, null));

        response.setContentType(MediaType.APPLICATION_JSON_VALUE);
        response.setCharacterEncoding("UTF-8");
        response.getWriter().write(responseContent);
    }

}
