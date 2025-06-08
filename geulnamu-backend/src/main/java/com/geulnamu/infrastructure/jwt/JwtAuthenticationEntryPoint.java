package com.geulnamu.infrastructure.jwt;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.geulnamu.infrastructure.response.BaseResponse;
import com.geulnamu.infrastructure.response.ResponseMessage;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.MediaType;
import org.springframework.security.core.AuthenticationException;
import org.springframework.security.web.AuthenticationEntryPoint;
import org.springframework.stereotype.Component;

import java.io.IOException;

@Slf4j
@Component
@RequiredArgsConstructor
public class JwtAuthenticationEntryPoint implements AuthenticationEntryPoint {

    private final ObjectMapper objectMapper;

    @Override
    public void commence(HttpServletRequest request,
                         HttpServletResponse response,
                         AuthenticationException authException) throws IOException {
        log.error("Not Authenticated Request", authException);
        log.error("Request Uri: {}", request.getRequestURI());

        String errorType = (String) request.getAttribute("TOKEN_ERROR_TYPE");
        String errorMessage = errorType.equals("INVALID") ? ResponseMessage.ACCESS_TOKEN_NOT_VALIDATE : ResponseMessage.NOT_FOUND_ACCESS_TOKEN;
        String responseContent = objectMapper.writeValueAsString(BaseResponse.ofFail(401, errorMessage, null));

        response.setContentType(MediaType.APPLICATION_JSON_VALUE);
        response.setContentType("UTF-8");
        response.getWriter().write(responseContent);
    }

}
