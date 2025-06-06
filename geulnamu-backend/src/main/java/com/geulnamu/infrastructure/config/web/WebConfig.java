package com.geulnamu.infrastructure.config.web;

import com.geulnamu.infrastructure.config.security.AuthTokenResolver;
import lombok.RequiredArgsConstructor;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.method.support.HandlerMethodArgumentResolver;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurationSupport;

import java.util.List;

@Configuration
@RequiredArgsConstructor
public class WebConfig extends WebMvcConfigurationSupport {

    private final AuthTokenResolver authTokenResolver;

    @Override
    public void addArgumentResolvers(final List<HandlerMethodArgumentResolver> argumentResolvers) {
        argumentResolvers.add(authTokenResolver);
    }

}
