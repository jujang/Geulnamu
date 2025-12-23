package com.geulnamu.infrastructure.jwt;

import com.geulnamu.infrastructure.security.token.TokenInfo;
import com.geulnamu.infrastructure.security.token.TokenType;
import com.geulnamu.infrastructure.util.JwtTokenUtil;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpHeaders;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.util.StringUtils;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;

@Slf4j
@RequiredArgsConstructor
public class JwtFilter extends OncePerRequestFilter {

    private final JwtTokenUtil jwtTokenUtil;

    /**
     * 공개 API는 JWT 필터를 거치지 않음
     */
    @Override
    protected boolean shouldNotFilter(HttpServletRequest request) {
        String path = request.getRequestURI();
        
        // 공개 경로 체크
        return path.equals("/actuator/health") ||
               path.startsWith("/login/oauth/kakao") ||
               path.matches("/login/\\d+/direct") ||  // /login/{memberId}/direct
               path.equals("/login/re-issue/accessToken") ||
               path.equals("/members/register") ||
               path.equals("/hello/health-check") ||
               path.startsWith("/docs/") ||
               path.equals("/favicon.ico") ||
               path.equals("/error");
    }

    @Override
    protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response, FilterChain filterChain) throws IOException, ServletException {
        String jwt = resolveAccessToken(request);
        String requestURI = request.getRequestURI();

        if(StringUtils.hasText(jwt)) {
            if(jwtTokenUtil.validateToken(jwt, TokenType.AccessToken)) {
                log.info("값이 유효한 액세스 토큰이 들어왔습니다.");
                Authentication authentication = jwtTokenUtil.getAuthentication(jwt, TokenType.AccessToken);
                SecurityContextHolder.getContext().setAuthentication(authentication);
                log.info("Security Context에 '{}' 인증 정보를 저장했습니다, uri: {}", authentication.getName(), requestURI);
            } else {
                request.setAttribute("TOKEN_ERROR_TYPE", "INVALID"); // 해당 속성은 에러 응답을 할 경우에만 쓰임
            }
        } else {
            log.info("Bearer가 붙은 액세스 토큰이 전달되지 않았습니다.");
            request.setAttribute("TOKEN_ERROR_TYPE", "MISSING"); // 해당 속성은 에러 응답을 할 경우에만 쓰임
        }

        filterChain.doFilter(request, response);
    }

    private String resolveAccessToken(HttpServletRequest request) {
        String bearerToken = request.getHeader(HttpHeaders.AUTHORIZATION);

        if(StringUtils.hasText(bearerToken) && bearerToken.startsWith(TokenInfo.TOKEN_PREFIX)) {
            return bearerToken.replace(TokenInfo.TOKEN_PREFIX, "");
        }

        return null;
    }

}
