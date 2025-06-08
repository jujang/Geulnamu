package com.geulnamu.infrastructure.config.web;

import com.geulnamu.infrastructure.config.security.AuthTokenResolver;
import com.geulnamu.infrastructure.config.security.MemberIdResolver;
import lombok.RequiredArgsConstructor;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.method.support.HandlerMethodArgumentResolver;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurationSupport;

import java.util.List;

@Configuration
@RequiredArgsConstructor
public class WebConfig extends WebMvcConfigurationSupport {

    private final AuthTokenResolver authTokenResolver;
    private final MemberIdResolver memberIdResolver;

    @Override
    public void addArgumentResolvers(final List<HandlerMethodArgumentResolver> argumentResolvers) {
        argumentResolvers.add(authTokenResolver);
        argumentResolvers.add(memberIdResolver);
    }

}
