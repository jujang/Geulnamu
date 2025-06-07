package com.geulnamu.infrastructure.config.security;

import com.geulnamu.infrastructure.security.token.TokenInfo;
import com.geulnamu.infrastructure.security.token.TokenType;
import com.geulnamu.infrastructure.response.ResponseMessage;
import com.geulnamu.infrastructure.annotation.AuthMemberId;
import com.geulnamu.infrastructure.exception.TokenException;
import com.geulnamu.infrastructure.util.JwtTokenUtil;
import io.micrometer.common.util.StringUtils;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.core.MethodParameter;
import org.springframework.http.HttpHeaders;
import org.springframework.stereotype.Component;
import org.springframework.web.bind.support.WebDataBinderFactory;
import org.springframework.web.context.request.NativeWebRequest;
import org.springframework.web.method.support.HandlerMethodArgumentResolver;
import org.springframework.web.method.support.ModelAndViewContainer;

@Slf4j
@Component
@RequiredArgsConstructor
public class MemberIdResolver implements HandlerMethodArgumentResolver {

    private final JwtTokenUtil jwtTokenUtil;

    @Override
    public boolean supportsParameter(MethodParameter parameter) {
        return parameter.hasParameterAnnotation(AuthMemberId.class) &&
            parameter.getParameterType().equals(Long.class);
    }

    @Override
    public Object resolveArgument(MethodParameter parameter,
                                  ModelAndViewContainer modelAndViewContainer,
                                  NativeWebRequest nativeWebRequest,
                                  WebDataBinderFactory webDataBinderFactory
    ) {
        String authHeader = nativeWebRequest.getHeader(HttpHeaders.AUTHORIZATION);
        if(StringUtils.isBlank(authHeader)) {
            throw new TokenException(ResponseMessage.NOT_FOUND_ACCESS_TOKEN);
        } else if(!authHeader.startsWith(TokenInfo.TOKEN_PREFIX)) {
            log.error("액세스 토큰에 bearer가 들어있지 않습니다.");
            throw new TokenException(ResponseMessage.ACCESS_TOKEN_NOT_VALIDATE);
        }

        String accessToken = authHeader.substring(TokenInfo.TOKEN_PREFIX.length());

        try {
            return jwtTokenUtil.getMemberId(accessToken, TokenType.AccessToken);
        } catch (Exception e) {
            throw new TokenException(ResponseMessage.ACCESS_TOKEN_NOT_VALIDATE);
        }
    }

}
