package com.geulnamu.infrastructure.jwt;

import com.geulnamu.domain.shared.TokenInfo;
import com.geulnamu.domain.shared.enums.TokenType;
import com.geulnamu.infrastructure.util.JwtTokenUtil;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.ServletRequest;
import jakarta.servlet.ServletResponse;
import jakarta.servlet.http.HttpServletRequest;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpHeaders;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.util.StringUtils;
import org.springframework.web.filter.GenericFilterBean;

import java.io.IOException;

@Slf4j
@RequiredArgsConstructor
public class JwtFilter extends GenericFilterBean {

    private final JwtTokenUtil jwtTokenUtil;

    @Override
    public void doFilter(ServletRequest servletRequest, ServletResponse servletResponse, FilterChain filterChain) throws IOException, ServletException {
        HttpServletRequest httpServletRequest = (HttpServletRequest) servletRequest;
        String jwt = resolveAccessToken(httpServletRequest);
        String requestURI = httpServletRequest.getRequestURI();

        if(StringUtils.hasText(jwt)) {
            if(jwtTokenUtil.validateToken(jwt, TokenType.AccessToken)) {
                log.info("값이 유효한 엑세스 토큰이 들어왔습니다.");
                Authentication authentication = jwtTokenUtil.getAuthentication(jwt, TokenType.AccessToken);
                SecurityContextHolder.getContext().setAuthentication(authentication);
                log.info("Security Context에 '{}' 인증 정보를 저장했습니다, uri: {}", authentication.getName(), requestURI);
            } else {
                servletRequest.setAttribute("TOKEN_ERROR_TYPE", "INVALID"); // 해당 속성은 에러 응답을 할 경우에만 쓰임
            }
        } else {
            log.info("Bearer가 붙은 엑세스 토큰이 전달되지 않았습니다.");
            servletRequest.setAttribute("TOKEN_ERROR_TYPE", "MISSING"); // 해당 속성은 에러 응답을 할 경우에만 쓰임
        }

        filterChain.doFilter(servletRequest, servletResponse);
    }

    private String resolveAccessToken(HttpServletRequest request) {
        String bearerToken = request.getHeader(HttpHeaders.AUTHORIZATION);

        if(StringUtils.hasText(bearerToken) && bearerToken.startsWith(TokenInfo.TOKEN_PREFIX)) {
            return bearerToken.replace(TokenInfo.TOKEN_PREFIX, "");
        }

        return null;
    }

}
