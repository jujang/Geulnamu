package com.geulnamu.controller.shared;

import com.geulnamu.infrastructure.jwt.JwtAccessDeniedHandler;
import com.geulnamu.infrastructure.jwt.JwtAuthenticationEntryPoint;
import com.geulnamu.infrastructure.security.SecurityConfig;
import com.geulnamu.infrastructure.util.JwtTokenUtil;
import org.springframework.context.annotation.Import;
import org.springframework.test.context.bean.override.mockito.MockitoBean;

@Import(SecurityConfig.class)
public class ControllerTest {

    @MockitoBean
    private JwtTokenUtil jwtTokenUtil;
    @MockitoBean
    private JwtAuthenticationEntryPoint jwtAuthenticationEntryPoint;
    @MockitoBean
    private JwtAccessDeniedHandler jwtAccessDeniedHandler;

}
